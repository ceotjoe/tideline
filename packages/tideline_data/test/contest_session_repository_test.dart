import 'package:drift/drift.dart' show Value;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/contest_fixtures.dart';
import 'support/test_database.dart';

void main() {
  late ContestHarness h;

  setUp(() async {
    h = await ContestHarness.create(await openTestDatabase());
  });

  group('sessions', () {
    test('start stores settings and decides the remote state', () async {
      final s = await h.sessions.start(
        accountId: 'acc',
        definitionId: 'test-serial',
        me: me,
        accountSupportsSessions: true,
        ownExchange: {'cqZone': '14'},
        cabrillo: {'CATEGORY-OPERATOR': 'SINGLE-OP'},
      );
      expect(s.remoteState, ContestRemoteState.pending);
      expect(s.usesSerial, isTrue);
      expect(s.definitionVersion, 1);
      expect(s.ownExchange, {'cqZone': '14'});
      expect(s.cabrillo, {'CATEGORY-OPERATOR': 'SINGLE-OP'});
      expect(s.isActive, isTrue);

      final noServer = await h.startSerial(remote: false);
      expect(noServer.remoteState, ContestRemoteState.local);

      // No ADIF name: cannot exist on Wavelog.
      final noAdif = await h.sessions.start(
        accountId: 'acc',
        definitionId: 'test-zone',
        me: me,
        accountSupportsSessions: true,
      );
      expect(noAdif.remoteState, ContestRemoteState.local);
      expect(noAdif.usesSerial, isFalse);
    });

    test('rows carry origin device, HLC and revision', () async {
      final s = await h.startSerial();
      final row = await h.db.select(h.db.contestSessions).getSingle();
      expect(row.id, s.id);
      expect(row.originDeviceId, 'dev');
      expect(row.hlcCreated, row.hlcModified);
      await h.sessions.end(s.id, 9000);
      final after = await h.db.select(h.db.contestSessions).getSingle();
      expect(after.rev, 2);
      expect(after.hlcModified.compareTo(row.hlcModified), greaterThan(0));
    });

    test('unknown definition is an ArgumentError', () {
      expect(
        h.sessions.start(
          accountId: 'acc',
          definitionId: 'nope',
          me: me,
          accountSupportsSessions: true,
        ),
        throwsArgumentError,
      );
    });

    test('end, reopen, watchActive, watchAll and soft delete', () async {
      final s = await h.startSerial();
      expect((await h.sessions.watchActive('acc').first)!.id, s.id);
      await h.sessions.end(s.id, 9000);
      expect(await h.sessions.watchActive('acc').first, isNull);
      expect((await h.sessions.find(s.id))!.endedAt, 9000);
      await h.sessions.reopen(s.id);
      expect((await h.sessions.watchActive('acc').first)!.endedAt, isNull);
      expect(await h.sessions.watchAll('acc').first, hasLength(1));

      final q = await h.sessions.logContestQso(testQso(), sessionId: s.id);
      await h.sessions.delete(s.id);
      expect(await h.sessions.find(s.id), isNull);
      expect(await h.sessions.watchAll('acc').first, isEmpty);
      expect(await h.sessions.watchActive('acc').first, isNull);
      // The QSO stays.
      expect((await h.qsos.find(q.qso.id))!.qso.contestSessionId, s.id);
      expect(
        (await h.db.select(h.db.contestSessions).getSingle()).deletedAt,
        isNotNull,
      );
    });

    test('needingRemoteSync and setRemote', () async {
      final s = await h.startSerial();
      expect(await h.sessions.needingRemoteSync('acc'), hasLength(1));
      await h.sessions.setRemote(
        s.id,
        state: ContestRemoteState.created,
        remoteSessionId: const Value(42),
        remoteEndSynced: const Value(null),
      );
      // Created sessions stay in the list: they may have QSOs to link.
      expect(await h.sessions.needingRemoteSync('acc'), hasLength(1));
      await h.sessions.setRemote(s.id, state: ContestRemoteState.local);
      expect(await h.sessions.needingRemoteSync('acc'), isEmpty);
      await h.sessions.setRemote(s.id, state: ContestRemoteState.created);
      await h.sessions.end(s.id, 9000);
      await h.sessions.setRemote(s.id, remoteEndSynced: const Value(9000));
      final after = (await h.sessions.find(s.id))!;
      expect(after.remoteSessionId, 42);
      expect(after.remoteState, ContestRemoteState.created);
    });

    test('contest links are recorded and idempotent', () async {
      final s = await h.startSerial();
      final a = await h.sessions.logContestQso(testQso(), sessionId: s.id);
      await h.sessions.recordLinks(s.id, {a.qso.id: 11});
      await h.sessions.recordLinks(s.id, {a.qso.id: 11});
      expect(await h.sessions.linkedQsos(s.id), {a.qso.id: 11});
    });
  });

  group('logContestQso', () {
    test('writes serial, contest id, session and sync row', () async {
      final s = await h.startSerial();
      final r = await h.sessions.logContestQso(testQso(), sessionId: s.id);
      expect(r.serial, 1);
      final stored = (await h.qsos.find(r.qso.id))!;
      expect(stored.qso.field('STX'), '1');
      expect(stored.qso.field('CONTEST_ID'), 'TEST-SERIAL');
      expect(stored.qso.contestSessionId, s.id);
      expect(stored.status, isNotNull);
      final alloc = await h.db.select(h.db.serialAllocations).getSingle();
      expect((alloc.sessionId, alloc.serial, alloc.qsoId), (s.id, 1, r.qso.id));
      expect(await h.sessions.peekNextSerial(s.id), 2);
    });

    test('fieldsForSerial adds fields that depend on the serial', () async {
      final s = await h.startSerial();
      final r = await h.sessions.logContestQso(
        testQso(),
        sessionId: s.id,
        fieldsForSerial: (n) => {
          'STX_STRING': '59 ${n.toString().padLeft(3, '0')}',
        },
      );
      expect(r.qso.field('STX_STRING'), '59 001');
    });

    test(
      'no serial element: no allocation, CONTEST_ID only when named',
      () async {
        final s = await h.sessions.start(
          accountId: 'acc',
          definitionId: 'test-zone',
          me: me,
          accountSupportsSessions: false,
        );
        final r = await h.sessions.logContestQso(testQso(), sessionId: s.id);
        expect(r.serial, isNull);
        expect(r.qso.field('STX'), isNull);
        expect(r.qso.field('CONTEST_ID'), isNull);
        expect(await h.db.select(h.db.serialAllocations).get(), isEmpty);
      },
    );

    test(
      '50 parallel calls give serials 1..50 without gaps or repeats',
      () async {
        final s = await h.startSerial();
        final results = await Future.wait([
          for (var i = 0; i < 50; i++)
            h.sessions.logContestQso(testQso(), sessionId: s.id),
        ]);
        final serials = results.map((r) => r.serial!).toList()..sort();
        expect(serials, [for (var i = 1; i <= 50; i++) i]);
        expect((await h.db.select(h.db.serialAllocations).get()).length, 50);
        expect(await h.sessions.watchSessionQsos(s.id).first, hasLength(50));
      },
    );

    test('serials are per session', () async {
      final a = await h.startSerial();
      final b = await h.startSerial();
      await h.sessions.logContestQso(testQso(), sessionId: a.id);
      await h.sessions.logContestQso(testQso(), sessionId: a.id);
      final r = await h.sessions.logContestQso(testQso(), sessionId: b.id);
      expect(r.serial, 1);
    });

    test(
      'a deleted QSO keeps its serial; the next QSO gets the next one',
      () async {
        final s = await h.startSerial();
        await h.sessions.logContestQso(testQso(), sessionId: s.id);
        final last = await h.sessions.logContestQso(testQso(), sessionId: s.id);
        expect(last.serial, 2);
        await h.qsos.delete(last.qso.id, canDeleteOnServer: false);
        final alloc = await (h.db.select(
          h.db.serialAllocations,
        )..where((a) => a.serial.equals(2))).getSingle();
        expect(alloc.qsoId, isNull);
        expect(await h.sessions.peekNextSerial(s.id), 3);
        final next = await h.sessions.logContestQso(testQso(), sessionId: s.id);
        expect(next.serial, 3);
        expect(await h.sessions.watchSessionQsos(s.id).first, hasLength(2));
      },
    );

    test('editing a QSO keeps its serial', () async {
      final s = await h.startSerial();
      final r = await h.sessions.logContestQso(testQso(), sessionId: s.id);
      final stored = (await h.qsos.find(r.qso.id))!.qso;
      await h.qsos.update(
        stored.copyWith(
          fields: {...stored.fields, 'STX': '99', 'COMMENT': 'edited'},
        ),
      );
      final after = (await h.qsos.find(r.qso.id))!.qso;
      expect(after.field('STX'), '1');
      expect(after.field('COMMENT'), 'edited');
    });

    test('rejects unknown/deleted sessions and other accounts', () async {
      final s = await h.startSerial();
      expect(
        h.sessions.logContestQso(testQso(), sessionId: 'nope'),
        throwsStateError,
      );
      await h.db
          .into(h.db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'other',
              label: 'Other',
              baseUrl: 'https://x.example.org',
              createdAt: 0,
            ),
          );
      final foreign = Qso(
        id: 'f',
        accountId: 'other',
        call: testQso().call,
        timeOn: UtcDateTime.fromMillis(1),
        band: testQso().band,
        mode: testQso().mode,
      );
      expect(
        h.sessions.logContestQso(foreign, sessionId: s.id),
        throwsArgumentError,
      );
      // Nothing leaked from the failed calls.
      expect(await h.db.select(h.db.qsos).get(), isEmpty);
      expect(await h.sessions.peekNextSerial(s.id), 1);
    });

    test(
      'watchSessionQsos is ordered by time and excludes deleted QSOs',
      () async {
        final s = await h.startSerial();
        final late = await h.sessions.logContestQso(
          testQso(timeOn: 3000000),
          sessionId: s.id,
        );
        await h.sessions.logContestQso(
          testQso(timeOn: 2000000),
          sessionId: s.id,
        );
        final gone = await h.sessions.logContestQso(
          testQso(timeOn: 2500000),
          sessionId: s.id,
        );
        await h.qsos.delete(gone.qso.id, canDeleteOnServer: false);
        final list = await h.sessions.watchSessionQsos(s.id).first;
        expect(list.map((q) => q.timeOn.millis), [2000000, 3000000]);
        expect(list.last.id, late.qso.id);
        expect(await h.sessions.watchNextSerial(s.id).first, 4);
      },
    );
  });
}
