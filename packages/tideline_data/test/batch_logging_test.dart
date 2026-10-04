import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/contest_fixtures.dart';
import 'support/test_database.dart';

void main() {
  late ContestHarness h;
  late ActivationRepository activations;

  setUp(() async {
    h = await ContestHarness.create(await openTestDatabase());
    activations = ActivationRepository(h.db, HlcClock('dev'), h.qsos);
  });

  Future<int> count(String table) async =>
      (await h.db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
          .read<int>('n');

  group('logAll', () {
    test(
      'stores every QSO with its sync row and one journal entry each',
      () async {
        final qsos = [testQso(call: 'DL1AAA'), testQso(call: 'DL1BBB')];
        expect(await h.qsos.logAll(qsos), 2);
        expect(await count('qsos'), 2);
        expect(await count('qso_sync'), 2);
        final journal = await h.db.select(h.db.syncJournal).get();
        expect(journal.where((e) => e.event == 'logged'), hasLength(2));
      },
    );

    test('all or none: one bad QSO stores nothing', () async {
      final a = testQso(call: 'DL1AAA');
      final b = testQso(call: 'DL1BBB');
      await h.qsos.log(b);
      // The same id twice cannot be stored.
      await expectLater(h.qsos.logAll([a, b]), throwsA(anything));
      expect(await count('qsos'), 1);
      expect(await h.qsos.find(a.id), isNull);
    });

    test('the worked-before index and the directory learn from them', () async {
      await h.qsos.logAll([
        testQso(call: 'DL1AAA', fields: {'NAME': 'Anna'}),
      ]);
      expect(
        (await CallsignDirectoryRepository(h.db).lookup('DL1AAA'))!.name,
        'Anna',
      );
      expect(
        (await WorkedBeforeRepository(h.db).lookup('acc', 'DL1AAA')).worked,
        isTrue,
      );
    });

    test('an empty list is fine', () async {
      expect(await h.qsos.logAll(const []), 0);
    });
  });

  group('activation logQsos', () {
    Future<Activation> start() => activations.start(
      accountId: 'acc',
      program: ReferenceProgram.pota,
      reference: 'US-0001',
    );

    test('every QSO carries the activation and its references', () async {
      final a = await start();
      final stored = await activations.logQsos([
        testQso(call: 'DL1AAA'),
        testQso(call: 'DL1BBB'),
      ], activationId: a.id);
      expect(stored, hasLength(2));
      expect(stored.every((q) => q.activationId == a.id), isTrue);
      expect(stored.first.field('MY_POTA_REF'), 'US-0001');
      expect(await count('qsos'), 2);
    });

    test('an ended activation takes none', () async {
      final a = await start();
      await activations.end(a.id, 20000);
      await expectLater(
        activations.logQsos([testQso()], activationId: a.id),
        throwsA(isA<ActivationUnavailable>()),
      );
      expect(await count('qsos'), 0);
    });

    test('a QSO of another account stops the whole batch', () async {
      final a = await start();
      await h.db
          .into(h.db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: 'other',
              label: 'o',
              baseUrl: 'https://o.example.org',
              createdAt: 0,
            ),
          );
      await expectLater(
        activations.logQsos([
          testQso(call: 'DL1AAA'),
          testQso(call: 'DL1BBB', accountId: 'other'),
        ], activationId: a.id),
        throwsArgumentError,
      );
      expect(await count('qsos'), 0);
    });
  });
}
