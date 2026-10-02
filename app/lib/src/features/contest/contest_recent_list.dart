import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/contest/contest_edit_controller.dart';
import 'package:tideline/src/features/contest/contest_labels.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_qso_codec.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/features/contest/exchange_field.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/widgets/callsign_text.dart';
import 'package:tideline/src/widgets/frequency_field.dart';
import 'package:tideline/src/widgets/upper_case_formatter.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The session's QSOs, newest first, as a sliver. A row opens an inline
/// editor in place, so the operator never leaves contest mode to fix a
/// busted call or a wrong zone.
///
/// Virtualised: only visible rows are built, so 5,000 QSOs cost no more
/// than 50.
class ContestRecentSliver extends ConsumerWidget {
  /// Creates the list.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final live = ref.watch(contestLiveProvider);
    final spec = ref.watch(contestSpecProvider);
    final editing = ref.watch(contestEditProvider.select((e) => e?.qsoId));
    if (live == null || spec == null || live.qsos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(context.metrics.md),
          child: Text(l10n.contestRecentEmpty),
        ),
      );
    }
    final qsos = live.qsos;
    final count = qsos.length;
    return SliverList.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        final qso = qsos[count - 1 - index];
        if (qso.id == editing) {
          return ContestInlineEditor(key: ValueKey('edit-${qso.id}'), qso: qso);
        }
        return ContestQsoRow(
          key: ValueKey(qso.id),
          qso: qso,
          spec: spec,
          score: live.engine.scores[qso.id],
          onTap: () => ref.read(contestEditProvider.notifier).begin(qso),
        );
      },
    );
  }
}

/// One dense row of the recent list.
class ContestQsoRow extends StatelessWidget {
  /// Creates the row.
  const new({
    required this.qso,
    required this.spec,
    required this.score,
    required this.onTap,
    super.key,
  });

  /// The QSO.
  final Qso qso;

  /// The running session.
  final ContestSpec spec;

  /// What the QSO scored, if known.
  final QsoScore? score;

  /// Opens the inline editor.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    final sent = sentValuesOf(spec, qso).where((v) => v.isNotEmpty).join(' ');
    final rcvd = rcvdValuesOf(spec, qso).where((v) => v.isNotEmpty).join(' ');
    final time = '${utcClock(qso.timeOn)} ${l10n.unitUtc}';
    final summary = [
      time,
      bandDisplayName(qso.band),
      qso.mode.label,
      l10n.contestRowExchange(sent, rcvd),
    ].join(' · ');
    final flags = <Widget>[
      if (score?.status == QsoScoreStatus.dupe)
        _Flag(
          icon: Icons.block,
          text: l10n.contestFlagDupe,
          colors: c.rejected,
        ),
      if (score?.isNewMultiplier ?? false)
        _Flag(icon: Icons.stars, text: l10n.contestFlagMult, colors: c.synced),
      if (score?.status == QsoScoreStatus.outOfContest)
        _Flag(
          icon: Icons.do_not_disturb_on_outlined,
          text: l10n.contestFlagOut,
          colors: c.pending,
        ),
    ];
    return Semantics(
      button: true,
      hint: l10n.contestRowEditHint,
      child: MergeSemantics(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: metrics.contestRowHeight),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.md,
                vertical: metrics.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: metrics.sm,
                          runSpacing: metrics.xs,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CallsignText(
                              qso.call.value,
                              style: TidelineType.callsign.copyWith(
                                fontSize: 17,
                                color: c.text,
                              ),
                            ),
                            ...flags,
                          ],
                        ),
                        Text(summary, style: text.bodySmall),
                      ],
                    ),
                  ),
                  if (score != null)
                    Padding(
                      padding: EdgeInsetsDirectional.only(start: metrics.sm),
                      child: Text(
                        l10n.contestPoints(score!.points),
                        style: text.labelLarge,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Flag extends StatelessWidget {
  const new({required this.icon, required this.text, required this.colors});

  final IconData icon;
  final String text;
  final StatusColors colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: context.metrics.xs * 2,
      vertical: context.metrics.xs / 2,
    ),
    decoration: BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: colors.foreground.withValues(alpha: .4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.foreground),
        SizedBox(width: context.metrics.xs),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.foreground, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

/// The inline editor that replaces a row: call, received exchange, band and
/// mode. The sent exchange is shown but cannot change.
class ContestInlineEditor extends ConsumerStatefulWidget {
  /// Creates the editor for [qso].
  const new({required this.qso, super.key});

  /// The QSO being edited.
  final Qso qso;

  @override
  ConsumerState<ContestInlineEditor> createState() =>
      _ContestInlineEditorState();
}

class _ContestInlineEditorState extends ConsumerState<ContestInlineEditor> {
  late final TextEditingController _call;
  late final FocusNode _callFocus = FocusNode(
    debugLabel: 'edit call',
    onKeyEvent: (_, event) => spaceMovesOn(event, () => _focusElement(0)),
  );
  List<TextEditingController> _rcvd = [];
  List<FocusNode> _rcvdFocus = [];

  @override
  void initState() {
    super.initState();
    final edit = ref.read(contestEditProvider);
    _call = TextEditingController(text: edit?.call ?? widget.qso.call.value);
  }

  @override
  void dispose() {
    _call.dispose();
    _callFocus.dispose();
    for (final c in _rcvd) {
      c.dispose();
    }
    for (final f in _rcvdFocus) {
      f.dispose();
    }
    super.dispose();
  }

  void _focusElement(int i) {
    if (i < _rcvdFocus.length) _rcvdFocus[i].requestFocus();
  }

  void _ensureShape(int count, ContestEdit edit) {
    if (_rcvd.length == count) return;
    _rcvd = [
      for (var i = 0; i < count; i++)
        TextEditingController(text: i < edit.rcvd.length ? edit.rcvd[i] : ''),
    ];
    _rcvdFocus = [
      for (var i = 0; i < count; i++)
        FocusNode(
          debugLabel: 'edit exchange $i',
          onKeyEvent: (_, event) =>
              spaceMovesOn(event, () => _focusElement(i + 1)),
        ),
    ];
  }

  Future<void> _save() async {
    final controller = ref.read(contestEditProvider.notifier);
    final saved = await controller.save();
    if (saved || !mounted) return;
    final issues = ref.read(contestEditProvider)?.issues ?? const [];
    final first = issues.firstOrNull;
    if (first == null) return;
    switch (first.field) {
      case ContestIssueField.call:
        _callFocus.requestFocus();
      case ContestIssueField.element:
        _focusElement(first.elementIndex ?? 0);
      case ContestIssueField.band ||
          ContestIssueField.mode ||
          ContestIssueField.frequency:
        break;
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context);
    final spec = ref.read(contestSpecProvider);
    final controller = ref.read(contestEditProvider.notifier);
    final serial = widget.qso.field('STX');
    final call = widget.qso.call.value;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contestDeleteTitle),
        content: Text(
          spec?.usesSerial ?? false
              ? l10n.contestDeleteBodySerial(call, serial ?? '')
              : l10n.contestDeleteBody(call),
        ),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDeleteQso),
          ),
        ],
      ),
    );
    if (ok ?? false) await controller.delete(widget.qso.id);
  }

  @override
  Widget build(BuildContext context) {
    final edit = ref.watch(contestEditProvider);
    final spec = ref.watch(contestSpecProvider);
    if (edit == null || spec == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final controller = ref.read(contestEditProvider.notifier);
    _ensureShape(spec.exchange.rcvd.length, edit);
    final scale = MediaQuery.textScalerOf(context);

    final sentValues = sentValuesOf(spec, widget.qso);
    final sent = [
      for (final (i, e) in spec.exchange.sent.indexed)
        if (sentValues[i].isNotEmpty)
          '${exchangeLabel(l10n, e)} ${sentValues[i]}',
    ].join(' · ');

    return CommandHandlers(
      handlers: {
        CommandIds.contestLog: _save,
        CommandIds.contestWipe: controller.cancel,
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: metrics.sm,
          vertical: metrics.xs,
        ),
        padding: EdgeInsets.all(metrics.md),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: const BorderRadius.all(TidelineMetrics.radiusMd),
          border: Border.all(color: context.colors.outline),
        ),
        child: FocusTraversalGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.contestEditTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(height: metrics.xs),
              Text(
                l10n.contestEditSent(sent),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(height: metrics.sm),
              TextField(
                controller: _call,
                focusNode: _callFocus,
                autofocus: true,
                style: TidelineType.callsign.copyWith(
                  color: context.colors.text,
                ),
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9/]')),
                  UpperCaseFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: l10n.fieldCallsign,
                  errorText:
                      edit.issues.any((i) => i.field == ContestIssueField.call)
                      ? l10n.issueInvalidCall
                      : null,
                ),
                onChanged: controller.setCall,
                onEditingComplete: _save,
              ),
              SizedBox(height: metrics.sm),
              Wrap(
                spacing: metrics.sm,
                runSpacing: metrics.sm,
                children: [
                  for (final (i, element) in spec.exchange.rcvd.indexed)
                    SizedBox(
                      width: scale.scale(metrics.contestFieldWidth),
                      child: ExchangeField(
                        element: element,
                        controller: _rcvd[i],
                        focusNode: _rcvdFocus[i],
                        errorText: switch (edit.errorAt(i)) {
                          final ExchangeError error => exchangeErrorText(
                            l10n,
                            element,
                            error,
                          ),
                          null => null,
                        },
                        onChanged: (v) => controller.setRcvd(i, v),
                        onSubmitted: _save,
                      ),
                    ),
                  SizedBox(
                    width: scale.scale(metrics.contestFieldWidth),
                    child: DropdownButtonFormField<Band>(
                      key: ValueKey('edit-band-${edit.band.name}'),
                      initialValue: edit.band,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.fieldBand),
                      items: [
                        for (final b in {
                          ...contestBands(spec.definition),
                          edit.band,
                        })
                          DropdownMenuItem(
                            value: b,
                            child: Text(bandDisplayName(b)),
                          ),
                      ],
                      onChanged: (b) {
                        if (b != null) controller.setBand(b);
                      },
                    ),
                  ),
                  SizedBox(
                    width: scale.scale(metrics.contestFieldWidth),
                    child: DropdownButtonFormField<Mode>(
                      key: ValueKey('edit-mode-${edit.mode.label}'),
                      initialValue: edit.mode,
                      isExpanded: true,
                      decoration: InputDecoration(labelText: l10n.fieldMode),
                      items: [
                        for (final m in {
                          ...contestModes(spec.definition),
                          edit.mode,
                        })
                          DropdownMenuItem(value: m, child: Text(m.label)),
                      ],
                      onChanged: (m) {
                        if (m != null) controller.setMode(m);
                      },
                    ),
                  ),
                ],
              ),
              if (edit.saveFailed)
                Padding(
                  padding: EdgeInsets.only(top: metrics.sm),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.contestSaveFailed,
                      style: TextStyle(color: context.colors.error),
                    ),
                  ),
                ),
              SizedBox(height: metrics.sm),
              Wrap(
                spacing: metrics.sm,
                runSpacing: metrics.sm,
                alignment: WrapAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.actionDeleteQso),
                  ),
                  OutlinedButton(
                    onPressed: controller.cancel,
                    child: Text(l10n.actionCancel),
                  ),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.actionSave),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
