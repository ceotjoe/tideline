import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/commands/shortcuts_overlay.dart';

/// Whether the app runs on a desktop operating system: pointer and keyboard
/// first, windows instead of screens, and a menu bar. This is about the input
/// environment, not the layout: the window size class still decides how many
/// columns a screen has (ADR 0010, ADR 0025).
bool isDesktopPlatform(BuildContext context) =>
    switch (Theme.of(context).platform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };

/// One command in a menu.
@immutable
class _Item {
  const new(this.id, this.label, this.chord, this.onSelected);

  final String id;
  final String label;

  /// The shortcut to show, if the command has one with a modifier. Plain keys
  /// (Enter, Esc) are not shown in menus.
  final KeyChord? chord;

  /// Null when the command has no handler on this screen (disabled).
  final VoidCallback? onSelected;
}

/// A menu with its commands, built from the command registry so that menus,
/// shortcuts and the shortcut overlay always agree.
@immutable
class _Menu {
  const new(this.title, this.groups);

  final String title;

  /// Items in groups; groups are separated by a divider.
  final List<List<_Item>> groups;
}

List<_Menu> _menus({
  required CommandRegistry registry,
  required AppLocalizations l10n,
  required Map<String, VoidCallback> handlers,
}) {
  _Item item(String id) {
    final command = registry.commands.firstWhere((c) => c.id == id);
    final chord = registry
        .bindingsOf(command)
        .where((c) => c.primary || c.alt || c.shift)
        .firstOrNull;
    return _Item(id, command.label(l10n), chord, handlers[id]);
  }

  return [
    _Menu(l10n.menuGo, [
      [
        item(CommandIds.goToLog),
        item(CommandIds.goToSync),
        item(CommandIds.goToSettings),
      ],
      [item(CommandIds.goBack)],
    ]),
    _Menu(l10n.menuOperate, [
      [item(CommandIds.syncNow)],
      [
        item(CommandIds.fastLogEntry),
        item(CommandIds.openContest),
        item(CommandIds.startActivation),
      ],
    ]),
    _Menu(l10n.menuHelp, [
      [item(CommandIds.showShortcuts)],
    ]),
  ];
}

/// The menu bar of Windows and Linux: a row of menus above the window's
/// content.
class DesktopMenuBar extends StatelessWidget {
  /// Creates the menu bar for the commands in [handlers].
  const new({required this.registry, required this.handlers, super.key});

  /// Source of labels and shortcuts.
  final CommandRegistry registry;

  /// The commands that work on this screen.
  final Map<String, VoidCallback> handlers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final platform = ShortcutPlatform.of(Theme.of(context).platform);
    final menus = _menus(registry: registry, l10n: l10n, handlers: handlers);
    final colors = Theme.of(context).colorScheme;
    // A flat strip across the window, like the menu bar of any desktop
    // program, not a floating card.
    return MenuBar(
      style: MenuStyle(
        elevation: const WidgetStatePropertyAll(0),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        side: WidgetStatePropertyAll(BorderSide(color: colors.outlineVariant)),
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 40)),
      ),
      children: [
        for (final menu in menus)
          SubmenuButton(
            menuChildren: [
              for (final (i, group) in menu.groups.indexed) ...[
                if (i > 0) const Divider(height: 1),
                for (final item in group)
                  MenuItemButton(
                    onPressed: item.onSelected,
                    // The shortcut is shown, not registered: the app's own
                    // shortcut map handles the key (one handler, not two).
                    trailingIcon: item.chord == null
                        ? null
                        : Text(describeChord(item.chord!, platform, l10n)),
                    child: Text(item.label),
                  ),
              ],
            ],
            child: Text(menu.title),
          ),
      ],
    );
  }
}

/// The macOS menu bar, drawn by the system: the app menu, the same menus as
/// [DesktopMenuBar], and the standard Window menu.
class MacMenuBar extends StatelessWidget {
  /// Creates the menu bar around [child].
  const new({
    required this.registry,
    required this.handlers,
    required this.child,
    super.key,
  });

  /// Source of labels and shortcuts.
  final CommandRegistry registry;

  /// The commands that work on this screen.
  final Map<String, VoidCallback> handlers;

  /// The window's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menus = _menus(registry: registry, l10n: l10n, handlers: handlers);

    PlatformMenuItem native(_Item item) => PlatformMenuItem(
      label: item.label,
      onSelected: item.onSelected,
      shortcut: item.chord?.toActivator(ShortcutPlatform.apple),
    );

    // Settings lives in the app menu on macOS, by convention.
    final settings = menus.first.groups.first.firstWhere(
      (i) => i.id == CommandIds.goToSettings,
    );
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: l10n.appTitle,
          menus: [
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.about,
            ),
            PlatformMenuItemGroup(members: [native(settings)]),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hide,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hideOtherApplications,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.showAllApplications,
                ),
              ],
            ),
            const PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.quit,
            ),
          ],
        ),
        for (final menu in menus)
          PlatformMenu(
            label: menu.title,
            menus: [
              for (final group in menu.groups)
                PlatformMenuItemGroup(
                  members: [
                    for (final item in group)
                      // Settings is in the app menu already.
                      if (item.id != CommandIds.goToSettings) native(item),
                  ],
                ),
            ],
          ),
        PlatformMenu(
          label: l10n.menuWindow,
          menus: const [
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.minimizeWindow,
            ),
            PlatformProvidedMenuItem(
              type: PlatformProvidedMenuItemType.zoomWindow,
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
