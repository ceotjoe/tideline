import 'dart:math' as math;

import 'package:tideline_domain/src/reference/program_reference.dart';

/// Great-circle distance, computed offline.
abstract final class GeoDistance {
  static const double _earthRadiusKm = 6371.0088;

  /// Distance in kilometres between two points in decimal degrees.
  static double km(double lat1, double lon1, double lat2, double lon2) {
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLon = rad(lon2 - lon1);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return 2 * _earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }

  /// A latitude/longitude box that contains every point within [radiusKm] of
  /// the centre, for narrowing a database query before exact distances are
  /// computed. It is slightly generous, never too small.
  ///
  /// The longitude part is a list of ranges because the box can cross the
  /// antimeridian (two ranges) or cover the whole circle near a pole.
  static ({
    double minLat,
    double maxLat,
    List<({double min, double max})> lonRanges,
  })
  boundingBox(double latitude, double longitude, double radiusKm) {
    const kmPerDegree = _earthRadiusKm * math.pi / 180;
    final dLat = radiusKm / kmPerDegree * 1.001 + 1e-9;
    final minLat = math.max<double>(-90, latitude - dLat);
    final maxLat = math.min<double>(90, latitude + dLat);
    const full = [(min: -180.0, max: 180.0)];
    if (latitude - dLat <= -90 || latitude + dLat >= 90) {
      return (minLat: minLat, maxLat: maxLat, lonRanges: full);
    }
    final angular = radiusKm / _earthRadiusKm;
    final cosLat = math.cos(latitude * math.pi / 180);
    final ratio = math.sin(angular) / cosLat;
    if (angular >= math.pi / 2 || ratio >= 1) {
      return (minLat: minLat, maxLat: maxLat, lonRanges: full);
    }
    final dLon = math.asin(ratio) * 180 / math.pi * 1.001 + 1e-9;
    final lo = longitude - dLon;
    final hi = longitude + dLon;
    final ranges = lo < -180
        ? [(min: lo + 360, max: 180.0), (min: -180.0, max: hi)]
        : hi > 180
        ? [(min: lo, max: 180.0), (min: -180.0, max: hi - 360)]
        : [(min: lo, max: hi)];
    return (minLat: minLat, maxLat: maxLat, lonRanges: ranges);
  }

  /// The [limit] references nearest to the point, closest first.
  ///
  /// References without coordinates are left out.
  static List<({ProgramReference reference, double km})> nearest(
    Iterable<ProgramReference> references,
    double latitude,
    double longitude, {
    int limit = 20,
  }) {
    final found = <({ProgramReference reference, double km})>[];
    for (final r in references) {
      final lat = r.latitude;
      final lon = r.longitude;
      if (lat == null || lon == null) continue;
      found.add((reference: r, km: km(latitude, longitude, lat, lon)));
    }
    found.sort((a, b) => a.km.compareTo(b.km));
    return found.length > limit ? found.sublist(0, limit) : found;
  }
}
