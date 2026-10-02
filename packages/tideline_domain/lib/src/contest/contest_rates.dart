import 'package:tideline_domain/src/values/utc_date_time.dart';

/// The best window found by [ContestRates.bestWindow].
final class BestWindow {
  /// Creates the result.
  const new({required this.count, required this.start});

  /// QSOs in the window.
  final int count;

  /// Start of the window (the time of its first QSO).
  final UtcDateTime start;
}

/// QSO rates from QSO times. All functions are pure: they take the times and
/// `now` and never read a clock.
///
/// Times need not be sorted. Times after `now` are ignored.
abstract final class ContestRates {
  /// QSOs in the half-open window `(now - window, now]`.
  static int countInLast(
    Iterable<UtcDateTime> times,
    UtcDateTime now,
    Duration window,
  ) {
    final from = now.millis - window.inMilliseconds;
    return times.where((t) => t.millis > from && t.millis <= now.millis).length;
  }

  /// The QSOs in the last [window] projected to QSOs per hour
  /// (`count * 1h / window`): window 10 minutes gives `count * 6`.
  static double projectedRate(
    Iterable<UtcDateTime> times,
    UtcDateTime now,
    Duration window,
  ) {
    if (window <= Duration.zero) return 0;
    return countInLast(times, now, window) *
        Duration.millisecondsPerHour /
        window.inMilliseconds;
  }

  /// Projected rate of the last 10 minutes.
  static double last10MinutesRate(
    Iterable<UtcDateTime> times,
    UtcDateTime now,
  ) => projectedRate(times, now, const Duration(minutes: 10));

  /// Projected rate of the last 60 minutes (equal to the count).
  static double last60MinutesRate(
    Iterable<UtcDateTime> times,
    UtcDateTime now,
  ) => projectedRate(times, now, const Duration(minutes: 60));

  /// The rate over the last [n] QSOs before or at [now], in QSOs per hour:
  /// `(n - 1)` intervals over the time between the oldest and the newest of
  /// them. Null if there are fewer than [n] QSOs (or n < 2) or if they all
  /// share one instant.
  static double? rateOverLast(
    Iterable<UtcDateTime> times,
    UtcDateTime now,
    int n,
  ) {
    if (n < 2) return null;
    final sorted = _sortedUpTo(times, now);
    if (sorted.length < n) return null;
    final span = sorted.last - sorted[sorted.length - n];
    if (span <= 0) return null;
    return (n - 1) * Duration.millisecondsPerHour / span;
  }

  /// [rateOverLast] for 10 QSOs.
  static double? rateOverLast10(Iterable<UtcDateTime> times, UtcDateTime now) =>
      rateOverLast(times, now, 10);

  /// [rateOverLast] for 100 QSOs.
  static double? rateOverLast100(
    Iterable<UtcDateTime> times,
    UtcDateTime now,
  ) => rateOverLast(times, now, 100);

  /// The window of [window] length (default 60 minutes), half-open
  /// `[start, start + window)` and starting at a QSO, that holds the most
  /// QSOs up to [now]; the earliest wins ties. Null if there are no QSOs.
  static BestWindow? bestWindow(
    Iterable<UtcDateTime> times,
    UtcDateTime now, {
    Duration window = const Duration(minutes: 60),
  }) {
    final sorted = _sortedUpTo(times, now);
    if (sorted.isEmpty) return null;
    var best = 0;
    var bestStart = sorted.first;
    var lo = 0;
    for (var hi = 0; hi < sorted.length; hi++) {
      while ((sorted[hi] - sorted[lo]) >= window.inMilliseconds) {
        lo++;
      }
      final count = hi - lo + 1;
      if (count > best) {
        best = count;
        bestStart = sorted[lo];
      }
    }
    return BestWindow(count: best, start: UtcDateTime.fromMillis(bestStart));
  }

  static List<int> _sortedUpTo(Iterable<UtcDateTime> times, UtcDateTime now) =>
      [
        for (final t in times)
          if (t.millis <= now.millis) t.millis,
      ]..sort();
}
