import 'package:meta/meta.dart';

/// A point in time that is guaranteed to be UTC.
///
/// QSO times are always UTC. This type keeps that explicit in signatures;
/// converting to local time is a presentation concern only.
@immutable
final class UtcDateTime implements Comparable<UtcDateTime> {
  /// Wraps [value], converting it to UTC.
  new(DateTime value) : value = value.toUtc();

  /// From UTC epoch milliseconds (the database representation).
  factory fromMillis(int millis) =>
      UtcDateTime(DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true));

  /// The current time.
  factory now() => UtcDateTime(DateTime.now());

  /// Parses ADIF `QSO_DATE` (YYYYMMDD) and `TIME_ON` (HHMM or HHMMSS).
  /// Returns null for anything malformed or out of range.
  static UtcDateTime? tryParseAdif(String date, String time) {
    final d = RegExp(r'^(\d{4})(\d{2})(\d{2})$').firstMatch(date.trim());
    final t = RegExp(r'^(\d{2})(\d{2})(\d{2})?$').firstMatch(time.trim());
    if (d == null || t == null) return null;
    final y = int.parse(d[1]!);
    final mo = int.parse(d[2]!);
    final da = int.parse(d[3]!);
    final h = int.parse(t[1]!);
    final mi = int.parse(t[2]!);
    final s = int.parse(t[3] ?? '0');
    if (y < 1930 ||
        mo < 1 ||
        mo > 12 ||
        da < 1 ||
        h > 23 ||
        mi > 59 ||
        s > 59) {
      return null;
    }
    final dt = DateTime.utc(y, mo, da, h, mi, s);
    // Reject dates such as 20260231 that DateTime silently rolls over.
    if (dt.month != mo || dt.day != da) return null;
    return UtcDateTime(dt);
  }

  /// The wrapped UTC value.
  final DateTime value;

  /// UTC epoch milliseconds.
  int get millis => value.millisecondsSinceEpoch;

  /// ADIF `QSO_DATE`: YYYYMMDD.
  String get adifDate =>
      '${value.year.toString().padLeft(4, '0')}'
      '${_two(value.month)}${_two(value.day)}';

  /// ADIF `TIME_ON` with seconds: HHMMSS.
  String get adifTime =>
      '${_two(value.hour)}${_two(value.minute)}${_two(value.second)}';

  /// Truncated to the minute (Wavelog's duplicate granularity).
  UtcDateTime get toMinute => UtcDateTime(
    DateTime.utc(value.year, value.month, value.day, value.hour, value.minute),
  );

  static String _two(int v) => v.toString().padLeft(2, '0');

  @override
  int compareTo(UtcDateTime other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) =>
      other is UtcDateTime && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toIso8601String();
}
