import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart';

import 'support/memory_secret_store.dart';
import 'support/test_database.dart';

const _token = 'wl2_evict_token';
const _scopes = {'qso:read', 'qso:write', 'qso:delete', 'station:read'};

class _H {
  new _(
    this.server,
    this.db,
    this.qsos,
    this.accounts,
    this.engine,
    this.eviction,
    this.service,
    this.accountId,
    this.stationId,
  );

  final MockWavelog server;
  final TidelineDatabase db;
  final QsoRepository qsos;
  final AccountRepository accounts;
  final SyncEngine engine;
  final QsoEvictionRepository eviction;
  final QsoEvictionService service;
  final String accountId;
  final String stationId;
  int minute = 0;

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
    // Read once: the address is gone when a test stops the server.
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
      accounts,
      engine,
      eviction,
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

  Qso qso({String call = 'DL1ABC', int? day, Map<String, String>? fields}) =>
      Qso(
        id: newUuidV4(),
        accountId: accountId,
        stationProfileId: stationId,
        call: Callsign.tryParse(call)!,
        timeOn: UtcDateTime(
          DateTime.utc(2026, 1, day ?? 2, 14).add(Duration(minutes: minute++)),
        ),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('USB')!,
        freqHz: 14205000,
        rstSent: '59',
        rstRcvd: '57',
        fields: fields ?? const {'NAME': 'Anna'},
      );

  /// Logs a QSO and syncs it, so it is genuinely on the server.
  Future<Qso> synced({String call = 'DL1ABC', int? day}) async {
    final q = qso(call: call, day: day);
    await qsos.log(q);
    await engine.sync(accountId);
    return q;
  }

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
          .read<int>('n');
}

void main() {
  late _H h;

  setUp(() async => h = await _H.start());

  group('what may be removed', () {
    test('a synced, unchanged QSO may', () async {
      final q = await h.synced();
      final c = await h.eviction.candidates(h.accountId);
      expect(c.eligible.map((i) => i.qso.id), [q.id]);
      expect(c.blockedCount, 0);
    });

    test('a QSO still waiting to upload may not', () async {
      await h.qsos.log(h.qso());
      final c = await h.eviction.candidates(h.accountId);
      expect(c.eligible, isEmpty);
      expect(c.blocked[EvictionBlock.notSynced], 1);
    });

    test('a QSO edited after the sync may not', () async {
      final q = await h.synced();
      await h.qsos.update(q.copyWith(fields: {'NAME': 'Annie'}));
      final c = await h.eviction.candidates(h.accountId);
      expect(c.eligible, isEmpty);
      expect(
        c.blocked.keys.single,
        anyOf(EvictionBlock.changedSinceSync, EvictionBlock.notSynced),
      );
    });

    test('a QSO whose edit was synced again may', () async {
      final q = await h.synced();
      await h.qsos.update(q.copyWith(fields: {'NAME': 'Annie'}));
      await h.engine.sync(h.accountId);
      final c = await h.eviction.candidates(h.accountId);
      expect(c.eligible.map((i) => i.qso.id), [q.id]);
    });

    test('a QSO of an activation or a contest may not', () async {
      final a = await h.synced(call: 'DL1AAA');
      final b = await h.synced(call: 'DL1BBB');
      await h.db.customStatement(
        'INSERT INTO activations (id, account_id, program, reference, '
        'started_at, origin_device_id, hlc_created, hlc_modified) '
        "VALUES ('act', '${h.accountId}', 'pota', 'DL-0001', 1, 'dev', "
        "'h', 'h')",
      );
      await h.db.customStatement(
        "UPDATE qsos SET activation_id = 'act' WHERE id = '${a.id}'",
      );
      await h.db.customStatement(
        'INSERT INTO contest_definitions (id, name, version, definition, '
        "builtin) VALUES ('c', 'C', 1, '{}', 0)",
      );
      await h.db.customStatement(
        'INSERT INTO contest_sessions (id, definition_id, account_id, '
        'started_at, origin_device_id, hlc_created, hlc_modified) '
        "VALUES ('s', 'c', '${h.accountId}', 1, 'dev', 'h', 'h')",
      );
      await h.db.customStatement(
        "UPDATE qsos SET contest_session_id = 's' WHERE id = '${b.id}'",
      );
      final c = await h.eviction.candidates(h.accountId);
      expect(c.eligible, isEmpty);
      expect(c.blocked, {
        EvictionBlock.inActivation: 1,
        EvictionBlock.inContest: 1,
      });
    });

    test('a deleted QSO is not in scope', () async {
      final q = await h.synced();
      await h.qsos.delete(q.id, canDeleteOnServer: false);
      final c = await h.eviction.candidates(h.accountId);
      expect(c.eligible, isEmpty);
      expect(c.blockedCount, 0);
    });

    test('the scope is by age and/or by id', () async {
      final old = await h.synced(call: 'DL1OLD', day: 2);
      final young = await h.synced(call: 'DL1NEW', day: 20);
      final cutoff = DateTime.utc(2026, 1, 10).millisecondsSinceEpoch;
      expect(
        (await h.eviction.candidates(
          h.accountId,
          olderThanMillis: cutoff,
        )).eligible.map((i) => i.qso.id),
        [old.id],
      );
      expect(
        (await h.eviction.candidates(
          h.accountId,
          ids: {young.id},
        )).eligible.map((i) => i.qso.id),
        [young.id],
      );
      expect(
        (await h.eviction.candidates(
          h.accountId,
          olderThanMillis: cutoff,
          ids: {young.id},
        )).eligible,
        isEmpty,
      );
    });
  });

  group('asking Wavelog', () {
    test('QSOs the server has are confirmed', () async {
      final a = await h.synced(call: 'DL1AAA');
      final b = await h.synced(call: 'DL1BBB');
      final plan = await h.service.plan(h.account);
      expect(plan.confirmed.map((i) => i.qso.id).toSet(), {a.id, b.id});
      expect(plan.missingOnServer, isEmpty);
    });

    test('a QSO deleted on the server is not confirmed', () async {
      final a = await h.synced(call: 'DL1AAA');
      final b = await h.synced(call: 'DL1BBB');
      final remoteId = (await h.qsos.readStatus(
        b.id,
        h.accountId,
      ))!.remoteQsoId;
      h.server.qsos.remove(remoteId);
      final plan = await h.service.plan(h.account);
      expect(plan.confirmed.map((i) => i.qso.id), [a.id]);
      expect(plan.missingOnServer.map((i) => i.qso.id), [b.id]);
    });

    test('a QSO the server has under another call is not confirmed', () async {
      final a = await h.synced(call: 'DL1AAA');
      final remoteId = (await h.qsos.readStatus(
        a.id,
        h.accountId,
      ))!.remoteQsoId;
      h.server.qsos[remoteId]!.fields['call'] = 'G4XYZ';
      final plan = await h.service.plan(h.account);
      expect(plan.confirmed, isEmpty);
      expect(plan.missingOnServer, hasLength(1));
    });

    test('nothing to ask when nothing is eligible', () async {
      await h.qsos.log(h.qso());
      final account = h.account;
      await h.server.stop();
      final plan = await h.service.plan(account);
      expect(plan.confirmed, isEmpty);
      expect(plan.blocked[EvictionBlock.notSynced], 1);
    });

    test('no answer from the server: nothing is confirmed', () async {
      await h.synced();
      final account = h.account;
      await h.server.stop();
      await expectLater(
        h.service.plan(account),
        throwsA(
          isA<EvictionCheckFailed>().having(
            (e) => e.problem,
            'problem',
            EvictionCheckProblem.offline,
          ),
        ),
      );
    });

    test('a revoked token is reported', () async {
      await h.synced();
      h.server.tokens.remove(_token);
      await expectLater(
        h.service.plan(h.account),
        throwsA(
          isA<EvictionCheckFailed>().having(
            (e) => e.problem,
            'problem',
            EvictionCheckProblem.unauthorized,
          ),
        ),
      );
    });
  });

  group('removing', () {
    test(
      'the local copy goes, Wavelog keeps the QSO, a record stays',
      () async {
        final q = await h.synced();
        final remoteId = (await h.qsos.readStatus(
          q.id,
          h.accountId,
        ))!.remoteQsoId!;
        final plan = await h.service.plan(h.account);
        expect(await h.service.carryOut(plan), 1);

        expect(await h.qsos.find(q.id), isNull);
        expect(await h.count('qsos'), 0);
        expect(await h.count('qso_sync'), 0);
        expect(h.server.qsos.keys, contains(remoteId)); // never deleted there
        final record = (await h.db.select(h.db.evictedQsos).get()).single;
        expect(
          (
            record.qsoId,
            record.accountId,
            record.remoteQsoId,
            record.evictedAt,
          ),
          (q.id, h.accountId, remoteId, 777),
        );
        expect(await h.eviction.watchEvictedCount(h.accountId).first, 1);
      },
    );

    test(
      'it is not sent to Wavelog, and sync does not bring it back',
      () async {
        final q = await h.synced();
        final before = Map.of(h.server.qsos);
        await h.service.carryOut(await h.service.plan(h.account));
        final result = await h.engine.sync(h.accountId);
        expect(result.outcome, SyncRunOutcome.completed);
        expect(h.server.qsos.keys.toSet(), before.keys.toSet());
        expect(await h.qsos.find(q.id), isNull);
        expect(await h.count('qsos'), 0);
      },
    );

    test(
      'what the history learned stays, and survives a local rebuild',
      () async {
        await h.synced(call: 'EA8/DL1ABC/P');
        await h.service.carryOut(await h.service.plan(h.account));
        final worked = WorkedBeforeRepository(h.db);
        expect(
          (await worked.lookup(h.accountId, 'EA8/DL1ABC/P')).worked,
          isTrue,
        );
        expect(
          (await CallsignDirectoryRepository(h.db).lookup('DL1ABC'))!.name,
          'Anna',
        );
        // A rebuild of the local part used to drop what has no QSO any more.
        await worked.rebuildLocal(h.accountId);
        expect(
          (await worked.lookup(h.accountId, 'EA8/DL1ABC/P')).worked,
          isTrue,
        );
      },
    );

    test('a removed QSO is recognised later by its fingerprint only', () async {
      final q = await h.synced();
      await h.service.carryOut(await h.service.plan(h.account));
      final hashes = await h.eviction.evictedDupeHashes(h.accountId);
      expect(hashes, {QsoEvictionRepository.dupeHash(q)});
      expect(hashes.single, matches(RegExp(r'^[0-9a-f]{64}$')));
      // The record holds no callsign.
      final record = (await h.db.select(h.db.evictedQsos).get()).single;
      expect('$record', isNot(contains('DL1ABC')));
      // Another QSO, or the same one on another station, differs.
      expect(QsoEvictionRepository.dupeHash(h.qso()), isNot(hashes.single));
      expect(
        QsoEvictionRepository.dupeHash(q.copyWith(stationProfileId: 'other')),
        isNot(hashes.single),
      );
    });

    test('the journal says how many were removed', () async {
      await h.synced(call: 'DL1AAA');
      await h.synced(call: 'DL1BBB');
      await h.service.carryOut(await h.service.plan(h.account));
      final entries = await h.db.select(h.db.syncJournal).get();
      final evicted = entries.where((e) => e.event == 'evictedLocally');
      expect(evicted, hasLength(1));
      expect(evicted.single.detail, contains('"count":2'));
    });

    test('a QSO edited after the plan stays', () async {
      final a = await h.synced(call: 'DL1AAA');
      final b = await h.synced(call: 'DL1BBB');
      final plan = await h.service.plan(h.account);
      await h.qsos.update(b.copyWith(fields: {'NAME': 'Bea'}));
      expect(await h.service.carryOut(plan), 1);
      expect(await h.qsos.find(a.id), isNull);
      expect(await h.qsos.find(b.id), isNotNull);
    });

    test('removing again, or nothing, removes nothing', () async {
      await h.synced();
      final plan = await h.service.plan(h.account);
      expect(await h.service.carryOut(plan), 1);
      expect(await h.service.carryOut(plan), 0);
      expect(await h.eviction.evict(h.accountId, const []), 0);
    });

    test('a large removal works in chunks', () async {
      final ids = <String>[];
      for (var i = 0; i < 3; i++) {
        ids.add((await h.synced(call: 'DL${i}ABC')).id);
      }
      // More ids than one chunk, most of them unknown: they are ignored.
      final many = [...ids, for (var i = 0; i < 1200; i++) 'unknown-$i'];
      expect(await h.eviction.evict(h.accountId, many), 3);
    });

    test('removing the account removes its records too', () async {
      await h.synced();
      await h.service.carryOut(await h.service.plan(h.account));
      await h.accounts.remove(h.accountId);
      expect(await h.count('evicted_qsos'), 0);
    });
  });
}
