import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

ActivationQso q(
  String call, {
  int day = 3,
  int hour = 10,
  String band = '20m',
  String mode = 'SSB',
}) => ActivationQso(
  time: UtcDateTime(DateTime.utc(2026, 10, day, hour)),
  call: call,
  band: band,
  mode: mode,
);

void main() {
  rulesJsonTests();
  final pota = ActivationRules.defaultFor(ReferenceProgram.pota);
  final sota = ActivationRules.defaultFor(ReferenceProgram.sota);

  test('default thresholds', () {
    expect(pota.minQsos, 10);
    expect(sota.minQsos, 4);
    expect(ActivationRules.defaultFor(ReferenceProgram.wwff).minQsos, 44);
  });

  test('POTA counts within a UTC day, the best day wins', () {
    final qsos = [
      for (var i = 0; i < 6; i++) q('DL${i}A'),
      for (var i = 0; i < 10; i++) q('DL${i}B', day: 4),
    ];
    final p = ActivationProgress.evaluate(pota, qsos);
    expect(p.counted, 10);
    expect(p.total, 16);
    expect(p.isValid, isTrue);
    expect(p.remaining, 0);
    expect(p.countedByDay, {'2026-10-03': 6, '2026-10-04': 10});
  });

  test('POTA: 6 QSOs on each of two days is not valid', () {
    final qsos = [
      for (var i = 0; i < 6; i++) q('DL${i}A'),
      for (var i = 0; i < 6; i++) q('DL${i}B', day: 4),
    ];
    final p = ActivationProgress.evaluate(pota, qsos);
    expect(p.counted, 6);
    expect(p.isValid, isFalse);
    expect(p.remaining, 4);
  });

  test('the UTC day changes at midnight UTC', () {
    final p = ActivationProgress.evaluate(pota, [
      q('A1A', hour: 23),
      q('A2A', day: 4, hour: 0),
    ]);
    expect(p.countedByDay.length, 2);
  });

  test(
    'POTA: same call, band and mode is a duplicate; other band or mode counts',
    () {
      final p = ActivationProgress.evaluate(pota, [
        q('DL1ABC'),
        q('dl1abc'),
        q('DL1ABC', band: '40m'),
        q('DL1ABC', mode: 'CW'),
      ]);
      expect(p.counted, 3);
      expect(p.duplicates, 1);
      expect(p.total, 4);
      expect(p.remaining, 7);
    },
  );

  test('SOTA: every QSO needs a different station, on one UTC day', () {
    expect(sota.window, ActivationWindow.utcDay);
    final p = ActivationProgress.evaluate(sota, [
      q('DL1ABC'),
      q('DL1ABC', band: '40m'),
      q('DL1ABC', mode: 'CW'),
      q('G4XYZ'),
    ]);
    expect(p.counted, 2);
    expect(p.duplicates, 2);
    expect(p.isValid, isFalse);
    expect(p.remaining, 2);
  });

  test('SOTA: QSOs split across midnight UTC do not add up', () {
    final p = ActivationProgress.evaluate(sota, [
      q('A1A', hour: 23),
      q('A2A', hour: 23),
      q('A3A', day: 4, hour: 0),
      q('A4A', day: 4, hour: 1),
    ]);
    expect(p.counted, 2);
    expect(p.isValid, isFalse);
  });

  test('WWFF: days add up, and a call on another day counts again', () {
    final wwff = ActivationRules.defaultFor(ReferenceProgram.wwff);
    final p = ActivationProgress.evaluate(wwff, [
      q('DL1ABC'),
      q('DL1ABC'),
      q('DL1ABC', day: 4),
      q('G4XYZ', day: 4),
    ]);
    expect(p.counted, 3);
    expect(p.duplicates, 1);
    expect(p.countedByDay, {'2026-10-03': 1, '2026-10-04': 2});
  });

  test('a session rule counts across days', () {
    const session = ActivationRules(
      program: ReferenceProgram.sota,
      minQsos: 4,
      window: ActivationWindow.session,
    );
    final p = ActivationProgress.evaluate(session, [
      q('A1A'),
      q('A2A', day: 4),
      q('A3A', day: 5),
      q('A4A', day: 6),
    ]);
    expect(p.isValid, isTrue);
    expect(p.countedByDay, {'*': 4});
  });

  test('no QSOs', () {
    final p = ActivationProgress.evaluate(pota, const []);
    expect(p.counted, 0);
    expect(p.remaining, 10);
    expect(p.isValid, isFalse);
  });
}

void rulesJsonTests() {
  group('rules as data', () {
    test('round trip and rejection of unusable values', () {
      const rules = ActivationRules(
        program: ReferenceProgram.sota,
        minQsos: 6,
        window: ActivationWindow.utcDay,
        repeat: ActivationRepeat.call,
      );
      final back = ActivationRules.tryFromJson(
        ReferenceProgram.sota,
        rules.toJson(),
      )!;
      expect(back.minQsos, 6);
      expect(back.window, ActivationWindow.utcDay);
      expect(back.repeat, ActivationRepeat.call);
      // Rules stored before `repeat` existed still load.
      expect(
        ActivationRules.tryFromJson(ReferenceProgram.sota, {
          'minQsos': 4,
          'window': 'session',
        })!.repeat,
        ActivationRepeat.callBandMode,
      );
      for (final bad in <Object?>[
        null,
        'text',
        <String, Object>{},
        {'minQsos': 0, 'window': 'utcDay'},
        {'minQsos': 10001, 'window': 'utcDay'},
        {'minQsos': '4', 'window': 'utcDay'},
        {'minQsos': 4, 'window': 'weekly'},
      ]) {
        expect(
          ActivationRules.tryFromJson(ReferenceProgram.sota, bad),
          isNull,
          reason: '$bad',
        );
      }
    });
  });

  group('Activation', () {
    test('adif fields carry the own reference and grid', () {
      const a = Activation(
        id: 'a',
        accountId: 'acc',
        program: ReferenceProgram.pota,
        reference: 'US-0001',
        startedAt: 1,
        myGridsquare: 'FN54vh',
      );
      expect(a.adifFields, {
        'MY_POTA_REF': 'US-0001',
        'MY_GRIDSQUARE': 'FN54vh',
      });
      expect(a.isActive, isTrue);
      expect(
        const Activation(
          id: 'b',
          accountId: 'acc',
          program: ReferenceProgram.sota,
          reference: 'G/LD-001',
          startedAt: 1,
          endedAt: 2,
        ).adifFields,
        {'MY_SOTA_REF': 'G/LD-001'},
      );
    });
  });
}
