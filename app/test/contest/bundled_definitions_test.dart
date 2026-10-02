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

ContestStation st(
  String call,
  int dxcc,
  String continent, {
  int? cqz,
  int? ituz,
}) => ContestStation(
  call: call,
  dxcc: dxcc,
  continent: continent,
  cqz: cqz,
  ituz: ituz,
);

final ContestStation de = st('DO1HOZ', 230, 'EU', cqz: 14, ituz: 28);
final ContestStation us = st('W1AW', 291, 'NA', cqz: 5, ituz: 8);
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

    // Alaska (6) and Hawaii (110) take part as DX stations (rules 2.3,
    // 5.2.3.1).
    // Me W1AW. KL7AA and KH6AA: 3 pts each, DXCC multipliers 6 and 110.
    // Me KL7AA (DX): sends power, receives a state; W1AW 3 pts, state CT.
    test('Alaska and Hawaii are DX', () {
      final d = load('arrl-dx-cw');
      final kl7 = st('KL7AA', 6, 'NA');
      final s = score(d, [
        qso(0, us, kl7, '20m', 'CW'),
        qso(1, us, st('KH6AA', 110, 'OC'), '20m', 'CW'),
        qso(2, us, st('VE3AA', 1, 'NA'), '20m', 'CW'),
      ]);
      expect((s.points, s.multipliers, s.total), (6, 2, 12));
      expect(d.exchangeFor(kl7).sent[1].kind, ExchangeKind.power);
      expect(d.exchangeFor(kl7).rcvd[1].kind, ExchangeKind.state);
      final s2 = score(d, [
        qso(0, kl7, us, '20m', 'CW', rcvd: {ExchangeKind.state: 'CT'}),
        qso(
          1,
          kl7,
          st('VE3AA', 1, 'NA'),
          '20m',
          'CW',
          rcvd: {ExchangeKind.state: 'ON'},
        ),
        qso(2, kl7, st('KH6AA', 110, 'OC'), '20m', 'CW'),
      ]);
      expect((s2.points, s2.multipliers, s2.total), (6, 2, 12));
    });
  });

  group('IARU HF', () {
    // Me DO1HOZ (230 EU, ITU zone 28), mixed CW/phone, 20m.
    //  1 K1ABC  SSB  zone 8  other continent         5 pts; zone 8
    //  2 K1ABC  CW   zone 8  other mode, no dupe     5 pts; zone 8 already
    //                        (zones count per band, not per mode)
    //  3 DL2XYZ SSB  zone 28 same zone               1 pt;  zone 28
    //  4 OH2AA  SSB  zone 18 same continent          3 pts; zone 18
    //  5 K1DEF  SSB  zone 8  other continent         5 pts; zone 8 already
    //  6 9A1AA  SSB  zone 28 other country, same zone 1 pt; zone 28 already
    // Points 20, zones 3, score 60.
    test('mixed mode from Europe; zones count per band, not per mode', () {
      final d = load('iaru-hf');
      ContestQso q(
        int m,
        String call,
        int dxcc,
        String cont,
        String mode,
        int zone,
      ) => qso(
        m,
        de,
        st(call, dxcc, cont),
        '20m',
        mode,
        rcvd: {ExchangeKind.ituZone: '$zone'},
      );
      final s = score(d, [
        q(0, 'K1ABC', 291, 'NA', 'USB', 8),
        q(1, 'K1ABC', 291, 'NA', 'CW', 8),
        q(2, 'DL2XYZ', 230, 'EU', 'USB', 28),
        q(3, 'OH2AA', 224, 'EU', 'USB', 18),
        q(4, 'K1DEF', 291, 'NA', 'USB', 8),
        q(5, '9A1AA', 497, 'EU', 'USB', 28),
      ]);
      expect(
        (s.qsos, s.dupes, s.points, s.multipliers, s.total),
        (6, 0, 20, 3, 60),
      );
    });

    // Me W1AW (USA, zone 8). The received zone decides, not the country:
    // W6AA in zone 6 (same country, other zone, same continent) 3 pts;
    // W2AA in zone 8 (same zone) 1 pt. The resolver's zone for the other
    // station is overridden by the exchange.
    test('same zone is decided by the received exchange', () {
      final d = load('iaru-hf');
      final s = score(d, [
        qso(
          0,
          us,
          st('W6AA', 291, 'NA', ituz: 8),
          '20m',
          'CW',
          rcvd: {ExchangeKind.ituZone: '6'},
        ),
        qso(
          1,
          us,
          st('W2AA', 291, 'NA', ituz: 6),
          '20m',
          'CW',
          rcvd: {ExchangeKind.ituZone: '8'},
        ),
      ]);
      expect((s.points, s.multipliers, s.total), (4, 2, 8));
    });

    // Without a zone of my own the zone rule cannot apply: continent rules.
    test('unknown zones fall through to the continent rules', () {
      final d = load('iaru-hf');
      final s = score(d, [
        qso(
          0,
          st('DO1HOZ', 230, 'EU'),
          st('DL2XYZ', 230, 'EU'),
          '20m',
          'CW',
          rcvd: {ExchangeKind.ituZone: '28'},
        ),
      ]);
      expect(s.points, 3);
    });
  });

  group('WAG', () {
    // Me DO1HOZ (DL). DL-DL 1 pt, DL-Europe 3, DL-DX 5. The multiplier is
    // the DXCC entity per band and mode category (not DL itself).
    //  1 20m SSB W1AW   291 NA  5 pts; dxcc 291/20m/phone
    //  2 20m SSB DL2XYZ 230     1 pt;  no multiplier
    //  3 20m SSB OH2AA  224 EU  3 pts; dxcc 224/20m/phone
    //  4 40m SSB W1AW           5 pts; dxcc 291/40m/phone
    //  5 20m CW  OH2AA          not a dupe, 3 pts; dxcc 224/20m/cw (new)
    //  6 20m SSB OH2AA          dupe of #3, 0 pts
    // Points 17, multipliers 4, score 68.
    test('from Germany', () {
      final d = load('darc-wag');
      final s = score(d, [
        qso(0, de, us, '20m', 'USB', rcvd: {ExchangeKind.serial: '12'}),
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
        (5, 1, 17, 4, 68),
      );
    });

    // Me OH2AA (224, non-DL). Only DL stations count, 3 pts; the multiplier
    // is the first letter of the DOK per band and mode category; NM is no
    // multiplier.
    //  1 20m SSB DL1AA A01  3 pts; district A/20m/phone
    //  2 20m SSB DL2BB B02  3 pts; district B/20m/phone
    //  3 20m SSB DL3CC A15  3 pts; district A already counted
    //  4 20m SSB DL4DD NM   3 pts; no multiplier
    //  5 40m SSB DL1AA A01  3 pts; district A/40m/phone
    //  6 20m CW  DL1AA A01  3 pts; district A/20m/cw
    //  7 20m SSB W1AW       0 pts (DX-DX), no multiplier
    // Points 18, multipliers 4, score 72.
    test('from outside Germany', () {
      final d = load('darc-wag');
      ContestQso q(int m, String call, String band, String mode, String dok) =>
          qso(
            m,
            fi,
            st(call, 230, 'EU'),
            band,
            mode,
            rcvd: {ExchangeKind.dok: dok},
          );
      final s = score(d, [
        q(0, 'DL1AA', '20m', 'USB', 'A01'),
        q(1, 'DL2BB', '20m', 'USB', 'B02'),
        q(2, 'DL3CC', '20m', 'USB', 'A15'),
        q(3, 'DL4DD', '20m', 'USB', 'NM'),
        q(4, 'DL1AA', '40m', 'USB', 'A01'),
        q(5, 'DL1AA', '20m', 'CW', 'A01'),
        qso(6, fi, us, '20m', 'USB'),
      ]);
      expect((s.points, s.multipliers, s.total), (18, 4, 72));
    });

    test('DL stations send a DOK, others a serial', () {
      final d = load('darc-wag');
      expect(d.exchangeFor(de).sent[1].kind, ExchangeKind.dok);
      expect(d.exchangeFor(fi).sent[1].kind, ExchangeKind.serial);
      expect(d.exchangeFor(fi).rcvd[1].kind, ExchangeKind.dok);
    });

    test('a DL station receives a serial from DX and a DOK from DL', () {
      final rcvd = load('darc-wag').exchangeFor(de).rcvd;
      List<ExchangePresence> presence(ContestStation? them) => [
        for (final e in rcvd) e.presenceFor(them),
      ];
      expect(presence(us), [
        ExchangePresence.required,
        ExchangePresence.required,
        ExchangePresence.absent,
      ]);
      expect(presence(st('DL1AA', 230, 'EU')), [
        ExchangePresence.required,
        ExchangePresence.absent,
        ExchangePresence.required,
      ]);
      expect(presence(null), [
        ExchangePresence.required,
        ExchangePresence.optional,
        ExchangePresence.optional,
      ]);
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
