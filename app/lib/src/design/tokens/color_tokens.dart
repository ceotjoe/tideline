import 'package:flutter/material.dart';
import 'package:tideline/src/design/tokens/palette.dart';

/// Which of Tideline's themes is active.
enum TidelineThemeVariant {
  /// Calm sand-and-sea light theme.
  light,

  /// Deep-sea dark theme.
  dark,

  /// Maximum contrast for bright sunlight.
  sunlight,

  /// Red on black to preserve night vision.
  nightRed;

  /// Brightness reported to Flutter for platform integration.
  Brightness get brightness => switch (this) {
    light || sunlight => Brightness.light,
    dark || nightRed => Brightness.dark,
  };
}

/// A foreground/background pair for a status chip.
@immutable
class StatusColors {
  /// Creates a status colour pair.
  const new({required this.foreground, required this.background});

  /// Linear interpolation for theme animations.
  factory lerp(StatusColors a, StatusColors b, double t) => StatusColors(
    foreground: Color.lerp(a.foreground, b.foreground, t)!,
    background: Color.lerp(a.background, b.background, t)!,
  );

  /// Text and icon colour.
  final Color foreground;

  /// Chip fill colour.
  final Color background;
}

/// A pair of colours that must meet a minimum contrast ratio.
typedef ContrastPair = ({
  String name,
  Color foreground,
  Color background,
  double minRatio,
});

/// Semantic colour tokens. Every widget colour comes from here.
@immutable
class TidelineColors extends ThemeExtension<TidelineColors> {
  /// Creates a full set of semantic colours.
  const new({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.text,
    required this.textSecondary,
    required this.primary,
    required this.onPrimary,
    required this.outline,
    required this.focus,
    required this.error,
    required this.tideWater,
    required this.tideLine,
    required this.synced,
    required this.pending,
    required this.conflict,
    required this.rejected,
  });

  /// Colours of [variant].
  factory forVariant(TidelineThemeVariant variant) => switch (variant) {
    TidelineThemeVariant.light => light,
    TidelineThemeVariant.dark => dark,
    TidelineThemeVariant.sunlight => sunlight,
    TidelineThemeVariant.nightRed => nightRed,
  };

  /// Page background.
  final Color background;

  /// Cards, sheets and panes.
  final Color surface;

  /// Subtle tinted surfaces (selected rows, input fills).
  final Color surfaceVariant;

  /// Primary text and icons.
  final Color text;

  /// Secondary text (metadata). Still meets 4.5:1.
  final Color textSecondary;

  /// Primary actions.
  final Color primary;

  /// Text and icons on [primary].
  final Color onPrimary;

  /// Borders and dividers of interactive components (≥ 3:1).
  final Color outline;

  /// Keyboard focus ring (≥ 3:1).
  final Color focus;

  /// Error text and icons.
  final Color error;

  /// Decorative fill of the tide gauge. Never carries information alone.
  final Color tideWater;

  /// The tide gauge's water line (≥ 3:1 against the background).
  final Color tideLine;

  /// Status: synced.
  final StatusColors synced;

  /// Status: local, queued, uploading or verifying.
  final StatusColors pending;

  /// Status: conflict or blocked.
  final StatusColors conflict;

  /// Status: rejected.
  final StatusColors rejected;

  /// Light "Low Tide" theme.
  static const light = TidelineColors(
    background: Palette.sand100,
    surface: Palette.sand50,
    surfaceVariant: Palette.seafoam100,
    text: Palette.sea900,
    textSecondary: Palette.sea600,
    primary: Palette.seafoam700,
    onPrimary: Palette.white,
    outline: Palette.sea400,
    focus: Palette.focusLight,
    error: Palette.coral700,
    tideWater: Palette.seafoam300,
    tideLine: Palette.seafoam700,
    synced: StatusColors(
      foreground: Palette.kelp800,
      background: Palette.kelp100,
    ),
    pending: StatusColors(
      foreground: Palette.harbour800,
      background: Palette.harbour100,
    ),
    conflict: StatusColors(
      foreground: Palette.amber800,
      background: Palette.amber100,
    ),
    rejected: StatusColors(
      foreground: Palette.coral800,
      background: Palette.coral100,
    ),
  );

  /// Dark "Low Tide" theme.
  static const dark = TidelineColors(
    background: Palette.sea950,
    surface: Palette.sea850,
    surfaceVariant: Palette.sea800,
    text: Palette.sea50,
    textSecondary: Palette.sea300,
    primary: Palette.seafoam400,
    onPrimary: Palette.seafoam900,
    outline: Palette.sea400,
    focus: Palette.focusDark,
    error: Palette.coral200,
    tideWater: Palette.sea800,
    tideLine: Palette.seafoam400,
    synced: StatusColors(
      foreground: Palette.kelp300,
      background: Palette.kelp900,
    ),
    pending: StatusColors(
      foreground: Palette.harbour300,
      background: Palette.harbour900,
    ),
    conflict: StatusColors(
      foreground: Palette.amber300,
      background: Palette.amber900,
    ),
    rejected: StatusColors(
      foreground: Palette.coral300,
      background: Palette.coral900,
    ),
  );

  /// Sunlight: maximum contrast (targets WCAG AAA, 7:1).
  static const sunlight = TidelineColors(
    background: Palette.white,
    surface: Palette.white,
    surfaceVariant: Color(0xFFF0F0F0),
    text: Palette.black,
    textSecondary: Color(0xFF1F1F1F),
    primary: Color(0xFF003D37),
    onPrimary: Palette.white,
    outline: Palette.black,
    focus: Color(0xFF0000B8),
    error: Color(0xFF7A0F05),
    tideWater: Color(0xFFD0E8E2),
    tideLine: Palette.black,
    synced: StatusColors(
      foreground: Color(0xFF003D1F),
      background: Palette.white,
    ),
    pending: StatusColors(
      foreground: Color(0xFF002E5C),
      background: Palette.white,
    ),
    conflict: StatusColors(
      foreground: Color(0xFF4A2E00),
      background: Palette.white,
    ),
    rejected: StatusColors(
      foreground: Color(0xFF6B0F05),
      background: Palette.white,
    ),
  );

  /// Night red: one red hue on black. Statuses differ by icon and text only.
  static const nightRed = TidelineColors(
    background: Palette.night0,
    surface: Palette.night50,
    surfaceVariant: Palette.night100,
    text: Palette.nightRed,
    textSecondary: Palette.nightRedDim,
    primary: Palette.nightRed,
    onPrimary: Palette.night0,
    outline: Palette.nightRedLine,
    focus: Palette.nightRedBright,
    error: Palette.nightRedBright,
    tideWater: Palette.night100,
    tideLine: Palette.nightRedLine,
    synced: StatusColors(
      foreground: Palette.nightRed,
      background: Palette.night100,
    ),
    pending: StatusColors(
      foreground: Palette.nightRed,
      background: Palette.night100,
    ),
    conflict: StatusColors(
      foreground: Palette.nightRed,
      background: Palette.night100,
    ),
    rejected: StatusColors(
      foreground: Palette.nightRed,
      background: Palette.night100,
    ),
  );

  /// Every foreground/background pair the UI uses, with its WCAG 2.2
  /// minimum: 4.5:1 for text, 3:1 for non-text UI components.
  ///
  /// The contrast test checks all of them for all themes.
  List<ContrastPair> get contrastPairs {
    final pairs = <ContrastPair>[];
    for (final (bgName, bg) in [
      ('background', background),
      ('surface', surface),
      ('surfaceVariant', surfaceVariant),
    ]) {
      pairs.addAll([
        (name: 'text/$bgName', foreground: text, background: bg, minRatio: 4.5),
        (
          name: 'textSecondary/$bgName',
          foreground: textSecondary,
          background: bg,
          minRatio: 4.5,
        ),
        (
          name: 'primary/$bgName',
          foreground: primary,
          background: bg,
          minRatio: 4.5,
        ),
        (
          name: 'error/$bgName',
          foreground: error,
          background: bg,
          minRatio: 4.5,
        ),
        (
          name: 'outline/$bgName',
          foreground: outline,
          background: bg,
          minRatio: 3,
        ),
        (name: 'focus/$bgName', foreground: focus, background: bg, minRatio: 3),
      ]);
    }
    pairs.addAll([
      (
        name: 'onPrimary/primary',
        foreground: onPrimary,
        background: primary,
        minRatio: 4.5,
      ),
      (
        name: 'tideLine/background',
        foreground: tideLine,
        background: background,
        minRatio: 3,
      ),
      (
        name: 'tideLine/tideWater',
        foreground: tideLine,
        background: tideWater,
        minRatio: 3,
      ),
      (
        name: 'text/tideWater',
        foreground: text,
        background: tideWater,
        minRatio: 4.5,
      ),
      for (final (n, s) in [
        ('synced', synced),
        ('pending', pending),
        ('conflict', conflict),
        ('rejected', rejected),
      ]) ...[
        (
          name: '$n.foreground/$n.background',
          foreground: s.foreground,
          background: s.background,
          minRatio: 4.5,
        ),
        (
          name: '$n.foreground/surface',
          foreground: s.foreground,
          background: surface,
          minRatio: 4.5,
        ),
      ],
    ]);
    return pairs;
  }

  @override
  TidelineColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? text,
    Color? textSecondary,
    Color? primary,
    Color? onPrimary,
    Color? outline,
    Color? focus,
    Color? error,
    Color? tideWater,
    Color? tideLine,
    StatusColors? synced,
    StatusColors? pending,
    StatusColors? conflict,
    StatusColors? rejected,
  }) => TidelineColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    outline: outline ?? this.outline,
    focus: focus ?? this.focus,
    error: error ?? this.error,
    tideWater: tideWater ?? this.tideWater,
    tideLine: tideLine ?? this.tideLine,
    synced: synced ?? this.synced,
    pending: pending ?? this.pending,
    conflict: conflict ?? this.conflict,
    rejected: rejected ?? this.rejected,
  );

  @override
  TidelineColors lerp(TidelineColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return TidelineColors(
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceVariant: c(surfaceVariant, other.surfaceVariant),
      text: c(text, other.text),
      textSecondary: c(textSecondary, other.textSecondary),
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      outline: c(outline, other.outline),
      focus: c(focus, other.focus),
      error: c(error, other.error),
      tideWater: c(tideWater, other.tideWater),
      tideLine: c(tideLine, other.tideLine),
      synced: StatusColors.lerp(synced, other.synced, t),
      pending: StatusColors.lerp(pending, other.pending, t),
      conflict: StatusColors.lerp(conflict, other.conflict, t),
      rejected: StatusColors.lerp(rejected, other.rejected, t),
    );
  }
}
