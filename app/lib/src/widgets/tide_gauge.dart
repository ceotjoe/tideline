import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';

/// Tideline's signature sync indicator: a wave horizon whose level shows
/// how many QSOs are waiting to sync. When everything is synced, the tide
/// is out.
///
/// The wave is decoration only. The count is always shown as text and
/// announced to screen readers, and the wave stops moving when the user
/// asks for reduced motion.
class TideGauge extends StatelessWidget {
  /// Creates a gauge for [pendingCount] unsynced QSOs.
  const new({required this.pendingCount, this.height = 56, super.key});

  /// QSOs not yet synced.
  final int pendingCount;

  /// Height of the wave band.
  final double height;

  /// Water level from 0 (all synced) to 1, on a logarithmic scale so that
  /// both 3 and 300 waiting QSOs are visible.
  static double levelFor(int count) {
    if (count <= 0) return 0;
    return (0.2 + 0.8 * math.log(count + 1) / math.log(501)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = l10n.tideGaugeLabel(pendingCount);
    final colors = context.colors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      liveRegion: true,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: levelFor(pendingCount)),
              duration: TidelineMetrics.motion(
                context,
                TidelineMetrics.durationTide,
              ),
              curve: Curves.easeInOut,
              builder: (context, level, _) => _AnimatedWave(
                level: level,
                water: colors.tideWater,
                line: colors.tideLine,
                animate: !reduceMotion && pendingCount > 0,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsetsDirectional.only(start: context.metrics.md),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedWave extends StatefulWidget {
  const new({
    required this.level,
    required this.water,
    required this.line,
    required this.animate,
  });

  final double level;
  final Color water;
  final Color line;
  final bool animate;

  @override
  State<_AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<_AnimatedWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _phase = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_AnimatedWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.animate && !_phase.isAnimating) {
      _phase.repeat();
    } else if (!widget.animate && _phase.isAnimating) {
      _phase.stop();
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _phase,
    builder: (context, _) => CustomPaint(
      painter: _WavePainter(
        level: widget.level,
        phase: _phase.value,
        water: widget.water,
        line: widget.line,
      ),
    ),
  );
}

class _WavePainter extends CustomPainter {
  new({
    required this.level,
    required this.phase,
    required this.water,
    required this.line,
  });

  final double level;
  final double phase;
  final Color water;
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    // At low tide a thin line remains at the bottom: the horizon.
    final waterTop = size.height * (1 - (0.06 + 0.94 * level));
    final amplitude = level == 0 ? 0.0 : math.min(4, size.height * 0.08);
    final path = Path()..moveTo(0, waterTop);
    for (var x = 0.0; x <= size.width; x += 4) {
      final y =
          waterTop +
          amplitude *
              math.sin((x / size.width * 4 * math.pi) + phase * 2 * math.pi);
      path.lineTo(x, y);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(fill, Paint()..color = water)
      ..drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.level != level ||
      old.phase != phase ||
      old.water != water ||
      old.line != line;
}
