import 'package:test/test.dart';
import 'package:tideline_domain/src/contest/wpx_prefix.dart';

void main() {
  group('WpxPrefix.of', () {
    const cases = {
      // Plain calls: up to and including the last digit before the suffix.
      'N8BJQ': 'N8',
      'WA9ALS': 'WA9',
      'DL1ABC': 'DL1',
      'K1ABC': 'K1',
      'W1AW': 'W1',
      '9A1A': '9A1',
      '2E0ABC': '2E0',
      '3DA0XX': '3DA0',
      '4U1ITU': '4U1',
      'HB9ABC': 'HB9',
      'VK9XX': 'VK9',
      'TM100A': 'TM100',
      'dl1abc': 'DL1',
      ' DL1ABC ': 'DL1',
      // No digit: first two letters plus 0.
      'RAEM': 'RA0',
      // Operating suffixes are ignored.
      'DL1ABC/P': 'DL1',
      'DL1ABC/M': 'DL1',
      'DL1ABC/MM': 'DL1',
      'DL1ABC/AM': 'DL1',
      'DL1ABC/QRP': 'DL1',
      'DL1ABC/P/QRP': 'DL1',
      // A trailing digit replaces the prefix digit.
      'K1ABC/2': 'K2',
      'K1ABC/E': 'K1',
      'W1AW/AG': 'W1',
      'N8BJQ/7': 'N7',
      'OH2AAA/7': 'OH7',
      '3DA0XX/5': '3DA5',
      '9A1A/3': '9A3',
      'RAEM/3': 'RA3',
      'DL1ABC/7/P': 'DL7',
      // Prefix/call and call/prefix.
      'LX/DL1ABC': 'LX0',
      'PA/DL1ABC': 'PA0',
      'PA/DL1ABC/P': 'PA0',
      'EA8/DL1ABC': 'EA8',
      'KH6/W1AW': 'KH6',
      'W1AW/KH6': 'KH6',
      'DL1ABC/EA8': 'EA8',
      '9A/DL1ABC': '9A0',
      'VE3ABC/VE': 'VE0',
      'EA8/DL1ABC/P': 'EA8',
    };
    cases.forEach((call, prefix) {
      test('"$call" gives $prefix', () => expect(WpxPrefix.of(call), prefix));
    });

    test('unusable input gives null', () {
      for (final bad in [
        '',
        '  ',
        '/',
        'DL1ABC/',
        '/DL1ABC',
        'DL1//ABC',
        'DL1-ABC',
        'A',
        'EA8/DL1ABC/EA9/OE2',
        'DL1ABC/P/',
      ]) {
        expect(WpxPrefix.of(bad), isNull, reason: bad);
      }
    });

    test('a call ending in a digit is its own prefix', () {
      expect(WpxPrefix.of('R2D2'), 'R2D2');
    });
  });
}
