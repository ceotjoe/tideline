import 'package:test/test.dart';
import 'package:tideline_domain/src/contest/contest_rates.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

void main() {
  final base = DateTime.utc(2026, 10, 24, 12);
  UtcDateTime at(int minutes, [int seconds = 0]) =>
      UtcDateTime(base.add(Duration(minutes: minutes, seconds: seconds)));
  final now = at(60);

  group('windows', () {
    // 30 QSOs one per two minutes from 12:00 to 12:58 (the one at 12:00 is
    // exactly 60 minutes before now and so outside the 60-minute window),
    // plus one in the future (ignored).
    final times = [for (var i = 0; i < 30; i++) at(i * 2), at(90)];

    test('counts QSOs in (now - window, now]', () {
      expect(
        ContestRates.countInLast(times, now, const Duration(minutes: 10)),
        4,
      );
      expect(
        ContestRates.countInLast(times, now, const Duration(minutes: 60)),
        29,
      );
      // Boundary: a QSO exactly 10 minutes ago is outside, one at now inside.
      expect(
        ContestRates.countInLast(
          [at(50), at(60)],
          now,
          const Duration(minutes: 10),
        ),
        1,
      );
    });

    test('projects to QSOs per hour', () {
      // 12:52, 54, 56, 58 = 4 QSOs in the last 10 minutes (12:50 excluded).
      expect(ContestRates.last10MinutesRate(times, now), 24);
      expect(ContestRates.last60MinutesRate(times, now), 29);
      // 12:32 .. 12:58 = 14 QSOs in 30 minutes.
      expect(
        ContestRates.projectedRate(times, now, const Duration(minutes: 30)),
        28,
      );
      expect(ContestRates.projectedRate(times, now, Duration.zero), 0);
    });

    test('empty log', () {
      expect(ContestRates.last10MinutesRate(const [], now), 0);
      expect(ContestRates.bestWindow(const [], now), isNull);
    });
  });

  group('rateOverLast', () {
    test('uses the span between the oldest and newest of the last n', () {
      // 10 QSOs each minute: 9 intervals in 9 minutes = 60/h.
      final times = [for (var i = 0; i < 10; i++) at(i)];
      expect(ContestRates.rateOverLast10(times, now), 60);
    });

    test('only the last n count, input order is irrelevant', () {
      final times = [
        at(0),
        at(1),
        for (var i = 0; i < 10; i++) at(30 + i * 2),
      ].reversed.toList();
      // Last 10: every 2 minutes, 9 intervals in 18 minutes = 30/h.
      expect(ContestRates.rateOverLast10(times, now), closeTo(30, 1e-9));
    });

    test('null with too few QSOs or no time span', () {
      expect(ContestRates.rateOverLast10([at(0), at(1)], now), isNull);
      expect(
        ContestRates.rateOverLast100([
          for (var i = 0; i < 99; i++) at(i % 50),
        ], now),
        isNull,
      );
      expect(ContestRates.rateOverLast([at(1), at(1)], now, 2), isNull);
      expect(ContestRates.rateOverLast([at(1), at(2)], now, 1), isNull);
    });

    test('100 QSOs', () {
      final times = [for (var i = 0; i < 100; i++) at(0, i * 30)];
      // 99 intervals in 99 * 30 s = 120/h.
      expect(ContestRates.rateOverLast100(times, now), closeTo(120, 1e-9));
    });
  });

  group('bestWindow', () {
    test('finds the busiest 60 minutes', () {
      // 3 QSOs early, then 5 within 20 minutes, then 2 late.
      final times = [
        at(0),
        at(1),
        at(2),
        at(200),
        at(205),
        at(210),
        at(215),
        at(220),
        at(400),
        at(401),
      ];
      final best = ContestRates.bestWindow(times, at(500))!;
      expect(best.count, 5);
      expect(best.start, at(200));
    });

    test('the window is half open', () {
      final times = [at(0), at(60)];
      expect(ContestRates.bestWindow(times, at(120))!.count, 1);
      expect(ContestRates.bestWindow([at(0), at(59, 59)], at(120))!.count, 2);
    });

    test('earliest wins ties; later QSOs than now are ignored', () {
      final best = ContestRates.bestWindow([
        at(0),
        at(1),
        at(200),
        at(201),
        at(300),
      ], at(250))!;
      expect(best.count, 2);
      expect(best.start, at(0));
      final onlyFuture = ContestRates.bestWindow([at(300)], at(250));
      expect(onlyFuture, isNull);
    });

    test('custom window', () {
      final best = ContestRates.bestWindow(
        [at(0), at(5), at(9), at(30)],
        at(100),
        window: const Duration(minutes: 10),
      )!;
      expect(best.count, 3);
    });
  });
}
