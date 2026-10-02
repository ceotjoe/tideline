import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

const _token = 'wl2_engine_token';
const _scopes = {'qso:read', 'qso:write', 'qso:delete', 'station:read'};

class Harness {
  new _(
    this.server,
    this.db,
    this.secrets,
    this.qsos,
    this.accounts,
    this.engine,
    this.accountId,
    this.stationId,
  );

  final MockWavelog server;
  final TidelineDatabase db;
  final MemorySecretStore secrets;
  final QsoRepository qsos;
  final AccountRepository accounts;
  final SyncEngine engine;
  final String accountId;
  final String stationId;
  int minute = 0;

  static Future<Harness> start({Set<String> scopes = _scopes}) async {
    final server = MockWavelog(
      tokens: {_token: MockToken(scopes: scopes)},
      stations: [
        {'id': 3, 'name': 'Home', 'callsign': 'DO1HOZ', 'active': true},
      ],
    );
    await server.start();
    addTearDown(server.stop);
    final db = await openTestDatabase();
    final secrets = MemorySecretStore();
    final machine = SyncMachine(random: Random(1));
    final qsos = QsoRepository(db, HlcClock('dev-1'), machine);
    final accounts = AccountRepository(db, secrets);
    final httpClient = http.Client();
    addTearDown(httpClient.close);
    final baseUri = server.baseUri;
    final engine = SyncEngine(
      qsos: qsos,
      accounts: accounts,
      journal: SyncJournalRepository(db),
      machine: machine,
      clientFor: (account, token) => WavelogClient(
        endpoint: WavelogEndpoint(baseUri, usesIndexPhp: true),
        token: token,
        httpClient: httpClient,
        timeout: const Duration(seconds: 5),
      ),
    );
    final accountId = await accounts.add(
      label: 'Home',
      baseUrl: server.baseUri.toString(),
      usesIndexPhp: true,
      token: _token,
      scopes: scopes,
      hasContestSessions: true,
      nowMillis: 0,
    );
    await accounts.syncStations(accountId, [
      (remoteId: 3, name: 'Home', callsign: 'DO1HOZ', grid: null, active: true),
    ], nowMillis: 0);
    final station = (await accounts.watchStations(accountId).first).single;
    return Harness._(
      server,
      db,
      secrets,
      qsos,
      accounts,
      engine,
      accountId,
      station.id,
    );
  }

  Qso qso({String call = 'DL1ABC', int? atMinute, bool withStation = true}) =>
      Qso(
        id: newUuidV4(),
        accountId: accountId,
        stationProfileId: withStation ? stationId : null,
        call: Callsign.tryParse(call)!,
        timeOn: UtcDateTime(
          DateTime.utc(
            2026,
            10,
            2,
            14,
          ).add(Duration(minutes: atMinute ?? minute++)),
        ),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('USB')!,
        freqHz: 14205000,
        rstSent: '59',
        rstRcvd: '57',
        fields: const {'NAME': 'Anna'},
      );

  Future<SyncStatus?> status(Qso q) => qsos.readStatus(q.id, accountId);
}

void main() {
  test('uploads queued QSOs and stores server ids', () async {
    final h = await Harness.start();
    final a = h.qso();
    final b = h.qso(call: 'G4XYZ');
    await h.qsos.log(a);
    await h.qsos.log(b);
    final result = await h.engine.sync(h.accountId);
    expect(result.outcome, SyncRunOutcome.completed);
    expect(result.processed, 2);
    expect(h.server.qsos, hasLength(2));
    for (final q in [a, b]) {
      final s = (await h.status(q))!;
      expect(s.state, SyncState.synced);
      expect(h.server.qsos[s.remoteQsoId]!.fields['call'], q.call.value);
    }
    expect(h.server.qsos.values.first.fields['name'], 'Anna');
  });

  test('drafts without a station stay local', () async {
    final h = await Harness.start();
    final draft = h.qso(withStation: false);
    await h.qsos.log(draft);
    await h.engine.sync(h.accountId);
    expect((await h.status(draft))!.state, SyncState.local);
    expect(h.server.qsos, isEmpty);
  });

  test(
    'server stored the QSO but answered 500 → verified, no duplicate',
    () async {
      final h = await Harness.start();
      final q = h.qso();
      await h.qsos.log(q);
      h.server.postQsoFaults.add(MockFault.storeThenServerError);
      await h.engine.sync(h.accountId);
      expect((await h.status(q))!.state, SyncState.synced);
      expect(h.server.qsos, hasLength(1));
    },
  );

  test('connection dropped after storing → verifying, then verified', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    h.server.postQsoFaults.add(MockFault.storeThenDropConnection);
    final first = await h.engine.sync(h.accountId);
    expect(first.outcome, SyncRunOutcome.offline);
    expect((await h.status(q))!.state, SyncState.verifying);

    final second = await h.engine.sync(h.accountId);
    expect(second.outcome, SyncRunOutcome.completed);
    final s = (await h.status(q))!;
    expect(s.state, SyncState.synced);
    expect(h.server.qsos.keys, [s.remoteQsoId]);
  });

  test('500 without storing → verified absent, uploaded once', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    h.server.postQsoFaults.add(MockFault.serverError);
    await h.engine.sync(h.accountId);
    // Verified absent, queued again: the next run uploads it.
    expect((await h.status(q))!.state, SyncState.queued);
    await h.engine.sync(h.accountId);
    expect((await h.status(q))!.state, SyncState.synced);
    expect(h.server.qsos, hasLength(1));
  });

  test(
    'QSO already on the server (e.g. imported there) → linked, not duplicated',
    () async {
      final h = await Harness.start();
      final q = h.qso();
      await h.qsos.log(q);
      // Same QSO entered in Wavelog's web UI meanwhile.
      h.server.postQsoFaults.add(MockFault.storeThenDropConnection);
      await h.engine.sync(h.accountId); // stores it, then drops
      final storedId = h.server.qsos.keys.single;
      await h.qsos.writeStatus(
        q.id,
        h.accountId,
        const SyncStatus(state: SyncState.queued),
      ); // pretend we never knew
      await h.engine.sync(h.accountId);
      final s = (await h.status(q))!;
      expect(s.state, SyncState.synced);
      expect(s.remoteQsoId, storedId);
      expect(h.server.qsos, hasLength(1));
    },
  );

  test('same-minute twins: the second becomes a visible conflict', () async {
    final h = await Harness.start();
    final a = h.qso(atMinute: 5);
    final twin = h.qso(atMinute: 5);
    await h.qsos.log(a);
    await h.engine.sync(h.accountId);
    await h.qsos.log(twin);
    await h.engine.sync(h.accountId);
    final s = (await h.status(twin))!;
    expect(s.state, SyncState.conflict);
    expect(s.problem, SyncProblem.sameMinuteTwin);
    expect(h.server.qsos, hasLength(1));

    // Fixing the time resolves it.
    await h.qsos.update(
      twin.copyWith(timeOn: UtcDateTime(DateTime.utc(2026, 10, 2, 14, 6))),
    );
    await h.engine.sync(h.accountId);
    expect((await h.status(twin))!.state, SyncState.synced);
    expect(h.server.qsos, hasLength(2));
  });

  test('expired token blocks waiting QSOs; a new token unblocks', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    h.server.tokens[_token] = const MockToken(scopes: _scopes, expired: true);
    final run = await h.engine.sync(h.accountId);
    expect(run.outcome, SyncRunOutcome.blocked);
    final blocked = (await h.status(q))!;
    expect(
      (blocked.state, blocked.problem),
      (SyncState.blocked, SyncProblem.tokenExpired),
    );

    h.server.tokens['wl2_new'] = const MockToken(scopes: _scopes);
    await h.accounts.replaceToken(
      h.accountId,
      token: 'wl2_new',
      scopes: _scopes,
    );
    await h.engine.sync(h.accountId);
    expect((await h.status(q))!.state, SyncState.synced);
    expect(h.server.qsos, hasLength(1));
  });

  test('patchable edits are patched on the server', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    await h.engine.sync(h.accountId);
    await h.qsos.update(q.copyWith(rstRcvd: '55', fields: {'NAME': 'Anne'}));
    final queued = (await h.status(q))!;
    expect(
      (queued.state, queued.operation),
      (SyncState.queued, SyncOperation.patch),
    );
    await h.engine.sync(h.accountId);
    final s = (await h.status(q))!;
    expect(s.state, SyncState.synced);
    expect(h.server.qsos[s.remoteQsoId]!.fields['name'], 'Anne');
    expect(h.server.qsos[s.remoteQsoId]!.fields['rst_rcvd'], '55');
  });

  test('read-only edits → conflict → replace on server', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    await h.engine.sync(h.accountId);
    final oldRemote = (await h.status(q))!.remoteQsoId;

    await h.qsos.update(q.copyWith(mode: Mode.tryParse('CW'), rstSent: '599'));
    expect((await h.status(q))!.state, SyncState.conflict);
    await h.engine.sync(h.accountId);
    expect((await h.status(q))!.state, SyncState.conflict); // waits for user

    await h.qsos.resolveConflict(q.id, replaceOnServer: true);
    await h.engine.sync(h.accountId);
    final s = (await h.status(q))!;
    expect(s.state, SyncState.synced);
    expect(s.remoteQsoId, isNot(oldRemote));
    expect(h.server.qsos.keys, [s.remoteQsoId]);
    expect(h.server.qsos[s.remoteQsoId]!.fields['mode'], 'CW');
  });

  test('read-only edits → conflict → keep the server version', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    await h.engine.sync(h.accountId);
    await h.qsos.update(q.copyWith(freqHz: 14210000));
    await h.qsos.resolveConflict(q.id, replaceOnServer: false);
    expect((await h.status(q))!.state, SyncState.synced);
    await h.engine.sync(h.accountId);
    expect(h.server.qsos.values.single.fields['freq'], 14205000);
  });

  test('deleting a synced QSO deletes it on the server', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    await h.engine.sync(h.accountId);
    await h.qsos.delete(q.id, canDeleteOnServer: true);
    await h.engine.sync(h.accountId);
    expect(h.server.qsos, isEmpty);
    expect(await h.status(q), isNull);
  });

  test(
    'without qso:delete the server copy stays and the journal says so',
    () async {
      final h = await Harness.start(
        scopes: {'qso:read', 'qso:write', 'station:read'},
      );
      final q = h.qso();
      await h.qsos.log(q);
      await h.engine.sync(h.accountId);
      await h.qsos.delete(q.id, canDeleteOnServer: false);
      await h.engine.sync(h.accountId);
      expect(h.server.qsos, hasLength(1));
      final journal = await SyncJournalRepository(h.db)
          .watch(qsoId: q.id)
          .first;
      expect(
        journal.map((e) => e.event),
        contains(JournalEvent.deletedLocallyOnly),
      );
    },
  );

  test(
    'restart recovery turns interrupted uploads into verifications',
    () async {
      final h = await Harness.start();
      final q = h.qso();
      await h.qsos.log(q);
      await h.qsos.writeStatus(
        q.id,
        h.accountId,
        const SyncStatus(state: SyncState.uploading),
      );
      await h.engine.recoverAfterRestart(h.accountId);
      expect((await h.status(q))!.state, SyncState.verifying);
      await h.engine.sync(h.accountId);
      expect((await h.status(q))!.state, SyncState.synced);
      expect(h.server.qsos, hasLength(1));
    },
  );

  test('offline: nothing changes and nothing is lost', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    await h.server.stop();
    final result = await h.engine.sync(h.accountId);
    expect(result.outcome, SyncRunOutcome.offline);
    expect((await h.status(q))!.state, SyncState.queued);
  });

  test('the journal records every step', () async {
    final h = await Harness.start();
    final q = h.qso();
    await h.qsos.log(q);
    await h.engine.sync(h.accountId);
    final events = (await SyncJournalRepository(
      h.db,
    ).watch(qsoId: q.id).first).map((e) => e.event).toList().reversed;
    expect(events, [
      JournalEvent.logged,
      JournalEvent.requestStarted,
      JournalEvent.uploaded,
    ]);
  });

  test(
    'preview counts uploads, local duplicates and the server dry run',
    () async {
      final h = await Harness.start();
      final a = h.qso(atMinute: 1);
      await h.qsos.log(a);
      await h.engine.sync(h.accountId);
      // Two new QSOs: one duplicates the synced one, one is new.
      await h.qsos.log(h.qso(atMinute: 1));
      await h.qsos.log(h.qso(atMinute: 2));
      final p = await h.engine.preview(h.accountId);
      expect(p.toUpload, 2);
      expect(p.localDuplicates, 1);
      expect(p.serverParsed, 2);
      expect(h.server.qsos, hasLength(1)); // nothing was uploaded
    },
  );
}
