import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/routing/routes.dart';

/// Locales offered in the language picker (pseudo-locale only in debug).
List<Locale> selectableLocales() => [
  for (final l in AppLocalizations.supportedLocales)
    if (l.countryCode != 'XA' || kDebugMode) l,
];

/// One entry of the settings hub: a page of related settings.
typedef _Entry = ({IconData icon, String title, String? hint, String route});

/// The settings hub: a short list of groups, each opening its own page.
class SettingsScreen extends StatelessWidget {
  /// Creates the settings hub.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <_Entry>[
      (
        icon: Icons.cloud_outlined,
        title: l10n.settingsAccounts,
        hint: l10n.accountsHint,
        route: Routes.settingsAccount,
      ),
      (
        icon: Icons.palette_outlined,
        title: l10n.settingsAppearanceAndLanguage,
        hint: l10n.settingsAppearanceHint,
        route: Routes.settingsAppearance,
      ),
      (
        icon: Icons.terrain_outlined,
        title: l10n.settingsFieldMode,
        hint: l10n.settingsFieldModeHint,
        route: Routes.settingsFieldMode,
      ),
      (
        icon: Icons.menu_book_outlined,
        title: l10n.settingsReferenceData,
        hint: l10n.settingsReferenceDataHint,
        route: Routes.settingsReferenceData,
      ),
      (
        icon: Icons.lock_outline,
        title: l10n.settingsSecurityAndBackup,
        hint: l10n.settingsSecurityAndBackupHint,
        route: Routes.settingsSecurity,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: context.metrics.sm),
        children: [
          for (final e in entries)
            ListTile(
              leading: Icon(e.icon),
              title: Text(e.title),
              subtitle: e.hint == null ? null : Text(e.hint!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(e.route),
            ),
          ListTile(
            leading: const Icon(Icons.keyboard_outlined),
            title: Text(l10n.settingsKeyboard),
            subtitle: Text(l10n.commandShowShortcuts),
            onTap: () =>
                CommandHandlers.invoke(context, CommandIds.showShortcuts),
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(l10n.settingsDeveloper),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(Routes.settingsDeveloper),
            ),
        ],
      ),
    );
  }
}

/// A settings page: a title bar with a back button and a scrolling body.
class SettingsPage extends StatelessWidget {
  /// Creates a page titled [title] showing [children].
  const new({required this.title, required this.children, super.key});

  /// The page title.
  final String title;

  /// The page content.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(vertical: context.metrics.sm),
      children: children,
    ),
  );
}
