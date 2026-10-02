import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

const _token = 'wl2_contest_token';

void main() {
  late MockWavelog server;
  late http.Client httpClient;
  late WavelogClient client;

  WavelogClient clientFor(MockWavelog s, {String token = _token}) =>
      WavelogClient(
        endpoint: WavelogEndpoint(s.baseUri, usesIndexPhp: true),
        token: token,
        httpClient: httpClient,
        timeout: const Duration(seconds: 5),
      );

  MockWavelog newServer({
    MockWavelogVersion version = MockWavelogVersion.v3_2,
    Set<String>? scopes,
  }) => MockWavelog(
    version: version,
    tokens: {
      _token: MockToken(
        scopes:
            scopes ??
            const {
              'qso:read',
              'qso:write',
              'qso:delete',
              'station:read',
              'contest:read',
              'contest:write',
              'contest:delete',
            },
      ),
    },
    stations: [
      {'id': 3, 'name': 'Home', 'callsign': 'DO1HOZ', 'active': true},
      {'id': 4, 'name': 'Field', 'callsign': 'DO1HOZ/P', 'active': false},
    ],
  );

  setUp(() async {
    httpClient = http.Client();
    server = newServer();
    await server.start();
    client = clientFor(server);
  });

  tearDown(() async {
    httpClient.close();
    await server.stop();
  });

  Future<int> logQso(String call, {String time = '14:05:33'}) =>
      client.createQso(
        stationProfileId: 3,
        fields: {
          'call': call,
          'band': '20m',
          'mode': 'SSB',
          'qso_date': '2026-10-02',
          'time_on': time,
          'freq': 14205000,
        },
      );

  Future<WavelogContestSession> newSession({List<int>? qsoIds}) =>
      client.createContestSession(
        contestAdifName: 'CQ-WW-SSB',
        start: DateTime.utc(2026, 10, 25),
        end: DateTime.utc(2026, 10, 27),
        stationId: 3,
        comment: 'Multi-single',
        qsoIds: qsoIds,
      );

  group('catalog', () {
    test('lists only active contests with ADIF names', () async {
      final catalog = await client.contestCatalog();
      final names = catalog.map((c) => c.adifName);
      expect(
        names,
        containsAll(['CQ-WW-SSB', 'CQ-WPX-CW', 'CQ-WW-CW', 'DARC-WAEDC-CW']),
      );
      expect(names, isNot(contains('DARC-WAEDC-SSB')));
      expect(
        catalog.firstWhere((c) => c.adifName == 'CQ-WW-SSB').name,
        'CQ WW DX Contest (SSB)',
      );
    });

    test('a 3.1.x server answers 404', () async {
      final old = newServer(version: MockWavelogVersion.v3_1);
      await old.start();
      addTearDown(old.stop);
      final c = clientFor(old);
      await expectLater(c.contestCatalog(), throwsA(isA<WavelogNotFound>()));
      expect(await c.hasContestCatalog(), isFalse);
      await expectLater(
        c.listContestSessions(),
        throwsA(isA<WavelogNotFound>()),
      );
    });
  });

  group('sessions', () {
    test('create, get and list', () async {
      final created = await newSession();
      expect(created.contestAdifName, 'CQ-WW-SSB');
      expect(created.start, DateTime.utc(2026, 10, 25));
      expect(created.end, DateTime.utc(2026, 10, 27));
      expect(created.stationId, 3);
      expect(created.comment, 'Multi-single');
      expect(created.settings['serial_scope'], 'station');
      expect(created.qsoIds, isNull);
      expect(
        server.contestSessions[created.id]!.timeStart,
        '2026-10-25 00:00:00',
      );

      final got = await client.getContestSession(created.id);
      expect(got.qsoIds, isEmpty);

      final list = await client.listContestSessions();
      expect(list.map((s) => s.id), [created.id]);
      expect(await client.listContestSessions(stationId: 4), isEmpty);
      expect(await client.listContestSessions(sinceId: created.id), isEmpty);
    });

    test('non-UTC times are sent as UTC', () async {
      final s = await client.createContestSession(
        contestAdifName: 'CQ-WPX-CW',
        start: DateTime.parse('2026-05-30T02:00:00+02:00'),
        end: DateTime.parse('2026-05-31T02:00:00+02:00'),
        stationId: 3,
      );
      expect(server.contestSessions[s.id]!.timeStart, '2026-05-30 00:00:00');
    });

    test('create links QSOs and sets contest_id on them', () async {
      final a = await logQso('DL1ABC');
      final s = await newSession(qsoIds: [a]);
      expect(s.linkedCount, 1);
      expect(s.skippedQsoIds, isEmpty);
      expect(s.qsoCount, 1);
      expect(server.qsos[a]!.fields['contest_id'], 'CQ-WW-SSB');
      expect((await client.getContestSession(s.id)).qsoIds, [a]);
    });

    test('link and unlink keep contest_id in step', () async {
      final a = await logQso('DL1ABC');
      final b = await logQso('DL2XYZ', time: '14:07:00');
      final s = await newSession();

      final linked = await client.patchContestSession(s.id, linkQsoIds: [a, b]);
      expect(linked.linkedCount, 2);
      expect(linked.qsoCount, 2);
      expect(server.qsos[b]!.fields['contest_id'], 'CQ-WW-SSB');

      // Re-sending is idempotent.
      final again = await client.patchContestSession(s.id, linkQsoIds: [a]);
      expect(again.linkedCount, 0);
      expect(again.skippedQsoIds, isEmpty);

      final unlinked = await client.patchContestSession(
        s.id,
        unlinkQsoIds: [a],
      );
      expect(unlinked.unlinkedCount, 1);
      expect(server.qsos[a]!.fields.containsKey('contest_id'), isFalse);
      expect((await client.getContestSession(s.id)).qsoIds, [b]);
    });

    test('a QSO in another session is skipped', () async {
      final a = await logQso('DL1ABC');
      await newSession(qsoIds: [a]);
      final second = await newSession();
      final r = await client.patchContestSession(second.id, linkQsoIds: [a]);
      expect(r.linkedCount, 0);
      expect(r.skippedQsoIds, [a]);
    });

    test('patch edits fields and re-derives exchangetype', () async {
      final s = await newSession();
      final p = await client.patchContestSession(
        s.id,
        comment: 'changed',
        end: DateTime.utc(2026, 10, 26, 12),
        settings: {
          'exchangefields': ['serial', 'exchange'],
        },
      );
      expect(p.comment, 'changed');
      expect(p.end, DateTime.utc(2026, 10, 26, 12));
      expect(p.settings['exchangetype'], 'Serialexchange');
    });

    test('delete keeps QSOs by default', () async {
      final a = await logQso('DL1ABC');
      final s = await newSession(qsoIds: [a]);
      await client.deleteContestSession(s.id);
      expect(server.contestSessions, isEmpty);
      expect(server.qsos[a]!.fields.containsKey('contest_id'), isFalse);
      // Already gone is fine.
      await client.deleteContestSession(s.id);
    });

    test('delete with deleteQsos removes the QSOs', () async {
      final a = await logQso('DL1ABC');
      final s = await newSession(qsoIds: [a]);
      await client.deleteContestSession(s.id, deleteQsos: true);
      expect(server.qsos, isEmpty);
    });

    test('unknown session is a 404', () async {
      await expectLater(
        client.getContestSession(99),
        throwsA(isA<WavelogNotFound>()),
      );
    });
  });

  group('errors', () {
    test('an inactive contest is a rejected contest', () async {
      await expectLater(
        client.createContestSession(
          contestAdifName: 'DARC-WAEDC-SSB',
          start: DateTime.utc(2026, 9),
          end: DateTime.utc(2026, 9, 2),
          stationId: 3,
        ),
        throwsA(
          isA<WavelogValidationError>()
              .having((e) => e.isContestRejected, 'isContestRejected', isTrue)
              .having((e) => e.rejectedField, 'rejectedField', 'contest'),
        ),
      );
    });

    test('an unknown contest is rejected as well', () async {
      await expectLater(
        client.createContestSession(
          contestAdifName: 'NOPE',
          start: DateTime.utc(2026, 9),
          end: DateTime.utc(2026, 9, 2),
          stationId: 3,
        ),
        throwsA(
          isA<WavelogValidationError>().having(
            (e) => e.isContestRejected,
            'isContestRejected',
            isTrue,
          ),
        ),
      );
    });

    test('invalid settings are a validation error', () async {
      await expectLater(
        client.createContestSession(
          contestAdifName: 'CQ-WW-SSB',
          start: DateTime.utc(2026, 9),
          end: DateTime.utc(2026, 9, 2),
          stationId: 3,
          settings: {'bogus': 1},
        ),
        throwsA(
          isA<WavelogValidationError>().having(
            (e) => e.isContestRejected,
            'isContestRejected',
            isFalse,
          ),
        ),
      );
    });

    test('a foreign station is forbidden', () async {
      await expectLater(
        client.createContestSession(
          contestAdifName: 'CQ-WW-SSB',
          start: DateTime.utc(2026, 9),
          end: DateTime.utc(2026, 9, 2),
          stationId: 99,
        ),
        throwsA(isA<WavelogForbidden>()),
      );
    });

    test('missing scope is an insufficient-scope 403', () async {
      final ro = newServer(scopes: {'qso:read', 'contest:read'});
      await ro.start();
      addTearDown(ro.stop);
      final c = clientFor(ro);
      expect(await c.listContestSessions(), isEmpty);
      await expectLater(
        c.createContestSession(
          contestAdifName: 'CQ-WW-SSB',
          start: DateTime.utc(2026, 9),
          end: DateTime.utc(2026, 9, 2),
          stationId: 3,
        ),
        throwsA(
          isA<WavelogForbidden>().having(
            (e) => e.isInsufficientScope,
            'isInsufficientScope',
            isTrue,
          ),
        ),
      );
    });

    test('deleteQsos needs qso:delete', () async {
      final s = newServer(
        scopes: {'qso:read', 'qso:write', 'contest:write', 'contest:delete'},
      );
      await s.start();
      addTearDown(s.stop);
      final c = clientFor(s);
      final session = await c.createContestSession(
        contestAdifName: 'CQ-WW-SSB',
        start: DateTime.utc(2026, 9),
        end: DateTime.utc(2026, 9, 2),
        stationId: 3,
      );
      await expectLater(
        c.deleteContestSession(session.id, deleteQsos: true),
        throwsA(isA<WavelogForbidden>()),
      );
      await c.deleteContestSession(session.id);
    });
  });

  group('ADIF pull', () {
    test('pages by since_id with lastfetchedid', () async {
      for (var i = 0; i < 5; i++) {
        await logQso('DL${i}ABC', time: '14:0$i:00');
      }
      final first = await client.fetchQsosAdif(perPage: 2);
      expect(first.exported, 2);
      expect(first.hasMore, isTrue);
      expect(first.adif, contains('<call:6>DL0ABC'));
      expect(first.adif, contains('<eoh>'));
      expect(first.adif, contains('<freq:9>14.205000'));
      expect(first.lastFetchedId, 1001);

      final second = await client.fetchQsosAdif(
        sinceId: first.lastFetchedId,
        perPage: 2,
      );
      expect(second.exported, 2);
      expect(second.adif, contains('DL2ABC'));
      expect(second.lastFetchedId, 1003);

      final third = await client.fetchQsosAdif(
        sinceId: second.lastFetchedId,
        perPage: 2,
      );
      expect(third.exported, 1);
      expect(third.hasMore, isFalse);

      final empty = await client.fetchQsosAdif(sinceId: third.lastFetchedId);
      expect(empty.exported, 0);
      expect(empty.adif, isEmpty);
      expect(empty.lastFetchedId, third.lastFetchedId);
    });

    test('carries the contest id of linked QSOs', () async {
      final a = await logQso('DL1ABC');
      await newSession(qsoIds: [a]);
      final page = await client.fetchQsosAdif();
      expect(page.adif, contains('<contest_id:9>CQ-WW-SSB'));
    });

    test('filters by station', () async {
      await logQso('DL1ABC');
      expect((await client.fetchQsosAdif(stationId: 4)).exported, 0);
      expect((await client.fetchQsosAdif(stationId: 3)).exported, 1);
    });
  });
}
