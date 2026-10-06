import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/commands/shortcuts_overlay.dart';
import 'package:tideline/src/features/sync/sync_screen.dart';
import 'package:tideline/src/layout/desktop_menu.dart';
import 'package:tideline/src/layout/size_class.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/keyboard_dock.dart';
import 'package:tideline/src/widgets/tide_gauge.dart';

/// Window width from which the navigation rail shows its labels beside the
/// icons (extended). Below it the rail is compact.
const double extendedRailMinWidth = 1440;

/// The same on desktop operating systems, where the sidebar is the usual
/// navigation and the content adapts to the width it is left.
const double desktopExtendedRailMinWidth = 1100;

/// Top-level navigation: a bottom bar on compact touch windows (thumb reach),
/// a navigation rail from medium width up and always on desktop operating
/// systems, where a menu bar carries the commands as well (ADR 0025). The
/// tide gauge runs across the top of the content on every size.
class AdaptiveShell extends ConsumerWidget {
  /// Creates the shell around go_router's [navigationShell].
  const new({required this.navigationShell, super.key});

  /// The router's stateful shell; keeps each branch's state.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sizeClass = SizeClass.of(context);
    final desktop = isDesktopPlatform(context);
    // The wide rail with labels costs ~180 dp more. Tablets in landscape
    // (1180–1376 dp) need that room for content, so only wider windows get it.
    // A desktop window is not held in one hand: its sidebar names the places
    // from a smaller width on.
    final extendedRail =
        MediaQuery.sizeOf(context).width >=
        (desktop ? desktopExtendedRailMinWidth : extendedRailMinWidth);
    final useRail = desktop || sizeClass != SizeClass.compact;
    final isApple = Theme.of(context).platform == TargetPlatform.macOS;
    final registry = ref.watch(commandRegistryProvider);
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;
    final saver = ref.watch(appSettingsProvider).value?.batterySaver ?? false;

    void goTo(int index) => navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );

    final destinations = [
      (
        icon: Icons.edit_note_outlined,
        selected: Icons.edit_note,
        label: l10n.navLog,
      ),
      (
        icon: Icons.contacts_outlined,
        selected: Icons.contacts,
        label: l10n.navCallsigns,
      ),
      (icon: Icons.waves_outlined, selected: Icons.waves, label: l10n.navSync),
      (
        icon: Icons.tune_outlined,
        selected: Icons.tune,
        label: l10n.navSettings,
      ),
    ];

    final content = Column(
      children: [
        SafeArea(
          bottom: false,
          child: TideGauge(pendingCount: pending, animate: !saver),
        ),
        // The gauge already sits below the status bar; without this every
        // screen's app bar would pad for it a second time. The Builder
        // matters: it takes the MediaQuery from below the shell's Scaffold,
        // which has already consumed the keyboard inset.
        Expanded(
          child: Builder(
            builder: (context) => MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: navigationShell,
            ),
          ),
        ),
      ],
    );

    final parent = Routes.parentOf(
      GoRouter.of(context).routeInformationProvider.value.uri,
    );
    final handlers = <String, VoidCallback>{
      CommandIds.showShortcuts: () =>
          showShortcutsOverlay(context, ref.read(commandRegistryProvider)),
      CommandIds.goToLog: () => goTo(0),
      CommandIds.goToCallsigns: () => goTo(1),
      CommandIds.goToSync: () => goTo(2),
      CommandIds.goToSettings: () => goTo(3),
      // Only while there is a page to leave: Esc then passes through.
      if (parent != null) CommandIds.goBack: () => context.go(parent),
      CommandIds.openContest: () => context.push(Routes.contest),
      CommandIds.startActivation: () => context.push(Routes.activationSetup),
      CommandIds.fastLogEntry: () => context.push(Routes.fle),
      CommandIds.syncNow: () async {
        await ref.read(syncControllerProvider.notifier).syncNow();
        if (!context.mounted) return;
        final activity = ref.read(syncControllerProvider);
        if (activity is SyncNeedsReview) {
          await showUploadPreview(context, ref);
          return;
        }
        final text = describeRun(l10n, activity);
        if (text != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(text)));
        }
      },
    };

    final rail = SafeArea(
      right: false,
      child: NavigationRail(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: goTo,
        extended: extendedRail,
        labelType: extendedRail
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.all,
        destinations: [
          for (final d in destinations)
            NavigationRailDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selected),
              label: Text(d.label),
            ),
        ],
      ),
    );

    final Widget scaffold = useRail
        ? Scaffold(
            body: Column(
              children: [
                // Windows and Linux draw the menu in the window; macOS has
                // it in the system menu bar (below).
                if (desktop && !isApple)
                  DesktopMenuBar(registry: registry, handlers: handlers),
                Expanded(
                  child: Row(
                    children: [
                      rail,
                      const VerticalDivider(width: 1),
                      Expanded(child: content),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            body: content,
            bottomNavigationBar: KeyboardDock.isDocked(context)
                ? null
                : NavigationBar(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: goTo,
                    destinations: [
                      for (final d in destinations)
                        NavigationDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selected),
                          label: d.label,
                        ),
                    ],
                  ),
          );

    return CommandHandlers(
      handlers: handlers,
      // Autofocus so global shortcuts work before anything is tapped.
      child: Focus(
        autofocus: true,
        child: desktop && isApple
            ? MacMenuBar(
                registry: registry,
                handlers: handlers,
                child: scaffold,
              )
            : scaffold,
      ),
    );
  }
}
