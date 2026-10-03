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
