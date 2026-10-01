import 'package:meta/meta.dart';

/// A hybrid logical clock timestamp.
///
/// HLCs order changes across devices even when wall clocks drift slightly,
/// which device-to-device sync relies on. The string form
/// (`<millis>-<counter>-<deviceId>`) sorts lexicographically in causal order
/// because both numeric parts are zero-padded.
@immutable
final class Hlc implements Comparable<Hlc> {
  /// Creates a timestamp from its components.
  const new(this.millis, this.counter, this.deviceId)
    : assert(millis >= 0, 'millis must not be negative'),
      assert(counter >= 0 && counter <= maxCounter, 'counter out of range');

  /// Parses the canonical string form produced by [toString].
  factory parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null) {
      throw FormatException('Invalid HLC', value);
    }
    return Hlc(
      int.parse(match[1]!),
      int.parse(match[2]!, radix: 16),
      match[3]!,
    );
  }

  static final RegExp _pattern = RegExp(r'^(\d{15})-([0-9a-f]{4})-(.+)$');

  /// Highest counter value before the clock refuses to advance.
  static const int maxCounter = 0xffff;

  /// Physical component: UTC milliseconds since the epoch.
  final int millis;

  /// Logical component, disambiguating events within the same millisecond.
  final int counter;

  /// Identifier of the device that produced this timestamp.
  final String deviceId;

  @override
  int compareTo(Hlc other) {
    final byMillis = millis.compareTo(other.millis);
    if (byMillis != 0) return byMillis;
    final byCounter = counter.compareTo(other.counter);
    if (byCounter != 0) return byCounter;
    return deviceId.compareTo(other.deviceId);
  }

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.millis == millis &&
      other.counter == counter &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(millis, counter, deviceId);

  @override
  String toString() =>
      '${millis.toString().padLeft(15, '0')}-'
      '${counter.toRadixString(16).padLeft(4, '0')}-$deviceId';
}

/// Produces monotonically increasing [Hlc] timestamps for one device.
class HlcClock {
  /// Creates a clock for [deviceId]. [nowMillis] is injectable for tests.
  new(this.deviceId, {int Function()? nowMillis})
    : _nowMillis = nowMillis ?? _systemNowMillis;

  /// This device's identifier, embedded in every timestamp.
  final String deviceId;
  final int Function() _nowMillis;
  Hlc? _last;

  static int _systemNowMillis() =>
      DateTime.now().toUtc().millisecondsSinceEpoch;

  /// Returns a timestamp for a local event, strictly greater than any
  /// timestamp previously returned or received.
  Hlc now() {
    final wall = _nowMillis();
    final last = _last;
    final Hlc next;
    if (last == null || wall > last.millis) {
      next = Hlc(wall, 0, deviceId);
    } else {
      next = _bump(last.millis, last.counter);
    }
    return _last = next;
  }

  /// Merges a timestamp received from another device so that subsequent
  /// local timestamps sort after it.
  Hlc receive(Hlc remote) {
    final wall = _nowMillis();
    final last = _last ?? Hlc(0, 0, deviceId);
    final maxMillis = [
      wall,
      last.millis,
      remote.millis,
    ].reduce((a, b) => a > b ? a : b);
    final Hlc next;
    if (maxMillis == last.millis && maxMillis == remote.millis) {
      next = _bump(
        maxMillis,
        last.counter > remote.counter ? last.counter : remote.counter,
      );
    } else if (maxMillis == last.millis) {
      next = _bump(maxMillis, last.counter);
    } else if (maxMillis == remote.millis) {
      next = _bump(maxMillis, remote.counter);
    } else {
      next = Hlc(maxMillis, 0, deviceId);
    }
    return _last = next;
  }

  Hlc _bump(int millis, int counter) {
    if (counter >= Hlc.maxCounter) {
      // Too many events within one millisecond: move into the next one.
      return Hlc(millis + 1, 0, deviceId);
    }
    return Hlc(millis, counter + 1, deviceId);
  }
}
