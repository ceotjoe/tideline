import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

const _parser = FleParser();

/// 2026-10-02 12:00 UTC.
final _today = DateTime.utc(2026, 10, 2, 12);

FleResult parse(String text, {DateTime? now}) =>
    _parser.parse(text, todayUtc: _today, nowUtc: now);

FleQso only(String text) {
  final r = parse(text);
  expect(r.errors, isEmpty, reason: '${r.errors.map((e) => e.problem)}');
  expect(r.qsos, hasLength(1));
  return r.qsos.single;
}

FleProblem problem(String text) {
  final r = parse(text);
  expect(r.errors, hasLength(1), reason: text);
  return r.errors.single.problem;
}

String hhmm(FleQso q) =>
    '${q.timeOn.value.hour.toString().padLeft(2, '0')}'
    '${q.timeOn.value.minute.toString().padLeft(2, '0')}';

void main() {
  group('lines that set what follows', () {
    test('band and mode, then QSOs by time and call', () {
      final r = parse('20m ssb\n1734 4W7EST\n5 HB9HIL\n1800 DJ7NT\n13 DF2ET');
      expect(r.lines.first, isA<FleHeaderLine>());
      expect(r.qsos.map((q) => q.call), ['4W7EST', 'HB9HIL', 'DJ7NT', 'DF2ET']);
      expect(r.qsos.map(hhmm), ['1734', '1735', '1800', '1813']);
      expect(r.qsos.map((q) => q.band.name).toSet(), {'20m'});
      expect(r.qsos.first.mode.mode, 'SSB');
      expect(r.qsos.first.timeOn.value, DateTime.utc(2026, 10, 2, 17, 34));
    });

    test('a two-digit fragment replaces the minutes, one digit the last', () {
      final r = parse('40m cw\n1212 DL1AAA\n3 DL1BBB\n30 DL1CCC');
      expect(r.qsos.map(hhmm), ['1212', '1213', '1230']);
    });

    test('a frequency sets the band, a band clears the frequency', () {
      final r = parse('10.112 cw\n1200 DL1AAA\n17m\n1201 DL1BBB');
      expect(r.qsos[0].band.name, '30m');
      expect(r.qsos[0].freqHz, 10112000);
      expect(r.qsos[1].band.name, '17m');
      expect(r.qsos[1].freqHz, isNull);
    });

    test('band and mode may share a line with a QSO', () {
      final q = only('20m ssb 1200 DL1ABC');
      expect((q.band.name, q.mode.mode), ('20m', 'SSB'));
    });

    test('a submode is read as such', () {
      final q = only('20m usb\n1200 DL1ABC');
      expect((q.mode.mode, q.mode.submode), ('SSB', 'USB'));
      final ft4 = only('20m ft4\n1200 DL1ABC');
      expect((ft4.mode.mode, ft4.mode.submode), ('MFSK', 'FT4'));
    });

    test('date, day + and time zone', () {
      final r = parse(
        'date 2026-01-05\n20m cw\n2330 DL1AAA\nday +\n0015 DL1BBB\n'
        'timezone +2\n0200 DL1CCC',
      );
      expect(r.qsos[0].timeOn.value, DateTime.utc(2026, 1, 5, 23, 30));
      expect(r.qsos[1].timeOn.value, DateTime.utc(2026, 1, 6, 0, 15));
      // 02:00 at UTC+2 is 00:00 UTC.
      expect(r.qsos[2].timeOn.value, DateTime.utc(2026, 1, 6));
    });

    test('day ++ adds two days; a bare ISO date works too', () {
      final r = parse('2026-02-27\n20m cw\n1200 DL1AAA\nday ++\n1200 DL1BBB');
      expect(r.qsos[1].timeOn.value, DateTime.utc(2026, 3, 1, 12));
    });

    test('timezone and tzofs, either way', () {
      expect(
        only('tzofs -5\n20m cw\n1200 DL1AAA').timeOn.value,
        DateTime.utc(2026, 10, 2, 17),
      );
      expect(
        only('TIMEZONE +2\n20m cw\n1200 DL1AAA').timeOn.value,
        DateTime.utc(2026, 10, 2, 10),
      );
    });

    test('QSOs get today (UTC) without a date', () {
      expect(only('20m cw\n0100 DL1AAA').timeOn.value.day, 2);
    });
  });

  group('what a QSO line carries', () {
    test('reports, locator, name, reference, comment, QSL message', () {
      final q = only(
        '20m cw\n1200 DL1ABC 579 599 JO62 @Anna de-0034 <good op> '
        '[tnx fer qso]',
      );
      expect((q.rstSent, q.rstRcvd), ('579', '599'));
      expect(q.fields['GRIDSQUARE'], 'JO62');
      expect(q.fields['NAME'], 'Anna');
      expect(q.fields['POTA_REF'], 'DE-0034');
      expect(q.fields['COMMENT'], 'good op');
      expect(q.fields['QSLMSG'], 'tnx fer qso');
    });

    test('the mode decides the default reports and how short ones fill', () {
      expect(
        (
          only('20m ssb\n1200 DL1ABC').rstSent,
          only('20m cw\n1200 DL1ABC').rstSent,
        ),
        ('59', '599'),
      );
      expect(only('20m ft8\n1200 DL1ABC').rstSent, '-10');
      // One report is the sent one; received falls back to the default.
      final q = only('20m cw\n1200 DL1ABC 5');
      expect((q.rstSent, q.rstRcvd), ('559', '599'));
      // Single digits are the second digit of the report.
      final two = only('20m ssb\n1200 DL1ABC 7 3');
      expect((two.rstSent, two.rstRcvd), ('57', '53'));
      final cw = only('20m cw\n1200 DL1ABC 57 33');
      expect((cw.rstSent, cw.rstRcvd), ('579', '339'));
      // Three digits for phone keep the first two.
      expect(only('20m ssb\n1200 DL1ABC 599').rstSent, '59');
    });

    test('digital modes take dB reports', () {
      final q = only('20m ft8\n1200 DL1ABC -4 -12');
      expect((q.rstSent, q.rstRcvd), ('-4', '-12'));
      expect(only('20m ft8\n1200 DL1ABC 5').rstSent, '+5');
    });

    test('references are told apart by shape', () {
      expect(
        only('20m cw\n1200 DL1ABC dm/bw-001').fields['SOTA_REF'],
        'DM/BW-001',
      );
      expect(
        only('20m cw\n1200 DL1ABC dlff-0123').fields['WWFF_REF'],
        'DLFF-0123',
      );
      expect(only('20m cw\n1200 DL1ABC eu-005').fields['IOTA'], 'EU-005');
      expect(
        only('20m cw\n1200 DL1ABC ch-0067,ch-0068').fields['POTA_REF'],
        'CH-0067,CH-0068',
      );
    });

    test('a locator may carry # and any of 4, 6 and 8 characters', () {
      expect(only('20m cw\n1200 DL1ABC #jo62').fields['GRIDSQUARE'], 'JO62');
      expect(only('20m cw\n1200 DL1ABC jo62qm').fields['GRIDSQUARE'], 'JO62qm');
      expect(
        only('20m cw\n1200 DL1ABC JO62QM55').fields['GRIDSQUARE'],
        'JO62qm55',
      );
    });

    test('portable and prefixed calls', () {
      expect(only('20m cw\n1200 la8aja/p').call, 'LA8AJA/P');
      expect(only('20m cw\n1200 hb0/f4ans').call, 'HB0/F4ANS');
      expect(only('20m cw\n1200 dl/4w7est/m').call, 'DL/4W7EST/M');
      expect(only('20m cw\n1200 w1aw/4').call, 'W1AW/4');
    });

    test('extra ADIF fields; tx_pwr stays until changed', () {
      final r = parse(
        '20m cw\n1200 DL1AAA <tx_pwr:50> <rig:QRPlabs QCX>\n'
        '1 DL1BBB\n2 DL1CCC <tx_pwr:>\n3 DL1DDD',
      );
      expect(r.qsos[0].fields['TX_PWR'], '50');
      expect(r.qsos[0].fields['RIG'], 'QRPlabs QCX');
      expect(r.qsos[1].fields['TX_PWR'], '50');
      expect(r.qsos[1].fields.containsKey('RIG'), isFalse);
      expect(r.qsos[2].fields.containsKey('TX_PWR'), isFalse);
      expect(r.qsos[3].fields.containsKey('TX_PWR'), isFalse);
    });
  });

  group('contest exchange', () {
    test('sent after a comma, received after a dot', () {
      final q = only('20m cw\n2112 DN5CE ,1.12');
      expect(q.fields['STX'], '1');
      expect(q.fields['SRX'], '12');
    });

    test('text exchanges are strings', () {
      final q = only('20m cw\n2114 DN5CE ,2,EU.NM');
      expect(q.fields['STX'], '2');
      expect(q.fields['STX_STRING'], 'EU');
      expect(q.fields['SRX_STRING'], 'NM');
    });

    test('the sent exchange stays, counts up with ,++ and stops with ,+0', () {
      final r = parse(
        '20m cw\n1200 DL1AAA ,1,++.10\n1 DL1BBB .11\n2 DL1CCC .12\n'
        '3 DL1DDD ,+0.13\n4 DL1EEE .14',
      );
      expect(r.errors, isEmpty);
      // ,+0 stops the counting after that QSO.
      expect(r.qsos.map((q) => q.fields['STX']), ['1', '2', '3', '4', '4']);
      expect(r.qsos.map((q) => q.fields['SRX']), [
        '10',
        '11',
        '12',
        '13',
        '14',
      ]);
    });

    test(',- clears the sent exchange', () {
      final r = parse('20m cw\n1200 DL1AAA ,5.1\n1 DL1BBB ,-.2');
      expect(r.qsos[0].fields['STX'], '5');
      expect(r.qsos[1].fields.containsKey('STX'), isFalse);
      expect(r.qsos[1].fields['SRX'], '2');
    });

    test('no received exchange: nothing is written', () {
      expect(only('20m cw\n1200 DL1AAA ,5').fields.containsKey('STX'), isFalse);
    });
  });

  group('problems are reported per line, and the rest is still read', () {
    test('typed problems', () {
      expect(problem('20m cw\n1200 DL1ABC blah'), FleProblem.unknownToken);
      expect(problem('20m cw\n2575 DL1ABC'), FleProblem.invalidTime);
      expect(problem('20m cw\n2459 DL1ABC'), FleProblem.invalidTime);
      expect(problem('20m cw\n5 DL1ABC'), FleProblem.missingTime);
      expect(problem('1200 DL1ABC'), FleProblem.missingBand);
      expect(problem('20m\n1200 DL1ABC'), FleProblem.missingMode);
      expect(problem('20m cw\n1200'), FleProblem.missingCall);
      expect(problem('20m cw\n1200 JO62'), FleProblem.missingCall);
      expect(problem('20m cw\n1200 DL1ABC DL2XYZ'), FleProblem.secondCallsign);
      expect(
        problem('20m cw\n1200 DL1ABC JO62 JN58'),
        FleProblem.duplicateSegment,
      );
      expect(
        problem('20m cw\n1200 DL1ABC 59 59 59'),
        FleProblem.tooManyReports,
      );
      expect(problem('20m cw\n1200 59 DL1ABC'), FleProblem.reportBeforeCall);
      expect(problem('sat'), FleProblem.unsupportedBand);
      expect(problem('9999m'), FleProblem.unsupportedBand);
      expect(problem('13.000'), FleProblem.frequencyOutsideBands);
      expect(problem('date 2026-02-30'), FleProblem.invalidDate);
      expect(problem('timezone +20'), FleProblem.invalidTimezone);
      expect(problem('day ${'+' * 40}'), FleProblem.invalidDayShift);
      expect(
        problem('20m cw\n1200 DL1ABC <tx_pwr 5'),
        FleProblem.unclosedBracket,
      );
      expect(
        problem('20m cw\n1200 DL1ABC <my_call:DL1XYZ>'),
        FleProblem.reservedField,
      );
      expect(
        problem('20m cw\n1200 DL1ABC <name:Anna>'),
        FleProblem.reservedField,
      );
      expect(
        problem('20m cw\n1200 DL1ABC <call:DL1XYZ>'),
        FleProblem.reservedField,
      );
      expect(problem('20m ft8\n1200 DL1ABC 599'), FleProblem.invalidReport);
      expect(problem('20m cw\n1200 DL1ABC -5'), FleProblem.invalidReport);
    });

    test('the line number and the word are kept', () {
      final r = parse('20m cw\n\n1200 DL1ABC blah');
      final e = r.errors.single;
      expect((e.number, e.token, e.text), (3, 'blah', '1200 DL1ABC blah'));
    });

    test(
      'a bad line does not stop the others, nor change what they inherit',
      () {
        final r = parse(
          '20m cw\n1200 DL1AAA\n40m bogus 1201 DL1BBB\n1202 DL1CCC',
        );
        expect(r.errors, hasLength(1));
        // The band word of the bad line was not kept.
        expect(r.qsos.map((q) => q.band.name), ['20m', '20m']);
      },
    );

    test('long fields and long lines', () {
      expect(
        problem('20m cw\n1200 DL1ABC <rig:${'x' * 300}>'),
        FleProblem.valueTooLong,
      );
      expect(
        problem('20m cw\n1200 DL1ABC <${'x' * 300}>'),
        FleProblem.valueTooLong,
      );
      expect(
        problem('20m cw\n1200 DL1ABC ${'a ' * 400}'),
        FleProblem.lineTooLong,
      );
    });

    test('too many lines are not read', () {
      const small = FleParser(maxLines: 3);
      final r = small.parse(
        '20m cw\n1200 DL1AAA\n1 DL1BBB\n2 DL1CCC\n3 DL1DDD',
        todayUtc: _today,
      );
      expect(r.qsos, hasLength(2));
      expect(r.errors.single.problem, FleProblem.tooManyLines);
    });

    test('control characters are removed from fields', () {
      final q = only('20m cw\n1200 DL1ABC <rig:a\u0007b>');
      expect(q.fields['RIG'], 'a b');
      final c = only('20m cw\n1200 DL1ABC <a\u0007b>');
      expect(c.fields['COMMENT'], 'a b');
    });
  });

  group('warnings', () {
    test('a QSO earlier than the one before it', () {
      final r = parse('20m cw\n1200 DL1AAA\n1100 DL1BBB');
      expect((r.lines[2] as FleQsoLine).warnings, [
        FleWarning.timeWentBackwards,
      ]);
      expect((r.lines[1] as FleQsoLine).warnings, isEmpty);
      // With a day line it is fine.
      final ok = parse('20m cw\n1200 DL1AAA\nday +\n1100 DL1BBB');
      expect((ok.lines[3] as FleQsoLine).warnings, isEmpty);
    });

    test('a QSO in the future', () {
      final r = parse('20m cw\n1300 DL1AAA', now: _today);
      expect((r.lines[1] as FleQsoLine).warnings, [FleWarning.futureTime]);
      expect(
        (parse('20m cw\n1200 DL1AAA', now: _today).lines[1] as FleQsoLine)
            .warnings,
        isEmpty,
      );
    });
  });

  group('to a QSO of the log', () {
    test('carries everything, with the source fle', () {
      final q = only('20m ssb\n1200 DL1ABC 59 57 JO62 @Anna');
      final qso = q.toQso(id: 'x', accountId: 'acc', stationProfileId: 'st');
      expect(qso.call.value, 'DL1ABC');
      expect((qso.rstSent, qso.rstRcvd), ('59', '57'));
      expect(qso.field('NAME'), 'Anna');
      expect(qso.field('GRIDSQUARE'), 'JO62');
      expect(qso.source, QsoSource.fle);
      expect(qso.timeOn, q.timeOn);
    });

    test('extra fields (an activation) are added', () {
      final q = only('20m ssb\n1200 DL1ABC');
      final qso = q.toQso(
        id: 'x',
        accountId: 'acc',
        extraFields: const {'MY_POTA_REF': 'DE-0001'},
      );
      expect(qso.field('MY_POTA_REF'), 'DE-0001');
    });
  });

  group('whitespace and case', () {
    test('any line ending, blank lines, tabs and upper case', () {
      final r = parse('20M  CW\r\n\r\n\t1200\tdl1abc  \r\n1 DL1XYZ\r');
      expect(r.errors, isEmpty);
      expect(r.qsos.map((q) => q.call), ['DL1ABC', 'DL1XYZ']);
    });

    test('empty text has no lines', () {
      expect(parse('').lines, isEmpty);
      expect(parse('\n \n').lines, isEmpty);
    });
  });
}
