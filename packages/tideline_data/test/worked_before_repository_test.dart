import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:test/test.dart';
import 'package:tideline_data/tideline_data.dart';

import 'support/contest_fixtures.dart';
import 'support/test_database.dart';

String _field(MapEntry<String, String> e) =>
    '<${e.key}:${e.value.length}>${e.value}';

String _adif(List<Map<String, String>> records) => [
  '<ADIF_VER:5>3.1.4 <EOH>',
  for (final r in records) '${r.entries.map(_field).join(' ')} <EOR>',
].join('\n');

void main() {
  late ContestHarness h;
  late WorkedBeforeRepository repo;

  setUp(() async {
    h = await ContestHarness.create(await openTestDatabase());
    repo = WorkedBeforeRepository(h.db);
  });

  test(
    'rebuildLocal indexes non-deleted QSOs with the earliest time',
    () async {
      await h.qsos.log(testQso(timeOn: 5000));
      await h.qsos.log(testQso(timeOn: 3000));
      await h.qsos.log(testQso(timeOn: 4000, band: '40m'));
      final gone = testQso(call: 'F5XYZ');
      await h.qsos.log(gone);
      await h.qsos.delete(gone.id, canDeleteOnServer: false);
      await repo.rebuildLocal('acc');

      final s = await repo.lookup('acc', 'dl1abc');
      expect(s.worked, isTrue);
      expect(s.bands, {'20m', '40m'});
      expect(s.modes, {'CW'});
      expect(s.slots, {('20m', 'CW'), ('40m', 'CW')});
      expect(s.firstTime, 3000);
      expect((await repo.lookup('acc', 'F5XYZ')).worked, isFalse);

      // Rebuild is repeatable and drops entries of QSOs deleted meanwhile.
      final first = testQso(timeOn: 6000, band: '40m');
      await h.qsos.log(first);
      await repo.rebuildLocal('acc');
      await repo.rebuildLocal('acc');
      expect((await repo.lookup('acc', 'DL1ABC')).slots, hasLength(2));
    },
  );

  test(
    'mergeServerAdif upserts with source server and keeps the earliest time',
    () async {
      await h.qsos.log(testQso(timeOn: 1_800_000_000_000));
      await repo.rebuildLocal('acc');
      final result = await repo.mergeServerAdif(
        'acc',
        _adif([
          {
            'CALL': 'dl1abc',
            'BAND': '20m',
            'MODE': 'CW',
            'QSO_DATE': '20240101',
            'TIME_ON': '120000',
            'DXCC': '230',
            'GRIDSQUARE': 'jo62',
          },
          {
            'CALL': 'DL1ABC',
            'FREQ': '7.030',
            'MODE': 'CW',
            'QSO_DATE': '20240102',
          },
          {
            'CALL': 'W1AW',
            'BAND': '20m',
            'MODE': 'SSB',
            'QSO_DATE': '20240103',
          },
          {'CALL': 'BROKEN', 'MODE': 'CW'},
        ]),
      );
      expect(result, (merged: 3, skipped: 1));
      final s = await repo.lookup('acc', 'DL1ABC');
      expect(s.slots, {('20m', 'CW'), ('40m', 'CW')});
      expect(s.firstTime, DateTime.utc(2024, 1, 1, 12).millisecondsSinceEpoch);
      final row =
          await (h.db.select(h.db.workedBefore)
                ..where((w) => w.call.equals('DL1ABC') & w.band.equals('20m')))
              .getSingle();
      expect((row.source, row.dxcc, row.gridsquare), ('server', 230, 'JO62'));
      expect((await repo.lookup('acc', 'W1AW')).worked, isTrue);

      // A later rebuild keeps server entries.
      await repo.rebuildLocal('acc');
      expect((await repo.lookup('acc', 'W1AW')).worked, isTrue);
    },
  );

  test('cursor getter/setter and clear', () async {
    expect(await repo.lastFetchedId('acc'), isNull);
    await repo.setLastFetchedId('acc', 1234);
    expect(await repo.lastFetchedId('acc'), 1234);
    expect(
      (await h.db.select(h.db.settings).get()).single.key,
      'workedBefore.acc.lastFetchedId',
    );
    await repo.mergeServerAdif(
      'acc',
      _adif([
        {'CALL': 'W1AW', 'BAND': '20m', 'MODE': 'CW', 'QSO_DATE': '20240103'},
      ]),
    );
    await repo.clear('acc');
    expect(await repo.lastFetchedId('acc'), isNull);
    expect((await repo.lookup('acc', 'W1AW')).worked, isFalse);
  });

  test('exact versus base-call lookup', () async {
    await repo.mergeServerAdif(
      'acc',
      _adif([
        {
          'CALL': 'DL1ABC/P',
          'BAND': '20m',
          'MODE': 'CW',
          'QSO_DATE': '20240103',
        },
        {
          'CALL': 'EA8/DL1ABC',
          'BAND': '40m',
          'MODE': 'SSB',
          'QSO_DATE': '20240104',
        },
        {
          'CALL': 'DL1ABCD',
          'BAND': '10m',
          'MODE': 'CW',
          'QSO_DATE': '20240105',
        },
      ]),
    );
    expect((await repo.lookup('acc', 'DL1ABC')).worked, isFalse);
    expect((await repo.lookup('acc', 'DL1ABC/P')).bands, {'20m'});
    final base = await repo.lookupBase('acc', 'DL1ABC');
    expect(base.bands, {'20m', '40m'});
    expect(base.modes, {'CW', 'SSB'});
    expect((await repo.lookupBase('acc', 'dl1abc/m')).bands, {'20m', '40m'});
  });

  test('slotStatus classifies new call, band, mode and slot', () async {
    await repo.mergeServerAdif(
      'acc',
      _adif([
        {'CALL': 'W1AW', 'BAND': '20m', 'MODE': 'CW', 'QSO_DATE': '20240103'},
        {'CALL': 'W1AW', 'BAND': '40m', 'MODE': 'SSB', 'QSO_DATE': '20240103'},
      ]),
    );
    final s = await repo.lookup('acc', 'W1AW');
    expect(s.slotStatus('20m', 'CW'), WorkedSlotStatus.workedBefore);
    expect(s.slotStatus('20m', 'SSB'), WorkedSlotStatus.newSlot);
    expect(s.slotStatus('15m', 'CW'), WorkedSlotStatus.newBand);
    expect(s.slotStatus('20m', 'RTTY'), WorkedSlotStatus.newMode);
    expect(
      (await repo.lookup('acc', 'K1ABC')).slotStatus('20m', 'CW'),
      WorkedSlotStatus.newCall,
    );
  });

  test('accounts are isolated', () async {
    await repo.mergeServerAdif(
      'acc',
      _adif([
        {'CALL': 'W1AW', 'BAND': '20m', 'MODE': 'CW', 'QSO_DATE': '20240103'},
      ]),
    );
    expect((await repo.lookup('other', 'W1AW')).worked, isFalse);
  });
}
