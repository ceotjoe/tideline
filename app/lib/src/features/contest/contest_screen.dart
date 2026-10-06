import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/commands/shortcuts_overlay.dart';
import 'package:tideline/src/design/contest_density.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/contest/cabrillo_export_flow.dart';
import 'package:tideline/src/features/contest/contest_edit_controller.dart';
import 'package:tideline/src/features/contest/contest_entry_controller.dart';
import 'package:tideline/src/features/contest/contest_entry_panel.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_rates_panel.dart';
import 'package:tideline/src/features/contest/contest_recent_list.dart';
import 'package:tideline/src/features/contest/contest_setup_screen.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/features/contest/contest_sync_status.dart';
import 'package:tideline/src/features/log/qso_entry_form.dart'
    show QsoEntryLayout;
import 'package:tideline/src/layout/size_class.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/empty_state.dart';
import 'package:tideline/src/widgets/keyboard_aware.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Whether the score and rates panel is open. Null means "the default for
/// this window": open from medium width up, collapsed on a phone.
final ratesPanelOpenProvider = NotifierProvider<_PanelOpen, bool?>(
  _PanelOpen.new,
);

class _PanelOpen extends Notifier<bool?> {
  @override
  bool? build() => null;

  // A named parameter reads better at call sites than a setter.
  // ignore: use_setters_to_change_properties
  void set({required bool open}) => state = open;
}

/// The `/contest` route: the entry screen while a session runs, the setup
/// otherwise.
class ContestRoute extends ConsumerWidget {
  /// Creates the route.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeContestSessionProvider);
    if (session.isLoading && !session.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final active = session.value;
    if (active == null) return const ContestSetupScreen();
    if (ref.watch(contestSpecProvider) == null) {
      final definitions = ref.watch(contestDefinitionsProvider);
      final missing =
          definitions.hasValue &&
          !definitions.requireValue.any(
            (d) => d.definition.id == active.definitionId,
          );
      if (!missing) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return _MissingDefinition(sessionId: active.id);
    }
    return const ContestDensityScope(child: ContestScreen());
  }
}

class _MissingDefinition extends ConsumerWidget {
  const new({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contestTitle)),
      body: EmptyState(
        icon: Icons.error_outline,
        title: l10n.contestMissingTitle,
        body: l10n.contestMissingBody,
        action: FilledButton(
          onPressed: () => ref
              .read(contestSessionRepositoryProvider)
              .end(sessionId, UtcDateTime.now().millis),
          child: Text(l10n.commandEndContest),
        ),
      ),
    );
  }
}

/// The contest entry screen: fast keyboard entry, live hints, recent QSOs
/// with inline editing, and the score and rates.
///
/// Layout follows the window size class (ADR 0010): a phone stacks entry,
/// a collapsible panel and the recent list; a tablet in portrait adds room;
/// a tablet in landscape and desktop windows put the panel in a side
/// column.
class ContestScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends ConsumerState<ContestScreen>
    with WidgetsBindingObserver, KeyboardAware {
  /// The body needs this much width, and the window must be wider than
  /// tall, for the entry strip (a tablet in landscape).
  static const double _stripMinWidth = 900;

  /// The recent list keeps at least this much height beside the strip,
  /// unless the keyboard is up: then the entry takes what it needs.
  static const double _minListHeight = 96;

  // Keeps the entry panel's state when the layout changes.
  final _entryKey = GlobalKey<ContestEntryPanelState>();

  bool _panelOpen(SizeClass size) =>
      ref.read(ratesPanelOpenProvider) ?? size.isAtLeast(SizeClass.medium);

  void _togglePanel() => ref
      .read(ratesPanelOpenProvider.notifier)
      .set(open: !_panelOpen(SizeClass.of(context)));

  /// The session row as stored now (the spec ignores sync-state changes).
  ContestSession _liveSession(ContestSpec spec) =>
      ref.read(activeContestSessionProvider).value ?? spec.session;

  void _wipe() {
    ref.read(contestEntryProvider.notifier).wipe();
    _entryKey.currentState?.focusCall();
  }

  Future<void> _endSession() async {
    final l10n = AppLocalizations.of(context);
    final spec = ref.read(contestSpecProvider);
    if (spec == null) return;
    final repository = ref.read(contestSessionRepositoryProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contestEndTitle),
        content: Text(l10n.contestEndBody),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commandEndContest),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await repository.end(spec.session.id, UtcDateTime.now().millis);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final spec = ref.watch(contestSpecProvider);
    if (spec == null) return const SizedBox.shrink();
    final size = SizeClass.of(context);
    final open =
        ref.watch(ratesPanelOpenProvider) ?? size.isAtLeast(SizeClass.medium);
    final entryController = ref.read(contestEntryProvider.notifier);

    // One key for all layouts, so typed input and focus survive a rotation.
    Widget entryCard({QsoEntryLayout layout = QsoEntryLayout.stacked}) => Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.md),
        child: ContestEntryPanel(
          key: _entryKey,
          layout: layout,
          onEditLast: ref.read(contestEditProvider.notifier).beginLast,
        ),
      ),
    );

    final landscape =
        MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final Widget body;
    if (size.isAtLeast(SizeClass.expanded)) {
      final sideBySide = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.62,
                    ),
                    // The card scrolls its fields and pins the Log row.
                    child: Padding(
                      padding: EdgeInsets.all(metrics.sm),
                      child: entryCard(),
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _SectionTitle(l10n.contestRecentTitle),
                        ),
                        const ContestRecentSliver(),
                        SliverToBoxAdapter(
                          child: SizedBox(height: bottomInset),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (open) ...[
            const VerticalDivider(width: 1),
            SizedBox(
              width: metrics.contestSideWidth,
              child: const SingleChildScrollView(child: ContestRatesPanel()),
            ),
          ],
        ],
      );
      body = LayoutBuilder(
        builder: (context, constraints) {
          if (!landscape || constraints.maxWidth < _stripMinWidth) {
            return sideBySide;
          }
          // Entry across the full width, so everything stays visible above
          // the keyboard; recent QSOs and the score panel share the rest.
          return Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      (constraints.maxHeight -
                              (keyboardUp && landscape ? 0 : _minListHeight) -
                              1) // the divider below
                          .clamp(0, double.infinity),
                ),
                // The card scrolls its fields and pins the Log row.
                child: Padding(
                  padding: EdgeInsets.all(metrics.sm),
                  child: entryCard(layout: QsoEntryLayout.strip),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _SectionTitle(l10n.contestRecentTitle),
                          ),
                          const ContestRecentSliver(),
                          SliverToBoxAdapter(
                            child: SizedBox(height: bottomInset),
                          ),
                        ],
                      ),
                    ),
                    if (open) ...[
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: metrics.contestSideWidth,
                        child: const SingleChildScrollView(
                          child: ContestRatesPanel(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      );
    } else {
      body = CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(metrics.sm),
            sliver: SliverToBoxAdapter(child: entryCard()),
          ),
          SliverToBoxAdapter(
            child: _PanelHeader(open: open, onToggle: _togglePanel),
          ),
          if (open)
            const SliverToBoxAdapter(
              child: ContestRatesPanel(showTitle: false),
            ),
          SliverToBoxAdapter(child: _SectionTitle(l10n.contestRecentTitle)),
          const ContestRecentSliver(),
          SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
        ],
      );
    }

    final hideAppBar =
        keyboardUp && size.isAtLeast(SizeClass.medium) && landscape;

    return CommandHandlers(
      handlers: {
        CommandIds.contestLog: () => _entryKey.currentState?.submit(),
        CommandIds.contestWipe: _wipe,
        CommandIds.contestEditLast: ref
            .read(contestEditProvider.notifier)
            .beginLast,
        CommandIds.contestFocusCall: () => _entryKey.currentState?.focusCall(),
        CommandIds.bandUp: () => entryController.stepBand(1),
        CommandIds.bandDown: () => entryController.stepBand(-1),
        CommandIds.nextMode: entryController.stepMode,
        CommandIds.contestToggleRates: _togglePanel,
        CommandIds.contestEnd: _endSession,
        CommandIds.contestExportCabrillo: () =>
            exportCabrillo(context, ref, _liveSession(spec)),
        CommandIds.showShortcuts: () =>
            showShortcutsOverlay(context, ref.read(commandRegistryProvider)),
        CommandIds.goToLog: () => context.go(Routes.log),
        CommandIds.goToSync: () => context.go(Routes.sync),
        CommandIds.goToSettings: () => context.go(Routes.settings),
        CommandIds.syncNow: () =>
            ref.read(syncControllerProvider.notifier).syncNow(manual: true),
      },
      child: Scaffold(
        // The keyboard needs the room on a tablet in landscape.
        appBar: hideAppBar
            ? null
            : AppBar(
                title: Text(
                  spec.definition.name,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  IconButton(
                    tooltip: l10n.commandToggleRates,
                    icon: Icon(open ? Icons.insights : Icons.insights_outlined),
                    onPressed: _togglePanel,
                  ),
                  IconButton(
                    tooltip: l10n.contestSessionsAction,
                    icon: const Icon(Icons.history),
                    onPressed: () => context.push(Routes.contestSetup),
                  ),
                  IconButton(
                    tooltip: l10n.commandEndContest,
                    icon: const Icon(Icons.stop_circle_outlined),
                    onPressed: _endSession,
                  ),
                  PopupMenuButton<String>(
                    tooltip: l10n.contestMoreActions,
                    onSelected: (_) =>
                        exportCabrillo(context, ref, _liveSession(spec)),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: CommandIds.contestExportCabrillo,
                        child: Row(
                          children: [
                            const Icon(Icons.file_upload_outlined),
                            SizedBox(width: metrics.sm),
                            Flexible(child: Text(l10n.commandExportCabrillo)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        body: Column(
          children: [
            _StatusStrip(definition: spec.definition),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}

/// The session's Wavelog state, and a warning when the contest cannot be
/// exported as Cabrillo.
class _StatusStrip extends ConsumerWidget {
  const new({required this.definition});

  final ContestDefinition definition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    // The live session row: the spec ignores sync changes on purpose.
    final session = ref.watch(activeContestSessionProvider).value;
    if (session == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.md,
        vertical: metrics.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContestSyncStatus(session: session),
          if (definition.cabrillo == null)
            Padding(
              padding: EdgeInsets.only(top: metrics.xs),
              child: Semantics(
                container: true,
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: context.colors.error,
                      ),
                    ),
                    SizedBox(width: metrics.xs),
                    Expanded(
                      child: Text(
                        l10n.cabrilloUnavailableBanner,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      context.metrics.md,
      context.metrics.sm,
      context.metrics.md,
      context.metrics.xs,
    ),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

/// The collapsible header of the score panel on narrow windows; collapsed
/// it shows the score in one line.
class _PanelHeader extends ConsumerWidget {
  const new({required this.open, required this.onToggle});

  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final score = ref.watch(contestLiveProvider.select((l) => l?.score));
    final summary = score == null
        ? null
        : l10n.contestPanelSummary(score.qsos, score.points, score.total);
    return Semantics(
      button: true,
      expanded: open,
      label: l10n.contestPanelTitle,
      value: open ? null : summary,
      excludeSemantics: true,
      onTap: onToggle,
      child: InkWell(
        onTap: onToggle,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: metrics.minTouchTarget),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.md),
            child: Row(
              children: [
                Icon(open ? Icons.expand_less : Icons.expand_more),
                SizedBox(width: metrics.sm),
                Expanded(
                  child: Text(
                    open || summary == null
                        ? l10n.contestPanelTitle
                        : '${l10n.contestPanelTitle} · $summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
