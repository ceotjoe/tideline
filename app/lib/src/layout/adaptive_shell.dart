import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/commands/shortcuts_overlay.dart';
import 'package:tideline/src/features/sync/sync_screen.dart';
import 'package:tideline/src/layout/size_class.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/tide_gauge.dart';

/// Window width from which the navigation rail shows its labels beside the
/// icons (extended). Below it the rail is compact.
const double extendedRailMinWidth = 1440;

/// Top-level navigation: a bottom bar on compact windows (thumb reach), a
/// navigation rail from medium width up. The tide gauge runs across the top
/// of the content on every size.
class AdaptiveShell extends ConsumerWidget {
  /// Creates the shell around go_router's [navigationShell].
  const new({required this.navigationShell, super.key});

  /// The router's stateful shell; keeps each branch's state.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sizeClass = SizeClass.of(context);
    // The wide rail with labels costs ~180 dp more. Tablets in landscape
    // (1180–1376 dp) need that room for content, so only wider windows get it.
    final extendedRail =
        MediaQuery.sizeOf(context).width >= extendedRailMinWidth;
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;

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
      (icon: Icons.waves_outlined, selected: Icons.waves, label: l10n.navSync),
      (
        icon: Icons.tune_outlined,
        selected: Icons.tune,
        label: l10n.navSettings,
      ),
    ];

    final content = Column(
      children: [
        SafeArea(bottom: false, child: TideGauge(pendingCount: pending)),
        Expanded(child: navigationShell),
      ],
    );

    return CommandHandlers(
      handlers: {
        CommandIds.showShortcuts: () =>
            showShortcutsOverlay(context, ref.read(commandRegistryProvider)),
        CommandIds.goToLog: () => goTo(0),
        CommandIds.goToSync: () => goTo(1),
        CommandIds.goToSettings: () => goTo(2),
        CommandIds.openContest: () => context.push(Routes.contest),
        CommandIds.startActivation: () => context.push(Routes.activationSetup),
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
      },
      // Autofocus so global shortcuts work before anything is tapped.
      child: Focus(
        autofocus: true,
        child: sizeClass == SizeClass.compact
            ? Scaffold(
                body: content,
                bottomNavigationBar: NavigationBar(
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
              )
            : Scaffold(
                body: Row(
                  children: [
                    SafeArea(
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
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                ),
              ),
      ),
    );
  }
}
