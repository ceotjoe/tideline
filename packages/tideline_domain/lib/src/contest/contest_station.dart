import 'package:meta/meta.dart';
import 'package:tideline_domain/src/dxcc/dxcc.dart';

/// What the contest rules know about one station (mine or theirs).
///
/// Every field except [call] may be unknown (null). A predicate that needs
/// an unknown value does not match.
@immutable
final class ContestStation {
  /// Creates a station.
  const new({
    required this.call,
    this.dxcc,
    this.continent,
    this.cqz,
    this.ituz,
    this.grid,
    this.state,
    this.dok,
  });

  /// From a resolver result; unknown (null) [match] gives a station with
  /// only a call.
  factory fromMatch(String call, DxccMatch? match) => ContestStation(
    call: call,
    dxcc: match?.entity.dxcc,
    continent: match?.continent,
    cqz: match?.cqz,
    ituz: match?.ituz,
  );

  /// Upper-case callsign.
  final String call;

  /// ADIF DXCC entity code.
  final int? dxcc;

  /// AF, AN, AS, EU, NA, OC or SA.
  final String? continent;

  /// CQ zone.
  final int? cqz;

  /// ITU zone.
  final int? ituz;

  /// Maidenhead locator (4 or 6 characters, any case).
  final String? grid;

  /// State, province or similar (my station only).
  final String? state;

  /// DARC DOK (my station only).
  final String? dok;
}
