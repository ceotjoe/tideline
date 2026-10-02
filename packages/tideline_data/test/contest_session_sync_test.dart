import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

const _token = 'wl2_contest_token';
const _allScopes = {
  'qso:read',
  'qso:write',
  'qso:delete',
  'station:read',
  'contest:read',
  'contest:write',
};

/// How the wrapped HTTP client treats `POST /contest`.
enum Fault {
  none,

  /// The request never leaves the device.
  beforeSend,

  /// The server handles the request, but the answer is lost.
  afterSend,
}

/// Injects network faults and shrinks ADIF pages.
class TestHttp extends http.BaseClient {
  new(this.inner);

  final http.Client inner;
  Fault createFault = Fault.none;
  int? adifPerPage;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    final isCreate = request.method == 'POST' && path.endsWith('/contest');
    if (isCreate && createFault == Fault.beforeSend) {
      throw http.ClientException('offline');
    }
    var out = request;
    final perPage = adifPerPage;
    if (perPage != null &&
        request.method == 'GET' &&
        path.endsWith('/qso') &&
        request.url.queryParameters['format'] == 'adif') {
      out = http.Request(
        'GET',
        request.url.replace(
          queryParameters: {
            ...request.url.queryParameters,
            'per_page': '$perPage',
          },
        ),
      )..headers.addAll(request.headers);
    }
    final response = await inner.send(out);
    if (isCreate && createFault == Fault.afterSend) {
      await response.stream.drain<void>();
      throw http.ClientException('answer lost');
    }
    return response;
  }
}

String _definitionJson(String id, String? adif, String rcvd) =>
    '''
{
  "schema": 1, "id": "$id", "version": 1, "name": "Test $id",
  ${adif == null ? '' : '"adif": "$adif",'}
  "modes": ["CW", "PHONE"], "bands": ["20m", "40m"],
  "exchange": {
    "sent": [{"kind": "rst"}],
    "rcvd": [$rcvd]
  },
  "dupe": {"per": ["band"]},
  "points": [{"points": 1}],
  "score": "points"
}''';

const _rst = '{"kind": "rst"}';
const _serial = '{"kind": "serial"}';
const _grid = '{"kind": "grid"}';
const _zone = '{"kind": "cqZone"}';

ContestDefinition _parsed(String rcvd) =>
    ContestDefinition.parse(_definitionJson('x', 'CQ-WW-CW', rcvd));

class Harness {
  new _(
    this.server,
    this.db,
    this.qsos,
    this.accounts,
    this.sessions,
    this.journal,
    this.workedBefore,
    this.engine,
    this.net,
    this.accountId,
    this.stationId,
  );

  final MockWavelog server;
  final TidelineDatabase db;
  final QsoRepository qsos;
  final AccountRepository accounts;
  final ContestSessionRepository sessions;
  final SyncJournalRepository journal;
  final WorkedBeforeRepository workedBefore;
  final SyncEngine engine;
  final TestHttp net;
  final String accountId;
  final String stationId;

  /// 2026-10-02 14:00 UTC.
  static final int start = DateTime.utc(2026, 10, 2, 14).millisecondsSinceEpoch;

  static Future<Harness> start_({
    Set<String> scopes = _allScopes,
    MockWavelogVersion version = MockWavelogVersion.v3_2,
    bool hasContestSessions = true,
  }) async {
    final server = MockWavelog(
      version: version,
      tokens: {_token: MockToken(scopes: scopes)},
      stations: [
        {'id': 3, 'name': 'Home', 'callsign': 'DO1HOZ', 'active': true},
      ],
    );
    await server.start();
    addTearDown(server.stop);
    final db = await openTestDatabase();
    final machine = SyncMachine(random: Random(1));
    final qsos = QsoRepository(db, HlcClock('dev-1'), machine);
    final accounts = AccountRepository(db, MemorySecretStore());
    final journal = SyncJournalRepository(db);
    final sessions = ContestSessionRepository(db, HlcClock('dev-1'), qsos);
    final definitions = ContestDefinitionRepository(db);
    await definitions.seedBuiltins([
      _definitionJson('serial-cw', 'CQ-WW-CW', '$_rst, $_serial'),
      _definitionJson('zone-ssb', 'CQ-WW-SSB', '$_rst, $_zone'),
      _definitionJson('inactive', 'DARC-WAEDC-SSB', '$_rst, $_serial'),
      _definitionJson('no-adif', null, '$_rst, $_serial'),
    ]);
    final workedBefore = WorkedBeforeRepository(db);
    final testHttp = TestHttp(http.Client());
    addTearDown(testHttp.close);
    final baseUri = server.baseUri;
    final engine = SyncEngine(
      qsos: qsos,
      accounts: accounts,
      journal: journal,
      machine: machine,
      contestSessions: ContestSessionSync(
        sessions: sessions,
        definitions: definitions,
        journal: journal,
      ),
      workedBefore: workedBefore,
      clientFor: (account, token) => WavelogClient(
        endpoint: WavelogEndpoint(baseUri, usesIndexPhp: true),
        token: token,
        httpClient: testHttp,
        timeout: const Duration(seconds: 5),
      ),
    );
    final accountId = await accounts.add(
      label: 'Home',
      baseUrl: baseUri.toString(),
      usesIndexPhp: true,
      token: _token,
      scopes: scopes,
      hasContestSessions: hasContestSessions,
      nowMillis: 0,
    );
    await accounts.syncStations(accountId, [
      (remoteId: 3, name: 'Home', callsign: 'DO1HOZ', grid: null, active: true),
    ], nowMillis: 0);
    final station = (await accounts.watchStations(accountId).first).single;
    return Harness._(
      server,
      db,
      qsos,
      accounts,
      sessions,
      journal,
      workedBefore,
      engine,
      testHttp,
      accountId,
      station.id,
    );
  }

  Future<ContestSession> startSession(
    String definitionId, {
    bool supported = true,
  }) => sessions.start(
    accountId: accountId,
    definitionId: definitionId,
    me: const ContestStation(call: 'DO1HOZ'),
    accountSupportsSessions: supported,
    stationProfileId: stationId,
    startedAt: start,
  );

  /// Logs a contest QSO [minute] minutes after the session start.
  Future<Qso> log(ContestSession s, int minute, {String? call}) async {
    final qso = Qso(
      id: newUuidV4(),
      accountId: accountId,
      stationProfileId: stationId,
      call: Callsign.tryParse(call ?? 'DL${1000 + minute}')!,
      timeOn: UtcDateTime.fromMillis(start + minute * 60000),
      band: Band.tryParse('20m')!,
      mode: Mode.tryParse('CW')!,
      rstSent: '599',
      rstRcvd: '599',
      contestSessionId: s.id,
      fields: {'CONTEST_ID': ?(await _adif(s))},
    );
    await qsos.log(qso);
    return qso;
  }

  Future<String?> _adif(ContestSession s) async =>
      (await ContestDefinitionRepository(db).find(s.definitionId))?.adif;

  Future<SyncRunResult> sync() => engine.sync(accountId);

  Future<ContestSession> session(ContestSession s) async =>
      (await sessions.find(s.id))!;

  Future<List<JournalEvent>> events() async => [
    for (final e in await journal.watch(accountId: accountId).first) e.event,
  ];

  /// Requests the mock saw for the contest endpoints, as `METHOD` strings.
  List<String> contestRequests() => [
    for (final r in server.requests)
      if (RegExp(r'/contest(/\d+)?$').hasMatch(r.path)) r.method,
  ];

  MockContestSession get onlySession => server.contestSessions.values.single;

  /// Puts a session on the mock as a lost create request would have.
  MockContestSession createOnServer(String contest, DateTime startTime) {
    final session = MockContestSession(
      id: 77,
      contest: server.contests.firstWhere((c) => c.adifName == contest),
      timeStart: _fmt(startTime),
      timeEnd: _fmt(startTime.add(const Duration(minutes: 3))),
      stationId: 3,
      comment: '',
      settings: const {},
    );
    server.contestSessions[session.id] = session;
    return session;
  }

  static String _fmt(DateTime t) =>
      t.toIso8601String().substring(0, 19).replaceFirst('T', ' ');
}

DateTime _at(int minute) => DateTime.utc(2026, 10, 2, 14, minute);

void main() {
  group('creating a session', () {
    test('waits for the first uploaded QSO, then mirrors everything', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      expect(s.remoteState, ContestRemoteState.pending);

      await h.sync();
      expect(h.server.contestSessions, isEmpty);
      expect((await h.session(s)).remoteState, ContestRemoteState.pending);

      final a = await h.log(s, 0);
      final b = await h.log(s, 7);
      final result = await h.sync();
      expect(result.outcome, SyncRunOutcome.completed);

      final remote = h.onlySession;
      expect(remote.contest.adifName, 'CQ-WW-CW');
      expect(remote.stationId, 3);
      expect(remote.timeStart, startsWith('2026-10-02 14:00'));
      expect(remote.timeEnd, startsWith('2026-10-02 14:07'));
      expect(remote.settings['exchangefields'], ['serial']);
      expect(h.server.qsos, hasLength(2));
      expect(remote.qsoIds, h.server.qsos.keys.toSet());
      for (final q in h.server.qsos.values) {
        expect(q.fields['contest_id'], 'CQ-WW-CW');
      }

      final local = await h.session(s);
      expect(local.remoteState, ContestRemoteState.created);
      expect(local.remoteSessionId, remote.id);
      expect(local.remoteEndSynced, Harness.start + 7 * 60000);
      expect(local.remoteErrorKey, isNull);
      final links = await h.sessions.linkedQsos(s.id);
      expect(links.keys.toSet(), {a.id, b.id});
      expect(links.values.toSet(), remote.qsoIds);
      expect(await h.events(), contains(JournalEvent.contestSessionCreated));
    });

    test('ends at least a minute after the start', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.sync();
      expect(h.onlySession.timeEnd, startsWith('2026-10-02 14:01'));
    });
  });

  group('created sessions', () {
    test('later QSOs are linked with a patch and move the end', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.log(s, 5);
      await h.sync();
      expect(h.contestRequests(), ['POST']);

      final c = await h.log(s, 9);
      final d = await h.log(s, 12);
      await h.sync();
      expect(h.contestRequests(), ['POST', 'PATCH']);
      expect(h.onlySession.qsoIds, hasLength(4));
      expect(h.onlySession.timeEnd, startsWith('2026-10-02 14:12'));
      final links = await h.sessions.linkedQsos(s.id);
      expect(links.keys, containsAll([c.id, d.id]));
      expect(links, hasLength(4));
      expect((await h.session(s)).remoteEndSynced, Harness.start + 12 * 60000);
      expect(await h.events(), contains(JournalEvent.contestQsosLinked));

      // Nothing new: no request at all.
      await h.sync();
      await h.sync();
      expect(h.contestRequests(), ['POST', 'PATCH']);
    });

    test('ending the session patches the end time', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.log(s, 5);
      await h.sync();
      await h.sessions.end(s.id, Harness.start + 30 * 60000);
      await h.sync();
      expect(h.contestRequests(), ['POST', 'PATCH']);
      expect(h.onlySession.timeEnd, startsWith('2026-10-02 14:30'));
      expect((await h.session(s)).remoteEndSynced, Harness.start + 30 * 60000);
      await h.sync();
      expect(h.contestRequests(), hasLength(2));
    });

    test('a session deleted on the server is not recreated', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.sync();
      h.server.contestSessions.clear();
      await h.log(s, 4);
      await h.sync();
      final local = await h.session(s);
      expect(local.remoteState, ContestRemoteState.local);
      expect(local.remoteErrorKey, ContestSyncProblem.deletedOnServer);
      expect(h.server.contestSessions, isEmpty);
      expect(await h.events(), contains(JournalEvent.contestSessionLocalOnly));

      // Terminal: further runs leave it alone.
      await h.log(s, 6);
      await h.sync();
      expect(h.server.contestSessions, isEmpty);
    });
  });

  group('sessions that stay local', () {
    test('an inactive contest is local, its QSOs still upload', () async {
      final h = await Harness.start_();
      final s = await h.startSession('inactive');
      await h.log(s, 0);
      await h.sync();
      final local = await h.session(s);
      expect(local.remoteState, ContestRemoteState.local);
      expect(local.remoteErrorKey, ContestSyncProblem.contestNotActive);
      expect(h.server.contestSessions, isEmpty);
      expect(
        h.server.qsos.values.single.fields['contest_id'],
        'DARC-WAEDC-SSB',
      );
      expect(await h.events(), contains(JournalEvent.contestSessionLocalOnly));
      await h.sync();
      expect(h.contestRequests(), ['POST']);
    });

    test('a definition without an ADIF name is local', () async {
      final h = await Harness.start_();
      final s = await h.startSession('no-adif');
      // start() already makes such a session local; force the state a
      // definition update could leave behind.
      await h.sessions.setRemote(s.id, state: ContestRemoteState.pending);
      await h.log(s, 0);
      await h.sync();
      final local = await h.session(s);
      expect(local.remoteState, ContestRemoteState.local);
      expect(local.remoteErrorKey, ContestSyncProblem.noAdifName);
      expect(h.contestRequests(), isEmpty);
      expect(await h.events(), contains(JournalEvent.contestSessionLocalOnly));
    });

    test('a Wavelog 3.1 server is left alone', () async {
      final h = await Harness.start_(
        version: MockWavelogVersion.v3_1,
        hasContestSessions: false,
      );
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      final result = await h.sync();
      expect(result.outcome, SyncRunOutcome.completed);
      expect(h.server.qsos, hasLength(1));
      expect((await h.session(s)).remoteState, ContestRemoteState.pending);
      expect(h.contestRequests(), isEmpty);
    });

    test('without contest:write the step is skipped', () async {
      final h = await Harness.start_(
        scopes: {'qso:read', 'qso:write', 'station:read', 'contest:read'},
      );
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      final result = await h.sync();
      expect(result.outcome, SyncRunOutcome.completed);
      expect(h.server.qsos, hasLength(1));
      expect((await h.session(s)).remoteState, ContestRemoteState.pending);
      expect(h.contestRequests(), isEmpty);
    });
  });

  group('verifying (lost create)', () {
    test('adopts a session the server already has', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.sessions.setRemote(s.id, state: ContestRemoteState.verifying);
      final existing = h.createOnServer('CQ-WW-CW', _at(0));

      await h.sync();
      expect(h.server.contestSessions, hasLength(1));
      expect(h.contestRequests(), ['GET', 'PATCH']);
      final local = await h.session(s);
      expect(local.remoteState, ContestRemoteState.created);
      expect(local.remoteSessionId, existing.id);
      expect(existing.qsoIds, h.server.qsos.keys.toSet());
      expect(await h.events(), contains(JournalEvent.contestSessionCreated));
    });

    test('a different contest or start is not adopted', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.sessions.setRemote(s.id, state: ContestRemoteState.verifying);
      h.createOnServer('CQ-WW-SSB', _at(0));
      await h.sync();
      expect(h.server.contestSessions, hasLength(2));
      final local = await h.session(s);
      expect(local.remoteState, ContestRemoteState.created);
      expect(local.remoteSessionId, isNot(77));
    });

    test('with nothing on the server it creates exactly one', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.sessions.setRemote(s.id, state: ContestRemoteState.verifying);
      await h.sync();
      expect(h.server.contestSessions, hasLength(1));
      expect(h.contestRequests(), ['GET', 'POST']);
      expect((await h.session(s)).remoteState, ContestRemoteState.created);
    });

    test('a failed create stays verifying and reconciles later', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      h.net.createFault = Fault.beforeSend;
      final result = await h.sync();
      expect(result.outcome, SyncRunOutcome.offline);
      expect(h.server.qsos, hasLength(1));
      expect(h.server.contestSessions, isEmpty);
      expect((await h.session(s)).remoteState, ContestRemoteState.verifying);

      h.net.createFault = Fault.none;
      final again = await h.sync();
      expect(again.outcome, SyncRunOutcome.completed);
      expect(h.server.contestSessions, hasLength(1));
      expect((await h.session(s)).remoteState, ContestRemoteState.created);
      expect(h.onlySession.qsoIds, h.server.qsos.keys.toSet());
    });

    test('a lost answer does not duplicate the session', () async {
      final h = await Harness.start_();
      final s = await h.startSession('serial-cw');
      await h.log(s, 0);
      await h.log(s, 3);
      h.net.createFault = Fault.afterSend;
      final result = await h.sync();
      expect(result.outcome, SyncRunOutcome.offline);
      expect(h.server.contestSessions, hasLength(1));
      expect((await h.session(s)).remoteState, ContestRemoteState.verifying);

      h.net.createFault = Fault.none;
      await h.sync();
      expect(h.server.contestSessions, hasLength(1));
      final local = await h.session(s);
      expect(local.remoteState, ContestRemoteState.created);
      expect(local.remoteSessionId, h.onlySession.id);
      // The first request had linked both QSOs on the server; the retry
      // only records them locally.
      expect(h.onlySession.qsoIds, hasLength(2));
      expect(h.contestRequests().where((m) => m == 'POST'), hasLength(1));
    });
  });

  group('worked-before pull', () {
    void addServerQsos(Harness h, int count, {int firstId = 2001}) {
      for (var i = 0; i < count; i++) {
        final id = firstId + i;
        h.server.qsos[id] = MockQso(
          id: id,
          stationId: 3,
          fields: {
            'call': 'DL${100 + i}A',
            'band': '40m',
            'mode': 'CW',
            'qso_date': '2026-09-01 10:${'$i'.padLeft(2, '0')}:00',
          },
        );
      }
    }

    Future<List<WorkedBeforeRow>> rows(Harness h) =>
        h.db.select(h.db.workedBefore).get();

    int adifRequests(Harness h) =>
        h.server.requests.where((r) => r.path.endsWith('/qso')).length;

    test(
      'merges server QSOs, stores the cursor, then fetches nothing',
      () async {
        final h = await Harness.start_();
        addServerQsos(h, 3);
        await h.sync();
        final found = await rows(h);
        expect(found, hasLength(3));
        expect(found.every((r) => r.source == 'server'), isTrue);
        expect(found.map((r) => r.call), contains('DL100A'));
        expect(await h.workedBefore.lastFetchedId(h.accountId), 2003);

        final before = adifRequests(h);
        await h.sync();
        expect(adifRequests(h), before + 1);
        expect(await rows(h), hasLength(3));
        expect(await h.workedBefore.lastFetchedId(h.accountId), 2003);
      },
    );

    test('follows pages within a run', () async {
      final h = await Harness.start_();
      h.net.adifPerPage = 2;
      addServerQsos(h, 5);
      await h.sync();
      expect(await rows(h), hasLength(5));
      expect(await h.workedBefore.lastFetchedId(h.accountId), 2005);
    });

    test('reads at most ten pages per run', () async {
      final h = await Harness.start_();
      h.net.adifPerPage = 1;
      addServerQsos(h, 12);
      await h.sync();
      expect(await rows(h), hasLength(SyncEngine.workedBeforePagesPerRun));
      expect(await h.workedBefore.lastFetchedId(h.accountId), 2010);
      await h.sync();
      expect(await rows(h), hasLength(12));
      expect(await h.workedBefore.lastFetchedId(h.accountId), 2012);
    });

    test('a pull error does not fail the run', () async {
      final h = await Harness.start_();
      h.net.adifPerPage = 0; // the mock falls back to its default
      final result = await h.sync();
      expect(result.outcome, SyncRunOutcome.completed);
    });
  });

  group('exchangeFieldsFor', () {
    List<String> fields(String rcvd) =>
        ContestSessionSync.exchangeFieldsFor(_parsed(rcvd));

    test('serial', () => expect(fields('$_rst, $_serial'), ['serial']));
    test('grid', () => expect(fields('$_rst, $_grid'), ['gridsquare']));
    test('zone', () => expect(fields('$_rst, $_zone'), ['exchange']));
    test('report only', () => expect(fields(_rst), isEmpty));
    test(
      'serial plus other elements',
      () => expect(fields('$_rst, $_serial, $_zone'), ['serial', 'exchange']),
    );

    test('looks at variants too', () {
      final def = ContestDefinition.parse(
        jsonEncode({
          ...(jsonDecode(_definitionJson('v', 'CQ-WW-CW', '$_rst, $_zone'))
              as Map<String, Object?>),
          'exchange': {
            'sent': [
              {'kind': 'rst'},
            ],
            'rcvd': [
              {'kind': 'rst'},
              {'kind': 'cqZone'},
            ],
            'variants': [
              {
                'when': {
                  'myDxcc': [291],
                },
                'rcvd': [
                  {'kind': 'rst'},
                  {'kind': 'grid'},
                ],
              },
            ],
          },
        }),
      );
      expect(ContestSessionSync.exchangeFieldsFor(def), [
        'gridsquare',
        'exchange',
      ]);
    });
  });
}
