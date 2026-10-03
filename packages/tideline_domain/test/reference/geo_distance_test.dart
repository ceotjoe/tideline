import 'dart:math';

import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

ProgramReference ref(String r, double? lat, double? lon) => ProgramReference(
  program: ReferenceProgram.pota,
  reference: r,
  name: r,
  latitude: lat,
  longitude: lon,
);

void main() {
  test('known distances', () {
    // Berlin to Munich is about 504 km.
    expect(GeoDistance.km(52.52, 13.405, 48.137, 11.575), closeTo(504, 3));
    expect(GeoDistance.km(10, 20, 10, 20), 0);
    // Across the antimeridian.
    expect(GeoDistance.km(0, 179.5, 0, -179.5), closeTo(111.2, 1));
  });

  test('nearest sorts, limits and skips references without coordinates', () {
    final list = [
      ref('A', 48, 11),
      ref('B', 52.5, 13.4),
      ref('C', null, null),
      ref('D', 48.2, 11.6),
    ];
    final near = GeoDistance.nearest(list, 48.137, 11.575, limit: 2);
    expect(near.map((e) => e.reference.reference), ['D', 'A']);
    expect(near.first.km, lessThan(near.last.km));
  });

  group('boundingBox', () {
    bool inBox(
      ({
        double minLat,
        double maxLat,
        List<({double min, double max})> lonRanges,
      })
      b,
      double lat,
      double lon,
    ) =>
        lat >= b.minLat &&
        lat <= b.maxLat &&
        b.lonRanges.any((r) => lon >= r.min && lon <= r.max);

    test('contains every point within the radius (random sampling)', () {
      final random = Random(9);
      for (var i = 0; i < 400; i++) {
        final lat = random.nextDouble() * 180 - 90;
        final lon = random.nextDouble() * 360 - 180;
        final radius = const [10.0, 100.0, 1000.0, 5000.0][random.nextInt(4)];
        final box = GeoDistance.boundingBox(lat, lon, radius);
        for (var j = 0; j < 40; j++) {
          final plat = random.nextDouble() * 180 - 90;
          final plon = random.nextDouble() * 360 - 180;
          if (GeoDistance.km(lat, lon, plat, plon) <= radius) {
            expect(
              inBox(box, plat, plon),
              isTrue,
              reason: '($lat,$lon) r=$radius contains ($plat,$plon)',
            );
          }
        }
      }
    });

    test('crossing the antimeridian gives two ranges; poles give all', () {
      expect(GeoDistance.boundingBox(0, 179.9, 100).lonRanges, hasLength(2));
      expect(GeoDistance.boundingBox(0, -179.9, 100).lonRanges, hasLength(2));
      expect(GeoDistance.boundingBox(0, 10, 100).lonRanges, hasLength(1));
      final pole = GeoDistance.boundingBox(89.9, 10, 100);
      expect(pole.lonRanges.single.min, -180);
      expect(pole.lonRanges.single.max, 180);
      expect(pole.maxLat, 90);
    });
  });
}
