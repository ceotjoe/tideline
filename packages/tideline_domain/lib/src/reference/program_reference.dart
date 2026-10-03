import 'package:meta/meta.dart';
import 'package:tideline_domain/src/reference/reference_program.dart';

/// One summit, park or flora/fauna area from a downloaded reference pack.
@immutable
final class ProgramReference {
  /// Creates a reference.
  const new({
    required this.program,
    required this.reference,
    required this.name,
    this.region,
    this.latitude,
    this.longitude,
    this.validFrom,
    this.validTo,
    this.active = true,
  });

  /// The programme it belongs to.
  final ReferenceProgram program;

  /// The reference, for example `US-0001`. Always upper case.
  final String reference;

  /// The name of the summit, park or area.
  final String name;

  /// A region, state or country, as the source gives it. Search text only.
  final String? region;

  /// Decimal degrees, positive north; null if the source has none.
  final double? latitude;

  /// Decimal degrees, positive east; null if the source has none.
  final double? longitude;

  /// First day (UTC) the reference is valid, or null if the source has none.
  final DateTime? validFrom;

  /// Last day (UTC) the reference is valid, or null if the source has none.
  final DateTime? validTo;

  /// False when the source marks the reference as retired or inactive.
  final bool active;

  /// Whether the reference can be activated on [day] (UTC).
  bool isValidOn(DateTime day) {
    if (!active) return false;
    final d = DateTime.utc(day.year, day.month, day.day);
    if (validFrom != null && d.isBefore(validFrom!)) return false;
    if (validTo != null && d.isAfter(validTo!)) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is ProgramReference &&
      other.program == program &&
      other.reference == reference &&
      other.name == name &&
      other.region == region &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.validFrom == validFrom &&
      other.validTo == validTo &&
      other.active == active;

  @override
  int get hashCode => Object.hash(
    program,
    reference,
    name,
    region,
    latitude,
    longitude,
    validFrom,
    validTo,
    active,
  );

  @override
  String toString() => 'ProgramReference($reference, $name)';
}
