import 'package:flutter/material.dart';
import 'package:tideline/src/design/tokens/metrics.dart';

/// Gives [child] the dense variant of the Low Tide tokens (contest mode).
///
/// Colours, type and radii stay the same; only spacing shrinks. Touch
/// targets stay at least 48 dp, and glove mode keeps its larger values.
class ContestDensityScope extends StatelessWidget {
  /// Creates the scope around [child].
  const new({required this.child, super.key});

  /// The contest screen.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final current = theme.extension<TidelineMetrics>();
    if (current == null) return child;
    final density = TidelineMetrics.contestDensity(current.density);
    if (density == current.density) return child;
    return Theme(
      data: theme.copyWith(
        extensions: [
          for (final e in theme.extensions.values)
            if (e is TidelineMetrics) TidelineMetrics(density: density) else e,
        ],
      ),
      child: child,
    );
  }
}
