import 'dart:async';
import 'dart:io';

import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A value with a stream that first replays it, then follows changes.
class _Live<T> {
  new(this._value);

  T _value;
  final _changes = StreamController<T>.broadcast(sync: true);

  T get value => _value;

  set value(T next) {
    _value = next;
    _changes.add(next);
  }

  Stream<T> get stream async* {
    yield _value;
    yield* _changes.stream;
  }
}

/// Loads a bundled definition from `assets/contests`.
ContestDefinition bundledDefinition(String id) => ContestDefinition.parse(
  File('assets/contests/$id.json').readAsStringSync(),
);

/// All bundled definitions, as the database would hold them.
List<StoredContestDefinition> bundledDefinitions() => [
  for (final f in Directory(
    'assets/contests',
  ).listSync().whereType<File>().where((f) => f.path.endsWith('.json')))
    StoredContestDefinition(
      ContestDefinition.parse(f.readAsStringSync()),
      builtin: true,
    ),
];

/// In-memory stand-in for the contest tables, shared by the fake
/// repositories below. It mimics the contracts the UI relies on:
/// - serials are allocated at save time and never reused;
/// - an edit cannot change the stored serial;
/// - streams replay their current value, then follow changes.
class ContestBackend {
  new({List<StoredContestDefinition>? definitions, this.scp})
    : definitions = definitions ?? bundledDefinitions();

  /// Definitions in the "database".
  final List<StoredContestDefinition> definitions;

  /// The Super Check Partial database, if the test has one.
  ScpDatabase? scp;

  /// Main-log history by call, for the worked-before hint.
  final Map<String, WorkedSummary> worked = {};

  /// Serials that were given out, per session. Deleting a QSO keeps them.
  final Map<String, int> highestSerial = {};

  /// Every `logContestQso` call, for assertions.
  final List<Qso> logged = [];

  /// Failure injection: the next `logContestQso` throws.
  bool failNextLog = false;

  final List<ContestSession> _sessions = [];
  final _active = _Live<ContestSession?>(null);
  final _all = _Live<List<ContestSession>>(const []);
  final _qsos = _Live<List<Qso>>(const []);
  final _nextSerial = _Live<int>(1);

  ContestSession? get active => _active.value;
  List<Qso> get qsos => _qsos.value;

  late final FakeContestSessions sessionRepository = FakeContestSessions(this);
  late final FakeContestQsos qsoRepository = FakeContestQsos(this);
  late final FakeContestDefinitions definitionRepository =
      FakeContestDefinitions(this);
  late final FakeWorkedBefore workedRepository = FakeWorkedBefore(this);

  /// Starts a session directly (tests that begin with a running contest).
  ContestSession startSession(
    String definitionId, {
    Map<String, String> ownExchange = const {},
    bool usesSerial = false,
    String accountId = 'acc-1',
    String stationProfileId = 'st-1',
  }) {
    final session = ContestSession(
      id: 's${_sessions.length + 1}',
      definitionId: definitionId,
      definitionVersion: 1,
      accountId: accountId,
      stationProfileId: stationProfileId,
      startedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      ownExchange: ownExchange,
      cabrillo: const {},
      usesSerial: usesSerial,
      remoteState: ContestRemoteState.local,
    );
    _sessions.add(session);
    _publish();
    return session;
  }

  ContestSession _replace(
    String id,
    ContestSession Function(ContestSession) f,
  ) {
    final i = _sessions.indexWhere((s) => s.id == id);
    _sessions[i] = f(_sessions[i]);
    _publish();
    return _sessions[i];
  }

  void _publish() {
    _all.value = List.of(_sessions.reversed);
    final active = _sessions.where((s) => s.isActive).lastOrNull;
    final changed = active?.id != _active.value?.id;
    _active.value = active;
    if (changed) _publishQsos();
    _publishSerial();
  }

  void _publishQsos() {
    final id = _active.value?.id;
    final list = [
      for (final q in _stored)
        if (q.contestSessionId == id) q,
    ]..sort((a, b) => a.timeOn.compareTo(b.timeOn));
    _qsos.value = list;
  }

  void _publishSerial() {
    final id = _active.value?.id;
    _nextSerial.value = (highestSerial[id] ?? 0) + 1;
  }

  final List<Qso> _stored = [];

  /// Recomputes the next-serial preview after a test set [highestSerial].
  void refreshSerial() => _publishSerial();

  /// Adds a QSO as if it had been logged (no serial logic).
  void seedQso(Qso qso) {
    _stored.add(qso);
    _publishQsos();
  }
}

/// Fake [ContestSessionRepository] on a [ContestBackend].
class FakeContestSessions implements ContestSessionRepository {
  new(this._b);

  final ContestBackend _b;

  @override
  Stream<ContestSession?> watchActive(String accountId) => _b._active.stream;

  @override
  Stream<List<ContestSession>> watchAll(String accountId) => _b._all.stream;

  @override
  Stream<List<Qso>> watchSessionQsos(String sessionId) => _b._qsos.stream;

  @override
  Stream<int> watchNextSerial(String sessionId) => _b._nextSerial.stream;

  @override
  Future<ContestSession> start({
    required String accountId,
    required String definitionId,
    required ContestStation me,
    required bool accountSupportsSessions,
    String? stationProfileId,
    Map<String, String> ownExchange = const {},
    Map<String, String> cabrillo = const {},
    int? startedAt,
  }) async {
    final def = _b.definitions
        .firstWhere((d) => d.definition.id == definitionId)
        .definition;
    final session = ContestSession(
      id: 's${_b._sessions.length + 1}',
      definitionId: definitionId,
      definitionVersion: def.version,
      accountId: accountId,
      stationProfileId: stationProfileId,
      startedAt: startedAt ?? DateTime.now().toUtc().millisecondsSinceEpoch,
      ownExchange: ownExchange,
      cabrillo: cabrillo,
      usesSerial: def
          .exchangeFor(me)
          .sent
          .any((e) => e.kind == ExchangeKind.serial),
      remoteState: accountSupportsSessions
          ? ContestRemoteState.pending
          : ContestRemoteState.local,
    );
    _b._sessions.add(session);
    _b._publish();
    return session;
  }

  @override
  Future<void> end(String id, int at) async {
    _b._replace(
      id,
      (s) => ContestSession(
        id: s.id,
        definitionId: s.definitionId,
        definitionVersion: s.definitionVersion,
        accountId: s.accountId,
        stationProfileId: s.stationProfileId,
        startedAt: s.startedAt,
        endedAt: at,
        ownExchange: s.ownExchange,
        cabrillo: s.cabrillo,
        usesSerial: s.usesSerial,
        remoteState: s.remoteState,
      ),
    );
  }

  @override
  Future<void> reopen(String id) async {
    _b._replace(
      id,
      (s) => ContestSession(
        id: s.id,
        definitionId: s.definitionId,
        definitionVersion: s.definitionVersion,
        accountId: s.accountId,
        stationProfileId: s.stationProfileId,
        startedAt: s.startedAt,
        ownExchange: s.ownExchange,
        cabrillo: s.cabrillo,
        usesSerial: s.usesSerial,
        remoteState: s.remoteState,
      ),
    );
  }

  @override
  Future<ContestLogResult> logContestQso(
    Qso qso, {
    required String sessionId,
    Map<String, String> Function(int serial)? fieldsForSerial,
  }) async {
    if (_b.failNextLog) {
      _b.failNextLog = false;
      throw StateError('disk full');
    }
    final session = _b._sessions.firstWhere((s) => s.id == sessionId);
    final serial = session.usesSerial
        ? (_b.highestSerial[sessionId] ?? 0) + 1
        : null;
    if (serial != null) _b.highestSerial[sessionId] = serial;
    final stored = qso.copyWith(
      fields: {
        ...qso.fields,
        if (serial != null) ...{
          'STX': '$serial',
          ...?fieldsForSerial?.call(serial),
        },
      },
      contestSessionId: sessionId,
    );
    _b._stored.add(stored);
    _b.logged.add(stored);
    _b
      .._publishQsos()
      .._publishSerial();
    return (qso: stored, serial: serial);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake [QsoRepository] for edits and deletes of contest QSOs.
class FakeContestQsos implements QsoRepository {
  new(this._b);

  final ContestBackend _b;

  /// QSOs passed to `update`, as the UI built them.
  final List<Qso> updates = [];

  /// Ids passed to `delete`.
  final List<String> deleted = [];

  /// QSOs logged through the normal (non-contest) log form.
  final List<Qso> plainLogged = [];

  @override
  Future<void> log(Qso qso) async => plainLogged.add(qso);

  @override
  Future<void> update(Qso edited) async {
    updates.add(edited);
    final i = _b._stored.indexWhere((q) => q.id == edited.id);
    final original = _b._stored[i];
    // Like the real repository: the allocated serial cannot change.
    final stx = original.field('STX');
    _b._stored[i] = edited.copyWith(fields: {...edited.fields, 'STX': ?stx});
    _b._publishQsos();
  }

  @override
  Future<void> delete(String id, {required bool canDeleteOnServer}) async {
    deleted.add(id);
    _b._stored.removeWhere((q) => q.id == id);
    _b._publishQsos();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake [ContestDefinitionRepository].
class FakeContestDefinitions implements ContestDefinitionRepository {
  new(this._b);

  final ContestBackend _b;

  @override
  Stream<List<StoredContestDefinition>> watchAll() => Stream.value(
    [..._b.definitions]
      ..sort((a, b) => a.definition.name.compareTo(b.definition.name)),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake [WorkedBeforeRepository].
class FakeWorkedBefore implements WorkedBeforeRepository {
  new(this._b);

  final ContestBackend _b;

  @override
  Future<WorkedSummary> lookupBase(String accountId, String call) async =>
      _b.worked[call] ?? WorkedSummary.none;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
