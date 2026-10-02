import 'dart:convert';

import 'package:test/test.dart';
import 'package:tideline_domain/src/contest/contest_definition.dart';
import 'package:tideline_domain/src/contest/contest_scorer.dart';
import 'package:tideline_domain/src/contest/contest_station.dart';
import 'package:tideline_domain/src/contest/exchange.dart';
import 'package:tideline_domain/src/values/band.dart';
import 'package:tideline_domain/src/values/mode.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

import 'cq_ww_ssb.dart';

const de = ContestStation(
  call: 'DO1HOZ',
  dxcc: 230,
  continent: 'EU',
  cqz: 14,
  ituz: 28,
);
const usMe = ContestStation(
  call: 'W1AW',
  dxcc: 291,
  continent: 'NA',
  cqz: 5,
  ituz: 8,
);

final t0 = UtcDateTime(DateTime.utc(2026, 10, 24, 10));

ContestQso qso(
  String id,
  int minute,
  String call,
  String band,
  String mode,
  ContestStation them, {
  ContestStation me = de,
  Map<ExchangeKind, String> rcvd = const {},
}) => ContestQso(
  id: id,
  call: call,
  time: UtcDateTime(t0.value.add(Duration(minutes: minute))),
  band: Band.tryParse(band)!,
  mode: Mode.tryParse(mode)!,
  me: me,
  them: them,
  rcvd: rcvd,
);

ContestStation st(String call, int dxcc, String cont) =>
    ContestStation(call: call, dxcc: dxcc, continent: cont);

void main() {
  final cqww = ContestDefinition.parse(cqWwSsbJson);

  group('CQ WW SSB, hand-computed log', () {
    // I am DO1HOZ (DXCC 230, EU). All QSOs on SSB unless noted.
    //
    //  #  band call    them             points  new multipliers
    //  1  20m  K1ABC   291 NA, zone 5     3     zone 5/20m, country 291/20m
    //  2  20m  DL2XYZ  230 EU, zone 14    0     zone 14/20m, country 230/20m
    //                  (same entity: 0 points, but multipliers still count)
    //  3  20m  OH2AA   224 EU, zone 15    1     zone 15/20m, country 224/20m
    //                  (different entity, same continent: last rule)
    //  4  20m  K1ABC   dupe of #1         0     none
    //  5  40m  K1ABC   291 NA, zone 5     3     zone 5/40m, country 291/40m
    //  6  40m  W2ZZ    291 NA, zone 5     3     none (both already on 40m)
    //  7  20m  CW      out of contest     0     none (category CW not allowed)
    //  8  10m  VE3AA   1 NA, zone 5       3     zone 5/10m, country 1/10m
    //
    // Valid QSOs: 1,2,3,5,6,8 = 6. Dupes: 1. Out of contest: 1.
    // Points: 3+0+1+3+3+3 = 13.
    // Multipliers: zones (5,20)(14,20)(15,20)(5,40)(5,10) = 5, countries
    // (291,20)(230,20)(224,20)(291,40)(1,10) = 5, total 10.
    // Score: 13 * 10 = 130.
    // Per band: 20m 3 QSOs / 4 pts / 6 mults; 40m 2 / 6 / 2; 10m 1 / 3 / 2.
    final k1 = st('K1ABC', 291, 'NA');
    final log = [
      qso('1', 0, 'K1ABC', '20m', 'USB', k1, rcvd: {ExchangeKind.cqZone: '5'}),
      qso(
        '2',
        1,
        'DL2XYZ',
        '20m',
        'SSB',
        st('DL2XYZ', 230, 'EU'),
        rcvd: {ExchangeKind.cqZone: '14'},
      ),
      qso(
        '3',
        2,
        'OH2AA',
        '20m',
        'SSB',
        st('OH2AA', 224, 'EU'),
        rcvd: {ExchangeKind.cqZone: '15'},
      ),
      qso('4', 3, 'K1ABC', '20m', 'LSB', k1, rcvd: {ExchangeKind.cqZone: '5'}),
      qso('5', 4, 'K1ABC', '40m', 'LSB', k1, rcvd: {ExchangeKind.cqZone: '5'}),
      qso(
        '6',
        5,
        'W2ZZ',
        '40m',
        'LSB',
        st('W2ZZ', 291, 'NA'),
        rcvd: {ExchangeKind.cqZone: '5'},
      ),
      qso('7', 6, 'JA1ZZZ', '20m', 'CW', st('JA1ZZZ', 339, 'AS')),
      qso(
        '8',
        7,
        'VE3AA',
        '10m',
        'SSB',
        st('VE3AA', 1, 'NA'),
        rcvd: {ExchangeKind.cqZone: '05'},
      ),
    ];

    test('totals', () {
      final report = ContestScorer.scoreAll(cqww, log);
      final s = report.score;
      expect(s.qsos, 6);
      expect(s.dupes, 1);
      expect(s.outOfContest, 1);
      expect(s.points, 13);
      expect(s.multipliers, 10);
      expect(s.multipliersById, {'zone': 5, 'country': 5});
      expect(s.total, 130);
      expect(
        [
          for (final b in s.bands)
            (b.band.name, b.qsos, b.points, b.multipliers),
        ],
        [('40m', 2, 6, 2), ('20m', 3, 4, 6), ('10m', 1, 3, 2)],
      );
    });

    test('per QSO', () {
      final per = ContestScorer.scoreAll(cqww, log).perQso;
      expect([for (final q in per) q.points], [3, 0, 1, 0, 3, 3, 0, 3]);
      expect(
        [for (final q in per) q.status],
        [
          QsoScoreStatus.valid,
          QsoScoreStatus.valid,
          QsoScoreStatus.valid,
          QsoScoreStatus.dupe,
          QsoScoreStatus.valid,
          QsoScoreStatus.valid,
          QsoScoreStatus.outOfContest,
          QsoScoreStatus.valid,
        ],
      );
      expect(
        [for (final q in per) q.newMultipliers.length],
        [2, 2, 2, 0, 2, 0, 0, 2],
      );
      // "05" is normalised to zone 5.
      expect(
        per.last.newMultipliers.map((h) => '${h.multiplierId}:${h.value}'),
        ['zone:5', 'country:1'],
      );
      expect(per.last.newMultipliers.first.scopeKey, '10m');
      expect(per[3].isDupe, isTrue);
      expect(per[5].isNewMultiplier, isFalse);
    });

    test('input order does not matter for scoreAll', () {
      final shuffled = [...log.reversed];
      final a = ContestScorer.scoreAll(cqww, shuffled);
      expect(a.score.total, 130);
      expect(a.perQso.map((q) => q.id), [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
      ]);
    });

    test('incremental add equals batch', () {
      final scorer = ContestScorer(cqww);
      log.forEach(scorer.add);
      expect(scorer.score.total, 130);
    });

    test('preview does not change the state and predicts the result', () {
      final scorer = ContestScorer(cqww);
      log.take(3).forEach(scorer.add);
      final before = scorer.score;
      final candidate = log[4]; // K1ABC on 40m
      final p = scorer.preview(candidate);
      expect(p.points, 3);
      expect(p.newMultipliers.map((h) => h.multiplierId), ['zone', 'country']);
      expect(scorer.score.total, before.total);
      expect(scorer.score.qsos, 3);
      // Previewing a dupe.
      expect(scorer.preview(log[3]).isDupe, isTrue);
      // Adding after the preview gives the same result.
      expect(scorer.add(candidate).points, 3);
      expect(scorer.score.qsos, 4);
    });
  });

  test('NA to NA gives 2 points, other continents 3, same continent 1', () {
    final r = ContestScorer.scoreAll(cqww, [
      qso('1', 0, 'VE3AA', '20m', 'SSB', st('VE3AA', 1, 'NA'), me: usMe),
      qso('2', 1, 'DL1A', '20m', 'SSB', st('DL1A', 230, 'EU'), me: usMe),
      qso('3', 2, 'K1ABC', '20m', 'SSB', st('K1ABC', 291, 'NA'), me: usMe),
    ]);
    expect([for (final q in r.perQso) q.points], [2, 3, 0]);
  });

  test('unknown DXCC data matches neither predicate rule', () {
    // sameDxcc / sameContinent / NA-NA all need data: only the last rule
    // matches, giving 1 point; no country multiplier either.
    final r = ContestScorer.scoreAll(cqww, [
      qso('1', 0, 'XX1A', '20m', 'SSB', const ContestStation(call: 'XX1A')),
    ]);
    expect(r.perQso.single.points, 1);
    expect(r.perQso.single.newMultipliers, isEmpty);
  });

  group('other score kinds and multiplier scopes', () {
    ContestDefinition def(Map<String, Object?> patch) {
      final json = jsonDecode(variantJson) as Map<String, Object?>
        ..addAll(patch);
      return ContestDefinition.parse(jsonEncode(json));
    }

    test(
      'dok multiplier only counts for German stations, once per contest',
      () {
        final d = def({});
        final de1 = st('DL1A', 230, 'EU');
        final r = ContestScorer.scoreAll(d, [
          qso(
            '1',
            0,
            'DL1A',
            '20m',
            'USB',
            de1,
            rcvd: {ExchangeKind.dok: 'a01'},
          ),
          qso(
            '2',
            1,
            'DL2B',
            '40m',
            'USB',
            st('DL2B', 230, 'EU'),
            rcvd: {ExchangeKind.dok: 'A01'},
          ),
          qso(
            '3',
            2,
            'DL3C',
            '40m',
            'USB',
            st('DL3C', 230, 'EU'),
            rcvd: {ExchangeKind.dok: 'B02'},
          ),
          qso(
            '4',
            3,
            'K1A',
            '40m',
            'USB',
            st('K1A', 291, 'NA'),
            rcvd: {ExchangeKind.dok: 'C03'},
          ),
          qso('5', 4, 'DL4D', '40m', 'USB', st('DL4D', 230, 'EU')),
        ]);
        // Points: EU 3, 3, 3, NA 5, 3 = 17. DOKs: A01, B02 = 2 (K1A's does not
        // count, DL4D sent none). 17 * 2 = 34.
        expect(r.score.points, 17);
        expect(r.score.multipliers, 2);
        expect(r.score.total, 34);
      },
    );

    test('same call on the same band in USB and LSB is a dupe per mode', () {
      // dupe per band + mode; USB and LSB are both SSB.
      final r = ContestScorer.scoreAll(def({}), [
        qso('1', 0, 'K1A', '20m', 'USB', st('K1A', 291, 'NA')),
        qso('2', 1, 'K1A', '20m', 'LSB', st('K1A', 291, 'NA')),
        qso('3', 2, 'K1A', '20m', 'CW', st('K1A', 291, 'NA')),
      ]);
      expect(
        [for (final q in r.perQso) q.status],
        [QsoScoreStatus.valid, QsoScoreStatus.dupe, QsoScoreStatus.valid],
      );
    });

    test('points kind and qsos kind', () {
      final pointsOnly = def({'score': 'points', 'multipliers': <Object?>[]});
      final log = [
        qso('1', 0, 'DL1A', '20m', 'USB', st('DL1A', 230, 'EU')),
        qso('2', 1, 'K1A', '20m', 'USB', st('K1A', 291, 'NA')),
        qso('3', 2, 'K1A', '20m', 'USB', st('K1A', 291, 'NA')),
      ];
      expect(ContestScorer.scoreAll(pointsOnly, log).score.total, 8);
      final qsos = def({
        'score': 'qsos',
        'multipliers': <Object?>[],
        'points': <Object?>[],
      });
      final s = ContestScorer.scoreAll(qsos, log).score;
      expect(s.total, 2);
      expect(s.points, 2);
    });

    test('bandMode scope counts per band and category; contest once', () {
      final d = ContestDefinition.parse(
        jsonEncode({
          'schema': 1,
          'id': 'scopes',
          'version': 1,
          'name': 'Scopes',
          'modes': ['CW', 'PHONE'],
          'bands': ['20m', '40m'],
          'exchange': {'sent': <Object?>[], 'rcvd': <Object?>[]},
          'dupe': {
            'per': ['band', 'modeCategory'],
          },
          'points': [
            {'points': 1},
          ],
          'multipliers': [
            {'id': 'bm', 'source': 'continent', 'per': 'bandMode'},
            {'id': 'c', 'source': 'continent', 'per': 'contest'},
            {
              'id': 'b',
              'source': 'continent',
              'per': 'band',
              'when': {'modeCategory': 'CW'},
            },
          ],
          'score': 'pointsTimesMultipliers',
        }),
      );
      final r = ContestScorer.scoreAll(d, [
        qso('1', 0, 'K1A', '20m', 'CW', st('K1A', 291, 'NA')),
        qso('2', 1, 'K2A', '20m', 'SSB', st('K2A', 291, 'NA')),
        qso('3', 2, 'K3A', '40m', 'CW', st('K3A', 291, 'NA')),
        qso('4', 3, 'K4A', '40m', 'CW', st('K4A', 291, 'NA')),
      ]);
      // bm: (20,CW)(20,PHONE)(40,CW) = 3; c: 1; b (CW only): 20m, 40m = 2.
      expect(r.score.multipliersById, {'bm': 3, 'c': 1, 'b': 2});
      expect(r.score.multipliers, 6);
      expect(r.score.total, 4 * 6);
    });

    test('wpxPrefix, grid4 and rcvd sources', () {
      final d = ContestDefinition.parse(
        jsonEncode({
          'schema': 1,
          'id': 'srcs',
          'version': 1,
          'name': 'Sources',
          'modes': ['CW'],
          'bands': ['20m'],
          'exchange': {
            'sent': <Object?>[],
            'rcvd': [
              {'kind': 'grid'},
              {'kind': 'state'},
            ],
          },
          'dupe': {
            'per': ['band'],
          },
          'points': [
            {'points': 1},
          ],
          'multipliers': [
            {'id': 'pfx', 'source': 'wpxPrefix', 'per': 'contest'},
            {'id': 'grid', 'source': 'grid4', 'per': 'contest'},
            {'id': 'state', 'source': 'rcvd:state', 'per': 'contest'},
          ],
          'score': 'pointsTimesMultipliers',
        }),
      );
      final r = ContestScorer.scoreAll(d, [
        qso(
          '1',
          0,
          'DL1ABC',
          '20m',
          'CW',
          st('DL1ABC', 230, 'EU'),
          rcvd: {ExchangeKind.grid: 'jo40hd', ExchangeKind.state: 'ny'},
        ),
        qso(
          '2',
          1,
          'DL1XYZ/P',
          '20m',
          'CW',
          st('DL1XYZ', 230, 'EU'),
          rcvd: {ExchangeKind.grid: 'JO40aa', ExchangeKind.state: 'NY'},
        ),
        qso(
          '3',
          2,
          'DL2ABC',
          '20m',
          'CW',
          st('DL2ABC', 230, 'EU'),
          rcvd: {ExchangeKind.grid: 'JO41'},
        ),
      ]);
      // prefixes DL1, DL2 = 2; grids JO40, JO41 = 2; states NY = 1.
      expect(r.score.multipliersById, {'pfx': 2, 'grid': 2, 'state': 1});
    });
  });

  test('scores 10,000 QSOs quickly', () {
    String letter(int n) => String.fromCharCode(65 + n % 26);
    final calls = <String>[
      for (var i = 0; i < 10000; i++)
        'K${i % 10}${letter(i)}${letter(i ~/ 26)}${letter(i ~/ 676)}',
    ];
    final log = [
      for (var i = 0; i < 10000; i++)
        qso(
          '$i',
          i,
          calls[i],
          const ['160m', '80m', '40m', '20m', '15m', '10m'][i % 6],
          i % 3 == 0 ? 'USB' : 'LSB',
          st(calls[i], 1 + i % 300, const ['EU', 'NA', 'AS'][i % 3]),
          rcvd: {ExchangeKind.cqZone: '${1 + i % 40}'},
        ),
    ];
    final sw = Stopwatch()..start();
    final report = ContestScorer.scoreAll(cqww, log);
    sw.stop();
    expect(report.perQso, hasLength(10000));
    expect(report.score.qsos + report.score.dupes, 10000);
    expect(sw.elapsedMilliseconds, lessThan(200));
  });
}
