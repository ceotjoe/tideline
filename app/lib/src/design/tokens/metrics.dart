import 'package:flutter/material.dart';

/// How tightly the UI is packed.
enum TidelineDensity {
  /// Default, airy "Low Tide" spacing.
  comfortable,

  /// Contest mode: less padding. Touch targets stay at least 48 dp.
  dense,

  /// Glove mode: larger touch targets and spacing.
  glove;

  /// Minimum size of any touch target, in logical pixels.
  double get minTouchTarget => switch (this) {
    comfortable || dense => 48,
    glove => 64,
  };

  /// Multiplier applied to the spacing scale.
  double get spacingFactor => switch (this) {
    comfortable => 1,
    dense => 0.75,
    glove => 1.25,
  };
}

/// User-adjustable text spacing (WCAG 1.4.12, dyslexia support).
@immutable
class TextSpacing {
  /// Creates text spacing settings.
  const new({
    this.letterSpacingEm = 0,
    this.wordSpacingEm = 0,
    this.lineHeightFactor = 1,
  });

  /// The default: no extra spacing.
  static const normal = TextSpacing();

  /// WCAG 1.4.12 maxima: letter 0.12 em, word 0.16 em, line height 1.5×.
  static const relaxed = TextSpacing(
    letterSpacingEm: 0.12,
    wordSpacingEm: 0.16,
    lineHeightFactor: 1.5,
  );

  /// Extra letter spacing as a fraction of the font size.
  final double letterSpacingEm;

  /// Extra word spacing as a fraction of the font size.
  final double wordSpacingEm;

  /// Multiplier on each style's line height.
  final double lineHeightFactor;

  /// Applies this spacing to [style].
  TextStyle apply(TextStyle style) {
    final size = style.fontSize ?? 14;
    return style.copyWith(
      letterSpacing: (style.letterSpacing ?? 0) + letterSpacingEm * size,
      wordSpacing: (style.wordSpacing ?? 0) + wordSpacingEm * size,
      height: (style.height ?? 1.2) * lineHeightFactor,
    );
  }
}

/// Spacing, radius, motion and type tokens.
@immutable
class TidelineMetrics extends ThemeExtension<TidelineMetrics> {
  /// Creates metrics for [density].
  const new({this.density = TidelineDensity.comfortable});

  /// Active density.
  final TidelineDensity density;

  /// 4 dp base unit, scaled by density.
  double get xs => 4 * density.spacingFactor;

  /// 8 dp, scaled by density.
  double get sm => 8 * density.spacingFactor;

  /// 16 dp, scaled by density.
  double get md => 16 * density.spacingFactor;

  /// 24 dp, scaled by density.
  double get lg => 24 * density.spacingFactor;

  /// 40 dp, scaled by density.
  double get xl => 40 * density.spacingFactor;

  /// Minimum touch target edge.
  double get minTouchTarget => density.minTouchTarget;

  /// Small radius: chips, inputs.
  static const radiusSm = Radius.circular(8);

  /// Medium radius: cards, buttons.
  static const radiusMd = Radius.circular(14);

  /// Large radius: sheets and panes.
  static const radiusLg = Radius.circular(22);

  /// Short motion (state changes).
  static const durationShort = Duration(milliseconds: 150);

  /// Medium motion (panes).
  static const durationMedium = Duration(milliseconds: 250);

  /// Tide gauge level change.
  static const durationTide = Duration(milliseconds: 1200);

  /// [duration], or zero when the user asked for reduced motion.
  static Duration motion(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;

  @override
  TidelineMetrics copyWith({TidelineDensity? density}) =>
      TidelineMetrics(density: density ?? this.density);

  @override
  TidelineMetrics lerp(TidelineMetrics? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

/// Type scale. Sizes are in logical pixels and scale with the OS text size.
abstract final class TidelineType {
  /// Large numbers and hero titles.
  static const display = TextStyle(
    fontSize: 34,
    height: 40 / 34,
    fontWeight: FontWeight.w600,
  );

  /// Screen titles.
  static const title = TextStyle(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
  );

  /// Section headings.
  static const heading = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  /// Body copy.
  static const body = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  /// Buttons and labels.
  static const label = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  /// Metadata.
  static const caption = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  /// Callsigns: tabular, slightly tracked, never ambiguous (0 vs O).
  static const callsign = TextStyle(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    fontFeatures: [FontFeature.tabularFigures(), FontFeature.slashedZero()],
  );
}
