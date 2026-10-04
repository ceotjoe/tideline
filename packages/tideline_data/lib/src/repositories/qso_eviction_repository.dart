import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_data/src/repositories/qso_repository.dart';
import 'package:tideline_data/src/repositories/qso_row_mapping.dart';
import 'package:tideline_data/src/repositories/sync_journal_repository.dart';
import 'package:tideline_data/src/repositories/worked_before_repository.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Why a QSO is not offered for removal from this device.
enum EvictionBlock {
  /// Not on Wavelog yet (or not known to be): the local copy is the only one.
  notSynced,

  /// On Wavelog, but changed here since (an edit waiting to be sent, a
  /// conflict), so the server's copy is not what is stored here.
  changedSinceSync,

  /// Part of a contest session: contest mode, Cabrillo and its dupe check
  /// need it.
  inContest,

  /// Part of an activation: its ADIF export needs it.
  inActivation,
}

/// QSOs that may be removed from this device, and how many in the same scope
/// may not.
@immutable
class EvictionCandidates {
  /// Creates the result.
  const new({required this.eligible, required this.blocked});

  /// QSOs on Wavelog, unchanged since, and not in a contest or activation.
  final List<LoggedQso> eligible;

  /// Counts of the QSOs in the scope that stay, by reason.
  final Map<EvictionBlock, int> blocked;

  /// Total of [blocked].
  int get blockedCount => blocked.values.fold(0, (a, b) => a + b);
}

/// Removing the local copy of QSOs that Wavelog already has, to free space on
/// the device (ADR 0027).
///
/// This is **not a delete**: nothing is queued for the server, the QSO stays
/// in Wavelog, and a record of what was removed is kept. Only a QSO that is
/// synced, unchanged since the sync and outside contests and activations is
/// ever removed. Whether the server really has it is checked by
/// `QsoEvictionService` before this runs; this class re-checks the local
/// conditions inside the transaction.
class QsoEvictionRepository {
  /// Creates the repository.
  new(this._db, this._journal, {int Function()? nowMillis})
    : _workedBefore = WorkedBeforeRepository(_db),
      _now = nowMillis ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  final TidelineDatabase _db;
  final SyncJournalRepository _journal;
  final WorkedBeforeRepository _workedBefore;
  final int Function() _now;

  /// Which block keeps a QSO, or null if it may be removed.
  ///
  /// The state machine moves a synced QSO out of `synced` on every local
  /// edit (to a queued patch, or a conflict), so `synced` means: what is
  /// stored here is what the server last accepted.
  EvictionBlock? _blockOf(QsoRow q, QsoSyncRow? s) {
    if (s == null || s.remoteQsoId == null) return EvictionBlock.notSynced;
    if (s.state != SyncState.synced.name) {
      // On the server once, but waiting for an edit, in conflict, or refused.
      return EvictionBlock.changedSinceSync;
    }
    if (q.contestSessionId != null) return EvictionBlock.inContest;
    if (q.activationId != null) return EvictionBlock.inActivation;
    return null;
  }

  /// The QSOs of [accountId] in a scope, split into those that may be removed
  /// and counts of those that may not. The scope is the QSOs older than
  /// [olderThanMillis] (QSO start, UTC millis) and/or with an id in [ids];
  /// with neither, every QSO of the account. Deleted QSOs are not in scope.
  Future<EvictionCandidates> candidates(
    String accountId, {
    int? olderThanMillis,
    Set<String>? ids,
  }) async {
    final query =
        _db.select(_db.qsos).join([
          leftOuterJoin(
            _db.qsoSync,
            _db.qsoSync.qsoId.equalsExp(_db.qsos.id) &
                _db.qsoSync.accountId.equalsExp(_db.qsos.accountId),
          ),
        ])..where(
          _db.qsos.accountId.equals(accountId) & _db.qsos.deletedAt.isNull(),
        );
    if (olderThanMillis != null) {
      query.where(_db.qsos.timeOn.isSmallerThanValue(olderThanMillis));
    }
    if (ids != null) query.where(_db.qsos.id.isIn(ids));
    query.orderBy([OrderingTerm.asc(_db.qsos.timeOn)]);

    final eligible = <LoggedQso>[];
    final blocked = <EvictionBlock, int>{};
    for (final r in await query.get()) {
      final row = r.readTable(_db.qsos);
      final sync = r.readTableOrNull(_db.qsoSync);
      final block = _blockOf(row, sync);
      if (block != null) {
        blocked[block] = (blocked[block] ?? 0) + 1;
        continue;
      }
      eligible.add(LoggedQso(qsoFromRow(row), _status(sync!)));
    }
    return EvictionCandidates(eligible: eligible, blocked: blocked);
  }

  SyncStatus _status(QsoSyncRow r) => SyncStatus(
    state: SyncState.values.byName(r.state),
    operation: SyncOperation.values.byName(r.operation),
    remoteQsoId: r.remoteQsoId,
  );

  /// The Wavelog station id of each local station profile of [accountId].
  Future<Map<String, int>> stationRemoteIds(String accountId) async {
    final rows = await (_db.select(
      _db.stationProfiles,
    )..where((s) => s.accountId.equals(accountId))).get();
    return {for (final s in rows) s.id: s.remoteId};
  }

  /// Removes the local copy of the QSOs in [qsoIds] that are still eligible
  /// (re-checked here, in the transaction). Returns how many were removed.
  ///
  /// What the history learned from them (worked-before index, callsign
  /// directory) is kept and marked as coming from the server, so a rebuild
  /// from the log cannot lose it.
  Future<int> evict(String accountId, Iterable<String> qsoIds) {
    final wanted = qsoIds.toSet();
    if (wanted.isEmpty) return Future.value(0);
    return _db.transaction(() async {
      final now = _now();
      var removed = 0;
      // In chunks: SQLite limits the number of variables of one statement.
      for (final chunk in _chunks(wanted.toList(), 500)) {
        final current = await candidates(accountId, ids: chunk.toSet());
        for (final item in current.eligible) {
          final q = item.qso;
          await _workedBefore.noteQso(q);
          await _db.customStatement(
            "UPDATE worked_before SET source = 'server' "
            'WHERE account_id = ? AND call = ? AND band = ? AND mode = ?',
            [accountId, q.call.value.toUpperCase(), q.band.name, q.mode.mode],
          );
          await (_db.delete(_db.qsoSync)..where(
                (s) => s.qsoId.equals(q.id) & s.accountId.equals(accountId),
              ))
              .go();
          await (_db.delete(_db.qsos)..where((x) => x.id.equals(q.id))).go();
          await _db
              .into(_db.evictedQsos)
              .insert(
                EvictedQsosCompanion.insert(
                  qsoId: q.id,
                  accountId: accountId,
                  remoteQsoId: item.status!.remoteQsoId!,
                  evictedAt: now,
                ),
                mode: InsertMode.insertOrReplace,
              );
          removed++;
        }
      }
      if (removed > 0) {
        _db.markTablesUpdated([_db.workedBefore]);
        await _journal.append(
          accountId: accountId,
          event: JournalEvent.evictedLocally,
          at: now,
          detail: {'count': removed},
        );
      }
      return removed;
    });
  }

  Iterable<List<T>> _chunks<T>(List<T> list, int size) sync* {
    for (var i = 0; i < list.length; i += size) {
      yield list.sublist(i, i + size > list.length ? list.length : i + size);
    }
  }

  /// How many QSOs of [accountId] were removed from this device so far.
  Stream<int> watchEvictedCount(String accountId) {
    final n = _db.evictedQsos.qsoId.count();
    return (_db.selectOnly(_db.evictedQsos)
          ..addColumns([n])
          ..where(_db.evictedQsos.accountId.equals(accountId)))
        .watchSingle()
        .map((row) => row.read(n) ?? 0);
  }
}
