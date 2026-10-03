import 'package:drift/drift.dart' show Value;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/contest_fixtures.dart';
import 'support/test_database.dart';

void main() {
  late ContestHarness h;
  late ActivationRepository repo;
  var clock = 10000;

  setUp(() async {
    clock = 10000;
    h = await ContestHarness.create(await openTestDatabase());
    repo = ActivationRepository(
      h.db,
      HlcClock('dev'),
      h.qsos,
      nowMillis: () => clock,
    );
  });

  Future<Activation> startPota([String ref = 'US-0001', String? grid]) =>
      repo.start(
        accountId: 'acc',
        program: ReferenceProgram.pota,
        reference: ref,
        myGridsquare: grid,
      );

  group('lifecycle', () {
    test(
      'start normalises the reference and grid and stores the row',
      () async {
        final a = await startPota(' us-0001 ', 'fn54vh');
        expect(a.reference, 'US-0001');
        expect(a.myGridsquare, 'FN54vh');
        expect(a.program, ReferenceProgram.pota);
        expect(a.startedAt, 10000);
        expect(a.isActive, isTrue);
        final row = await h.db.select(h.db.activations).getSingle();
        expect(row.originDeviceId, 'dev');
        expect(row.hlcCreated, row.hlcModified);
        expect(row.program, 'POTA');
      },
    );

    test('a malformed reference or grid is an ArgumentError', () async {
      expect(() => startPota('nonsense'), throwsArgumentError);
      expect(
        () => repo.start(
          accountId: 'acc',
          program: ReferenceProgram.sota,
          reference: 'US-0001',
        ),
        throwsArgumentError,
      );
      expect(() => startPota('US-0001', 'ZZ99'), throwsArgumentError);
      expect(await h.db.select(h.db.activations).get(), isEmpty);
    });

    test(
      'only one activation is active; the old one ends at the new start',
      () async {
        final first = await startPota();
        clock = 20000;
        final second = await repo.start(
          accountId: 'acc',
          program: ReferenceProgram.sota,
          reference: 'G/LD-001',
        );
        expect((await repo.find(first.id))!.endedAt, 20000);
        expect((await repo.find(second.id))!.isActive, isTrue);
        final active = await repo.watchActive('acc').first;
        expect(active!.id, second.id);

        // Reopening the first one ends the second.
        clock = 30000;
        await repo.reopen(first.id);
        expect((await repo.find(first.id))!.isActive, isTrue);
        expect((await repo.find(second.id))!.endedAt, 30000);
      },
    );

    test('end, delete and revision bump', () async {
      final a = await startPota();
      await repo.end(a.id, 15000);
      expect((await repo.find(a.id))!.endedAt, 15000);
      final row = await h.db.select(h.db.activations).getSingle();
      expect(row.rev, 2);
      await repo.delete(a.id);
      expect(await repo.find(a.id), isNull);
      expect(await repo.watchAll('acc').first, isEmpty);
      expect(await repo.watchActive('acc').first, isNull);
      expect(() => repo.end('missing', 1), throwsStateError);
    });

    test('other accounts are not affected', () async {
      await h.db
          .into(h.db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'other',
              label: 'Other',
              baseUrl: 'https://o.example.org',
              createdAt: 0,
            ),
          );
      final mine = await startPota();
      await repo.start(
        accountId: 'other',
        program: ReferenceProgram.pota,
        reference: 'DE-0001',
      );
      expect((await repo.find(mine.id))!.isActive, isTrue);
    });
  });

  group('logging', () {
    test('the QSO carries the activation and the own reference', () async {
      final a = await repo.start(
        accountId: 'acc',
        program: ReferenceProgram.sota,
        reference: 'DL/WS-001',
        myGridsquare: 'JN57tp',
      );
      final qso = testQso();
      final stored = await repo.logQso(qso, activationId: a.id);
      expect(stored.activationId, a.id);
      expect(stored.fields['MY_SOTA_REF'], 'DL/WS-001');
      expect(stored.fields['MY_GRIDSQUARE'], 'JN57tp');

      final read = (await h.qsos.find(qso.id))!;
      expect(read.qso.activationId, a.id);
      expect(read.qso.fields['MY_SOTA_REF'], 'DL/WS-001');
      expect(read.status, isNotNull, reason: 'queued for sync like any QSO');
      expect((await repo.watchQsos(a.id).first).single.id, qso.id);
    });

    test('values typed on the QSO win over the activation', () async {
      final a = await startPota('US-0001', 'FN54vh');
      final qso = Qso(
        id: 'own',
        accountId: 'acc',
        call: Callsign.tryParse('K1ABC')!,
        timeOn: UtcDateTime.fromMillis(1000000),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('SSB')!,
        fields: const {'MY_GRIDSQUARE': 'FN55aa', 'POTA_REF': 'US-0002'},
      );
      final stored = await repo.logQso(qso, activationId: a.id);
      expect(stored.fields['MY_GRIDSQUARE'], 'FN55aa');
      expect(stored.fields['POTA_REF'], 'US-0002', reason: 'park to park');
      expect(stored.fields['MY_POTA_REF'], 'US-0001');
    });

    test(
      'unknown, ended and foreign-account activations are refused',
      () async {
        expect(
          () => repo.logQso(testQso(), activationId: 'nope'),
          throwsA(
            isA<ActivationUnavailable>().having((e) => e.ended, 'ended', false),
          ),
        );
        final a = await startPota();
        await repo.end(a.id, 11000);
        expect(
          () => repo.logQso(testQso(), activationId: a.id),
          throwsA(
            isA<ActivationUnavailable>().having((e) => e.ended, 'ended', true),
          ),
        );
        await repo.reopen(a.id);
        final foreign = Qso(
          id: 'f',
          accountId: 'other',
          call: Callsign.tryParse('K1ABC')!,
          timeOn: UtcDateTime.fromMillis(1),
          band: Band.tryParse('20m')!,
          mode: Mode.tryParse('CW')!,
        );
        expect(
          () => repo.logQso(foreign, activationId: a.id),
          throwsArgumentError,
        );
      },
    );
  });

  group('progress', () {
    test('counts per UTC day, ignores deleted QSOs, follows the log', () async {
      final a = await startPota();
      final events = <int>[];
      final sub = repo.watchProgress(a.id).listen((p) => events.add(p.counted));

      Future<void> until(bool Function() done) async {
        for (var i = 0; i < 300 && !done(); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      }

      await until(() => events.isNotEmpty);
      expect(events.last, 0);

      final day1 = DateTime.utc(2026, 10, 3, 10).millisecondsSinceEpoch;
      final ids = <String>[];
      for (var i = 0; i < 10; i++) {
        final q = testQso(call: 'DL${i}ABC', timeOn: day1 + i * 60000);
        ids.add(q.id);
        await repo.logQso(q, activationId: a.id);
      }
      await until(() => events.last == 10);
      var p = await repo.progress(a.id);
      expect(p.isValid, isTrue);
      expect(p.counted, 10);

      await h.qsos.delete(ids.first, canDeleteOnServer: false);
      await until(() => events.last == 9);
      p = await repo.progress(a.id);
      expect(p.counted, 9);
      expect(p.isValid, isFalse);
      expect(p.remaining, 1);
      await sub.cancel();
    });

    test('a QSO of another activation does not count', () async {
      final a = await startPota();
      await repo.logQso(testQso(call: 'DL1AAA'), activationId: a.id);
      await h.qsos.log(testQso(call: 'DL1BBB'));
      expect((await repo.progress(a.id)).total, 1);
    });

    test('stored rules change the result and reset to the defaults', () async {
      final a = await startPota();
      expect((await repo.rulesFor(ReferenceProgram.pota)).minQsos, 10);
      for (var i = 0; i < 3; i++) {
        await repo.logQso(testQso(call: 'DL${i}ZZZ'), activationId: a.id);
      }
      expect((await repo.progress(a.id)).isValid, isFalse);

      await repo.saveRules(
        const ActivationRules(
          program: ReferenceProgram.pota,
          minQsos: 3,
          window: ActivationWindow.session,
        ),
      );
      final rules = await repo.rulesFor(ReferenceProgram.pota);
      expect(rules.minQsos, 3);
      expect(rules.version, 1);
      expect((await repo.progress(a.id)).isValid, isTrue);

      await repo.saveRules(rules);
      expect((await repo.rulesFor(ReferenceProgram.pota)).version, 2);

      await repo.resetRules(ReferenceProgram.pota);
      expect((await repo.rulesFor(ReferenceProgram.pota)).minQsos, 10);
      expect((await repo.progress(a.id)).isValid, isFalse);
    });

    test('corrupt stored rules fall back to the defaults', () async {
      for (final bad in [
        'not json',
        '{"minQsos": -4, "window": "utcDay"}',
        '[]',
      ]) {
        await h.db
            .into(h.db.programRules)
            .insertOnConflictUpdate(
              ProgramRulesCompanion.insert(
                program: 'SOTA',
                version: 9,
                rules: bad,
              ),
            );
        expect(
          (await repo.rulesFor(ReferenceProgram.sota)).minQsos,
          4,
          reason: bad,
        );
      }
    });

    test('rules change re-emits progress', () async {
      final a = await startPota();
      for (var i = 0; i < 3; i++) {
        await repo.logQso(testQso(call: 'DL${i}ZZZ'), activationId: a.id);
      }
      final valid = <bool>[];
      final sub = repo.watchProgress(a.id).listen((p) => valid.add(p.isValid));
      Future<void> until(bool Function() done) async {
        for (var i = 0; i < 300 && !done(); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      }

      await until(() => valid.isNotEmpty);
      expect(valid.last, isFalse);
      await repo.saveRules(
        const ActivationRules(
          program: ReferenceProgram.pota,
          minQsos: 2,
          window: ActivationWindow.session,
        ),
      );
      await until(() => valid.last);
      expect(valid.last, isTrue);
      await sub.cancel();
    });
  });

  test('rows of an unknown programme are left out of the lists', () async {
    final a = await startPota();
    await h.db
        .update(h.db.activations)
        .write(const ActivationsCompanion(program: Value('IOTA')));
    expect(await repo.find(a.id), isNull);
    expect(await repo.watchAll('acc').first, isEmpty);
    expect(await repo.watchActive('acc').first, isNull);
  });
}
