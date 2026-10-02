import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_domain/tideline_domain.dart';

// `flutter test` runs with the app package directory as the cwd.
final Directory contestsDir = Directory('assets/contests');

List<File> jsonFiles() =>
    contestsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

ContestDefinition load(String id) => ContestDefinition.parse(
  File('assets/contests/$id.json').readAsStringSync(),
);

ContestStation st(String call, int dxcc, String continent) =>
    ContestStation(call: call, dxcc: dxcc, continent: continent);

final ContestStation de = st('DO1HOZ', 230, 'EU');
final ContestStation us = st('W1AW', 291, 'NA');
final ContestStation fi = st('OH2AA', 224, 'EU');

final UtcDateTime t0 = UtcDateTime(DateTime.utc(2026, 10, 24, 10));

ContestQso qso(
  int minute,
  ContestStation me,
  ContestStation them,
  String band,
  String mode, {
  Map<ExchangeKind, String> rcvd = const {},
}) => ContestQso(
  id: '$minute',
  call: them.call,
  time: UtcDateTime(t0.value.add(Duration(minutes: minute))),
  band: Band.tryParse(band)!,
  mode: Mode.tryParse(mode)!,
  me: me,
  them: them,
  rcvd: rcvd,
);

ContestScore score(ContestDefinition d, List<ContestQso> log) =>
    ContestScorer.scoreAll(d, log).score;

void main() {
  group('bundled contest definitions', () {
    test('there are bundled files', () {
      expect(jsonFiles(), isNotEmpty);
    });

    test('every file parses, and its file name is its id', () {
      for (final file in jsonFiles()) {
        final def = ContestDefinition.parse(file.readAsStringSync());
        final name = file.uri.pathSegments.last;
        expect(name, '${def.id}.json', reason: file.path);
      }
    });

    test('ids are unique', () {
      final ids = [
        for (final f in jsonFiles())
          ContestDefinition.parse(f.readAsStringSync()).id,
      ];
      expect(ids.toSet().length, ids.length);
    });

    test('the expected set is present', () {
      final ids = {
        for (final f in jsonFiles())
          ContestDefinition.parse(f.readAsStringSync()).id,
      };
      expect(
        ids,
        containsAll(<String>[
          'cq-ww-ssb',
          'cq-ww-cw',
          'cq-wpx-ssb',
          'cq-wpx-cw',
          'arrl-dx-cw',
          'arrl-dx-ssb',
          'iaru-hf',
          'darc-wag',
          'generic-serial',
          'generic-exchange',
        ]),
      );
    });

    test('the contests folder is a registered asset folder', () {
      final lines = File('pubspec.yaml')
          .readAsLinesSync()
          .map((l) => l.trim())
          .toList();
      expect(lines, contains('- assets/contests/'));
    });

    test('definitions round-trip through the canonical JSON', () {
      for (final file in jsonFiles()) {
        final def = ContestDefinition.parse(file.readAsStringSync());
        expect(ContestDefinition.fromJson(def.toJson()), def);
      }
    });
  });

  group('CQ WW', () {
    // Me DO1HOZ (230 EU). All on 20m SSB (USB).
    //  1 K1ABC  291 NA zone 5   other continent  3 pts; zone 5, ctry 291
    //  2 DL2XYZ 230 EU zone 14  same entity       0 pts; zone 14, ctry 230
    //  3 OH2AA  224 EU zone 15  same continent    1 pt;  zone 15, ctry 224
    // Points 4, multipliers 6, score 24.
    test('SSB from Europe', () {
      final d = load('cq-ww-ssb');
      final s = score(d, [
        qso(
          0,
          de,
          st('K1ABC', 291, 'NA'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.cqZone: '5'},
        ),
        qso(
          1,
          de,
          st('DL2XYZ', 230, 'EU'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.cqZone: '14'},
        ),
        qso(2, de, fi, '20m', 'USB', rcvd: {ExchangeKind.cqZone: '15'}),
      ]);
      expect((s.points, s.multipliers, s.total), (4, 6, 24));
    });

    // Me W1AW (291 NA). VE3AA (1 NA, zone 5) 20m: NA-NA other country 2 pts,
    // zone 5 + country 1 = 2 mults. Same call on 40m is not a dupe: 2 pts,
    // 2 more mults. Points 4, mults 4, score 16.
    test('CW from North America; same call on another band is no dupe', () {
      final d = load('cq-ww-cw');
      final ve = st('VE3AA', 1, 'NA');
      final s = score(d, [
        qso(0, us, ve, '20m', 'CW', rcvd: {ExchangeKind.cqZone: '5'}),
        qso(1, us, ve, '40m', 'CW', rcvd: {ExchangeKind.cqZone: '5'}),
        qso(2, us, ve, '40m', 'CW', rcvd: {ExchangeKind.cqZone: '5'}),
      ]);
      expect(
        (s.qsos, s.dupes, s.points, s.multipliers, s.total),
        (2, 1, 4, 4, 16),
      );
    });

    test('the SSB contest rejects CW', () {
      final r = ContestScorer.scoreAll(load('cq-ww-ssb'), [
        qso(0, de, fi, '20m', 'CW', rcvd: {ExchangeKind.cqZone: '15'}),
      ]);
      expect(r.perQso.single.status, QsoScoreStatus.outOfContest);
    });
  });

  group('CQ WPX', () {
    // Me DO1HOZ (EU).
    //  1 20m K1ABC  NA, other continent, high band  3 pts; prefix K1
    //  2 40m K1ABC  other continent, low band        6 pts; K1 already
    //  3 20m DL2XYZ same country                     1 pt;  prefix DL2
    //  4 40m OH2AA  EU other country, low band       2 pts; prefix OH2
    //  5 15m OH2AA  EU other country, high band      1 pt;  OH2 already
    // Points 13, prefixes 3 (once per contest), score 39.
    test('SSB from Europe', () {
      final d = load('cq-wpx-ssb');
      final s = score(d, [
        qso(0, de, st('K1ABC', 291, 'NA'), '20m', 'USB'),
        qso(1, de, st('K1ABC', 291, 'NA'), '40m', 'USB'),
        qso(2, de, st('DL2XYZ', 230, 'EU'), '20m', 'USB'),
        qso(3, de, fi, '40m', 'USB'),
        qso(4, de, fi, '15m', 'USB'),
      ]);
      expect((s.points, s.multipliers, s.total), (13, 3, 39));
    });

    // Me W1AW (NA). VE3AA (NA, other country): 20m 2 pts, 80m 4 pts.
    // JA1AA (AS): 10m 3 pts, 160m 6 pts. W2ZZ same country 15m 1 pt.
    // Prefixes VE3, JA1, W2 = 3. Points 16, score 48.
    test('CW from North America', () {
      final d = load('cq-wpx-cw');
      final ve = st('VE3AA', 1, 'NA');
      final ja = st('JA1AA', 339, 'AS');
      final s = score(d, [
        qso(0, us, ve, '20m', 'CW'),
        qso(1, us, ve, '80m', 'CW'),
        qso(2, us, ja, '10m', 'CW'),
        qso(3, us, ja, '160m', 'CW'),
        qso(4, us, st('W2ZZ', 291, 'NA'), '15m', 'CW'),
      ]);
      expect((s.points, s.multipliers, s.total), (16, 3, 48));
    });
  });

  group('ARRL DX', () {
    // Me W1AW (291). Only W/VE <-> DX counts, 3 points each.
    //  1 20m DL2XYZ 230 EU    3 pts; dxcc 230/20m
    //  2 20m VE3AA  1         0 pts (W/VE-W/VE), no multiplier
    //  3 20m XE1AA  50 NA     3 pts; dxcc 50/20m
    //  4 40m DL2XYZ           3 pts; dxcc 230/40m
    //  5 20m JA1AA  339 AS    3 pts; dxcc 339/20m
    // Points 12, multipliers 4, score 48.
    test('CW from the USA', () {
      final d = load('arrl-dx-cw');
      final s = score(d, [
        qso(0, us, st('DL2XYZ', 230, 'EU'), '20m', 'CW'),
        qso(1, us, st('VE3AA', 1, 'NA'), '20m', 'CW'),
        qso(2, us, st('XE1AA', 50, 'NA'), '20m', 'CW'),
        qso(3, us, st('DL2XYZ', 230, 'EU'), '40m', 'CW'),
        qso(4, us, st('JA1AA', 339, 'AS'), '20m', 'CW'),
      ]);
      expect((s.points, s.multipliers, s.total), (12, 4, 48));
    });

    // Me DO1HOZ (DX). The multiplier is the state/province.
    //  1 20m W1AW   CT   3 pts; state CT/20m
    //  2 20m VE3AA  ON   3 pts; state ON/20m
    //  3 20m OH2AA       0 pts (DX-DX), no multiplier
    //  4 40m W2ZZ   NY   3 pts; state NY/40m
    //  5 20m W1BB   CT   3 pts; CT/20m already counted
    // Points 12, multipliers 3, score 36.
    test('SSB from Germany', () {
      final d = load('arrl-dx-ssb');
      final s = score(d, [
        qso(0, de, us, '20m', 'USB', rcvd: {ExchangeKind.state: 'CT'}),
        qso(
          1,
          de,
          st('VE3AA', 1, 'NA'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.state: 'ON'},
        ),
        qso(2, de, fi, '20m', 'USB'),
        qso(
          3,
          de,
          st('W2ZZ', 291, 'NA'),
          '40m',
          'USB',
          rcvd: {ExchangeKind.state: 'NY'},
        ),
        qso(
          4,
          de,
          st('W1BB', 291, 'NA'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.state: 'CT'},
        ),
      ]);
      expect((s.points, s.multipliers, s.total), (12, 3, 36));
    });

    test('W/VE stations send a state, DX stations a power', () {
      final d = load('arrl-dx-cw');
      expect(d.exchangeFor(us).sent[1].kind, ExchangeKind.state);
      expect(d.exchangeFor(us).rcvd[1].kind, ExchangeKind.power);
      expect(d.exchangeFor(de).sent[1].kind, ExchangeKind.power);
      expect(d.exchangeFor(de).rcvd[1].kind, ExchangeKind.state);
    });
  });

  group('IARU HF', () {
    // Me DO1HOZ (230 EU), mixed CW/phone, 20m. Same entity counts as the
    // "same zone" case (approximation, see README).
    //  1 K1ABC  SSB  zone 8  other continent  5 pts; zone 8/20m/PHONE
    //  2 K1ABC  CW   zone 8  not a dupe       5 pts; zone 8/20m/CW
    //  3 DL2XYZ SSB  zone 28 same entity      1 pt;  zone 28/20m/PHONE
    //  4 OH2AA  SSB  zone 18 same continent   3 pts; zone 18/20m/PHONE
    //  5 K1DEF  SSB  zone 8  other continent  5 pts; zone 8/20m/PHONE already
    // Points 19, multipliers 4, score 76.
    test('mixed mode from Europe', () {
      final d = load('iaru-hf');
      final s = score(d, [
        qso(
          0,
          de,
          st('K1ABC', 291, 'NA'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.ituZone: '8'},
        ),
        qso(
          1,
          de,
          st('K1ABC', 291, 'NA'),
          '20m',
          'CW',
          rcvd: {ExchangeKind.ituZone: '8'},
        ),
        qso(
          2,
          de,
          st('DL2XYZ', 230, 'EU'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.ituZone: '28'},
        ),
        qso(3, de, fi, '20m', 'USB', rcvd: {ExchangeKind.ituZone: '18'}),
        qso(
          4,
          de,
          st('K1DEF', 291, 'NA'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.ituZone: '8'},
        ),
      ]);
      expect(
        (s.qsos, s.dupes, s.points, s.multipliers, s.total),
        (5, 0, 19, 4, 76),
      );
    });
  });

  group('WAG', () {
    // Me DO1HOZ (DL). DL-DL 1 pt, DL-DX 3 pts; multiplier is the DXCC entity
    // per band, and only for non-DL contacts.
    //  1 20m SSB W1AW   291   3 pts; dxcc 291/20m
    //  2 20m SSB DL2XYZ 230   1 pt;  no multiplier
    //  3 20m SSB OH2AA  224   3 pts; dxcc 224/20m
    //  4 40m SSB W1AW         3 pts; dxcc 291/40m
    //  5 20m CW  OH2AA        not a dupe (other mode category), 3 pts;
    //                         dxcc 224/20m already counted
    //  6 20m SSB OH2AA        dupe of #3, 0 pts
    // Points 13, multipliers 3, score 39.
    test('from Germany', () {
      final d = load('darc-wag');
      final s = score(d, [
        qso(0, de, us, '20m', 'USB'),
        qso(
          1,
          de,
          st('DL2XYZ', 230, 'EU'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.dok: 'A01'},
        ),
        qso(2, de, fi, '20m', 'USB'),
        qso(3, de, us, '40m', 'USB'),
        qso(4, de, fi, '20m', 'CW'),
        qso(5, de, fi, '20m', 'USB'),
      ]);
      expect(
        (s.qsos, s.dupes, s.points, s.multipliers, s.total),
        (5, 1, 13, 3, 39),
      );
    });

    // Me OH2AA (224, non-DL). Only DL stations count, 3 pts; multiplier is
    // the DOK per band.
    //  1 20m DL1AA A01   3 pts; DOK A01/20m
    //  2 20m DL2BB A02   3 pts; DOK A02/20m
    //  3 20m DL3CC A01   3 pts; DOK A01/20m already counted
    //  4 20m W1AW        0 pts (DX-DX), no multiplier
    // Points 9, multipliers 2, score 18.
    test('from outside Germany', () {
      final d = load('darc-wag');
      final s = score(d, [
        qso(
          0,
          fi,
          st('DL1AA', 230, 'EU'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.dok: 'A01'},
        ),
        qso(
          1,
          fi,
          st('DL2BB', 230, 'EU'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.dok: 'A02'},
        ),
        qso(
          2,
          fi,
          st('DL3CC', 230, 'EU'),
          '20m',
          'USB',
          rcvd: {ExchangeKind.dok: 'A01'},
        ),
        qso(3, fi, us, '20m', 'USB'),
      ]);
      expect((s.points, s.multipliers, s.total), (9, 2, 18));
    });

    test('DL stations send a DOK, others a serial', () {
      final d = load('darc-wag');
      expect(d.exchangeFor(de).sent[1].kind, ExchangeKind.dok);
      expect(d.exchangeFor(fi).sent[1].kind, ExchangeKind.serial);
      expect(d.exchangeFor(fi).rcvd[1].kind, ExchangeKind.dok);
    });
  });

  group('generic contests', () {
    // Score is the number of valid QSOs; dupe per call + band + mode category.
    //  1 DL2XYZ 20m CW   valid
    //  2 DL2XYZ 20m CW   dupe
    //  3 DL2XYZ 20m USB  valid (other mode category)
    //  4 OH2AA  2m  FM   valid
    // Score 3.
    for (final id in ['generic-serial', 'generic-exchange']) {
      test('$id counts valid QSOs', () {
        final d = load(id);
        expect(d.cabrillo, isNull);
        expect(d.adif, isNull);
        final dl = st('DL2XYZ', 230, 'EU');
        final s = score(d, [
          qso(0, de, dl, '20m', 'CW'),
          qso(1, de, dl, '20m', 'CW'),
          qso(2, de, dl, '20m', 'USB'),
          qso(3, de, fi, '2m', 'FM'),
        ]);
        expect((s.qsos, s.dupes, s.total), (3, 1, 3));
      });
    }
  });
}
