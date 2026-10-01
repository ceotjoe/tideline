import 'package:flutter/widgets.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/design/tokens/metrics.dart';

/// The user's theme choice: follow the system, or a fixed variant.
enum ThemeChoice {
  /// Light or dark following the OS.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,

  /// Maximum contrast for sunlight.
  sunlight,

  /// Red on black for night operation.
  nightRed;

  /// The theme variant to use given the platform [brightness].
  TidelineThemeVariant resolve(Brightness brightness) => switch (this) {
    system =>
      brightness == Brightness.dark
          ? TidelineThemeVariant.dark
          : TidelineThemeVariant.light,
    light => TidelineThemeVariant.light,
    dark => TidelineThemeVariant.dark,
    sunlight => TidelineThemeVariant.sunlight,
    nightRed => TidelineThemeVariant.nightRed,
  };
}

/// Typed view of the user's UI settings.
@immutable
class AppSettings {
  /// Creates settings; defaults match a fresh install.
  const new({
    this.theme = ThemeChoice.system,
    this.density = TidelineDensity.comfortable,
    this.relaxedTextSpacing = false,
    this.localeOverride,
    this.forceRtl = false,
  });

  /// Parses stored key/value settings, ignoring unknown or invalid values.
  factory fromStore(Map<String, String> values) => AppSettings(
    theme: _byName(ThemeChoice.values, values[_theme]) ?? ThemeChoice.system,
    density:
        _byName(TidelineDensity.values, values[_density]) ??
        TidelineDensity.comfortable,
    relaxedTextSpacing: values[_textSpacing] == 'relaxed',
    localeOverride: switch (values[_locale]) {
      null || '' => null,
      final tag => _parseLocale(tag),
    },
    forceRtl: values[_forceRtl] == 'true',
  );

  static const _theme = 'ui.theme';
  static const _density = 'ui.density';
  static const _textSpacing = 'ui.textSpacing';
  static const _locale = 'ui.locale';
  static const _forceRtl = 'debug.forceRtl';

  /// Theme choice.
  final ThemeChoice theme;

  /// Control size and spacing.
  final TidelineDensity density;

  /// Whether WCAG 1.4.12 text spacing is applied.
  final bool relaxedTextSpacing;

  /// Language chosen in the app, or null to follow the system.
  final Locale? localeOverride;

  /// Debug-only: lay the UI out right-to-left to test mirroring.
  final bool forceRtl;

  /// Text spacing to apply.
  TextSpacing get textSpacing =>
      relaxedTextSpacing ? TextSpacing.relaxed : TextSpacing.normal;

  /// Key/value pairs for the settings store (null removes a key).
  Map<String, String?> toStore() => {
    _theme: theme.name,
    _density: density.name,
    _textSpacing: relaxedTextSpacing ? 'relaxed' : 'normal',
    _locale: localeOverride?.toLanguageTag(),
    _forceRtl: forceRtl ? 'true' : null,
  };

  /// A copy with the given fields replaced. Pass [clearLocale] to go back
  /// to the system language.
  AppSettings copyWith({
    ThemeChoice? theme,
    TidelineDensity? density,
    bool? relaxedTextSpacing,
    Locale? localeOverride,
    bool clearLocale = false,
    bool? forceRtl,
  }) => AppSettings(
    theme: theme ?? this.theme,
    density: density ?? this.density,
    relaxedTextSpacing: relaxedTextSpacing ?? this.relaxedTextSpacing,
    localeOverride: clearLocale
        ? null
        : (localeOverride ?? this.localeOverride),
    forceRtl: forceRtl ?? this.forceRtl,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.theme == theme &&
      other.density == density &&
      other.relaxedTextSpacing == relaxedTextSpacing &&
      other.localeOverride == localeOverride &&
      other.forceRtl == forceRtl;

  @override
  int get hashCode =>
      Object.hash(theme, density, relaxedTextSpacing, localeOverride, forceRtl);
}

T? _byName<T extends Enum>(List<T> values, String? name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

Locale? _parseLocale(String tag) {
  final parts = tag.split(RegExp('[-_]'));
  if (parts.isEmpty || parts.first.isEmpty) return null;
  return Locale(parts.first, parts.length > 1 ? parts[1] : null);
}
