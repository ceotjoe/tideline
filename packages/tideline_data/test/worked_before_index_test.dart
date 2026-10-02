import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'support/contest_fixtures.dart';
import 'support/test_database.dart';

void main() {
  late ContestHarness h;
  late WorkedBeforeRepository repo;

  setUp(() async {
    h = await ContestHarness.create(await openTestDatabase());
    repo = WorkedBeforeRepository(h.db);
  });

  Future<List<WorkedBeforeRow>> rows() => h.db.select(h.db.workedBefore).get();

  group('local index follows the write paths', () {
    test('log() indexes call, band, mode and the earliest time', () async {
      await h.qsos.log(testQso(timeOn: 5000));
      expect((await repo.lookup('acc', 'DL1ABC')).firstTime, 5000);
      await h.qsos.log(testQso(timeOn: 3000));
      await h.qsos.log(testQso(timeOn: 9000));
      final all = await rows();
      expect(all, hasLength(1));
      expect(all.single.firstTime, 3000);
      expect(all.single.source, 'local');
    });

    test('dxcc and grid are stored and not wiped by later QSOs', () async {
      await h.qsos.log(
        testQso(timeOn: 1000)
            .copyWith(fields: {'DXCC': '230', 'GRIDSQUARE': 'jo62'}),
      );
      await h.qsos.log(testQso(timeOn: 2000));
      final row = (await rows()).single;
      expect((row.dxcc, row.gridsquare), (230, 'JO62'));
    });

    test('importAll() indexes every QSO in the same transaction', () async {
      await h.qsos.importAll([
        testQso(call: 'W1AW', timeOn: 100),
        testQso(call: 'F5XYZ', timeOn: 200, band: '40m'),
      ]);
      expect((await repo.lookup('acc', 'W1AW')).worked, isTrue);
      expect((await repo.lookup('acc', 'F5XYZ')).bands, {'40m'});
    });

    test('update() adds the new slot', () async {
      final q = testQso(timeOn: 100);
      await h.qsos.log(q);
      await h.qsos.update(q.copyWith(band: Band.tryParse('40m')));
      final summary = await repo.lookup('acc', 'DL1ABC');
      expect(summary.bands, {'20m', '40m'});
    });

    test('deleting a QSO keeps the index row', () async {
      final q = testQso();
      await h.qsos.log(q);
      await h.qsos.delete(q.id, canDeleteOnServer: false);
      expect((await repo.lookup('acc', 'DL1ABC')).worked, isTrue);
    });

    test('a contest QSO is indexed like any other', () async {
      final s = await h.startSerial();
      await h.sessions.logContestQso(
        testQso(call: 'K1ABC', timeOn: 700),
        sessionId: s.id,
      );
      expect((await repo.lookup('acc', 'K1ABC')).firstTime, 700);
    });

    test('a restored backup QSO is indexed', () async {
      await h.qsos.restore(testQso(call: 'G4XYZ'), null);
      expect((await repo.lookup('acc', 'G4XYZ')).worked, isTrue);
    });

    test('a failed insert leaves the index untouched', () async {
      final q = testQso(timeOn: 5000);
      await h.qsos.log(q);
      await expectLater(
        h.qsos.log(q.copyWith(timeOn: UtcDateTime.fromMillis(1))),
        throwsA(anything),
      );
      expect((await repo.lookup('acc', 'DL1ABC')).firstTime, 5000);
    });

    test('a server row keeps its source; an older local time wins', () async {
      await repo.mergeServerAdif(
        'acc',
        '<ADIF_VER:5>3.1.4 <EOH>\n'
            '<CALL:6>DL1ABC <BAND:3>20m <MODE:2>CW <QSO_DATE:8>20990101 <EOR>',
      );
      await h.qsos.log(testQso(timeOn: 5000));
      final row = (await rows()).single;
      expect((row.source, row.firstTime), ('server', 5000));
    });
  });

  group('first build', () {
    test('ensureBuilt indexes an existing log exactly once', () async {
      await h.qsos.log(testQso(timeOn: 100));
      // A log from before the index existed.
      await h.db.delete(h.db.workedBefore).go();
      await h.db.delete(h.db.settings).go();

      expect(await repo.isBuilt('acc'), isFalse);
      expect(await repo.ensureBuilt('acc'), isTrue);
      expect(await repo.isBuilt('acc'), isTrue);
      expect((await repo.lookup('acc', 'DL1ABC')).worked, isTrue);

      // Second start: nothing runs, so a removed row stays removed.
      await h.db.delete(h.db.workedBefore).go();
      expect(await repo.ensureBuilt('acc'), isFalse);
      expect(await rows(), isEmpty);
    });

    test('the flag is per account and cleared by clear()', () async {
      await repo.rebuildLocal('acc');
      expect(await repo.isBuilt('acc'), isTrue);
      expect(await repo.isBuilt('other'), isFalse);
      await repo.clear('acc');
      expect(await repo.isBuilt('acc'), isFalse);
      await repo.rebuildLocal('acc');
      expect(await repo.isBuilt('acc'), isTrue);
    });

    test(
      'rebuildAll drops server rows and the cursor, keeps the log',
      () async {
        await h.qsos.log(testQso());
        await repo.mergeServerAdif(
          'acc',
          '<ADIF_VER:5>3.1.4 <EOH>\n'
              '<CALL:4>W1AW <BAND:3>20m <MODE:2>CW <QSO_DATE:8>20240101 <EOR>',
        );
        await repo.setLastFetchedId('acc', 500);
        await repo.rebuildAll('acc');
        expect((await repo.lookup('acc', 'W1AW')).worked, isFalse);
        expect((await repo.lookup('acc', 'DL1ABC')).worked, isTrue);
        expect(await repo.lastFetchedId('acc'), isNull);
        expect(await repo.isBuilt('acc'), isTrue);
      },
    );

    test('clear + rebuildLocal resets the pull cursor', () async {
      await h.qsos.log(testQso());
      await repo.setLastFetchedId('acc', 99);
      await repo.clear('acc');
      await repo.rebuildLocal('acc');
      expect(await repo.lastFetchedId('acc'), isNull);
      expect((await repo.lookup('acc', 'DL1ABC')).worked, isTrue);
    });
  });
}
