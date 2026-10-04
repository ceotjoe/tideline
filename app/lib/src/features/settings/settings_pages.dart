import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/settings/contest_definitions_section.dart';
import 'package:tideline/src/features/settings/reference_packs_section.dart';
import 'package:tideline/src/features/settings/scp_section.dart';
import 'package:tideline/src/features/settings/settings_screen.dart';
import 'package:tideline/src/features/settings/settings_sections.dart';
import 'package:tideline/src/features/settings/settings_widgets.dart';
import 'package:tideline/src/features/settings/worked_before_section.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline/src/settings/language_names.dart';

/// The Wavelog account: server, token and removal.
class AccountSettingsPage extends StatelessWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context) => SettingsPage(
    title: AppLocalizations.of(context).settingsAccount,
    children: const [AccountSection()],
  );
}

/// Theme, touch targets, text options and language.
class AppearanceSettingsPage extends ConsumerWidget {
  /// Creates the page.
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

    return SettingsPage(
      title: l10n.settingsAppearanceAndLanguage,
      children: [
        SettingsSectionHeader(l10n.settingsAppearance),
        SettingsRadioGroup<ThemeChoice>(
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
        SettingsRadioGroup<TidelineDensity>(
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
        SettingsSectionHeader(l10n.settingsLanguage),
        SettingsRadioGroup<String>(
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
      ],
    );
  }
}

/// Downloaded lists and derived indexes.
class ReferenceDataSettingsPage extends StatelessWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsPage(
      title: l10n.settingsReferenceData,
      children: [
        SettingsSectionHeader(l10n.settingsReferencePacks),
        const ReferencePacksSection(),
        SettingsSectionHeader(l10n.settingsScp),
        const ScpSection(),
        SettingsSectionHeader(l10n.settingsContestDefinitions),
        const ContestDefinitionsSection(),
        SettingsSectionHeader(l10n.settingsWorkedBefore),
        const WorkedBeforeSection(),
      ],
    );
  }
}

/// App lock, ADIF import and export, and the encrypted backup.
class SecuritySettingsPage extends StatelessWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsPage(
      title: l10n.settingsSecurityAndBackup,
      children: [
        SettingsSectionHeader(l10n.settingsSecurity),
        const SecuritySection(),
        SettingsSectionHeader(l10n.settingsData),
        const DataSection(),
      ],
    );
  }
}

/// Options that only exist in debug builds.
class DeveloperSettingsPage extends ConsumerWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    return SettingsPage(
      title: l10n.settingsDeveloper,
      children: [
        if (kDebugMode)
          SwitchListTile(
            title: Text(l10n.debugForceRtl),
            value: settings.forceRtl,
            onChanged: (v) => ref
                .read(settingsControllerProvider)
                .save(settings.copyWith(forceRtl: v)),
          ),
      ],
    );
  }
}
