import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/contest/contest_entry_controller.dart';
import 'package:tideline/src/features/contest/contest_hints_view.dart';
import 'package:tideline/src/features/contest/contest_labels.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_qso_codec.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/features/contest/exchange_field.dart';
import 'package:tideline/src/features/log/qso_entry_form.dart'
    show QsoEntryLayout;
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/frequency_field.dart';
import 'package:tideline/src/widgets/upper_case_formatter.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The contest entry: callsign, received exchange, the sent exchange
/// (read-only, with the next serial), band, mode and frequency.
///
/// All typed values live in [contestEntryProvider]; this widget only owns
/// the text controllers and focus, so a layout change that rebuilds it
/// loses nothing.
class ContestEntryPanel extends ConsumerStatefulWidget {
  /// Creates the panel. [onEditLast] opens the newest QSO for editing.
  const new({
    required this.onEditLast,
    this.layout = QsoEntryLayout.stacked,
    super.key,
  });

  /// Called by the "Edit last QSO" button.
  final VoidCallback onEditLast;

  /// `strip` puts callsign, exchange, band, mode and frequency in one row
  /// across the full width, with the hints and the buttons beneath it, so all
  /// of it stays above a tablet's on-screen keyboard in landscape.
  final QsoEntryLayout layout;

  @override
  ConsumerState<ContestEntryPanel> createState() => ContestEntryPanelState();
}

/// State of [ContestEntryPanel]; [submit] and [focusCall] serve the
/// command handlers.
class ContestEntryPanelState extends ConsumerState<ContestEntryPanel> {
  final _call = TextEditingController();
  final _freq = TextEditingController();
  final _bandFocus = FocusNode(debugLabel: 'contest band');
  final _modeFocus = FocusNode(debugLabel: 'contest mode');
  late final FocusNode _callFocus = FocusNode(
    debugLabel: 'contest call',
    onKeyEvent: (_, event) => spaceMovesOn(event, () => _focusElement(0)),
  );
  List<TextEditingController> _rcvd = [];
  List<FocusNode> _rcvdFocus = [];
  int _revision = -1;

  @override
  void dispose() {
    _call.dispose();
    _freq.dispose();
    _bandFocus.dispose();
    _modeFocus.dispose();
    _callFocus.dispose();
    for (final c in _rcvd) {
      c.dispose();
    }
    for (final f in _rcvdFocus) {
      f.dispose();
    }
    super.dispose();
  }

  /// Puts the cursor in the callsign field.
  void focusCall() => _callFocus.requestFocus();

  void _focusElement(int index) {
    if (index < _rcvdFocus.length) _rcvdFocus[index].requestFocus();
  }

  void _ensureShape(int count) {
    if (_rcvd.length == count) return;
    for (final c in _rcvd) {
      c.dispose();
    }
    for (final f in _rcvdFocus) {
      f.dispose();
    }
    _rcvd = [for (var i = 0; i < count; i++) TextEditingController()];
    _rcvdFocus = [
      for (var i = 0; i < count; i++)
        FocusNode(
          debugLabel: 'contest exchange $i',
          onKeyEvent: (_, event) =>
              spaceMovesOn(event, () => _focusElement(i + 1)),
        ),
    ];
    _revision = -1;
  }

  void _sync(ContestEntry entry) {
    if (entry.revision == _revision) return;
    _revision = entry.revision;
    _call.text = entry.call;
    _freq.text = entry.frequency;
    for (final (i, c) in _rcvd.indexed) {
      c.text = entry.rcvdAt(i);
    }
  }

  /// Logs the entry (or moves to what is missing). Announces the result.
  Future<void> submit() async {
    final l10n = AppLocalizations.of(context);
    final direction = Directionality.of(context);
    final view = View.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sync = ref.read(syncControllerProvider.notifier);
    final result = await ref.read(contestEntryProvider.notifier).submit();
    switch (result) {
      case SubmitNeedsCall():
        _callFocus.requestFocus();
      case SubmitInvalid(:final first):
        _focusIssue(first);
      case SubmitLogged(:final qso, :final serial, :final dupe):
        _callFocus.requestFocus();
        final spoken = qso.call.spelledOut;
        final text = serial == null
            ? l10n.contestLoggedAnnouncementNoSerial(
                spoken,
                dupe ? 'yes' : 'no',
              )
            : l10n.contestLoggedAnnouncement(
                spoken,
                serial,
                dupe ? 'yes' : 'no',
              );
        unawaited(SemanticsService.sendAnnouncement(view, text, direction));
        // Opportunistic: upload in the background if a connection exists.
        unawaited(sync.syncNow());
      case SubmitFailed():
        messenger.showSnackBar(SnackBar(content: Text(l10n.contestSaveFailed)));
      case SubmitIgnored():
        break;
    }
  }

  void _focusIssue(ContestIssue issue) {
    switch (issue.field) {
      case ContestIssueField.call:
        _callFocus.requestFocus();
      case ContestIssueField.element:
        _focusElement(issue.elementIndex ?? 0);
      case ContestIssueField.band:
        _bandFocus.requestFocus();
      case ContestIssueField.mode:
        _modeFocus.requestFocus();
      case ContestIssueField.frequency:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = ref.watch(contestSpecProvider);
    if (spec == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final entry = ref.watch(contestEntryProvider);
    final controller = ref.read(contestEntryProvider.notifier);
    _ensureShape(spec.exchange.rcvd.length);
    _sync(entry);

    final bands = contestBands(spec.definition);
    final modes = contestModes(spec.definition);
    final mode = entry.mode;
    final category = mode == null ? null : ModeCategory.of(mode);
    final textScale = MediaQuery.textScalerOf(context);
    double scaled(double width) => textScale.scale(width);

    String? exchangeError(int i) => switch (entry.errorAt(i)) {
      final ExchangeError error => exchangeErrorText(
        l10n,
        spec.exchange.rcvd[i],
        error,
      ),
      null => null,
    };

    final freqIssue = entry.issueOf(ContestIssueField.frequency);
    final bandIssue = entry.issueOf(ContestIssueField.band);
    final modeIssue = entry.issueOf(ContestIssueField.mode);
    final gap = SizedBox(height: metrics.sm);

    final strip = widget.layout == QsoEntryLayout.strip;
    final callField = TextField(
      controller: _call,
      focusNode: _callFocus,
      autofocus: true,
      style: TidelineType.callsignLarge.copyWith(color: context.colors.text),
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      enableSuggestions: false,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9/]')),
        UpperCaseFormatter(),
      ],
      decoration: InputDecoration(
        labelText: l10n.fieldCallsign,
        errorText: entry.issueOf(ContestIssueField.call) == null
            ? null
            : l10n.issueInvalidCall,
      ),
      onChanged: controller.setCall,
      onEditingComplete: submit,
    );
    final hints = ContestHintsView(
      onPickCall: (call) {
        controller.fillCall(call);
        _focusElement(0);
      },
    );
    final exchangeFields = [
      for (final (i, element) in spec.exchange.rcvd.indexed)
        ExchangeField(
          element: element,
          controller: _rcvd[i],
          focusNode: _rcvdFocus[i],
          errorText: exchangeError(i),
          hintText: element.kind == ExchangeKind.rst
              ? element.defaultFor(spec.me, category: category)
              : null,
          onChanged: (v) => controller.setRcvd(i, v),
          onSubmitted: submit,
        ),
    ];
    final sent = _SentExchange(spec: spec, category: category);
    final bandField = DropdownButtonFormField<Band>(
      key: ValueKey('band-${entry.band?.name}'),
      focusNode: _bandFocus,
      initialValue: entry.band,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.fieldBand,
        errorText: bandIssue == null ? null : l10n.issueMissingBand,
      ),
      items: [
        for (final b in {...bands, ?entry.band})
          DropdownMenuItem(value: b, child: Text(bandDisplayName(b))),
      ],
      onChanged: (b) {
        if (b != null) controller.setBand(b);
      },
    );
    final modeField = DropdownButtonFormField<Mode>(
      key: ValueKey('mode-${entry.mode?.label}'),
      focusNode: _modeFocus,
      initialValue: entry.mode,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.fieldMode,
        errorText: modeIssue == null ? null : l10n.issueMissingMode,
      ),
      items: [
        for (final m in {...modes, ?entry.mode})
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) {
        if (m != null) controller.setMode(m);
      },
    );
    final freqError = freqIssue == null
        ? null
        : (freqIssue.outsideBand
              ? l10n.issueFrequencyOutsideBand
              : l10n.issueInvalidFrequency);
    final freqField = FrequencyField(
      controller: _freq,
      errorText: freqError,
      // In the strip the reading goes into the row below the fields.
      showReadout: !strip,
      onChanged: controller.setFrequency,
    );

    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        callField,
        hints,
        Wrap(
          spacing: metrics.sm,
          runSpacing: metrics.sm,
          children: [
            for (final field in exchangeFields)
              SizedBox(width: scaled(metrics.contestFieldWidth), child: field),
          ],
        ),
        gap,
        sent,
        gap,
        Wrap(
          spacing: metrics.sm,
          runSpacing: metrics.sm,
          children: [
            SizedBox(
              width: scaled(metrics.contestFieldWidth),
              child: bandField,
            ),
            SizedBox(
              width: scaled(metrics.contestFieldWidth),
              child: modeField,
            ),
            // Wide enough for the reading under it ("14.205 MHz · 20 m",
            // or the hint) to stay on one line; the Wrap moves it to its own
            // line on narrow screens.
            SizedBox(
              width: scaled(metrics.contestFieldWidth * 3),
              child: freqField,
            ),
          ],
        ),
      ],
    );

    final actions = Wrap(
      spacing: metrics.sm,
      runSpacing: metrics.sm,
      alignment: WrapAlignment.end,
      children: [
        TextButton.icon(
          onPressed: widget.onEditLast,
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.commandEditLastQso),
        ),
        OutlinedButton(
          onPressed: () {
            controller.wipe();
            _callFocus.requestFocus();
          },
          child: Text(l10n.commandWipeEntry),
        ),
        FilledButton.icon(
          onPressed: submit,
          icon: const Icon(Icons.check),
          label: Text(l10n.commandLogQso),
        ),
      ],
    );

    if (strip) {
      Widget flex(int weight, Widget child) =>
          Expanded(flex: weight, child: child);
      final gapW = SizedBox(width: metrics.sm);
      final rows = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              flex(4, callField),
              for (final field in exchangeFields) ...[gapW, flex(2, field)],
              gapW,
              flex(2, bandField),
              gapW,
              flex(2, modeField),
              gapW,
              flex(3, freqField),
            ],
          ),
          gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: hints),
              gapW,
              SizedBox(
                width: scaled(metrics.contestFieldWidth * 3),
                child: sent,
              ),
            ],
          ),
        ],
      );
      // The reading and the buttons stay pinned; only when the rows above
      // do not fit (Split View, very large text) do they scroll.
      final bottom = Row(
        children: [
          Expanded(
            child: FrequencyReadout(controller: _freq, errorText: freqError),
          ),
          gapW,
          actions,
        ],
      );
      return FocusTraversalGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: SingleChildScrollView(child: rows)),
            gap,
            bottom,
          ],
        ),
      );
    }

    // With a bounded height (tablet landscape, desktop) the fields scroll
    // and the actions stay pinned below them, so Log is never hidden. In a
    // scrolling page (phone, tablet portrait) everything just flows.
    return FocusTraversalGroup(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [fields, gap, actions],
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: SingleChildScrollView(child: fields)),
              gap,
              actions,
            ],
          );
        },
      ),
    );
  }
}

/// The sent exchange, read-only, with the serial the next QSO will get.
class _SentExchange extends ConsumerWidget {
  const new({required this.spec, required this.category});

  final ContestSpec spec;
  final ModeCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final next = spec.usesSerial
        ? ref.watch(contestNextSerialProvider).value
        : null;
    final values = spec.sentValues(category: category, serial: next);
    final parts = [
      for (final (i, e) in spec.exchange.sent.indexed)
        if (values[i].isNotEmpty) '${exchangeLabel(l10n, e)} ${values[i]}',
    ];
    final text = parts.isEmpty
        ? l10n.contestSentNothing
        : l10n.contestSentSummary(parts.join(' · '));
    return Semantics(
      container: true,
      label: text,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.sm,
          vertical: metrics.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.surfaceVariant,
          borderRadius: const BorderRadius.all(TidelineMetrics.radiusSm),
        ),
        child: Row(
          children: [
            Icon(Icons.north_east, size: 18, color: context.colors.text),
            SizedBox(width: metrics.sm),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}
