import 'package:test/test.dart';
import 'package:tideline_domain/src/scp/scp_database.dart';

void main() {
  group('ScpParser', () {
    test('parses basic callsigns', () {
      const input = '''
DL1ABC
N0CALL
EA8/DO1HOZ''';
      final db = ScpParser.parse(input);
      expect(db.length, 3);
      expect(db.contains('DL1ABC'), isTrue);
      expect(db.contains('N0CALL'), isTrue);
      expect(db.contains('EA8/DO1HOZ'), isTrue);
    });

    test('ignores comments starting with #', () {
      const input = '''
# This is a comment
DL1ABC
# Another comment
N0CALL''';
      final db = ScpParser.parse(input);
      expect(db.length, 2);
      expect(db.contains('DL1ABC'), isTrue);
      expect(db.contains('N0CALL'), isTrue);
    });

    test('ignores blank lines', () {
      const input = '''
DL1ABC

N0CALL

EA8/DO1HOZ''';
      final db = ScpParser.parse(input);
      expect(db.length, 3);
    });

    test('trims whitespace from each line', () {
      const input = '''
  DL1ABC
	N0CALL
EA8/DO1HOZ  ''';
      final db = ScpParser.parse(input);
      expect(db.length, 3);
      expect(db.contains('DL1ABC'), isTrue);
    });

    test('converts to uppercase', () {
      const input = '''
dl1abc
n0call
ea8/do1hoz''';
      final db = ScpParser.parse(input);
      expect(db.contains('DL1ABC'), isTrue);
      expect(db.contains('N0CALL'), isTrue);
      expect(db.contains('EA8/DO1HOZ'), isTrue);
    });

    test('deduplicates callsigns', () {
      const input = '''
DL1ABC
DL1ABC
N0CALL
DL1ABC''';
      final db = ScpParser.parse(input);
      expect(db.length, 2);
      expect(db.calls.toList(), ['DL1ABC', 'N0CALL']);
    });

    test('skips invalid lines', () {
      const input = '''
DL1ABC
AB
TOOLONGCALLSIGNWITHMORETHAN15CHARS
N0CALL
123456
EA8/DO1HOZ''';
      final db = ScpParser.parse(input);
      // Only DL1ABC, N0CALL, EA8/DO1HOZ are valid
      expect(db.length, 3);
      expect(db.contains('DL1ABC'), isTrue);
      expect(db.contains('N0CALL'), isTrue);
      expect(db.contains('EA8/DO1HOZ'), isTrue);
    });

    test('rejects input larger than 8 MiB', () {
      // Create a string larger than 8 MiB
      final largeInput = 'A' * (8388608 + 1);
      expect(
        () => ScpParser.parse(largeInput),
        throwsA(isA<ScpFormatException>()),
      );
    });

    test('caps at 200,000 unique calls', () {
      // Generate 200,001 unique calls
      final lines = <String>[];
      for (var i = 0; i < 200001; i++) {
        lines.add('CALL$i');
      }
      final input = lines.join('\n');
      final db = ScpParser.parse(input);
      expect(db.length, lessThanOrEqualTo(200000));
    });

    test('accepts only valid callsign format [A-Z0-9/]{3,15}', () {
      const input = '''
ABC
ABCD
12AB
A/B/C
TEST/CALL
AB/CD/EF/GH
INVALID@CALL
TEST.CALL
/TEST/
TEST//CALL''';
      final db = ScpParser.parse(input);
      // Valid: ABC, ABCD, 12AB, A/B/C, TEST/CALL, AB/CD/EF/GH
      // Invalid: INVALID@CALL, TEST.CALL, /TEST/, TEST//CALL
      expect(db.contains('ABC'), isTrue);
      expect(db.contains('ABCD'), isTrue);
      expect(db.contains('12AB'), isTrue);
      expect(db.contains('A/B/C'), isTrue);
      expect(db.contains('TEST/CALL'), isTrue);
      expect(db.contains('AB/CD/EF/GH'), isTrue);
      expect(db.contains('INVALID@CALL'), isFalse);
      expect(db.contains('TEST.CALL'), isFalse);
      expect(db.contains('/TEST/'), isFalse);
      expect(db.contains('TEST//CALL'), isFalse);
    });
  });

  group('ScpDatabase.partial', () {
    late ScpDatabase db;

    setUp(() {
      const input = '''
DL1ABC
DL1ABD
DL1ABA
DL2ABC
EA8/DO1HOZ
EA8/DO1HOS
N0CALL
N0CALIFORNIA
N0CALI
N0CAL''';
      db = ScpParser.parse(input);
    });

    test('returns empty for fragment shorter than 2 characters', () {
      expect(db.partial('A'), isEmpty);
      expect(db.partial(''), isEmpty);
      expect(db.partial('1'), isEmpty);
    });

    test('returns exact matches with the fragment', () {
      final results = db.partial('DL1AB');
      expect(results, containsAll(['DL1ABC', 'DL1ABD', 'DL1ABA']));
    });

    test('sorts prefix matches first', () {
      final results = db.partial('DL1');
      // DL2ABC is in the DB but doesn't start with DL1
      // So prefix matches (DL1ABC, DL1ABD, DL1ABA) should come before DL2ABC
      expect(
        results.takeWhile((c) => c.startsWith('DL1')).toList(),
        containsAll(['DL1ABC', 'DL1ABD', 'DL1ABA']),
      );
    });

    test('is case-insensitive', () {
      final results1 = db.partial('dl1ab');
      final results2 = db.partial('DL1AB');
      final results3 = db.partial('Dl1Ab');
      expect(results1, results2);
      expect(results2, results3);
    });

    test('respects limit parameter', () {
      final results = db.partial('DL', limit: 2);
      expect(results.length, lessThanOrEqualTo(2));
    });

    test('returns default limit of 30 when not specified', () {
      final input = List.generate(
        50,
        (i) => 'CALL${i.toString().padLeft(2, '0')}',
      ).join('\n');
      final longDb = ScpParser.parse(input);
      final results = longDb.partial('CALL');
      expect(results.length, lessThanOrEqualTo(30));
    });

    test('finds substring matches', () {
      final results = db.partial('HOZ');
      expect(results, contains('EA8/DO1HOZ'));
    });

    test('finds matches at different positions', () {
      final results = db.partial('O1H');
      expect(results, contains('EA8/DO1HOZ'));
      expect(results, contains('EA8/DO1HOS'));
    });

    test('sorts results alphabetically within prefix vs non-prefix', () {
      final results = db.partial('DL');
      final prefixMatches = results.where((c) => c.startsWith('DL')).toList();
      expect(prefixMatches, equals(prefixMatches..sort()));
    });
  });

  group('ScpDatabase.nPlusOne', () {
    late ScpDatabase db;

    setUp(() {
      const input = '''
DL1ABC
DL1ABD
DL1AB
DL1ABCD
DL2ABC
N0CALL
N0CALI''';
      db = ScpParser.parse(input);
    });

    test('finds substitution: DL1ABC vs DL1ABD', () {
      final results = db.nPlusOne('DL1ABC');
      expect(results, containsAll(['DL1ABD']));
    });

    test('finds deletion: DL1ABC vs DL1AB', () {
      final results = db.nPlusOne('DL1ABC');
      expect(results, containsAll(['DL1AB']));
    });

    test('finds insertion: DL1AB vs DL1ABC', () {
      final results = db.nPlusOne('DL1AB');
      expect(results, containsAll(['DL1ABC', 'DL1ABD']));
    });

    test('excludes the input call itself', () {
      final results = db.nPlusOne('DL1ABC');
      expect(results, isNot(contains('DL1ABC')));
    });

    test('is case-insensitive', () {
      final results1 = db.nPlusOne('dl1abc');
      final results2 = db.nPlusOne('DL1ABC');
      expect(results1, results2);
    });

    test('returns empty list when no edit-distance-1 calls exist', () {
      final results = db.nPlusOne('XXXXXX');
      expect(results, isEmpty);
    });

    test('respects limit parameter', () {
      final results = db.nPlusOne('DL1ABC', limit: 1);
      expect(results.length, lessThanOrEqualTo(1));
    });

    test('returns sorted results', () {
      const input = '''
TEST
TEAT
BEST
ZEST''';
      final testDb = ScpParser.parse(input);
      final results = testDb.nPlusOne('TEST');
      expect(results, equals(results..sort()));
    });
  });

  group('ScpDatabase', () {
    test('provides contains() method', () {
      const input = 'DL1ABC\nN0CALL';
      final db = ScpParser.parse(input);
      expect(db.contains('DL1ABC'), isTrue);
      expect(db.contains('N0CALL'), isTrue);
      expect(db.contains('NONEXISTENT'), isFalse);
    });

    test('contains() is case-insensitive', () {
      const input = 'DL1ABC';
      final db = ScpParser.parse(input);
      expect(db.contains('dl1abc'), isTrue);
      expect(db.contains('DL1ABC'), isTrue);
      expect(db.contains('Dl1Abc'), isTrue);
    });

    test('provides length property', () {
      const input = '''
DL1ABC
N0CALL
EA8/DO1HOZ''';
      final db = ScpParser.parse(input);
      expect(db.length, 3);
    });

    test('provides calls iterable in sorted order', () {
      const input = '''
DL1ABC
N0CALL
EA8/DO1HOZ
APPLE''';
      final db = ScpParser.parse(input);
      expect(db.calls.toList(), ['APPLE', 'DL1ABC', 'EA8/DO1HOZ', 'N0CALL']);
    });

    test('empty input creates empty database', () {
      final db = ScpParser.parse('');
      expect(db.length, 0);
      expect(db.calls, isEmpty);
    });

    test('comments-only input creates empty database', () {
      const input = '''
# Comment 1
# Comment 2
# Comment 3''';
      final db = ScpParser.parse(input);
      expect(db.length, 0);
    });
  });

  group('Performance', () {
    test('partial queries on 50,000 calls are fast (under 500 ms total)', () {
      // Generate 50,000 synthetic calls
      final lines = <String>[];
      for (var i = 0; i < 50000; i++) {
        // Generate calls like CALL0, CALL1, ..., CALLZZZZ with variations
        final prefix = i < 1000 ? 'C' : 'D';
        final suffix = (i % 1000).toString().padLeft(4, '0');
        lines.add('$prefix$suffix');
      }
      final input = lines.join('\n');
      final db = ScpParser.parse(input);

      // Measure time for 100 partial queries
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 100; i++) {
        final fragment = i.toString().padLeft(2, '0');
        db.partial(fragment);
      }
      stopwatch.stop();

      final elapsed = stopwatch.elapsedMilliseconds;
      expect(
        elapsed,
        lessThan(500),
        reason: 'Expected 100 queries in under 500 ms, took $elapsed ms',
      );
    });
  });

  test('prefix matches are never crowded out by earlier other matches', () {
    final db = ScpParser.parse(
      [
        for (var i = 0; i < 40; i++) 'A${i.toString().padLeft(2, '0')}XY',
        'XYZ1',
      ].join('\n'),
    );
    expect(db.partial('XY', limit: 5).first, 'XYZ1');
  });
}
