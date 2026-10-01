import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

void main() {
  group('Hlc', () {
    test('round-trips through its string form', () {
      const hlc = Hlc(1767225600000, 42, 'device-a');
      expect(Hlc.parse(hlc.toString()), hlc);
    });

    test('device ids may contain dashes', () {
      final hlc = Hlc(1, 2, newUuidV4());
      expect(Hlc.parse(hlc.toString()), hlc);
    });

    test('string order matches causal order', () {
      const a = Hlc(999, 0xffff, 'z');
      const b = Hlc(1000, 0, 'a');
      expect(a.compareTo(b), lessThan(0));
      expect(a.toString().compareTo(b.toString()), lessThan(0));
    });

    test('rejects malformed input', () {
      expect(() => Hlc.parse('nope'), throwsFormatException);
      expect(() => Hlc.parse('1-2-'), throwsFormatException);
      expect(() => Hlc.parse('x-2-dev'), throwsFormatException);
    });
  });

  group('HlcClock', () {
    test('is strictly monotonic even if the wall clock goes backwards', () {
      var wall = 1000;
      final clock = HlcClock('dev', nowMillis: () => wall);
      final first = clock.now();
      wall = 500; // clock skew backwards
      final second = clock.now();
      final third = clock.now();
      expect(second.compareTo(first), greaterThan(0));
      expect(third.compareTo(second), greaterThan(0));
    });

    test('orders local events after received remote ones', () {
      final clock = HlcClock('local', nowMillis: () => 1000);
      final merged = clock.receive(const Hlc(5000, 7, 'remote'));
      expect(merged.compareTo(const Hlc(5000, 7, 'remote')), greaterThan(0));
      expect(clock.now().compareTo(merged), greaterThan(0));
    });

    test('rolls over to the next millisecond when the counter is full', () {
      final clock = HlcClock('dev', nowMillis: () => 10)
        ..receive(const Hlc(10, Hlc.maxCounter, 'other'));
      final next = clock.now();
      expect(next.millis, 11);
      expect(next.counter, lessThanOrEqualTo(Hlc.maxCounter));
    });
  });
}
