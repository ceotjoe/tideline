import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/contest_density.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/contest/cabrillo_categories.dart';
import 'package:tideline/src/features/contest/cabrillo_export_flow.dart';
import 'package:tideline/src/features/contest/contest_labels.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_setup_controller.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/features/contest/contest_sync_status.dart';
import 'package:tideline/src/features/contest/exchange_field.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/layout/size_class.dart';
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/empty_state.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Starts a contest session and lists past ones to reopen.
class ContestSetupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<ContestSetupScreen> createState() => _ContestSetupScreenState();
}

class _ContestSetupScreenState extends ConsumerState<ContestSetupScreen> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(contestSetupProvider).query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Leaves a pushed setup page once a session runs; the route that hosts
  /// the setup switches to the entry on its own.
  void _afterSessionChange() {
    if (!mounted) return;
    final location = GoRouterState.of(context).matchedLocation;
    if (location == Routes.contestSetup && context.canPop()) context.pop();
  }

  Future<void> _start() async {
    final session = await ref.read(contestSetupProvider.notifier).start();
    if (session != null) _afterSessionChange();
  }

  Future<void> _reopen(ContestSession session) async {
    await ref.read(contestSessionRepositoryProvider).reopen(session.id);
    _afterSessionChange();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final size = SizeClass.of(context);
    final definitions = ref.watch(contestDefinitionsProvider);

    final form = _SetupForm(search: _search, onStart: _start);
    final past = _PastSessions(onReopen: _reopen);

    return ContestDensityScope(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(l10n.contestSetupTitle)),
          body: definitions.hasError
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: l10n.contestSetupLoadFailed,
                  body: l10n.contestSetupLoadFailedBody,
                )
              : size.isAtLeast(SizeClass.expanded)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(context.metrics.md),
                        children: [form],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: context.metrics.contestSideWidth,
                      child: ListView(
                        padding: EdgeInsets.all(context.metrics.md),
                        children: [past],
                      ),
                    ),
                  ],
                )
              : ListView(
                  padding: EdgeInsets.all(metrics.md),
                  children: [
                    form,
                    SizedBox(height: metrics.lg),
                    past,
                  ],
                ),
        ),
      ),
    );
  }
}

class _SetupForm extends ConsumerWidget {
  const new({required this.search, required this.onStart});

  final TextEditingController search;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme;
    final setup = ref.watch(contestSetupProvider);
    final controller = ref.read(contestSetupProvider.notifier);
    final definitions = ref.watch(contestDefinitionsProvider).value ?? const [];
    final stations = ref.watch(stationsProvider).value ?? const [];
    final account = ref.watch(activeAccountProvider);
    final active = ref.watch(activeContestSessionProvider).value;
    final dxcc = ref.watch(dxccProvider).value;
    final defaultRemote = int.tryParse(
      ref
              .watch(settingsValuesProvider)
              .value?['account.${account?.id}.defaultStation'] ??
          '',
    );
    final resolved = resolveSetup(
      setup: setup,
      definitions: definitions,
      stations: stations,
      dxcc: dxcc,
      defaultStationRemoteId: defaultRemote,
    );

    final query = setup.query.trim().toLowerCase();
    final matching = [
      for (final d in definitions)
        if (query.isEmpty ||
            d.definition.name.toLowerCase().contains(query) ||
            d.definition.id.contains(query))
          d,
    ];

    Widget heading(String title) => Padding(
      padding: EdgeInsets.only(top: metrics.md, bottom: metrics.sm),
      child: Semantics(
        header: true,
        child: Text(title, style: text.titleMedium),
      ),
    );

    final canStart =
        active == null &&
        resolved != null &&
        account != null &&
        !setup.starting;

    return FocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (active != null)
            _Notice(
              icon: Icons.info_outline,
              text: l10n.contestSetupSessionRunning,
            ),
          heading(l10n.contestSetupChooseContest),
          TextField(
            controller: search,
            decoration: InputDecoration(
              labelText: l10n.contestSearchLabel,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: controller.setQuery,
          ),
          SizedBox(height: metrics.sm),
          if (matching.isEmpty)
            Text(l10n.contestSearchEmpty, style: text.bodyMedium)
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final d in matching)
                    _ContestTile(
                      stored: d,
                      selected: d.definition.id == setup.definitionId,
                      onTap: () => controller.selectDefinition(d.definition),
                    ),
                ],
              ),
            ),
          if (resolved == null && setup.definitionId != null)
            Padding(
              padding: EdgeInsets.only(top: metrics.sm),
              child: Text(l10n.contestSetupNeedStation),
            ),
          if (resolved != null) ...[
            heading(l10n.contestSetupStation),
            DropdownButtonFormField<String>(
              key: ValueKey('station-${resolved.station.id}'),
              initialValue: resolved.station.id,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.fieldStation),
              items: [
                for (final s in stations)
                  DropdownMenuItem(
                    value: s.id,
                    child: Text(
                      '${s.name} (${s.callsign})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (id) {
                if (id != null) controller.selectStation(id);
              },
            ),
            heading(l10n.contestSetupExchange),
            Text(l10n.contestSetupExchangeHelp, style: text.bodySmall),
            SizedBox(height: metrics.sm),
            Wrap(
              spacing: metrics.sm,
              runSpacing: metrics.sm,
              children: [
                for (final (i, e) in resolved.exchange.sent.indexed)
                  if (resolved.isEditable(i))
                    SizedBox(
                      width: MediaQuery.textScalerOf(context)
                          .scale(metrics.contestFieldWidth * 1.4),
                      child: _ExchangeValueField(
                        // A new default (other station or contest) must show,
                        // so the field starts over with it.
                        key: ValueKey(
                          '${resolved.definition.id}|${resolved.station.id}|'
                          '${ownExchangeKey(resolved.exchange.sent, i)}',
                        ),
                        element: e,
                        initial:
                            resolved.values[ownExchangeKey(
                              resolved.exchange.sent,
                              i,
                            )] ??
                            '',
                        errorText:
                            setup.showErrors && resolved.errorAt(i) != null
                            ? exchangeErrorText(l10n, e, resolved.errorAt(i)!)
                            : null,
                        onChanged: (v) => controller.setValue(
                          ownExchangeKey(resolved.exchange.sent, i),
                          v,
                        ),
                      ),
                    ),
              ],
            ),
            SizedBox(height: metrics.sm),
            for (final e in resolved.exchange.sent)
              if (e.kind == ExchangeKind.rst)
                _Notice(icon: Icons.bolt, text: l10n.contestSetupRstAuto)
              else if (e.kind == ExchangeKind.serial)
                _Notice(icon: Icons.tag, text: l10n.contestSetupSerialAuto),
            heading(l10n.contestSetupCabrillo),
            Text(l10n.contestSetupCabrilloHelp, style: text.bodySmall),
            SizedBox(height: metrics.sm),
            Wrap(
              spacing: metrics.sm,
              runSpacing: metrics.sm,
              children: [
                for (final category in CabrilloCategory.values)
                  SizedBox(
                    width: MediaQuery.textScalerOf(context)
                        .scale(metrics.contestFieldWidth * 2),
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey(
                        '${category.tag}-${setup.categories[category]}',
                      ),
                      initialValue: setup.categories[category],
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: category.label(l10n),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          child: Text(l10n.contestCatNotSet),
                        ),
                        // Protocol tokens: shown as they are written to the
                        // log, never translated.
                        for (final v in category.tokens)
                          DropdownMenuItem<String?>(value: v, child: Text(v)),
                      ],
                      onChanged: (v) => controller.setCategory(category, v),
                    ),
                  ),
              ],
            ),
          ],
          SizedBox(height: metrics.lg),
          if (setup.startFailed)
            Padding(
              padding: EdgeInsets.only(bottom: metrics.sm),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  l10n.contestStartFailed,
                  style: TextStyle(color: context.colors.error),
                ),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.icon(
              onPressed: canStart ? onStart : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.contestStart),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExchangeValueField extends StatelessWidget {
  const new({
    required this.element,
    required this.initial,
    required this.errorText,
    required this.onChanged,
    super.key,
  });

  final ExchangeElement element;
  final String initial;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final input = ExchangeInput.of(element.kind);
    final label = exchangeLabel(l10n, element);
    return TextFormField(
      initialValue: initial,
      keyboardType: input.keyboard,
      textCapitalization: input.capitalization,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: input.formatters,
      decoration: InputDecoration(
        labelText: element.optional ? l10n.contestOptionalLabel(label) : label,
        errorText: errorText,
        errorMaxLines: 3,
      ),
      onChanged: onChanged,
    );
  }
}

class _ContestTile extends StatelessWidget {
  const new({
    required this.stored,
    required this.selected,
    required this.onTap,
  });

  final StoredContestDefinition stored;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      selected: selected,
      selectedTileColor: context.colors.surfaceVariant,
      minVerticalPadding: context.metrics.xs,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
      ),
      title: Text(stored.definition.name),
      subtitle: Text(
        stored.builtin ? l10n.contestBuiltin : l10n.contestImported,
      ),
      onTap: onTap,
    );
  }
}

class _Notice extends StatelessWidget {
  const new({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.metrics.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Icon(icon, size: 18, color: context.colors.textSecondary),
        ),
        SizedBox(width: context.metrics.sm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );
}

class _PastSessions extends ConsumerWidget {
  const new({required this.onReopen});

  final Future<void> Function(ContestSession session) onReopen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme;
    final sessions = ref.watch(contestSessionsProvider).value ?? const [];
    final definitions = ref.watch(contestDefinitionsProvider).value ?? const [];
    final hasActive = sessions.any((s) => s.isActive);

    String nameOf(ContestSession s) =>
        definitions
            .where((d) => d.definition.id == s.definitionId)
            .firstOrNull
            ?.definition
            .name ??
        s.definitionId;

    bool hasCabrillo(ContestSession s) =>
        definitions
            .where((d) => d.definition.id == s.definitionId)
            .firstOrNull
            ?.definition
            .cabrillo !=
        null;

    String when(int millis) {
      final t = UtcDateTime.fromMillis(millis);
      final d = t.value;
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')} '
          '${utcClock(t)} ${l10n.unitUtc}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.contestPastTitle, style: text.titleMedium),
        ),
        SizedBox(height: metrics.sm),
        if (sessions.isEmpty)
          Text(l10n.contestPastEmpty, style: text.bodyMedium)
        else
          for (final s in sessions)
            Card(
              margin: EdgeInsets.only(bottom: metrics.sm),
              child: Padding(
                padding: EdgeInsets.all(metrics.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nameOf(s), style: text.titleMedium),
                    Text(when(s.startedAt), style: text.bodySmall),
                    SizedBox(height: metrics.xs),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          s.isActive
                              ? Icons.play_circle_outline
                              : Icons.check_circle_outline,
                          size: 16,
                          color: context.colors.textSecondary,
                        ),
                        SizedBox(width: metrics.xs),
                        Text(
                          s.isActive
                              ? l10n.contestStateActive
                              : l10n.contestStateEnded,
                          style: text.labelLarge,
                        ),
                      ],
                    ),
                    SizedBox(height: metrics.xs),
                    ContestSyncStatus(session: s),
                    if (!hasCabrillo(s))
                      Padding(
                        padding: EdgeInsets.only(top: metrics.xs),
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
                                style: text.bodySmall?.copyWith(
                                  color: context.colors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: metrics.xs),
                    Wrap(
                      spacing: metrics.sm,
                      runSpacing: metrics.xs,
                      children: [
                        if (!s.isActive && !hasActive)
                          OutlinedButton(
                            onPressed: () => onReopen(s),
                            child: Text(l10n.contestReopen),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => exportCabrillo(context, ref, s),
                          icon: const Icon(Icons.file_upload_outlined),
                          label: Text(l10n.commandExportCabrillo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
