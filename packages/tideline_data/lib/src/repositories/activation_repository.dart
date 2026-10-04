import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tideline_data/src/database/tideline_database.dart';
import 'package:tideline_data/src/repositories/qso_repository.dart';
import 'package:tideline_data/src/repositories/qso_row_mapping.dart';
import 'package:tideline_data/src/repositories/sync_journal_repository.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The activation a QSO was to be logged in does not exist or has ended.
class ActivationUnavailable implements Exception {
  /// Creates the exception.
  const new(this.activationId, {required this.ended});

  /// The activation's id.
  final String activationId;

  /// Whether it exists but has ended (otherwise it is unknown or deleted).
  final bool ended;

  @override
  String toString() => 'ActivationUnavailable($activationId, ended: $ended)';
}

/// SOTA, POTA and WWFF activations, the logging of their QSOs, and the
/// validity rules per programme (`program_rules`).
class ActivationRepository {
  /// Creates the repository. The QSO repository does the actual insert.
  new(this._db, this._clock, this._qsos, {int Function()? nowMillis})
    : _now = nowMillis ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);

  final TidelineDatabase _db;
  final HlcClock _clock;
  final QsoRepository _qsos;
  final int Function() _now;

  /// Starts an activation of [reference] and makes it the only active one of
  /// the account: an activation still running is ended at the new start time.
  ///
  /// [reference] is normalised to upper case and must have the shape of a
  /// [program] reference; whether it exists is not checked, so the app works
  /// without a downloaded pack. [myGridsquare] is normalised too.
  /// Throws [ArgumentError] for a malformed reference or grid.
  Future<Activation> start({
    required String accountId,
    required ReferenceProgram program,
    required String reference,
    String? myGridsquare,
    String? stationProfileId,
    int? startedAt,
  }) {
    final ref = reference.trim().toUpperCase();
    if (!program.isValidReference(ref)) {
      throw ArgumentError.value(
        reference,
        'reference',
        'not a ${program.code}',
      );
    }
    String? grid;
    if (myGridsquare != null && myGridsquare.trim().isNotEmpty) {
      grid = Maidenhead.normalize(myGridsquare);
      if (grid == null) {
        throw ArgumentError.value(myGridsquare, 'myGridsquare', 'not a grid');
      }
    }
    return _db.transaction(() async {
      final at = startedAt ?? _now();
      final running =
          await (_db.select(_db.activations)..where(
                (a) =>
                    a.accountId.equals(accountId) &
                    a.deletedAt.isNull() &
                    a.endedAt.isNull(),
              ))
              .get();
      for (final r in running) {
        await _touch(r.id, endedAt: Value(at < r.startedAt ? r.startedAt : at));
      }
      final id = newUuidV4();
      final hlc = _clock.now().toString();
      await _db
          .into(_db.activations)
          .insert(
            ActivationsCompanion.insert(
              id: id,
              accountId: accountId,
              program: program.code,
              reference: ref,
              myGridsquare: Value(grid),
              stationProfileId: Value(stationProfileId),
              startedAt: at,
              originDeviceId: _clock.deviceId,
              hlcCreated: hlc,
              hlcModified: hlc,
            ),
          );
      return (await find(id))!;
    });
  }

  /// Ends the activation at [at] (UTC millis).
  Future<void> end(String id, int at) => _touch(id, endedAt: Value(at));

  /// Reopens an ended activation. Any other running one of the account is
  /// ended first, so there is still one active activation at most.
  Future<void> reopen(String id) => _db.transaction(() async {
    final row = await _row(id);
    if (row == null || row.deletedAt != null) {
      throw StateError('Activation $id not found');
    }
    final now = _now();
    final running =
        await (_db.select(_db.activations)..where(
              (a) =>
                  a.accountId.equals(row.accountId) &
                  a.deletedAt.isNull() &
                  a.endedAt.isNull() &
                  a.id.isNotValue(id),
            ))
            .get();
    for (final r in running) {
      await _touch(r.id, endedAt: Value(now < r.startedAt ? r.startedAt : now));
    }
    await _touch(id, endedAt: const Value(null));
  });

  /// Soft-deletes the activation. Its QSOs stay in the log, with their own
  /// reference fields.
  Future<void> delete(String id) => _touch(id, deletedAt: Value(_now()));

  /// One non-deleted activation.
  Future<Activation?> find(String id) async {
    final row = await _row(id);
    return row == null || row.deletedAt != null ? null : _fromRow(row);
  }

  /// The running activation of [accountId], or null.
  Stream<Activation?> watchActive(String accountId) =>
      (_db.select(_db.activations)
            ..where(
              (a) =>
                  a.accountId.equals(accountId) &
                  a.deletedAt.isNull() &
                  a.endedAt.isNull(),
            )
            ..orderBy([(a) => OrderingTerm.desc(a.startedAt)])
            ..limit(1))
          .watch()
          .map((rows) => rows.map(_fromRow).nonNulls.firstOrNull);

  /// All non-deleted activations of [accountId], newest first.
  Stream<List<Activation>> watchAll(String accountId) =>
      (_db.select(_db.activations)
            ..where((a) => a.accountId.equals(accountId) & a.deletedAt.isNull())
            ..orderBy([(a) => OrderingTerm.desc(a.startedAt)]))
          .watch()
          .map((rows) => rows.map(_fromRow).nonNulls.toList());

  /// Logs [qso] as part of the activation, in one local transaction: the
  /// own reference (`MY_POTA_REF`, …) and `MY_GRIDSQUARE` are written to the
  /// QSO, which gets the activation's id and, if it has none, its station
  /// profile. Values the QSO already carries are kept, so a different grid
  /// typed for one contact wins.
  ///
  /// Throws [ActivationUnavailable] for an unknown, deleted or ended
  /// activation and [ArgumentError] when the QSO belongs to another account.
  Future<Qso> logQso(Qso qso, {required String activationId}) =>
      _db.transaction(() async {
        final activation = await find(activationId);
        if (activation == null) {
          throw ActivationUnavailable(activationId, ended: false);
        }
        if (!activation.isActive) {
          throw ActivationUnavailable(activationId, ended: true);
        }
        if (qso.accountId != activation.accountId) {
          throw ArgumentError.value(qso.accountId, 'qso', 'other account');
        }
        final stored = qso.copyWith(
          fields: {...activation.adifFields, ...qso.fields},
          activationId: activationId,
          stationProfileId: qso.stationProfileId ?? activation.stationProfileId,
        );
        await _qsos.insertQso(stored, JournalEvent.logged);
        return stored;
      });

  /// Like [logQso] for several QSOs in **one** transaction: all or none.
  /// Returns the stored QSOs.
  Future<List<Qso>> logQsos(List<Qso> qsos, {required String activationId}) =>
      _db.transaction(() async {
        final stored = <Qso>[];
        for (final qso in qsos) {
          stored.add(await logQso(qso, activationId: activationId));
        }
        return stored;
      });

  /// The live QSOs of an activation, oldest first.
  Stream<List<Qso>> watchQsos(String activationId) =>
      (_db.select(_db.qsos)
            ..where(
              (q) => q.activationId.equals(activationId) & q.deletedAt.isNull(),
            )
            ..orderBy([
              (q) => OrderingTerm.asc(q.timeOn),
              (q) => OrderingTerm.asc(q.hlcCreated),
            ]))
          .watch()
          .map((rows) => [for (final r in rows) qsoFromRow(r)]);

  /// Progress toward a valid activation, recomputed whenever a QSO or the
  /// rules change. Deleted QSOs do not count.
  Stream<ActivationProgress> watchProgress(String activationId) {
    final trigger = _db.customSelect(
      'SELECT 1',
      readsFrom: {_db.qsos, _db.programRules},
    );
    return trigger.watch().asyncMap((_) => progress(activationId));
  }

  /// [watchProgress] once. Throws [StateError] for an unknown activation.
  Future<ActivationProgress> progress(String activationId) async {
    final row = await _row(activationId);
    final program = row == null ? null : ReferenceProgram.tryParse(row.program);
    if (row == null || program == null) {
      throw StateError('Activation $activationId not found');
    }
    final qsos =
        await (_db.select(_db.qsos)
              ..where(
                (q) =>
                    q.activationId.equals(activationId) & q.deletedAt.isNull(),
              )
              ..orderBy([(q) => OrderingTerm.asc(q.timeOn)]))
            .get();
    return ActivationProgress.evaluate(await rulesFor(program), [
      for (final q in qsos) ActivationQso.of(qsoFromRow(q)),
    ]);
  }

  // Rules ------------------------------------------------------------------

  /// The rules of [program]: the stored ones, or the built-in defaults when
  /// none are stored or the stored row is unusable.
  Future<ActivationRules> rulesFor(ReferenceProgram program) async {
    final row = await (_db.select(
      _db.programRules,
    )..where((r) => r.program.equals(program.code))).getSingleOrNull();
    if (row == null) return ActivationRules.defaultFor(program);
    Object? json;
    try {
      json = jsonDecode(row.rules);
    } on FormatException {
      return ActivationRules.defaultFor(program);
    }
    return ActivationRules.tryFromJson(program, json, version: row.version) ??
        ActivationRules.defaultFor(program);
  }

  /// Stores [rules] for their programme. The version is raised on every call.
  Future<void> saveRules(ActivationRules rules) async {
    final current = await (_db.select(
      _db.programRules,
    )..where((r) => r.program.equals(rules.program.code))).getSingleOrNull();
    await _db
        .into(_db.programRules)
        .insertOnConflictUpdate(
          ProgramRulesCompanion.insert(
            program: rules.program.code,
            version: (current?.version ?? 0) + 1,
            rules: jsonEncode(rules.toJson()),
          ),
        );
  }

  /// Forgets stored rules, so the built-in defaults apply again.
  Future<void> resetRules(ReferenceProgram program) => (_db.delete(
    _db.programRules,
  )..where((r) => r.program.equals(program.code))).go();

  // ------------------------------------------------------------------------

  Future<ActivationRow?> _row(String id) => (_db.select(
    _db.activations,
  )..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<void> _touch(
    String id, {
    Value<int?> endedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
  }) => _db.transaction(() async {
    final row = await _row(id);
    if (row == null) throw StateError('Activation $id not found');
    await (_db.update(_db.activations)..where((a) => a.id.equals(id))).write(
      ActivationsCompanion(
        endedAt: endedAt,
        deletedAt: deletedAt,
        hlcModified: Value(_clock.now().toString()),
        rev: Value(row.rev + 1),
      ),
    );
  });

  /// Null for a programme this version does not know (a row written by a
  /// newer version), which is then left out instead of shown wrongly.
  Activation? _fromRow(ActivationRow r) {
    final program = ReferenceProgram.tryParse(r.program);
    if (program == null) return null;
    return Activation(
      id: r.id,
      accountId: r.accountId,
      program: program,
      reference: r.reference,
      myGridsquare: r.myGridsquare,
      stationProfileId: r.stationProfileId,
      startedAt: r.startedAt,
      endedAt: r.endedAt,
    );
  }
}
