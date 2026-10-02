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
import 'package:tideline_domain/tideline_domain.dart';

/// The QSO selected for the detail pane on large windows.
final selectedQsoProvider = NotifierProvider<_Selected, String?>(_Selected.new);

class _Selected extends Notifier<String?> {
  @override
  String? build() => null;

  // A method (not a setter) reads naturally at call sites: select(id).
  // ignore: use_setters_to_change_properties
  void select(String? id) => state = id;
}

/// The logging screen: entry, log and context, adapted to the window.
class LogScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  final _formKey = GlobalKey<QsoEntryFormState>();

  void _open(BuildContext context, String id, SizeClass size) {
    if (size.isAtLeast(SizeClass.expanded)) {
      ref.read(selectedQsoProvider.notifier).select(id);
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
    final selected = ref.watch(selectedQsoProvider);

    final form = Card(
      child: Padding(
        padding: EdgeInsets.all(metrics.md),
        child: QsoEntryForm(key: _formKey),
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
              selected: log[i].qso.id == selected,
              onTap: () => _open(context, log[i].qso.id, size),
            ),
          );

    final Widget body;
    switch (size) {
      case SizeClass.compact:
        body = ListView(
          padding: EdgeInsets.all(metrics.md),
          children: [
            form,
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
      case SizeClass.medium:
        body = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(metrics.md),
                child: form,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: list()),
          ],
        );
      case SizeClass.expanded || SizeClass.large:
        body = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 380,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(metrics.md),
                child: form,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: list()),
            const VerticalDivider(width: 1),
            SizedBox(
              width: size == SizeClass.large ? 400 : 320,
              child: selected == null
                  ? const _ContextPanel()
                  : QsoDetail(
                      key: ValueKey(selected),
                      qsoId: selected,
                      onClosed: () =>
                          ref.read(selectedQsoProvider.notifier).select(null),
                    ),
            ),
          ],
        );
    }

    return CommandHandlers(
      handlers: {
        CommandIds.logQso: () => _formKey.currentState?.submit(),
        CommandIds.clearEntry: () {
          ref.read(qsoEntryProvider.notifier).clear();
          ref.read(callsignFocusProvider).requestFocus();
        },
        CommandIds.newQso: () => ref.read(callsignFocusProvider).requestFocus(),
        CommandIds.editLastQso: () {
          if (log.isNotEmpty) _open(context, log.first.qso.id, size);
        },
      },
      child: Scaffold(
        appBar: AppBar(
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

/// Context for the callsign being entered: DXCC details and the local
/// worked-before history. Fully offline.
class _ContextPanel extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final call = ref.watch(qsoEntryProvider.select((e) => e.call));
    final db = ref.watch(dxccProvider).value;
    final match = call.length >= 2 ? db?.resolve(call) : null;
    final base = Callsign.tryParse(call)?.baseCall;
    final log = ref.watch(logProvider).value ?? const [];
    final before = base == null
        ? const <Never>[]
        : log.where((q) => q.qso.call.baseCall == base).toList();
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme;
    if (match == null) {
      return Padding(
        padding: EdgeInsets.all(metrics.lg),
        child: Text(l10n.contextHint, style: text.bodySmall),
      );
    }
    return ListView(
      padding: EdgeInsets.all(metrics.md),
      children: [
        Semantics(
          header: true,
          child: Text(match.entity.name, style: text.titleMedium),
        ),
        if (match.waeEntity case final wae?)
          Text(l10n.contextWae(wae.name), style: text.bodySmall),
        SizedBox(height: metrics.sm),
        Text(
          l10n.dxccSummary(
            match.entity.name,
            match.continent,
            match.cqz,
            match.ituz,
          ),
        ),
        Text(l10n.contextDxccNumber(match.entity.dxcc), style: text.bodySmall),
        SizedBox(height: metrics.lg),
        Semantics(
          header: true,
          child: Text(l10n.contextWorkedBefore, style: text.titleMedium),
        ),
        if (before.isEmpty)
          Text(l10n.contextNewOne)
        else
          for (final q in before.take(10)) QsoTile(item: q),
      ],
    );
  }
}
