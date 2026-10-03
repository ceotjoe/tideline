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
}
