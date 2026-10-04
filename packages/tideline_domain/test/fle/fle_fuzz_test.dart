import 'dart:math';

import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Text that is an input from outside (pasted, typed): the parser must read
/// any of it without throwing, within limits and in reasonable time.
void main() {
  const parser = FleParser();
  final today = DateTime.utc(2026, 10, 2);

  final pool = [
    '20m',
    '40m',
    '70cm',
    'sat',
    '14.205',
    '7.030',
    '10.112',
    '1.8',
    'cw',
    'ssb',
    'ft8',
    'usb',
    'rtty',
    'mfsk',
    '1200',
    '2359',
    '2400',
    '0000',
    '5',
    '13',
    '59',
    '599',
    '-12',
    '+5',
    '57+10',
    'DL1ABC',
    'w1aw/4',
    'EA8/DL1ABC/P',
    'JO62',
    '#JO62qm',
    'JO31DH',
    'de-0034',
    'dm/bw-001',
    'dlff-0123',
    'eu-005',
    'ch-0067,ch-0068',
    '@Anna',
    '@',
    ',1.12',
    ',2,EU.NM',
    ',++',
    ',+0',
    ',-',
    '.5',
    ',',
    '.',
    '<c>',
    '<tx_pwr:50>',
    '<my_call:X>',
    '<a:b',
    '[msg]',
    '[unclosed',
    'day +',
    'day ++++++++++++++++++++++++++++++++++++++++',
    'date 2026-02-30',
    'date 2026-10-05',
    'timezone +2',
    'tzofs -99',
    '\t',
    '  ',
    '\u0000',
    String.fromCharCode(0x202E),
    'ä',
    '日本',
    '😀',
    '/',
    '//',
    '-',
    '+',
    '<>',
    '[]',
  ];

  String randomText(Random r) {
    final lines = r.nextInt(30);
    final out = StringBuffer();
    for (var i = 0; i < lines; i++) {
      final tokens = r.nextInt(8);
      for (var j = 0; j < tokens; j++) {
        out
          ..write(pool[r.nextInt(pool.length)])
          ..write(r.nextInt(5) == 0 ? '' : ' ');
      }
      out.write(['\n', '\r\n', '\r'][r.nextInt(3)]);
    }
    return out.toString();
  }

  void check(FleResult result) {
    for (final line in result.lines) {
      expect(line.number, greaterThan(0));
      if (line is FleQsoLine) {
        final q = line.qso;
        expect(Callsign.tryParse(q.call), isNotNull, reason: line.text);
        expect(q.timeOn.value.isUtc, isTrue);
        expect(q.timeOn.value.year, inInclusiveRange(1929, 2100));
        expect(q.rstSent, isNotEmpty);
        expect(q.rstRcvd, isNotEmpty);
        for (final MapEntry(:key, :value) in q.fields.entries) {
          expect(key, matches(RegExp(r'^[A-Z][A-Z0-9_]*$')));
          expect(value.length, lessThanOrEqualTo(520), reason: key);
          expect(value, isNot(contains('\u0000')));
        }
        // It can always become a QSO of the log.
        q.toQso(id: 'x', accountId: 'acc');
      }
    }
  }

  test('random token soup is read without throwing, within the rules', () {
    final random = Random(20261002);
    for (var i = 0; i < 4000; i++) {
      final text = randomText(random);
      final result = parser.parse(text, todayUtc: today, nowUtc: today);
      check(result);
      // Deterministic.
      final again = parser.parse(text, todayUtc: today, nowUtc: today);
      expect(again.lines.length, result.lines.length);
      expect(
        [for (final l in again.lines) l.runtimeType],
        [for (final l in result.lines) l.runtimeType],
      );
    }
  });

  test('random characters are read without throwing', () {
    final random = Random(7);
    for (var i = 0; i < 1500; i++) {
      final n = random.nextInt(300);
      final text = String.fromCharCodes(
        [
          for (var j = 0; j < n; j++)
            if (random.nextInt(8) == 0)
              random.nextInt(0x10FFFF)
            else
              0x20 + random.nextInt(0x5F),
        ].map((c) => c >= 0xD800 && c <= 0xDFFF ? 0x20 : c),
      );
      check(parser.parse(text, todayUtc: today));
    }
  });

  test('a line starting with the shorthand of one QSO, mutated', () {
    final random = Random(99);
    const base = '1200 DL1ABC 579 599 JO62 @Anna de-0034 <c> [m] ,1.12';
    for (var i = 0; i < 2000; i++) {
      final chars = base.split('');
      for (var k = 0; k < 1 + random.nextInt(4); k++) {
        final at = random.nextInt(chars.length);
        switch (random.nextInt(3)) {
          case 0:
            chars.removeAt(at);
          case 1:
            chars.insert(at, pool[random.nextInt(pool.length)]);
          default:
            chars[at] = String.fromCharCode(0x20 + random.nextInt(0x5F));
        }
        if (chars.isEmpty) chars.add('x');
      }
      check(parser.parse('20m cw\n${chars.join()}', todayUtc: today));
    }
  });

  test('hostile sizes stay fast and bounded', () {
    final sw = Stopwatch()..start();
    final hostile = <String>[
      '20m cw\n${'1200 DL1ABC\n' * 20000}',
      '<' * 200000,
      '[' * 200000,
      '20m cw\n1200 DL1ABC ${',' * 400}',
      '20m cw\n1200 DL1ABC ${',1.' * 150}',
      '20m cw\n1200 DL1ABC ${'<a:' * 160}',
      'day +\n' * 100000,
      '\n' * 500000,
      'x' * 3000000,
      '20m cw\n1200 DL1ABC ${'JO62 ' * 90}',
    ];
    for (final text in hostile) {
      final result = parser.parse(text, todayUtc: today);
      expect(result.lines.length, lessThanOrEqualTo(parser.maxLines + 1));
      check(result);
    }
    expect(sw.elapsed, lessThan(const Duration(seconds: 20)));
  });
}
