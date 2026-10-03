import 'package:meta/meta.dart';
import 'package:tideline_domain/src/reference/reference_program.dart';

/// A SOTA, POTA or WWFF activation: the time the operator is at one
/// reference and logs from it.
@immutable
final class Activation {
  /// Creates an activation.
  const new({
    required this.id,
    required this.accountId,
    required this.program,
    required this.reference,
    required this.startedAt,
    this.myGridsquare,
    this.stationProfileId,
    this.endedAt,
  });

  /// Local UUID.
  final String id;

  /// Owning account.
  final String accountId;

  /// The programme.
  final ReferenceProgram program;

  /// The reference being activated, upper case (`DL/WS-001`).
  final String reference;

  /// The operator's grid square at the reference, if known.
  final String? myGridsquare;

  /// Station location used for the QSOs, if chosen.
  final String? stationProfileId;

  /// Start (UTC millis).
  final int startedAt;

  /// End (UTC millis), or null while active.
  final int? endedAt;

  /// Whether the activation has not been ended.
  bool get isActive => endedAt == null;

  /// The ADIF fields every QSO of this activation carries: the own reference
  /// (`MY_POTA_REF`, …) and, if known, `MY_GRIDSQUARE`.
  Map<String, String> get adifFields => {
    program.myAdifField: reference,
    'MY_GRIDSQUARE': ?myGridsquare,
  };
}
