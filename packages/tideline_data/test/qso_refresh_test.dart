import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

const _token = 'wl2_refresh_token';
const _scopes = {'qso:read', 'qso:write', 'qso:delete', 'station:read'};

class _H {
  new _(
    this.server,
    this.db,
    this.qsos,
    this.engine,
    this.eviction,
    this.refresh,
    this.evictionService,
    this.accountId,
    this.stationId,
  );

  final MockWavelog server;
  final TidelineDatabase db;
  final QsoRepository qsos;
  final SyncEngine engine;
  final QsoEvictionRepository eviction;
  final QsoRefreshService refresh;
  final QsoEvictionService evictionService;
  final String accountId;
  final String stationId;

  static Future<_H> start() async {
    final server = MockWavelog(
      tokens: {_token: const MockToken(scopes: _scopes)},
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
    final httpClient = http.Client();
    addTearDown(httpClient.close);
    final baseUri = server.baseUri;
    WavelogClient clientFor(Account account, String token) => WavelogClient(
      endpoint: WavelogEndpoint(baseUri, usesIndexPhp: true),
      token: token,
      httpClient: httpClient,
      timeout: const Duration(seconds: 5),
    );
    final journal = SyncJournalRepository(db);
    final engine = SyncEngine(
      qsos: qsos,
      accounts: accounts,
      journal: journal,
      machine: machine,
      clientFor: clientFor,
    );
    final accountId = await accounts.add(
      label: 'Home',
      baseUrl: server.baseUri.toString(),
      usesIndexPhp: true,
      token: _token,
      scopes: _scopes,
      hasContestSessions: true,
      nowMillis: 0,
    );
    await accounts.syncStations(accountId, [
      (remoteId: 3, name: 'Home', callsign: 'DO1HOZ', grid: null, active: true),
    ], nowMillis: 0);
    final station = (await accounts.watchStations(accountId).first).single;
    final eviction = QsoEvictionRepository(db, journal, nowMillis: () => 777);
    return _H._(
      server,
      db,
      qsos,
      engine,
      eviction,
      QsoRefreshService(qsos: qsos, accounts: accounts, clientFor: clientFor),
      QsoEvictionService(
        eviction: eviction,
        accounts: accounts,
        clientFor: clientFor,
      ),
      accountId,
      station.id,
    );
  }

  Account get account => Account(
    id: accountId,
    label: 'Home',
    baseUrl: server.baseUri.toString(),
    usesIndexPhp: true,
    allowHttpLan: false,
    scopes: _scopes,
    hasContestSessions: true,
  );

  /// Logs a QSO at 2026-01-02 14:00 UTC and syncs it.
  Future<Qso> synced({String call = 'DL1ABC'}) async {
    final q = Qso(
      id: newUuidV4(),
      accountId: accountId,
      stationProfileId: stationId,
      call: Callsign.tryParse(call)!,
      timeOn: UtcDateTime(DateTime.utc(2026, 1, 2, 14)),
      band: Band.tryParse('20m')!,
      mode: Mode.tryParse('USB')!,
      freqHz: 14205000,
      rstSent: '59',
      rstRcvd: '57',
      fields: const {'NAME': 'Anna'},
    );
    await qsos.log(q);
    await engine.sync(accountId);
    return q;
  }

  Future<MockQso> onServer(Qso q) async {
    final status = (await qsos.readStatus(q.id, accountId))!;
    return server.qsos[status.remoteQsoId]!;
  }
}

void main() {
  late _H h;

  setUp(() async => h = await _H.start());

  test(
    'a time changed in Wavelog is taken over, then it can be removed',
    () async {
      final q = await h.synced();
      final remote = await h.onServer(q);
      remote.fields['qso_date'] = '2026-01-02 14:37:00';
      remote.fields['name'] = 'Annie';

      // The removal check alone refuses it: the key differs.
      final before = await h.evictionService.plan(h.account);
      expect(before.confirmed, isEmpty);
      expect(before.missingOnServer, hasLength(1));

      final revBefore = await h.qsos.revOf(q.id);
      final outcome = await h.refresh.refresh(h.account, q.id);
      expect(outcome, RefreshOutcome.refreshed);

      final after = (await h.qsos.find(q.id))!;
      expect(after.qso.timeOn.value, DateTime.utc(2026, 1, 2, 14, 37));
      expect(after.qso.field('NAME'), 'Annie');
      expect(after.qso.id, q.id);
      expect(after.status!.state, SyncState.synced);
      expect(after.status!.remoteQsoId, isNotNull);
      expect(await h.qsos.revOf(q.id), revBefore! + 1);

      final journal = await SyncJournalRepository(h.db)
          .watch(qsoId: q.id)
          .first;
      expect(
        journal.map((e) => e.event),
        contains(JournalEvent.refreshedFromServer),
      );

      // Nothing is uploaded again.
      final posts = h.server.qsos.length;
      await h.engine.sync(h.accountId);
      expect(h.server.qsos, hasLength(posts));
      expect((await h.onServer(q)).fields['qso_date'], '2026-01-02 14:37:00');

      final plan = await h.evictionService.plan(h.account);
      expect(plan.confirmed.map((i) => i.qso.id), [q.id]);
    },
  );

  test('a QSO deleted in Wavelog is reported, nothing changes', () async {
    final q = await h.synced();
    final status = (await h.qsos.readStatus(q.id, h.accountId))!;
    h.server.qsos.remove(status.remoteQsoId);
    final rev = await h.qsos.revOf(q.id);

    expect(
      await h.refresh.refresh(h.account, q.id),
      RefreshOutcome.goneOnServer,
    );
    expect(await h.qsos.revOf(q.id), rev);
    expect((await h.qsos.find(q.id))!.qso.timeOn, q.timeOn);
  });

  test('a later QSO is not mistaken for the missing one', () async {
    final a = await h.synced(call: 'DL1AAA');
    await h.synced(call: 'DL1BBB');
    final status = (await h.qsos.readStatus(a.id, h.accountId))!;
    h.server.qsos.remove(status.remoteQsoId);

    expect(
      await h.refresh.refresh(h.account, a.id),
      RefreshOutcome.goneOnServer,
    );
    expect((await h.qsos.find(a.id))!.qso.call.value, 'DL1AAA');
  });

  test('a QSO with an edit waiting to be sent is not touched', () async {
    final q = await h.synced();
    await h.qsos.update(q.copyWith(fields: {'NAME': 'Local'}));
    (await h.onServer(q)).fields['name'] = 'Remote';

    expect(
      await h.refresh.refresh(h.account, q.id),
      RefreshOutcome.notEligible,
    );
    expect((await h.qsos.find(q.id))!.qso.field('NAME'), 'Local');
  });

  test('a QSO edited while the server was asked is not touched', () async {
    final q = await h.synced();
    final stale = await h.qsos.revOf(q.id);
    await h.qsos.update(q.copyWith(fields: {'NAME': 'Local'}));
    await h.engine.sync(h.accountId); // synced again, but a newer revision

    final server = q.copyWith(fields: {'NAME': 'Remote'});
    expect(
      await h.qsos.applyServerVersion(server, expectedRev: stale!),
      isFalse,
    );
    expect((await h.qsos.find(q.id))!.qso.field('NAME'), 'Local');
  });

  test('a QSO that never synced is not eligible', () async {
    final q = Qso(
      id: newUuidV4(),
      accountId: h.accountId,
      stationProfileId: h.stationId,
      call: Callsign.tryParse('DL1ABC')!,
      timeOn: UtcDateTime(DateTime.utc(2026, 1, 3, 9)),
      band: Band.tryParse('40m')!,
      mode: Mode.tryParse('CW')!,
    );
    await h.qsos.log(q);
    expect(
      await h.refresh.refresh(h.account, q.id),
      RefreshOutcome.notEligible,
    );
  });

  test('no answer from the server: nothing changes', () async {
    final q = await h.synced();
    final account = h.account;
    await h.server.stop();
    await expectLater(
      h.refresh.refresh(account, q.id),
      throwsA(
        isA<EvictionCheckFailed>().having(
          (e) => e.problem,
          'problem',
          EvictionCheckProblem.offline,
        ),
      ),
    );
    expect((await h.qsos.find(q.id))!.qso.timeOn, q.timeOn);
  });
}
