import 'dart:math' as math;

/// Maidenhead locator ("grid square") helpers, computed fully offline.
abstract final class Maidenhead {
  static final RegExp _pattern = RegExp(
    r'^[A-R]{2}(?:[0-9]{2}(?:[A-X]{2}(?:[0-9]{2})?)?)?$',
  );

  /// Normalises [input] to canonical case (`jo40hd` → `JO40hd`), or returns
  /// null if it is not a valid 2-, 4-, 6- or 8-character locator.
  static String? normalize(String input) {
    final text = input.trim().toUpperCase();
    if (!_pattern.hasMatch(text)) return null;
    if (text.length <= 4) return text;
    return text.substring(0, 4) +
        text.substring(4, 6).toLowerCase() +
        text.substring(6);
  }

  /// The locator for [latitude]/[longitude] with [length] characters
  /// (4, 6 or 8).
  static String fromLatLon(
    double latitude,
    double longitude, {
    int length = 6,
  }) {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw RangeError('Coordinates out of range');
    }
    if (length != 4 && length != 6 && length != 8) {
      throw ArgumentError.value(length, 'length', 'must be 4, 6 or 8');
    }
    // Shift to positive ranges; clamp the exact upper edges inside.
    var lon = math.min(longitude + 180, 359.999999);
    var lat = math.min(latitude + 90, 179.999999);
    final out = StringBuffer();
    const a = 65; // 'A'
    out
      ..writeCharCode(a + lon ~/ 20)
      ..writeCharCode(a + lat ~/ 10);
    lon %= 20;
    lat %= 10;
    out
      ..write(lon ~/ 2)
      ..write(lat ~/ 1);
    lon %= 2;
    lat %= 1;
    if (length >= 6) {
      out
        ..writeCharCode(97 + (lon * 12).floor())
        ..writeCharCode(97 + (lat * 24).floor());
      lon = (lon * 12) % 1;
      lat = (lat * 24) % 1;
    }
    if (length == 8) {
      out
        ..write((lon * 10).floor())
        ..write((lat * 10).floor());
    }
    return out.toString();
  }

  /// Centre of [locator] as (latitude, longitude), or null if invalid.
  static (double, double)? centerOf(String locator) {
    final l = normalize(locator)?.toUpperCase();
    if (l == null) return null;
    var lon = (l.codeUnitAt(0) - 65) * 20.0 - 180;
    var lat = (l.codeUnitAt(1) - 65) * 10.0 - 90;
    var lonSize = 20.0;
    var latSize = 10.0;
    if (l.length >= 4) {
      lon += int.parse(l[2]) * 2;
      lat += int.parse(l[3]);
      lonSize = 2;
      latSize = 1;
    }
    if (l.length >= 6) {
      lon += (l.codeUnitAt(4) - 65) * (2 / 24);
      lat += (l.codeUnitAt(5) - 65) * (1 / 24);
      lonSize = 2 / 24;
      latSize = 1 / 24;
    }
    if (l.length == 8) {
      lon += int.parse(l[6]) * (2 / 240);
      lat += int.parse(l[7]) * (1 / 240);
      lonSize = 2 / 240;
      latSize = 1 / 240;
    }
    return (lat + latSize / 2, lon + lonSize / 2);
  }
}
