import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline/src/settings/language_names.dart';
import 'package:tideline_data/tideline_data.dart' show Account;

/// The Wavelog accounts: which one logging uses, and a way to add more.
class AccountsSettingsPage extends ConsumerWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final active = ref.watch(activeAccountProvider);
    final pending = ref.watch(pendingByAccountProvider).value ?? const {};
    return SettingsPage(
      title: l10n.settingsAccounts,
      children: [
        for (final a in accounts)
          ListTile(
            leading: Icon(
              a.id == active?.id
                  ? Icons.check_circle_outline
                  : Icons.dns_outlined,
            ),
            title: Text(a.label),
            subtitle: Text(
              [
                a.baseUrl,
                if (a.id == active?.id) l10n.accountsInUse,
                l10n.accountsPending(pending[a.id] ?? 0),
              ].join('\n'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(Routes.settingsAccountDetail(a.id)),
          ),
        ListTile(
          leading: const Icon(Icons.add),
          title: Text(l10n.accountsAdd),
          onTap: () => context.push(Routes.addAccount),
        ),
      ],
    );
  }
}

/// One account: server, token, rename, use for logging, remove.
class AccountDetailSettingsPage extends ConsumerWidget {
  /// Creates the page for the account with [accountId].
  const new({required this.accountId, super.key});

  /// The account shown.
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref
        .watch(accountsProvider)
        .value
        ?.where((a) => a.id == accountId)
        .firstOrNull;
    return SettingsPage(
      title: account?.label ?? AppLocalizations.of(context).settingsAccount,
      children: [if (account != null) AccountSection(account: account)],
    );
  }
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
