import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_data/src/repositories/contest_definition_repository.dart';
import 'package:tideline_data/src/repositories/qso_repository.dart';
import 'package:tideline_data/src/repositories/qso_row_mapping.dart';
import 'package:tideline_data/src/repositories/sync_journal_repository.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Whether and how a contest session exists on Wavelog (3.2+).
enum ContestRemoteState {
  /// Never synced: the server is too old, the contest is not active on it,
  /// or the user turned it off.
  local,

  /// To be created on Wavelog.
  pending,

  /// A create request was in flight; reconcile before retrying (ADR 0008).
  verifying,

  /// Exists on Wavelog (see [ContestSession.remoteSessionId]).
  created,
}

/// A contest operating session.
@immutable
class ContestSession {
  /// Creates a session view.
  const new({
    required this.id,
    required this.definitionId,
    required this.definitionVersion,
    required this.accountId,
    required this.startedAt,
    required this.ownExchange,
    required this.cabrillo,
    required this.usesSerial,
    required this.remoteState,
    this.stationProfileId,
    this.endedAt,
    this.remoteSessionId,
    this.remoteEndSynced,
    this.remoteErrorKey,
  });

  /// Local UUID.
  final String id;

  /// The contest definition used.
  final String definitionId;

  /// The definition version the session started with.
  final int definitionVersion;

  /// Owning account.
  final String accountId;

  /// Station location, if chosen.
  final String? stationProfileId;

  /// Start (UTC millis).
  final int startedAt;

  /// End (UTC millis), or null while active.
  final int? endedAt;

  /// The values I send, by exchange element kind name (`cqZone` → `14`).
  /// A `serial` element is never stored here: serials are allocated.
  final Map<String, String> ownExchange;

  /// Cabrillo header values (`CATEGORY-OPERATOR` → `SINGLE-OP`, …).
  final Map<String, String> cabrillo;

  /// Whether my sent exchange contains a serial number.
  final bool usesSerial;

  /// Sync state of the session itself.
  final ContestRemoteState remoteState;

  /// Wavelog's session id, once created.
  final int? remoteSessionId;

  /// End time last sent to Wavelog (UTC millis).
  final int? remoteEndSynced;

  /// Localisation key of the last error.
  final String? remoteErrorKey;

  /// Whether the session has not been ended.
  bool get isActive => endedAt == null;
}

/// The result of logging a contest QSO.
typedef ContestLogResult = ({Qso qso, int? serial});

/// Contest sessions, and the atomic logging of their QSOs.
class ContestSessionRepository {
  /// Creates the repository. The QSO repository does the actual insert.
  new(this._db, this._clock, this._qsos, {int Function()? nowMillis})
    : _now = nowMillis ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch),
      _definitions = ContestDefinitionRepository(_db);

  final TidelineDatabase _db;
  final HlcClock _clock;
  final QsoRepository _qsos;
  final int Function() _now;
  final ContestDefinitionRepository _definitions;

  /// Starts a session of the stored definition [definitionId].
  ///
  /// [me] describes my station (used to pick the exchange variant).
  /// [accountSupportsSessions] is the account's `hasContestSessions`: only
  /// then, and only if the definition has an `adif` name, does the session
  /// start `pending` for Wavelog; otherwise it is `local`.
  /// Throws [ArgumentError] for an unknown definition.
  Future<ContestSession> start({
    required String accountId,
    required String definitionId,
    required ContestStation me,
    required bool accountSupportsSessions,
    String? stationProfileId,
    Map<String, String> ownExchange = const {},
    Map<String, String> cabrillo = const {},
    int? startedAt,
  }) => _db.transaction(() async {
    final def = await _definitions.find(definitionId);
    if (def == null) {
      throw ArgumentError.value(definitionId, 'definitionId', 'unknown');
    }
    final id = newUuidV4();
    final hlc = _clock.now().toString();
    final usesSerial = def
        .exchangeFor(me)
        .sent
        .any((e) => e.kind == ExchangeKind.serial);
    final remote = accountSupportsSessions && def.adif != null
        ? ContestRemoteState.pending
        : ContestRemoteState.local;
    await _db
        .into(_db.contestSessions)
        .insert(
          ContestSessionsCompanion.insert(
            id: id,
            definitionId: definitionId,
            accountId: accountId,
            stationProfileId: Value(stationProfileId),
            startedAt: startedAt ?? _now(),
            settings: Value(
              jsonEncode({
                'definitionVersion': def.version,
                'ownExchange': ownExchange,
                'cabrillo': cabrillo,
                'usesSerial': usesSerial,
              }),
            ),
            remoteState: Value(remote.name),
            originDeviceId: _clock.deviceId,
            hlcCreated: hlc,
            hlcModified: hlc,
          ),
        );
    return (await find(id))!;
  });

  /// Ends the session at [at] (UTC millis).
  Future<void> end(String id, int at) => _touch(id, endedAt: Value(at));

  /// Reopens an ended session.
  Future<void> reopen(String id) => _touch(id, endedAt: const Value(null));

  /// Soft-deletes the session. Its QSOs stay in the log.
  Future<void> delete(String id) => _touch(id, deletedAt: Value(_now()));

  /// Updates the Wavelog state (sync engine). Omitted values stay unchanged.
  Future<void> setRemote(
    String id, {
    ContestRemoteState? state,
    Value<int?> remoteSessionId = const Value.absent(),
    Value<int?> remoteEndSynced = const Value.absent(),
    Value<String?> errorKey = const Value.absent(),
  }) => _touch(
    id,
    remoteState: state == null ? const Value.absent() : Value(state.name),
    remoteSessionId: remoteSessionId,
    remoteEndSynced: remoteEndSynced,
    remoteErrorKey: errorKey,
  );

  Future<void> _touch(
    String id, {
    Value<int?> endedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    Value<String> remoteState = const Value.absent(),
    Value<int?> remoteSessionId = const Value.absent(),
    Value<int?> remoteEndSynced = const Value.absent(),
    Value<String?> remoteErrorKey = const Value.absent(),
  }) => _db.transaction(() async {
    final row = await _row(id);
    if (row == null) throw StateError('Contest session $id not found');
    await (_db.update(
      _db.contestSessions,
    )..where((s) => s.id.equals(id))).write(
      ContestSessionsCompanion(
        endedAt: endedAt,
        deletedAt: deletedAt,
        remoteState: remoteState,
        remoteSessionId: remoteSessionId,
        remoteEndSynced: remoteEndSynced,
        remoteErrorKey: remoteErrorKey,
        hlcModified: Value(_clock.now().toString()),
        rev: Value(row.rev + 1),
      ),
    );
  });

  /// One non-deleted session.
  Future<ContestSession?> find(String id) async {
    final row = await _row(id);
    return row == null || row.deletedAt != null ? null : _fromRow(row);
  }

  /// The running (not ended) session of [accountId], newest if several.
  Stream<ContestSession?> watchActive(String accountId) =>
      (_db.select(_db.contestSessions)
            ..where(
              (s) =>
                  s.accountId.equals(accountId) &
                  s.deletedAt.isNull() &
                  s.endedAt.isNull(),
            )
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
            ..limit(1))
          .watch()
          .map((rows) => rows.isEmpty ? null : _fromRow(rows.first));

  /// All non-deleted sessions of [accountId], newest first.
  Stream<List<ContestSession>> watchAll(String accountId) =>
      (_db.select(_db.contestSessions)
            ..where((s) => s.accountId.equals(accountId) & s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
          .watch()
          .map((rows) => [for (final r in rows) _fromRow(r)]);

  /// Sessions of [accountId] the sync engine has to act on: those still to
  /// create or verify, and created ones whose end time differs from the one
  /// last sent.
  Future<List<ContestSession>> needingRemoteSync(String accountId) async {
    final rows =
        await (_db.select(_db.contestSessions)..where(
              (s) => s.accountId.equals(accountId) & s.deletedAt.isNull(),
            ))
            .get();
    return [
      for (final r in rows)
        if (r.remoteState == ContestRemoteState.pending.name ||
            r.remoteState == ContestRemoteState.verifying.name ||
            (r.remoteState == ContestRemoteState.created.name &&
                r.endedAt != r.remoteEndSynced))
          _fromRow(r),
    ];
  }

  /// The live QSOs of a session, oldest first (for the contest screen).
  Stream<List<Qso>> watchSessionQsos(String sessionId) =>
      (_db.select(_db.qsos)
            ..where(
              (q) =>
                  q.contestSessionId.equals(sessionId) & q.deletedAt.isNull(),
            )
            ..orderBy([
              (q) => OrderingTerm.asc(q.timeOn),
              (q) => OrderingTerm.asc(q.hlcCreated),
            ]))
          .watch()
          .map((rows) => [for (final r in rows) qsoFromRow(r)]);

  // Atomic serials ---------------------------------------------------------

  /// The serial the next QSO of the session would get (for the form preview;
  /// the number is only taken by [logContestQso]).
  Future<int> peekNextSerial(String sessionId) => _nextSerial(sessionId);

  /// [peekNextSerial] as a stream, updated whenever a serial is allocated.
  Stream<int> watchNextSerial(String sessionId) {
    final max = _db.serialAllocations.serial.max();
    return (_db.selectOnly(_db.serialAllocations)
          ..addColumns([max])
          ..where(_db.serialAllocations.sessionId.equals(sessionId)))
        .watchSingle()
        .map((r) => (r.read(max) ?? 0) + 1);
  }

  Future<int> _nextSerial(String sessionId) async {
    final max = _db.serialAllocations.serial.max();
    final row =
        await (_db.selectOnly(_db.serialAllocations)
              ..addColumns([max])
              ..where(_db.serialAllocations.sessionId.equals(sessionId)))
            .getSingle();
    return (row.read(max) ?? 0) + 1;
  }

  /// Logs [qso] as part of the session, in ONE transaction:
  ///
  /// * takes the next serial (`max + 1`, starting at 1) when the session's
  ///   sent exchange has a `serial` element, writes it to `STX` and records
  ///   it in `serial_allocations`;
  /// * sets `CONTEST_ID` from the definition's `adif` name (unchanged when
  ///   the definition has none) and `contest_session_id`;
  /// * inserts the QSO and its sync row exactly like [QsoRepository.log].
  ///
  /// [fieldsForSerial] may derive further fields from the allocated serial,
  /// for example `STX_STRING` holding the whole sent exchange. Its result is
  /// merged over the QSO's fields.
  ///
  /// Throws [StateError] for an unknown or deleted session and
  /// [ArgumentError] when the QSO belongs to another account.
  Future<ContestLogResult> logContestQso(
    Qso qso, {
    required String sessionId,
    Map<String, String> Function(int serial)? fieldsForSerial,
  }) => _db.transaction(() async {
    final session = await find(sessionId);
    if (session == null) throw StateError('Contest session $sessionId unknown');
    if (qso.accountId != session.accountId) {
      throw ArgumentError.value(qso.accountId, 'qso', 'other account');
    }
    final def = await _definitions.find(session.definitionId);
    final serial = session.usesSerial ? await _nextSerial(sessionId) : null;
    final fields = {
      ...qso.fields,
      'CONTEST_ID': ?def?.adif,
      if (serial != null) ...{
        'STX': '$serial',
        ...?fieldsForSerial?.call(serial),
      },
    };
    final stored = qso.copyWith(fields: fields, contestSessionId: sessionId);
    await _qsos.insertQso(stored, JournalEvent.logged);
    if (serial != null) {
      await _db
          .into(_db.serialAllocations)
          .insert(
            SerialAllocationsCompanion.insert(
              sessionId: sessionId,
              serial: serial,
              qsoId: Value(stored.id),
              allocatedAt: _now(),
            ),
          );
    }
    return (qso: stored, serial: serial);
  });

  // Links ------------------------------------------------------------------

  /// Remote QSO ids already linked to the session on the server, by local
  /// QSO id.
  Future<Map<String, int>> linkedQsos(String sessionId) async {
    final rows = await (_db.select(
      _db.contestLinks,
    )..where((l) => l.sessionId.equals(sessionId))).get();
    return {for (final r in rows) r.qsoId: r.remoteQsoId};
  }

  /// Records that QSOs were linked to the session on the server.
  Future<void> recordLinks(String sessionId, Map<String, int> remoteIds) =>
      _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.contestLinks, [
          for (final MapEntry(:key, :value) in remoteIds.entries)
            ContestLinksCompanion.insert(
              sessionId: sessionId,
              qsoId: key,
              remoteQsoId: value,
              linkedAt: _now(),
            ),
        ]);
      });

  // ------------------------------------------------------------------------

  Future<ContestSessionRow?> _row(String id) => (_db.select(
    _db.contestSessions,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  ContestSession _fromRow(ContestSessionRow r) {
    final settings = jsonDecode(r.settings) as Map<String, dynamic>;
    Map<String, String> strings(Object? v) => {
      if (v is Map<String, dynamic>)
        for (final e in v.entries) e.key: '${e.value}',
    };
    return ContestSession(
      id: r.id,
      definitionId: r.definitionId,
      definitionVersion: (settings['definitionVersion'] as int?) ?? 1,
      accountId: r.accountId,
      stationProfileId: r.stationProfileId,
      startedAt: r.startedAt,
      endedAt: r.endedAt,
      ownExchange: strings(settings['ownExchange']),
      cabrillo: strings(settings['cabrillo']),
      usesSerial: (settings['usesSerial'] as bool?) ?? false,
      remoteState:
          ContestRemoteState.values.asNameMap()[r.remoteState] ??
          ContestRemoteState.local,
      remoteSessionId: r.remoteSessionId,
      remoteEndSynced: r.remoteEndSynced,
      remoteErrorKey: r.remoteErrorKey,
    );
  }
}
