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
    this.readingFont = false,
    this.batterySaver = false,
    this.keepScreenOn = false,
    this.fieldModeRestore,
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
    readingFont: values[_readingFont] == 'atkinson',
    batterySaver: values[_batterySaver] == 'true',
    keepScreenOn: values[_keepScreenOn] == 'true',
    fieldModeRestore: _validRestore(values[_fieldRestore]),
  );

  static const _theme = 'ui.theme';
  static const _density = 'ui.density';
  static const _textSpacing = 'ui.textSpacing';
  static const _locale = 'ui.locale';
  static const _forceRtl = 'debug.forceRtl';
  static const _readingFont = 'ui.readingFont';
  static const _batterySaver = 'ui.batterySaver';
  static const _keepScreenOn = 'ui.keepScreenOn';
  static const _fieldRestore = 'ui.fieldModeRestore';

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

  /// Use the Atkinson Hyperlegible reading font.
  final bool readingFont;

  /// Less periodic work: no animated tide, a clock that ticks once a minute.
  final bool batterySaver;

  /// Keep the screen on while the log or Fast Log Entry is open.
  final bool keepScreenOn;

  /// The theme and density from before field mode was switched on, as
  /// `theme|density`, so that switching it off puts them back.
  final String? fieldModeRestore;

  /// Whether field mode is on: the sunlight theme, glove mode, the battery
  /// saver and the screen kept on, all at once. Derived, so changing one of
  /// the four by hand turns the switch off by itself.
  bool get fieldMode =>
      theme == ThemeChoice.sunlight &&
      density == TidelineDensity.glove &&
      batterySaver &&
      keepScreenOn;

  /// These settings with field mode switched [on] or off. Switching it on
  /// remembers the theme and density to come back to.
  AppSettings withFieldMode({required bool on}) {
    if (on) {
      if (fieldMode) return this;
      // A theme or density that already is the field one has nothing to
      // come back to; the defaults stand in.
      final back = theme == ThemeChoice.sunlight ? ThemeChoice.system : theme;
      final backDensity = density == TidelineDensity.glove
          ? TidelineDensity.comfortable
          : density;
      return AppSettings(
        theme: ThemeChoice.sunlight,
        density: TidelineDensity.glove,
        relaxedTextSpacing: relaxedTextSpacing,
        localeOverride: localeOverride,
        forceRtl: forceRtl,
        readingFont: readingFont,
        batterySaver: true,
        keepScreenOn: true,
        fieldModeRestore: '${back.name}|${backDensity.name}',
      );
    }
    final restore = _validRestore(fieldModeRestore)?.split('|');
    return AppSettings(
      theme: _byName(ThemeChoice.values, restore?.first) ?? ThemeChoice.system,
      density:
          _byName(TidelineDensity.values, restore?.last) ??
          TidelineDensity.comfortable,
      relaxedTextSpacing: relaxedTextSpacing,
      localeOverride: localeOverride,
      forceRtl: forceRtl,
      readingFont: readingFont,
    );
  }

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
    _readingFont: readingFont ? 'atkinson' : null,
    _batterySaver: batterySaver ? 'true' : null,
    _keepScreenOn: keepScreenOn ? 'true' : null,
    _fieldRestore: fieldModeRestore,
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
    bool? readingFont,
    bool? batterySaver,
    bool? keepScreenOn,
  }) => AppSettings(
    theme: theme ?? this.theme,
    density: density ?? this.density,
    relaxedTextSpacing: relaxedTextSpacing ?? this.relaxedTextSpacing,
    localeOverride: clearLocale
        ? null
        : (localeOverride ?? this.localeOverride),
    forceRtl: forceRtl ?? this.forceRtl,
    readingFont: readingFont ?? this.readingFont,
    batterySaver: batterySaver ?? this.batterySaver,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    fieldModeRestore: fieldModeRestore,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.theme == theme &&
      other.density == density &&
      other.relaxedTextSpacing == relaxedTextSpacing &&
      other.localeOverride == localeOverride &&
      other.forceRtl == forceRtl &&
      other.readingFont == readingFont &&
      other.batterySaver == batterySaver &&
      other.keepScreenOn == keepScreenOn &&
      other.fieldModeRestore == fieldModeRestore;

  @override
  int get hashCode => Object.hash(
    theme,
    density,
    relaxedTextSpacing,
    localeOverride,
    forceRtl,
    readingFont,
    batterySaver,
    keepScreenOn,
    fieldModeRestore,
  );
}

/// A stored restore value if it names a theme and a density, else null.
String? _validRestore(String? value) {
  final parts = value?.split('|');
  if (parts == null || parts.length != 2) return null;
  if (_byName(ThemeChoice.values, parts[0]) == null) return null;
  if (_byName(TidelineDensity.values, parts[1]) == null) return null;
  return value;
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
