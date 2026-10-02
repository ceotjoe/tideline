import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

void main() {
  group('Band', () {
    test('parses names case-insensitively', () {
      expect(Band.tryParse('20M')?.name, '20m');
      expect(Band.tryParse('70cm')?.lowerHz, 420000000);
      expect(Band.tryParse('11m'), isNull);
    });

    test('finds the band for a frequency, edges inclusive', () {
      expect(Band.forFrequency(14074000)?.name, '20m');
      expect(Band.forFrequency(14000000)?.name, '20m');
      expect(Band.forFrequency(14350000)?.name, '20m');
      expect(Band.forFrequency(14350001), isNull);
      expect(Band.forFrequency(145500000)?.name, '2m');
      expect(Band.forFrequency(27555000), isNull); // CB
    });

    test('steps through bands in order', () {
      expect(Band.tryParse('40m')!.next?.name, '30m');
      expect(Band.tryParse('40m')!.previous?.name, '60m');
      expect(Band.all.first.previous, isNull);
      expect(Band.all.last.next, isNull);
    });

    test('covers the ADIF table', () {
      expect(Band.all, hasLength(33));
      expect(adifSpecVersion, '3.1.7');
    });
  });

  group('Mode', () {
    test('maps submodes to their parent mode', () {
      expect(Mode.tryParse('usb').toString(), 'SSB/USB');
      expect(Mode.tryParse('FT4').toString(), 'MFSK/FT4');
      expect(Mode.tryParse('FT8').toString(), 'FT8');
      expect(Mode.tryParse('CW')!.label, 'CW');
    });

    test('maps ADIF import-only modes', () {
      expect(Mode.tryParse('C4FM').toString(), 'DIGITALVOICE/C4FM');
      expect(Mode.tryParse('PSK31').toString(), 'PSK/PSK31');
    });

    test('accepts mode plus submode', () {
      expect(Mode.tryParse('SSB', submode: 'lsb').toString(), 'SSB/LSB');
      expect(Mode.tryParse('DIGITALVOICE DMR').toString(), 'DIGITALVOICE/DMR');
      expect(Mode.tryParse('SSB', submode: 'FT8'), isNull);
    });

    test('rejects unknown modes', () {
      expect(Mode.tryParse(''), isNull);
      expect(Mode.tryParse('MORSE'), isNull);
    });

    test('suggests default reports', () {
      expect(Mode.tryParse('USB')!.defaultReport, '59');
      expect(Mode.tryParse('CW')!.defaultReport, '599');
      expect(Mode.tryParse('FT8')!.defaultReport, '-10');
      expect(Mode.tryParse('FT4')!.defaultReport, '-10');
    });
  });

  group('Frequency', () {
    test('converts ADIF MHz without float errors', () {
      expect(Frequency.fromAdifMhz('14.074'), 14074000);
      expect(Frequency.fromAdifMhz('.1365'), 136500);
      expect(Frequency.fromAdifMhz('7'), 7000000);
      expect(Frequency.fromAdifMhz('144.3001234'), 144300123);
      expect(Frequency.fromAdifMhz('abc'), isNull);
      expect(Frequency.fromAdifMhz('0'), isNull);
      expect(Frequency.toAdifMhz(14074000), '14.074');
      expect(Frequency.toAdifMhz(7000000), '7');
      expect(Frequency.toAdifMhz(136500), '0.1365');
    });

    test('round-trips', () {
      for (final hz in [1840000, 3573000, 50313000, 432200000, 10368100000]) {
        expect(Frequency.fromAdifMhz(Frequency.toAdifMhz(hz)), hz);
      }
    });

    test('interprets operator input', () {
      expect(Frequency.parseUserInput('14.074'), 14074000);
      expect(Frequency.parseUserInput('14,074'), 14074000);
      expect(Frequency.parseUserInput('14074'), 14074000);
      expect(Frequency.parseUserInput('144300'), 144300000);
      expect(Frequency.parseUserInput('7'), 7000000);
      expect(Frequency.parseUserInput(''), isNull);
    });
  });

  group('UtcDateTime', () {
    test('parses and formats ADIF dates and times', () {
      final t = UtcDateTime.tryParseAdif('20261002', '1405')!;
      expect(t.value, DateTime.utc(2026, 10, 2, 14, 5));
      expect(t.adifDate, '20261002');
      expect(t.adifTime, '140500');
      expect(UtcDateTime.tryParseAdif('20261002', '140530')!.value.second, 30);
    });

    test('rejects impossible dates', () {
      expect(UtcDateTime.tryParseAdif('20260231', '1200'), isNull);
      expect(UtcDateTime.tryParseAdif('20261002', '2460'), isNull);
      expect(UtcDateTime.tryParseAdif('2026-10-02', '1200'), isNull);
      expect(UtcDateTime.tryParseAdif('19000101', '1200'), isNull);
    });

    test('is always UTC', () {
      final local = DateTime(2026, 10, 2, 12);
      expect(UtcDateTime(local).value.isUtc, isTrue);
    });
  });

  group('Maidenhead', () {
    test('computes locators offline', () {
      // Known reference: W1AW, Newington CT (41.7148 N, 72.7273 W) → FN31pr.
      expect(Maidenhead.fromLatLon(41.7148, -72.7273), 'FN31pr');
      expect(Maidenhead.fromLatLon(41.7148, -72.7273, length: 4), 'FN31');
      expect(Maidenhead.fromLatLon(-33.8688, 151.2093), 'QF56od');
      expect(Maidenhead.fromLatLon(90, 180), 'RR99xx');
    });

    test('normalises and validates', () {
      expect(Maidenhead.normalize('jo40HD'), 'JO40hd');
      expect(Maidenhead.normalize('JO40'), 'JO40');
      expect(Maidenhead.normalize('JO40hd12'), 'JO40hd12');
      expect(Maidenhead.normalize('JZ40'), isNull);
      expect(Maidenhead.normalize('JO4'), isNull);
    });

    test('centre lies inside the square', () {
      final (lat, lon) = Maidenhead.centerOf('JN58td')!;
      expect(Maidenhead.fromLatLon(lat, lon), 'JN58td');
    });
  });

  group('Callsign', () {
    test('normalises and accepts common forms', () {
      for (final c in ['do1hoz', 'DO1HOZ/P', 'EA8/DO1HOZ', 'VP2V/W1AW/M']) {
        expect(Callsign.tryParse(c), isNotNull, reason: c);
      }
      expect(Callsign.tryParse(' do1hoz ')!.value, 'DO1HOZ');
    });

    test('rejects non-callsigns', () {
      for (final c in [
        '',
        'AB',
        'HELLO',
        '12345',
        'DO1HOZ/',
        '/DO1HOZ',
        'DO1 HOZ',
        'DO1HOZ//P',
      ]) {
        expect(Callsign.tryParse(c), isNull, reason: c);
      }
    });

    test('extracts the base call and spells it out', () {
      expect(Callsign.tryParse('EA8/DO1HOZ/P')!.baseCall, 'DO1HOZ');
      expect(Callsign.tryParse('DO1HOZ')!.spelledOut, 'D O 1 H O Z');
    });
  });

  group('Qso', () {
    Qso sample({int? freq, Map<String, String> fields = const {}}) => Qso(
      id: newUuidV4(),
      accountId: 'acc',
      stationProfileId: 'st',
      call: Callsign.tryParse('DL1ABC')!,
      timeOn: UtcDateTime(DateTime.utc(2026, 10, 2, 14, 5, 33)),
      band: Band.tryParse('20m')!,
      mode: Mode.tryParse('USB')!,
      freqHz: freq,
      fields: fields,
    );

    test('keeps non-core fields by upper-case name, drops empty ones', () {
      final q = sample(
        fields: {'name': 'Anna', 'APP_FOO_BAR': 'x', 'CALL': 'X', 'QTH': ''},
      );
      expect(q.fields, {'NAME': 'Anna', 'APP_FOO_BAR': 'x'});
    });

    test('dupe key truncates to the minute', () {
      expect(
        sample().dupeKey.minuteMillis,
        DateTime.utc(2026, 10, 2, 14, 5).millisecondsSinceEpoch,
      );
    });

    test('detects edits Wavelog cannot patch', () {
      final a = sample(freq: 14200000);
      expect(
        Qso.changesServerReadOnlyFields(a, a.copyWith(rstSent: '57')),
        isFalse,
      );
      expect(
        Qso.changesServerReadOnlyFields(a, a.copyWith(freqHz: 14210000)),
        isTrue,
      );
      expect(
        Qso.changesServerReadOnlyFields(
          a,
          a.copyWith(mode: Mode.tryParse('CW')),
        ),
        isTrue,
      );
    });

    test('validation finds issues offline', () {
      final now = UtcDateTime(DateTime.utc(2026, 10, 2, 14, 10));
      expect(validateQso(sample(freq: 14200000), now: now), isEmpty);
      expect(
        validateQso(sample(freq: 7100000), now: now),
        contains(QsoIssue.frequencyOutsideBand),
      );
      expect(
        validateQso(sample(fields: {'GRIDSQUARE': 'XX99'}), now: now),
        contains(QsoIssue.invalidGridsquare),
      );
      final early = UtcDateTime(DateTime.utc(2026, 10, 2, 13));
      expect(
        validateQso(sample(), now: early),
        contains(QsoIssue.timeInFuture),
      );
    });
  });
}
