import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/settings/contest_definitions_section.dart';
import 'package:tideline/src/features/settings/reference_packs_section.dart';
import 'package:tideline/src/features/settings/scp_section.dart';
import 'package:tideline/src/features/settings/settings_sections.dart';
import 'package:tideline/src/features/settings/worked_before_section.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline/src/settings/language_names.dart';

/// Locales offered in the language picker (pseudo-locale only in debug).
List<Locale> selectableLocales() => [
  for (final l in AppLocalizations.supportedLocales)
    if (l.countryCode != 'XA' || kDebugMode) l,
];

/// Appearance, language and keyboard settings.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider);
    void save(AppSettings s) => controller.save(s);

    String localeName(Locale l) =>
        l.countryCode == 'XA' ? l10n.languagePseudo : endonymFor(l);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(vertical: context.metrics.sm),
        children: [
          _SectionHeader(l10n.settingsAccount),
          const AccountSection(),
          _SectionHeader(l10n.settingsAppearance),
          _Group<ThemeChoice>(
            title: l10n.settingsTheme,
            value: settings.theme,
            onChanged: (v) => save(settings.copyWith(theme: v)),
            options: {
              ThemeChoice.system: l10n.themeSystem,
              ThemeChoice.light: l10n.themeLight,
              ThemeChoice.dark: l10n.themeDark,
              ThemeChoice.sunlight: l10n.themeSunlight,
              ThemeChoice.nightRed: l10n.themeNightRed,
            },
          ),
          _Group<TidelineDensity>(
            title: l10n.settingsDensity,
            value: settings.density == TidelineDensity.dense
                ? TidelineDensity.comfortable
                : settings.density,
            onChanged: (v) => save(settings.copyWith(density: v)),
            options: {
              TidelineDensity.comfortable: l10n.densityComfortable,
              TidelineDensity.glove: l10n.densityGlove,
            },
          ),
          SwitchListTile(
            title: Text(l10n.settingsReadingFont),
            subtitle: Text(l10n.settingsReadingFontHint),
            value: settings.readingFont,
            onChanged: (v) => save(settings.copyWith(readingFont: v)),
          ),
          SwitchListTile(
            title: Text(l10n.settingsTextSpacing),
            value: settings.relaxedTextSpacing,
            onChanged: (v) => save(settings.copyWith(relaxedTextSpacing: v)),
          ),
          _SectionHeader(l10n.settingsLanguage),
          _Group<String>(
            showTitle: false,
            title: l10n.settingsLanguage,
            value: settings.localeOverride?.toLanguageTag() ?? '',
            onChanged: (tag) {
              final locale = selectableLocales()
                  .where((l) => l.toLanguageTag() == tag)
                  .firstOrNull;
              save(
                locale == null
                    ? settings.copyWith(clearLocale: true)
                    : settings.copyWith(localeOverride: locale),
              );
            },
            options: {
              '': l10n.languageSystem,
              for (final l in selectableLocales())
                l.toLanguageTag(): localeName(l),
            },
          ),
          _SectionHeader(l10n.settingsData),
          const DataSection(),
          _SectionHeader(l10n.settingsContestDefinitions),
          const ContestDefinitionsSection(),
          _SectionHeader(l10n.settingsReferencePacks),
          const ReferencePacksSection(),
          _SectionHeader(l10n.settingsScp),
          const ScpSection(),
          _SectionHeader(l10n.settingsWorkedBefore),
          const WorkedBeforeSection(),
          _SectionHeader(l10n.settingsSecurity),
          const SecuritySection(),
          _SectionHeader(l10n.settingsKeyboard),
          ListTile(
            leading: const Icon(Icons.keyboard_outlined),
            title: Text(l10n.commandShowShortcuts),
            onTap: () =>
                CommandHandlers.invoke(context, CommandIds.showShortcuts),
          ),
          if (kDebugMode) ...[
            _SectionHeader(l10n.settingsDeveloper),
            SwitchListTile(
              title: Text(l10n.debugForceRtl),
              value: settings.forceRtl,
              onChanged: (v) => save(settings.copyWith(forceRtl: v)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.fromSTEB(
      context.metrics.md,
      context.metrics.lg,
      context.metrics.md,
      context.metrics.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

/// A labelled group of radio options.
class _Group<T> extends StatelessWidget {
  const new({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.options,
    this.showTitle = true,
  });

  final String title;
  final bool showTitle;
  final T value;
  final ValueChanged<T> onChanged;
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showTitle)
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            context.metrics.md,
            context.metrics.sm,
            context.metrics.md,
            0,
          ),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: context.colors.textSecondary),
            ),
          ),
        ),
      RadioGroup<T>(
        groupValue: value,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        child: Column(
          children: [
            for (final MapEntry(key: option, value: label) in options.entries)
              RadioListTile<T>(value: option, title: Text(label)),
          ],
        ),
      ),
    ],
  );
}
