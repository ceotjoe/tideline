import 'dart:io';

import 'package:test/test.dart';
import 'package:tideline_domain/tideline_domain.dart';

void main() {
  // The real bundled file, so tests catch format changes on update.
  final db = DxccDatabase.parseCsv(
    File('../../app/assets/reference/cty.csv').readAsStringSync(),
  );

  DxccMatch resolve(String call) => db.resolve(call)!;

  test('loads every entity', () {
    expect(db.entities.length, greaterThan(340));
  });

  test('resolves plain callsigns by longest prefix', () {
    final dl = resolve('DO1HOZ');
    expect(dl.entity.dxcc, 230);
    expect(dl.entity.name, 'Fed. Rep. of Germany');
    expect(dl.continent, 'EU');
    expect((dl.cqz, dl.ituz), (14, 28));
    expect(dl.entity.longitude, closeTo(10.0, 0.01)); // east positive
    expect(resolve('W1AW').entity.dxcc, 291);
  });

  test('applies prefix zone overrides', () {
    // R8 is in CQ zone 17, ITU 30 in Asiatic Russia.
    final r8 = resolve('R8AA');
    expect(r8.entity.dxcc, 15);
    expect((r8.cqz, r8.ituz), (17, 30));
  });

  test('handles location prefixes and suffixes', () {
    expect(resolve('EA8/DO1HOZ').entity.primaryPrefix, 'EA8');
    expect(resolve('DO1HOZ/EA8').entity.primaryPrefix, 'EA8');
    expect(resolve('DO1HOZ/P').entity.dxcc, 230);
    expect(resolve('EA8/DO1HOZ/P').entity.primaryPrefix, 'EA8');
    expect(resolve('W1AW/4').entity.dxcc, 291);
  });

  test('maritime and aeronautical mobile have no entity', () {
    expect(db.resolve('DO1HOZ/MM'), isNull);
    expect(db.resolve('DO1HOZ/AM'), isNull);
  });

  test('WAE-only entities report the DXCC entity and the WAE entity', () {
    final it9 = resolve('IT9ABC');
    expect(it9.entity.dxcc, 248);
    expect(it9.entity.waeOnly, isFalse);
    expect(it9.waeEntity?.name, 'Sicily');
  });

  test('exact callsign entries win over prefixes', () {
    // =3D2CCC is Conway Reef although 3D2 is Fiji.
    expect(resolve('3D2CCC').entity.name, 'Conway Reef');
    expect(resolve('3D2ABC').entity.name, 'Fiji');
  });

  test('unknown input resolves to nothing', () {
    expect(db.resolve(''), isNull);
    expect(db.resolve('/'), isNull);
  });
}
