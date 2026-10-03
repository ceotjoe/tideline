import 'package:meta/meta.dart';
import 'package:tideline_domain/src/reference/reference_program.dart';
import 'package:tideline_domain/src/values/utc_date_time.dart';

/// Which QSOs are counted together toward one activation.
enum ActivationWindow {
  /// All QSOs of one UTC day. The best day counts.
  utcDay,

  /// All QSOs of the activation session.
  session,
}

/// What it takes for an activation to count. Programmes change these, so they
/// are data (`program_rules`), not code. `ActivationRules.defaultFor` is the
/// starting point.
@immutable
final class ActivationRules {
  /// Creates rules.
  const new({
    required this.program,
    required this.minQsos,
    required this.window,
    this.version = 1,
  }) : assert(minQsos > 0, 'minQsos must be positive');

  /// The built-in rules of [program].
  ///
  /// - POTA: 10 QSOs within one UTC day.
  /// - SOTA: 4 QSOs.
  /// - WWFF: 44 QSOs.
  ///
  /// Only the POTA window is confirmed to be per UTC day. For SOTA and WWFF
  /// the whole session counts, until the programme rules are checked.
  factory defaultFor(ReferenceProgram program) => switch (program) {
    ReferenceProgram.pota => const ActivationRules(
      program: ReferenceProgram.pota,
      minQsos: 10,
      window: ActivationWindow.utcDay,
    ),
    ReferenceProgram.sota => const ActivationRules(
      program: ReferenceProgram.sota,
      minQsos: 4,
      window: ActivationWindow.session,
    ),
    ReferenceProgram.wwff => const ActivationRules(
      program: ReferenceProgram.wwff,
      minQsos: 44,
      window: ActivationWindow.session,
    ),
  };

  /// The programme the rules belong to.
  final ReferenceProgram program;

  /// QSOs needed for a valid activation.
  final int minQsos;

  /// How QSOs are grouped before counting.
  final ActivationWindow window;

  /// Bumped when the rules change.
  final int version;
}

/// The part of a QSO that activation progress needs.
@immutable
final class ActivationQso {
  /// Creates the record. [band] and [mode] only tell contacts apart.
  const new({
    required this.time,
    required this.call,
    required this.band,
    required this.mode,
  });

  /// When the QSO started (UTC).
  final UtcDateTime time;

  /// The other station's callsign.
  final String call;

  /// The band, for example `20m`.
  final String band;

  /// The mode, for example `SSB`.
  final String mode;
}

/// Progress toward a valid activation, with everything a text-only display
/// needs.
@immutable
final class ActivationProgress {
  const new _({
    required this.required,
    required this.counted,
    required this.total,
    required this.duplicates,
    required this.countedByDay,
  });

  /// Computes progress for [qsos] under [rules].
  ///
  /// A second QSO with the same call, band and mode in the same window is a
  /// duplicate: it is logged but not counted.
  factory evaluate(ActivationRules rules, Iterable<ActivationQso> qsos) {
    final seen = <String>{};
    final perDay = <String, int>{};
    var total = 0;
    var duplicates = 0;
    for (final q in qsos) {
      total++;
      final d = q.time.value;
      final day =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
      final windowKey = rules.window == ActivationWindow.utcDay ? day : '*';
      final key =
          '$windowKey|${q.call.toUpperCase()}|'
          '${q.band.toUpperCase()}|${q.mode.toUpperCase()}';
      if (seen.add(key)) {
        perDay[windowKey] = (perDay[windowKey] ?? 0) + 1;
      } else {
        duplicates++;
      }
    }
    final best = perDay.values.fold<int>(0, (a, b) => a > b ? a : b);
    return ActivationProgress._(
      required: rules.minQsos,
      counted: best,
      total: total,
      duplicates: duplicates,
      countedByDay: Map.unmodifiable(perDay),
    );
  }

  /// QSOs needed.
  final int required;

  /// QSOs that count, in the best window.
  final int counted;

  /// All QSOs, including duplicates and other windows.
  final int total;

  /// QSOs that did not count because they repeat call, band and mode.
  final int duplicates;

  /// Counted QSOs per window: `yyyy-mm-dd` for UTC-day rules, `*` for a
  /// session rule.
  final Map<String, int> countedByDay;

  /// Whether the activation is valid.
  bool get isValid => counted >= required;

  /// QSOs still missing, never negative.
  int get remaining => isValid ? 0 : required - counted;
}
