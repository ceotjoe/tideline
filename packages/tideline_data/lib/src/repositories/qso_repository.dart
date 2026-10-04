import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_data/src/repositories/qso_row_mapping.dart';
import 'package:tideline_data/src/repositories/sync_journal_repository.dart';
import 'package:tideline_data/src/repositories/worked_before_repository.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A QSO with its sync status (null when it needs no sync anymore).
@immutable
class LoggedQso {
  /// Creates the pair.
  const new(this.qso, this.status);

  /// The QSO.
  final Qso qso;

  /// Its sync status for its account.
  final SyncStatus? status;
}

/// Writes and reads QSOs. Every write is one local transaction that also
/// updates the sync status (via [SyncMachine]) and the journal, so logging
/// never waits for the network and never loses track of a QSO.
class QsoRepository {
  /// Creates the repository.
  new(this._db, this._clock, this._machine, {int Function()? nowMillis})
    : _now = nowMillis ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch),
      _journal = SyncJournalRepository(_db),
      _workedBefore = WorkedBeforeRepository(_db);

  final TidelineDatabase _db;
  final HlcClock _clock;
  final SyncMachine _machine;
  final int Function() _now;
  final SyncJournalRepository _journal;
  final WorkedBeforeRepository _workedBefore;

  /// Logs a new QSO.
  Future<void> log(Qso qso) => _insert(qso, JournalEvent.logged);

  /// Logs several new QSOs in **one** transaction: all or none (Fast Log
  /// Entry). Returns how many were added.
  Future<int> logAll(List<Qso> qsos) => _db.transaction(() async {
    for (final q in qsos) {
      await _insert(q, JournalEvent.logged);
    }
    return qsos.length;
  });

  /// Imports QSOs in one transaction. Returns how many were added.
  Future<int> importAll(List<Qso> qsos) => _db.transaction(() async {
    for (final q in qsos) {
      await _insert(q, JournalEvent.imported);
    }
    return qsos.length;
  });

  /// Inserts [qso] with its sync row and journal entry in one transaction
  /// (joining an enclosing one). Shared with the contest logging service so
  /// that a contest QSO is stored exactly like any other.
  @internal
  Future<void> insertQso(Qso qso, JournalEvent event) => _insert(qso, event);

  Future<void> _insert(Qso qso, JournalEvent event) =>
      _db.transaction(() async {
        final hlc = _clock.now().toString();
        await _db
            .into(_db.qsos)
            .insert(
              qsoToCompanion(qso).copyWith(
                originDeviceId: Value(_clock.deviceId),
                hlcCreated: Value(hlc),
                hlcModified: Value(hlc),
                rev: const Value(1),
              ),
            );
        await _workedBefore.noteQso(qso);
        final status = SyncMachine.initial(
          complete: qso.stationProfileId != null,
        );
        await writeStatus(qso.id, qso.accountId, status);
        await _journal.append(
          accountId: qso.accountId,
          qsoId: qso.id,
          event: event,
          at: _now(),
          detail: {'call': qso.call.value, 'state': status.state.name},
        );
      });

  /// Restores a QSO from a backup with its sync [status]. Returns false if
  /// a QSO with the same id already exists (it is kept unchanged).
  Future<bool> restore(Qso qso, SyncStatus? status) =>
      _db.transaction(() async {
        if (await find(qso.id) != null) return false;
        final hlc = _clock.now().toString();
        await _db
            .into(_db.qsos)
            .insert(
              qsoToCompanion(qso).copyWith(
                originDeviceId: Value(_clock.deviceId),
                hlcCreated: Value(hlc),
                hlcModified: Value(hlc),
              ),
            );
        await _workedBefore.noteQso(qso);
        // An upload in flight when the backup was made may or may not have
        // reached the server: verify it first (ADR 0008).
        final restored = status?.state == SyncState.uploading
            ? SyncStatus(
                state: SyncState.verifying,
                remoteQsoId: status!.remoteQsoId,
              )
            : status;
        if (restored != null) {
          await writeStatus(qso.id, qso.accountId, restored);
        }
        await _journal.append(
          accountId: qso.accountId,
          qsoId: qso.id,
          event: JournalEvent.imported,
          at: _now(),
          detail: {'call': qso.call.value, 'from': 'backup'},
        );
        return true;
      });

  /// Every non-deleted QSO of every account, with status (for backups).
  Future<List<LoggedQso>> all() async {
    final rows = await (_db.select(
      _db.qsos,
    )..where((q) => q.deletedAt.isNull())).get();
    return [
      for (final r in rows)
        LoggedQso(qsoFromRow(r), await readStatus(r.id, r.accountId)),
    ];
  }

  /// Saves an edited QSO.
  Future<void> update(Qso edited) => _db.transaction(() async {
    var qso = edited;
    final before = await find(qso.id);
    if (before == null) throw StateError('QSO ${qso.id} not found');
    final changesReadOnly = Qso.changesServerReadOnlyFields(before.qso, qso);
    final row = await _row(qso.id);
    // A contest QSO keeps the serial it was allocated, whatever the edit says.
    final allocation =
        await (_db.select(_db.serialAllocations)..where(
              (a) =>
                  a.qsoId.equals(qso.id) &
                  a.sessionId.equals(row.contestSessionId ?? ''),
            ))
            .getSingleOrNull();
    if (allocation != null && qso.field('STX') != '${allocation.serial}') {
      qso = qso.copyWith(
        fields: {...qso.fields, 'STX': '${allocation.serial}'},
      );
    }
    await (_db.update(_db.qsos)..where((q) => q.id.equals(qso.id))).write(
      qsoToCompanion(qso).copyWith(
        hlcModified: Value(_clock.now().toString()),
        rev: Value(row.rev + 1),
      ),
    );
    await _workedBefore.noteQso(qso);
    var status = before.status;
    if (status == null) return;
    if (status.state == SyncState.local && qso.stationProfileId != null) {
      status = _machine.apply(status, const QsoCompleted(), _now())!;
    }
    final next = _machine.apply(
      status,
      LocalEdit(changesReadOnlyFields: changesReadOnly),
      _now(),
    );
    if (next != null) await writeStatus(qso.id, qso.accountId, next);
    if (next?.state != before.status?.state ||
        next?.operation == SyncOperation.patch) {
      await _journal.append(
        accountId: qso.accountId,
        qsoId: qso.id,
        event: next?.state == SyncState.conflict
            ? JournalEvent.conflict
            : JournalEvent.editQueued,
        at: _now(),
        detail: {'state': next?.state.name, 'problem': next?.problem?.name},
      );
    }
  });

  /// Deletes a QSO locally (soft delete) and, if it reached the server and
  /// [canDeleteOnServer], queues the server delete.
  Future<void> delete(String id, {required bool canDeleteOnServer}) =>
      _db.transaction(() async {
        final current = await find(id);
        if (current == null) return;
        final row = await _row(id);
        await (_db.update(_db.qsos)..where((q) => q.id.equals(id))).write(
          QsosCompanion(
            deletedAt: Value(_now()),
            hlcModified: Value(_clock.now().toString()),
            rev: Value(row.rev + 1),
          ),
        );
        // The serial stays allocated; it is never handed out again.
        await (_db.update(_db.serialAllocations)
              ..where((a) => a.qsoId.equals(id)))
            .write(const SerialAllocationsCompanion(qsoId: Value(null)));
        final status = current.status;
        if (status == null) return;
        final next = _machine.apply(
          status,
          LocalDelete(canDeleteOnServer: canDeleteOnServer),
          _now(),
        );
        final accountId = current.qso.accountId;
        if (next == null) {
          await _deleteStatus(id, accountId);
          if (status.remoteQsoId != null) {
            await _journal.append(
              accountId: accountId,
              qsoId: id,
              event: JournalEvent.deletedLocallyOnly,
              at: _now(),
              detail: {'remoteId': status.remoteQsoId},
            );
          }
        } else {
          await writeStatus(id, accountId, next);
        }
      });

  /// The user's decision on a conflict (ADR 0016).
  Future<void> resolveConflict(String id, {required bool replaceOnServer}) =>
      _db.transaction(() async {
        final current = await find(id);
        final status = current?.status;
        if (current == null || status == null) return;
        final next = _machine.apply(
          status,
          ConflictResolved(replaceOnServer: replaceOnServer),
          _now(),
        )!;
        await writeStatus(id, current.qso.accountId, next);
        await _journal.append(
          accountId: current.qso.accountId,
          qsoId: id,
          event: JournalEvent.conflictResolved,
          at: _now(),
          detail: {'replaceOnServer': replaceOnServer},
        );
      });

  /// One QSO (including soft-deleted ones) with its status.
  Future<LoggedQso?> find(String id) async {
    final row = await (_db.select(
      _db.qsos,
    )..where((q) => q.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return LoggedQso(qsoFromRow(row), await readStatus(id, row.accountId));
  }

  /// The log of [accountId], newest first, without deleted QSOs.
  Stream<List<LoggedQso>> watchLog(String accountId, {int limit = 500}) {
    final query =
        _db.select(_db.qsos).join([
            leftOuterJoin(
              _db.qsoSync,
              _db.qsoSync.qsoId.equalsExp(_db.qsos.id) &
                  _db.qsoSync.accountId.equalsExp(_db.qsos.accountId),
            ),
          ])
          ..where(
            _db.qsos.accountId.equals(accountId) & _db.qsos.deletedAt.isNull(),
          )
          ..orderBy([OrderingTerm.desc(_db.qsos.timeOn)])
          ..limit(limit);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          LoggedQso(
            qsoFromRow(r.readTable(_db.qsos)),
            _statusFromRow(r.readTableOrNull(_db.qsoSync)),
          ),
      ],
    );
  }

  /// Number of QSOs per sync state for [accountId] (deleted ones excluded
  /// unless a server delete is pending).
  Stream<Map<SyncState, int>> watchCounts(String accountId) {
    final count = _db.qsoSync.qsoId.count();
    final query = _db.selectOnly(_db.qsoSync)
      ..addColumns([_db.qsoSync.state, count])
      ..where(_db.qsoSync.accountId.equals(accountId))
      ..groupBy([_db.qsoSync.state]);
    return query.watch().map(
      (rows) => {
        for (final r in rows)
          SyncState.values.byName(r.read(_db.qsoSync.state)!):
              r.read(count) ?? 0,
      },
    );
  }

  /// QSOs waiting for their first upload (create), oldest first.
  Future<List<LoggedQso>> pendingCreates(String accountId) async {
    final rows =
        await (_db.select(_db.qsoSync)..where(
              (s) =>
                  s.accountId.equals(accountId) &
                  s.state.equals(SyncState.queued.name) &
                  s.operation.equals(SyncOperation.create.name),
            ))
            .get();
    final out = <LoggedQso>[];
    for (final r in rows) {
      final qso = await (_db.select(
        _db.qsos,
      )..where((q) => q.id.equals(r.qsoId))).getSingle();
      out.add(LoggedQso(qsoFromRow(qso), _statusFromRow(r)));
    }
    out.sort((a, b) => a.qso.timeOn.compareTo(b.qso.timeOn));
    return out;
  }

  /// The duplicate keys (call, minute, band, mode, station) of the live QSOs
  /// of [accountId] that started between [fromMillis] and [toMillis]
  /// (inclusive): what a batch of new QSOs is compared with.
  Future<Set<(String, int, String, String, String?)>> dupeKeysBetween(
    String accountId,
    int fromMillis,
    int toMillis,
  ) async {
    final rows =
        await (_db.select(_db.qsos)..where(
              (q) =>
                  q.accountId.equals(accountId) &
                  q.deletedAt.isNull() &
                  q.timeOn.isBetweenValues(fromMillis, toMillis),
            ))
            .get();
    final keys = <(String, int, String, String, String?)>{};
    for (final r in rows) {
      final k = qsoFromRow(r).dupeKey;
      keys.add((k.call, k.minuteMillis, k.band, k.mode, r.stationProfileId));
    }
    return keys;
  }

  /// Synced QSOs of [accountId] whose duplicate key matches one of [keys].
  Future<int> countSyncedMatching(
    String accountId,
    Set<(String, int, String, String, String?)> keys,
  ) async {
    if (keys.isEmpty) return 0;
    final rows =
        await (_db.select(_db.qsos).join([
              innerJoin(
                _db.qsoSync,
                _db.qsoSync.qsoId.equalsExp(_db.qsos.id) &
                    _db.qsoSync.state.equals(SyncState.synced.name),
              ),
            ])..where(
              _db.qsos.accountId.equals(accountId) &
                  _db.qsos.deletedAt.isNull(),
            ))
            .get();
    var n = 0;
    for (final r in rows) {
      final q = qsoFromRow(r.readTable(_db.qsos));
      final k = q.dupeKey;
      if (keys.contains((
        k.call,
        k.minuteMillis,
        k.band,
        k.mode,
        q.stationProfileId,
      ))) {
        n++;
      }
    }
    return n;
  }

  /// QSOs of [accountId] the engine may work on now, oldest first.
  Future<List<LoggedQso>> due(String accountId, int nowMillis) async {
    final rows =
        await (_db.select(_db.qsoSync)..where(
              (s) =>
                  s.accountId.equals(accountId) &
                  s.state.isIn([
                    SyncState.queued.name,
                    SyncState.verifying.name,
                  ]),
            ))
            .get();
    final out = <LoggedQso>[];
    for (final r in rows) {
      final status = _statusFromRow(r)!;
      if (!status.isDue(nowMillis)) continue;
      final qso = await (_db.select(
        _db.qsos,
      )..where((q) => q.id.equals(r.qsoId))).getSingle();
      out.add(LoggedQso(qsoFromRow(qso), status));
    }
    out.sort((a, b) => a.qso.timeOn.compareTo(b.qso.timeOn));
    return out;
  }

  /// All sync rows of [accountId] (engine use: restart recovery, blocking).
  Future<List<(String, SyncStatus)>> statuses(String accountId) async {
    final rows = await (_db.select(
      _db.qsoSync,
    )..where((s) => s.accountId.equals(accountId))).get();
    return [for (final r in rows) (r.qsoId, _statusFromRow(r)!)];
  }

  /// Local QSO id that already owns [remoteQsoId], if any.
  Future<String?> ownerOfRemote(String accountId, int remoteQsoId) async {
    final row =
        await (_db.select(_db.qsoSync)..where(
              (s) =>
                  s.accountId.equals(accountId) &
                  s.remoteQsoId.equals(remoteQsoId),
            ))
            .getSingleOrNull();
    return row?.qsoId;
  }

  /// Persists [status] (engine and repository use).
  Future<void> writeStatus(String qsoId, String accountId, SyncStatus status) =>
      _db
          .into(_db.qsoSync)
          .insertOnConflictUpdate(
            QsoSyncCompanion.insert(
              qsoId: qsoId,
              accountId: accountId,
              state: status.state.name,
              operation: Value(status.operation.name),
              remoteQsoId: Value(status.remoteQsoId),
              attempts: Value(status.attempts),
              nextAttemptAt: Value(status.nextAttemptAt),
              lastErrorCode: Value(status.problem?.name),
              serverMessage: Value(status.serverMessage),
            ),
          );

  /// Reads the status of [qsoId] for [accountId].
  Future<SyncStatus?> readStatus(String qsoId, String accountId) async {
    final row =
        await (_db.select(_db.qsoSync)..where(
              (s) => s.qsoId.equals(qsoId) & s.accountId.equals(accountId),
            ))
            .getSingleOrNull();
    return _statusFromRow(row);
  }

  Future<void> _deleteStatus(String qsoId, String accountId) => (_db.delete(
    _db.qsoSync,
  )..where((s) => s.qsoId.equals(qsoId) & s.accountId.equals(accountId))).go();

  /// Removes the sync row after the engine finished a server delete.
  Future<void> clearStatus(String qsoId, String accountId) =>
      _deleteStatus(qsoId, accountId);

  Future<QsoRow> _row(String id) =>
      (_db.select(_db.qsos)..where((q) => q.id.equals(id))).getSingle();

  SyncStatus? _statusFromRow(QsoSyncRow? r) {
    if (r == null) return null;
    return SyncStatus(
      state: SyncState.values.byName(r.state),
      operation: SyncOperation.values.byName(r.operation),
      remoteQsoId: r.remoteQsoId,
      attempts: r.attempts,
      nextAttemptAt: r.nextAttemptAt,
      problem: r.lastErrorCode == null
          ? null
          : SyncProblem.values.asNameMap()[r.lastErrorCode],
      serverMessage: r.serverMessage,
    );
  }
}
