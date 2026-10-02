import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/contest/contest_engine.dart';
import 'package:tideline/src/features/contest/contest_qso_codec.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';

ContestSpec specFor(String id, {Map<String, String> own = const {}}) {
  final definition = bundledDefinition(id);
  final me = contestStationFor(
    call: 'DO1HOZ',
    dxcc: testDxcc,
    grid: 'JO40',
    ownExchange: own,
  );
  return ContestSpec(
    session: ContestSession(
      id: 's1',
      definitionId: id,
      definitionVersion: definition.version,
      accountId: 'acc-1',
      startedAt: 0,
      ownExchange: own,
      cabrillo: const {},
      usesSerial: true,
      remoteState: ContestRemoteState.local,
    ),
    definition: definition,
    me: me,
    exchange: definition.exchangeFor(me),
  );
}

const _calls = [
  'DL1ABC',
  'G4XYZ',
  'EA8ABC',
  'W1AW',
  'JA1ZZZ',
  'VK2ABC',
  'OH2AA',
  'PY2XX',
  'ZS6ABC',
  'K1ABC',
];

/// A reproducible CQ WW log of [count] QSOs, one every 20 s.
List<Qso> syntheticLog(ContestSpec spec, int count, {int seed = 7}) {
  final random = Random(seed);
  final bands = ['80m', '40m', '20m', '15m', '10m'];
  final start = DateTime.utc(2026, 10, 24);
  return [
    for (var i = 0; i < count; i++)
      () {
        final call = i < _calls.length * 3
            ? _calls[i % _calls.length]
            : '${_calls[random.nextInt(_calls.length)]}${i % 997}';
        final rcvd = ExchangeMapping.toAdif(
          ExchangeSide.rcvd,
          spec.exchange.rcvd,
          ['59', '${1 + random.nextInt(40)}'],
        );
        return Qso(
          id: 'q$i',
          accountId: 'acc-1',
          call: Callsign.tryParse(call)!,
          timeOn: UtcDateTime(start.add(Duration(seconds: 20 * i))),
          band: Band.tryParse(bands[random.nextInt(bands.length)])!,
          mode: Mode.tryParse('SSB')!,
          rstSent: '59',
          rstRcvd: '59',
          fields: rcvd.fields,
        );
      }(),
  ];
}

ContestScoreReport reference(ContestEngine engine, List<Qso> qsos) =>
    ContestScorer.scoreAll(engine.spec.definition, [
      for (final q in qsos) engine.contestQso(q),
    ]);

void expectSameScore(ContestScore a, ContestScore b) {
  expect(a.qsos, b.qsos);
  expect(a.dupes, b.dupes);
  expect(a.outOfContest, b.outOfContest);
  expect(a.points, b.points);
  expect(a.multipliers, b.multipliers);
  expect(a.total, b.total);
  expect(a.multipliersById, b.multipliersById);
  expect(
    [for (final x in a.bands) (x.band.name, x.qsos, x.points)],
    [for (final x in b.bands) (x.band.name, x.qsos, x.points)],
  );
}

void main() {
  final spec = specFor('cq-ww-ssb');

  group('ContestEngine', () {
    test('appending QSOs scores incrementally, never rebuilding', () {
      final qsos = syntheticLog(spec, 400);
      final engine = ContestEngine(spec: spec, dxcc: testDxcc);
      for (var n = 1; n <= qsos.length; n++) {
        engine.sync(qsos.sublist(0, n));
      }
      expect(engine.rebuilds, 0);
      expect(engine.length, 400);
      expectSameScore(engine.score, reference(engine, qsos).score);
      expect(engine.score.dupes, greaterThan(0));
    });

    test('an unchanged list changes nothing', () {
      final qsos = syntheticLog(spec, 50);
      final engine = ContestEngine(spec: spec, dxcc: testDxcc)..sync(qsos);
      final version = engine.version;
      expect(engine.sync(qsos), isFalse);
      expect(engine.version, version);
    });

    test('an edit rebuilds and matches scoreAll', () {
      final qsos = syntheticLog(spec, 300);
      final engine = ContestEngine(spec: spec, dxcc: testDxcc)..sync(qsos);
      final edited = [...qsos];
      // Turn QSO 100 into a dupe of QSO 0 (same call, band and mode).
      edited[100] = Qso(
        id: qsos[100].id,
        accountId: 'acc-1',
        call: qsos[0].call,
        timeOn: qsos[100].timeOn,
        band: qsos[0].band,
        mode: qsos[0].mode,
        rstSent: '59',
        rstRcvd: '59',
        fields: qsos[100].fields,
      );
      expect(engine.sync(edited), isTrue);
      expect(engine.rebuilds, 1);
      expect(engine.scores['q100']!.isDupe, isTrue);
      expectSameScore(engine.score, reference(engine, edited).score);
    });

    test('an edited zone changes the multipliers', () {
      Qso qso(String id, String call, String zone, int minute) => Qso(
        id: id,
        accountId: 'acc-1',
        call: Callsign.tryParse(call)!,
        timeOn: UtcDateTime(DateTime.utc(2026, 10, 24, 12, minute)),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('SSB')!,
        rstRcvd: '59',
        fields: {'CQZ': zone},
      );
      final qsos = [qso('a', 'DL1ABC', '14', 0), qso('b', 'G4XYZ', '14', 1)];
      final engine = ContestEngine(spec: spec, dxcc: testDxcc)..sync(qsos);
      // Two countries and one zone.
      expect(engine.score.multipliersById, {'country': 2, 'zone': 1});
      engine.sync([qsos.first, qso('b', 'G4XYZ', '15', 1)]);
      expect(engine.rebuilds, 1);
      expect(engine.score.multipliersById, {'country': 2, 'zone': 2});
    });

    test('a delete rebuilds and matches scoreAll', () {
      final qsos = syntheticLog(spec, 300);
      final engine = ContestEngine(spec: spec, dxcc: testDxcc)..sync(qsos);
      final shorter = [...qsos]..removeAt(10);
      engine.sync(shorter);
      expect(engine.rebuilds, 1);
      expect(engine.length, 299);
      expectSameScore(engine.score, reference(engine, shorter).score);
    });

    test('a QSO inserted in the middle by time rebuilds', () {
      final qsos = syntheticLog(spec, 100);
      final engine = ContestEngine(spec: spec, dxcc: testDxcc)..sync(qsos);
      final late = Qso(
        id: 'late',
        accountId: 'acc-1',
        call: Callsign.tryParse('UA3AB')!,
        timeOn: UtcDateTime(
          qsos[40].timeOn.value.add(const Duration(seconds: 1)),
        ),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('SSB')!,
        rstRcvd: '59',
        fields: const {'CQZ': '16'},
      );
      final withLate = [...qsos]..insert(41, late);
      engine.sync(withLate);
      expect(engine.rebuilds, 1);
      expectSameScore(engine.score, reference(engine, withLate).score);
    });

    test('previews do not change the state', () {
      final qsos = syntheticLog(spec, 30);
      final engine = ContestEngine(spec: spec, dxcc: testDxcc)..sync(qsos);
      final before = engine.score.total;
      final preview = engine.preview(
        call: 'UA3AB',
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('SSB')!,
        rcvd: {ExchangeKind.cqZone: '16'},
      );
      expect(preview.status, QsoScoreStatus.valid);
      expect(preview.isNewMultiplier, isTrue);
      expect(engine.score.total, before);
      final dupe = engine.dupeCheck(
        call: qsos.first.call.value,
        band: qsos.first.band,
        mode: qsos.first.mode,
      );
      expect(dupe.isDupe, isTrue);
    });

    test('stays fast with 5,000 QSOs', () {
      final qsos = syntheticLog(spec, 5000);
      final full = Stopwatch()..start();
      final engine = ContestEngine(spec: spec, dxcc: testDxcc)
        ..sync(qsos.sublist(0, 4999));
      full.stop();

      // The hot path while contesting: one more QSO arrives.
      final append = Stopwatch()..start();
      engine.sync(qsos);
      append.stop();
      expect(engine.rebuilds, 0);

      // The rare path: an edit rescoring everything.
      final edited = [...qsos]..removeAt(2500);
      final rebuild = Stopwatch()..start();
      engine.sync(edited);
      rebuild.stop();

      // Real numbers go to the test log; the limits are generous so slow CI
      // machines do not flake, yet far below anything an operator notices.
      // ignore: avoid_print
      print(
        'contest engine, 5000 QSOs: first sync ${full.elapsedMilliseconds} ms, '
        'append ${append.elapsedMilliseconds} ms, '
        'rebuild ${rebuild.elapsedMilliseconds} ms',
      );
      expect(append.elapsedMilliseconds, lessThan(100));
      expect(rebuild.elapsedMilliseconds, lessThan(3000));
      expectSameScore(engine.score, reference(engine, edited).score);
    });
  });

  group('validation and ADIF mapping', () {
    final wpx = specFor('cq-wpx-ssb');

    test('a complete entry is normalised', () {
      final v = validateContestEntry(
        spec: wpx,
        call: 'dl1abc',
        band: Band.tryParse('20m'),
        mode: Mode.tryParse('SSB'),
        frequency: '14.205',
        rcvd: ['', '007'],
      );
      final entry = v.entry!;
      expect(entry.call.value, 'DL1ABC');
      expect(entry.rcvd, ['59', '7']);
      expect(entry.freqHz, 14205000);
    });

    test('issues come in focus order', () {
      final v = validateContestEntry(
        spec: wpx,
        call: 'x',
        band: null,
        mode: null,
        frequency: 'abc',
        rcvd: ['600', ''],
      );
      expect(
        [for (final i in v.issues) i.field.name],
        ['call', 'element', 'element', 'band', 'mode', 'frequency'],
      );
      expect(v.issues[1].error, ExchangeError.invalidFormat);
      expect(v.issues[2].error, ExchangeError.missing);
    });

    test('a frequency selects the band when none is chosen', () {
      final v = validateContestEntry(
        spec: wpx,
        call: 'DL1ABC',
        band: null,
        mode: Mode.tryParse('SSB'),
        frequency: '7150',
        rcvd: ['59', '1'],
      );
      expect(v.entry!.band.name, '40m');
    });

    test('built QSO carries both exchanges in ADIF fields', () {
      final entry = validateContestEntry(
        spec: wpx,
        call: 'DL1ABC',
        band: Band.tryParse('20m'),
        mode: Mode.tryParse('SSB'),
        frequency: '',
        rcvd: ['57', '12'],
      ).entry!;
      final qso = buildContestQso(
        spec: wpx,
        entry: entry,
        accountId: 'acc-1',
        stationProfileId: 'st-1',
        dxcc: testDxcc,
      );
      expect(qso.rstRcvd, '57');
      expect(qso.field('SRX'), '12');
      expect(qso.field('DXCC'), '230');
      // The serial is allocated later, atomically.
      expect(qso.field('STX'), isNull);
      final withSerial = contestSerialFields(
        spec: wpx,
        category: ModeCategory.phone,
      )(5);
      expect(withSerial['STX'], '5');
      expect(withSerial['STX_STRING'], '59 5');
    });

    test('an edit keeps the sent exchange and replaces the received one', () {
      final entry = validateContestEntry(
        spec: wpx,
        call: 'DL1ABC',
        band: Band.tryParse('20m'),
        mode: Mode.tryParse('SSB'),
        frequency: '14.205',
        rcvd: ['57', '12'],
      ).entry!;
      final original = buildContestQso(
        spec: wpx,
        entry: entry,
        accountId: 'acc-1',
        stationProfileId: 'st-1',
        dxcc: testDxcc,
      ).copyWith(fields: {'STX': '5', 'SRX': '12', 'STX_STRING': '59 5'});
      final fixed = validateContestEntry(
        spec: wpx,
        call: 'DL1ABD',
        band: Band.tryParse('40m'),
        mode: Mode.tryParse('SSB'),
        frequency: '',
        rcvd: ['59', '13'],
      ).entry!;
      final edited = applyContestEdit(
        spec: wpx,
        original: original,
        entry: fixed,
        dxcc: testDxcc,
      );
      expect(edited.field('STX'), '5');
      expect(edited.field('SRX'), '13');
      expect(edited.call.value, 'DL1ABD');
      expect(edited.rstRcvd, '59');
      // The frequency belonged to 20 m, so it goes with the band change.
      expect(edited.freqHz, isNull);
      expect(edited.timeOn, original.timeOn);
    });
  });
}
