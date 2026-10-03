import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/contest/contest_banner.dart';
import 'package:tideline/src/features/log/qso_detail.dart';
import 'package:tideline/src/features/log/qso_entry_controller.dart';
import 'package:tideline/src/features/log/qso_entry_form.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/layout/size_class.dart';
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/empty_state.dart';
import 'package:tideline/src/widgets/keyboard_aware.dart';

/// The logging screen: entry, log and context, adapted to the window.
class LogScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen>
    with WidgetsBindingObserver, KeyboardAware {
  final _formKey = GlobalKey<QsoEntryFormState>();

  /// The body needs this much width, and the window must be wider than tall,
  /// for the entry strip (a tablet in landscape).
  static const double _stripMinWidth = 900;

  /// The list keeps at least this much height beside the entry strip.
  static const double _minListHeight = 96;

  void _open(BuildContext context, String id) {
    if (SizeClass.of(context) != SizeClass.compact) {
      // Tablets show the details over the log, so the entry form stays put.
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            maxWidth: 640,
          ),
          builder: (context) =>
              QsoDetail(qsoId: id, onClosed: () => Navigator.of(context).pop()),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context).qsoDetails)),
          body: QsoDetail(
            qsoId: id,
            onClosed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = SizeClass.of(context);
    final metrics = context.metrics;
    final log = ref.watch(logProvider).value ?? const [];

    // One key for all variants, so typed input and focus survive a resize
    // or rotation between the layouts.
    Widget formCard({QsoEntryLayout layout = QsoEntryLayout.stacked}) => Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.md),
        child: QsoEntryForm(key: _formKey, layout: layout),
      ),
    );

    Widget list({bool shrinkWrap = false}) => log.isEmpty
        ? EmptyState(
            icon: Icons.edit_note,
            title: l10n.logEmptyTitle,
            body: l10n.logEmptyBodyReady,
          )
        : ListView.builder(
            shrinkWrap: shrinkWrap,
            physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
            itemCount: log.length,
            itemBuilder: (context, i) => QsoTile(
              item: log[i],
              onTap: () => _open(context, log[i].qso.id),
            ),
          );

    final Widget body;
    switch (size) {
      case SizeClass.compact:
        body = ListView(
          padding: EdgeInsets.all(metrics.md),
          children: [
            formCard(),
            SizedBox(height: metrics.md),
            Semantics(
              header: true,
              child: Text(
                l10n.recentQsos,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (log.isEmpty)
              Padding(
                padding: EdgeInsets.all(metrics.md),
                child: Text(l10n.logEmptyBodyReady),
              )
            else
              list(shrinkWrap: true),
          ],
        );
      case SizeClass.medium || SizeClass.expanded || SizeClass.large:
        // Layout follows the width and shape the body really has (the
        // navigation rail and split-screen windows take their share), not
        // the window class.
        final landscape =
            MediaQuery.sizeOf(context).width >
            MediaQuery.sizeOf(context).height;
        body = LayoutBuilder(
          builder: (context, constraints) {
            // Strip in landscape, rows of three otherwise. Either way the
            // fields come first and the log fills the rest; when the keyboard
            // leaves too little height the fields scroll and the list keeps
            // a minimum.
            final layout = landscape && constraints.maxWidth >= _stripMinWidth
                ? QsoEntryLayout.strip
                : QsoEntryLayout.grid;
            return Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: (constraints.maxHeight - _minListHeight).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(metrics.sm),
                    child: layout == QsoEntryLayout.strip
                        ? SingleChildScrollView(child: formCard(layout: layout))
                        : formCard(layout: layout),
                  ),
                ),
                const Divider(height: 1),
                Expanded(child: list()),
              ],
            );
          },
        );
    }

    final hideAppBar =
        keyboardUp &&
        size != SizeClass.compact &&
        MediaQuery.sizeOf(context).width > MediaQuery.sizeOf(context).height;

    return CommandHandlers(
      handlers: {
        CommandIds.logQso: () => _formKey.currentState?.submit(),
        CommandIds.clearEntry: () {
          ref.read(qsoEntryProvider.notifier).clear();
          ref.read(callsignFocusProvider).requestFocus();
        },
        CommandIds.newQso: () => ref.read(callsignFocusProvider).requestFocus(),
        CommandIds.editLastQso: () {
          if (log.isNotEmpty) _open(context, log.first.qso.id);
        },
      },
      child: Scaffold(
        // The keyboard needs the room on a tablet in landscape.
        appBar: hideAppBar
            ? null
            : AppBar(
                title: Text(l10n.navLog),
                actions: [
                  IconButton(
                    tooltip: l10n.contestOpenAction,
                    icon: const Icon(Icons.emoji_events_outlined),
                    onPressed: () => context.push(Routes.contest),
                  ),
                ],
              ),
        body: Column(
          children: [
            const ContestBanner(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
