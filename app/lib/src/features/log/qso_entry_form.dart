import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/activation/activation_labels.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline/src/features/callsigns/callsign_context.dart';
import 'package:tideline/src/features/callsigns/callsign_note_dialog.dart';
import 'package:tideline/src/features/callsigns/callsign_providers.dart';
import 'package:tideline/src/features/log/qso_entry_controller.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/features/log/worked_hint.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/frequency_field.dart';
import 'package:tideline/src/widgets/upper_case_formatter.dart';
import 'package:tideline_data/tideline_data.dart' show CallsignInfo;
import 'package:tideline_domain/tideline_domain.dart';

/// Focus of the callsign field, shared with the log screen's commands.
final callsignFocusProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'callsign');
  ref.onDispose(node.dispose);
  return node;
});

/// How [QsoEntryForm] arranges its fields.
enum QsoEntryLayout {
  /// One column: phones and tablets in portrait.
  stacked,

  /// Three rows across the full width, so that all fields stay visible above
  /// the on-screen keyboard of a tablet in landscape.
  strip,

  /// Fields in rows of up to three, the buttons pinned beneath: a tablet in
  /// portrait, or a window too narrow for the strip.
  grid,
}

/// Reports are numbers ("59", "599") and, in digital modes, signed ("-12").
/// A signed number keyboard keeps both reachable; the system keyboard still
/// offers the letters for the odd report such as "5NN".
const _reportKeyboard = TextInputType.numberWithOptions(signed: true);

/// The QSO entry form. Logging is local and instant: it never waits for the
/// network.
class QsoEntryForm extends ConsumerStatefulWidget {
  /// Creates the form.
  const new({this.layout = QsoEntryLayout.stacked, super.key});

  /// The arrangement of the fields. Only the arrangement differs; the
  /// controllers and the entry state are shared, so a switch (rotation)
  /// keeps typed input and focus.
  final QsoEntryLayout layout;

  @override
  ConsumerState<QsoEntryForm> createState() => QsoEntryFormState();
}

/// State of [QsoEntryForm]; [submit] is called by the log command.
class QsoEntryFormState extends ConsumerState<QsoEntryForm> {
  final _call = TextEditingController();
  final _freq = TextEditingController();
  final _rstSent = TextEditingController();
  final _rstRcvd = TextEditingController();
  final _name = TextEditingController();
  final _grid = TextEditingController();
  final _comment = TextEditingController();
  final _theirRef = TextEditingController();
  int _revision = -1;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  /// Keeps the displayed UTC time current. The display shows minutes, so the
  /// battery saver wakes once a minute, just after the minute changes,
  /// instead of every second (ADR 0029).
  void _tick() {
    final saver = ref.read(appSettingsProvider).value?.batterySaver ?? false;
    final wait = saver
        ? Duration(
            milliseconds:
                60000 - DateTime.now().millisecondsSinceEpoch % 60000 + 50,
          )
        : const Duration(seconds: 1);
    _clock = Timer(wait, () {
      if (!mounted) return;
      if (ref.read(qsoEntryProvider).manualTime == null) setState(() {});
      _tick();
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    for (final c in [
      _call,
      _freq,
      _rstSent,
      _rstRcvd,
      _name,
      _grid,
      _comment,
      _theirRef,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(QsoEntry e) {
    if (e.revision == _revision) return;
    _revision = e.revision;
    _call.text = e.call;
    _freq.text = e.frequency;
    _rstSent.text = e.rstSent;
    _rstRcvd.text = e.rstRcvd;
    _name.text = e.name;
    _grid.text = e.grid;
    _comment.text = e.comment;
    _theirRef.text = e.theirReference;
  }

  /// Copies what earlier contacts say into the empty name and locator fields;
  /// typed text is never replaced.
  void _fillFrom(CallsignInfo info) {
    final name = _name.text.trim().isEmpty ? info.name : null;
    final grid = _grid.text.trim().isEmpty ? info.gridsquare : null;
    if (name != null) _name.text = name;
    if (grid != null) _grid.text = grid;
    ref
        .read(qsoEntryProvider.notifier)
        .edit((e) => e.copyWith(name: name, grid: grid));
  }

  /// Logs the entry. Announces the result for screen readers.
  Future<void> submit() async {
    final account = ref.read(activeAccountProvider);
    if (account == null) return;
    final l10n = AppLocalizations.of(context);
    final direction = Directionality.of(context);
    final view = View.of(context);
    // Read before awaiting: the user may navigate away while logging.
    final focus = ref.read(callsignFocusProvider);
    final sync = ref.read(syncControllerProvider.notifier);
    final result = await ref
        .read(qsoEntryProvider.notifier)
        .log(accountId: account.id);
    final logged = result.logged;
    if (logged != null) {
      unawaited(
        SemanticsService.sendAnnouncement(
          view,
          l10n.qsoLoggedAnnouncement(logged.call.spelledOut),
          direction,
        ),
      );
      focus.requestFocus();
      // Opportunistic: upload right away if a connection exists.
      unawaited(sync.syncNow());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = ref.watch(qsoEntryProvider);
    final controller = ref.read(qsoEntryProvider.notifier);
    final stations = ref.watch(stationsProvider).value ?? const [];
    final account = ref.watch(activeAccountProvider);
    final defaultRemote = int.tryParse(
      ref
              .watch(settingsValuesProvider)
              .value?['account.${account?.id}.defaultStation'] ??
          '',
    );
    if (entry.stationProfileId == null && stations.isNotEmpty) {
      final initial =
          stations.where((s) => s.remoteId == defaultRemote).firstOrNull ??
          stations.where((s) => s.active).firstOrNull ??
          stations.first;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.edit((e) => e.copyWith(stationProfileId: initial.id)),
      );
    }
    _syncControllers(entry);
    final metrics = context.metrics;
    final issues = entry.issues;
    String? errorFor(EntryIssue issue, String text) =>
        issues.contains(issue) ? text : null;

    final mode = entry.mode;
    final time = entry.manualTime ?? UtcDateTime.now();
    final gap = SizedBox(height: metrics.md, width: metrics.md);

    // Side by side only when every field keeps a usable width, which grows
    // with the text size.
    final minFieldWidth = 130 * MediaQuery.textScalerOf(context).scale(1);
    Widget row(List<Widget> children) => LayoutBuilder(
      builder: (context, c) =>
          c.maxWidth <
              children.length * minFieldWidth +
                  (children.length - 1) * metrics.md
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, w) in children.indexed) ...[if (i > 0) gap, w],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, w) in children.indexed) ...[
                  if (i > 0) gap,
                  Expanded(child: w),
                ],
              ],
            ),
    );

    final clear = OutlinedButton(
      onPressed: controller.clear,
      child: Text(l10n.commandClearEntry, textAlign: TextAlign.center),
    );
    final log = FilledButton.icon(
      onPressed: submit,
      icon: const Icon(Icons.check),
      label: Text(l10n.commandLogQso, textAlign: TextAlign.center),
    );
    // Side by side when both labels fit, else stacked with Log first.
    final actions = LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 2 * minFieldWidth + metrics.sm
          ? Row(
              children: [
                Expanded(child: clear),
                SizedBox(width: metrics.sm),
                Expanded(child: log),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                log,
                SizedBox(height: metrics.sm),
                clear,
              ],
            ),
    );

    final contextLine = CallsignContextLine(
      call: entry.call,
      nameEmpty: entry.name.trim().isEmpty,
      gridEmpty: entry.grid.trim().isEmpty,
      onFill: _fillFrom,
    );
    final typedCall = entry.call.trim();
    final callValid = Callsign.tryParse(typedCall) != null;
    final hasNote =
        callValid && ref.watch(callsignNoteProvider(typedCall)).value != null;
    final callField = TextField(
      controller: _call,
      focusNode: ref.watch(callsignFocusProvider),
      autofocus: true,
      style: TidelineType.callsign.copyWith(
        fontSize: 28,
        color: context.colors.text,
      ),
      textCapitalization: TextCapitalization.characters,
      autocorrect: false,
      enableSuggestions: false,
      // Apple Pencil handwriting (Scribble) stays enabled (the
      // default); see docs/design/accessibility.md for known issues.
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9/]')),
        UpperCaseFormatter(),
      ],
      decoration: InputDecoration(
        labelText: l10n.fieldCallsign,
        errorText: errorFor(EntryIssue.invalidCall, l10n.issueInvalidCall),
        // The note of this station: filled when there is one.
        suffixIcon: IconButton(
          tooltip: hasNote
              ? l10n.callsignNoteTooltipHas
              : l10n.callsignNoteTooltip,
          icon: Icon(
            hasNote ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
          ),
          onPressed: callValid
              ? () => showCallsignNoteDialog(context, ref, typedCall)
              : null,
        ),
      ),
      onChanged: (v) => controller.edit((e) => e.copyWith(call: v)),
    );
    final bandField = DropdownButtonFormField<Band>(
      initialValue: entry.band,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.fieldBand,
        errorText: errorFor(EntryIssue.missingBand, l10n.issueMissingBand),
      ),
      items: [
        for (final b in Band.all)
          DropdownMenuItem(value: b, child: Text(b.name)),
      ],
      onChanged: (b) => controller.edit((e) => e.copyWith(band: b)),
    );
    final modeField = DropdownButtonFormField<Mode>(
      initialValue: entry.mode,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.fieldMode,
        errorText: errorFor(EntryIssue.missingMode, l10n.issueMissingMode),
      ),
      items: [
        for (final m in {...Mode.common, ?entry.mode})
          DropdownMenuItem(value: m, child: Text(m.label)),
      ],
      onChanged: (m) => controller.edit((e) => e.copyWith(mode: m)),
    );
    final freqError =
        errorFor(EntryIssue.invalidFrequency, l10n.issueInvalidFrequency) ??
        errorFor(
          EntryIssue.frequencyOutsideBand,
          l10n.issueFrequencyOutsideBand,
        );
    final strip = widget.layout == QsoEntryLayout.strip;
    final freqField = FrequencyField(
      controller: _freq,
      errorText: freqError,
      // The strip's frequency column is too narrow for the readout; it goes
      // into the bottom row.
      showReadout: !strip,
      onChanged: controller.setFrequency,
    );
    final rstSentField = TextField(
      controller: _rstSent,
      keyboardType: _reportKeyboard,
      decoration: InputDecoration(
        labelText: l10n.fieldRstSent,
        hintText: mode?.defaultReport,
      ),
      onChanged: (v) => controller.edit((e) => e.copyWith(rstSent: v)),
    );
    final rstRcvdField = TextField(
      controller: _rstRcvd,
      keyboardType: _reportKeyboard,
      decoration: InputDecoration(
        labelText: l10n.fieldRstRcvd,
        hintText: mode?.defaultReport,
      ),
      onChanged: (v) => controller.edit((e) => e.copyWith(rstRcvd: v)),
    );
    final nameField = TextField(
      controller: _name,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: l10n.fieldName),
      onChanged: (v) => controller.edit((e) => e.copyWith(name: v)),
    );
    final gridField = TextField(
      controller: _grid,
      autocorrect: false,
      inputFormatters: [UpperCaseFormatter()],
      decoration: InputDecoration(
        labelText: l10n.fieldGrid,
        errorText: errorFor(EntryIssue.invalidGrid, l10n.issueInvalidGrid),
      ),
      onChanged: (v) => controller.edit((e) => e.copyWith(grid: v)),
    );
    final commentField = TextField(
      controller: _comment,
      decoration: InputDecoration(labelText: l10n.fieldComment),
      onChanged: (v) => controller.edit((e) => e.copyWith(comment: v)),
    );
    final activation = ref.watch(activeActivationProvider).value;
    final theirRefField = activation == null
        ? null
        : TextField(
            controller: _theirRef,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.characters,
            textDirection: TextDirection.ltr,
            inputFormatters: [UpperCaseFormatter()],
            decoration: InputDecoration(
              labelText: theirReferenceFieldLabel(l10n, activation.program),
              errorText: errorFor(
                EntryIssue.invalidTheirReference,
                l10n.activationIssueTheirReference,
              ),
            ),
            onChanged: (v) =>
                controller.edit((e) => e.copyWith(theirReference: v)),
          );
    final stationField = stations.isEmpty
        ? null
        : DropdownButtonFormField<String>(
            initialValue: entry.stationProfileId,
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
            onChanged: (id) =>
                controller.edit((e) => e.copyWith(stationProfileId: id)),
          );
    final timeRow = _TimeRow(
      time: time,
      manual: entry.manualTime != null,
      onPick: (t) => controller.edit((e) => e.copyWith(manualTime: t)),
      onNow: () => controller.edit((e) => e.copyWith(clearManualTime: true)),
    );
    final issueText =
        issues.contains(EntryIssue.timeInFuture) ||
            issues.contains(EntryIssue.noStation)
        ? Padding(
            padding: EdgeInsets.only(top: metrics.sm),
            child: Semantics(
              liveRegion: true,
              child: Text(
                issues.contains(EntryIssue.noStation)
                    ? l10n.issueNoStation
                    : l10n.issueTimeInFuture,
                style: TextStyle(color: context.colors.conflict.foreground),
              ),
            ),
          )
        : null;

    if (strip) {
      return _buildStrip(
        context,
        fields: (
          call: callField,
          band: bandField,
          mode: modeField,
          freq: freqField,
          rstSent: rstSentField,
          rstRcvd: rstRcvdField,
          name: nameField,
          grid: gridField,
          comment: commentField,
          theirRef: theirRefField,
          station: stationField,
        ),
        hints: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: metrics.lg,
              children: [
                timeRow,
                FrequencyReadout(controller: _freq, errorText: freqError),
              ],
            ),
            _DxccHint(call: entry.call),
            WorkedHintLine(
              call: entry.call,
              band: entry.band,
              mode: entry.mode,
            ),
            contextLine,
            ?issueText,
          ],
        ),
        actions: (clear: clear, log: log),
      );
    }

    if (widget.layout == QsoEntryLayout.grid) {
      return _buildGrid(
        context,
        fields: (
          call: callField,
          band: bandField,
          mode: modeField,
          freq: freqField,
          rstSent: rstSentField,
          rstRcvd: rstRcvdField,
          name: nameField,
          grid: gridField,
          comment: commentField,
          theirRef: theirRefField,
          station: stationField,
        ),
        time: timeRow,
        hints: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DxccHint(call: entry.call),
            WorkedHintLine(
              call: entry.call,
              band: entry.band,
              mode: entry.mode,
            ),
            contextLine,
            ?issueText,
          ],
        ),
        actions: (clear: clear, log: log),
      );
    }

    return FocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          callField,
          _DxccHint(call: entry.call),
          WorkedHintLine(call: entry.call, band: entry.band, mode: entry.mode),
          contextLine,
          gap,
          row([bandField, modeField]),
          gap,
          freqField,
          gap,
          row([rstSentField, rstRcvdField]),
          gap,
          row([nameField, gridField]),
          gap,
          commentField,
          gap,
          if (theirRefField != null) ...[theirRefField, gap],
          ?stationField,
          gap,
          timeRow,
          ?issueText,
          gap,
          actions,
        ],
      ),
    );
  }

  /// The portrait arrangement: rows of up to three fields. The rows scroll
  /// only when they do not fit above the keyboard; Clear and Log stay pinned
  /// beneath them.
  Widget _buildGrid(
    BuildContext context, {
    required _StripFields fields,
    required Widget time,
    required Widget hints,
    required ({Widget clear, Widget log}) actions,
  }) {
    final metrics = context.metrics;
    final gap = SizedBox(width: metrics.md);
    Widget flex(int weight, Widget child) =>
        Expanded(flex: weight, child: child);
    Widget spaced(List<Widget> children) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, w) in children.indexed) ...[if (i > 0) gap, w],
      ],
    );
    final vgap = SizedBox(height: metrics.sm);
    final buttonWidth = 130 * MediaQuery.textScalerOf(context).scale(1);
    return FocusTraversalGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              // Room for the floating label of the first field.
              padding: EdgeInsets.only(top: metrics.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  spaced([
                    flex(3, fields.call),
                    flex(2, fields.band),
                    flex(2, fields.mode),
                  ]),
                  vgap,
                  spaced([
                    flex(3, fields.freq),
                    flex(2, fields.rstSent),
                    flex(2, fields.rstRcvd),
                  ]),
                  vgap,
                  spaced([
                    flex(2, fields.name),
                    flex(2, fields.grid),
                    flex(4, fields.comment),
                  ]),
                  vgap,
                  spaced([
                    if (fields.theirRef case final theirRef?) flex(3, theirRef),
                    if (fields.station case final station?) flex(4, station),
                    flex(5, time),
                  ]),
                  hints,
                ],
              ),
            ),
          ),
          vgap,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(width: buttonWidth, child: actions.clear),
              SizedBox(width: metrics.sm),
              SizedBox(width: buttonWidth, child: actions.log),
            ],
          ),
        ],
      ),
    );
  }

  /// The landscape arrangement: callsign, band, mode, frequency and reports
  /// in the first row; name, grid, comment and station in the second; time,
  /// hints and the two buttons in the third. Reading order is also focus
  /// order.
  Widget _buildStrip(
    BuildContext context, {
    required _StripFields fields,
    required Widget hints,
    required ({Widget clear, Widget log}) actions,
  }) {
    final metrics = context.metrics;
    final gap = SizedBox(width: metrics.md);
    Widget flex(int weight, Widget child) =>
        Expanded(flex: weight, child: child);
    Widget spaced(List<Widget> children) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, w) in children.indexed) ...[if (i > 0) gap, w],
      ],
    );
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final buttonWidth = 130 * scale;
    // At the normal text size the hints share the bottom row with the
    // buttons, which saves a row of height above the keyboard. With larger
    // text the hints (a time row, two lines) get tall and would crowd the
    // fields out, so they scroll below the fields instead.
    final hintsBesideButtons = scale < 1.1;
    final buttons = [
      SizedBox(width: buttonWidth, child: actions.clear),
      SizedBox(width: metrics.sm),
      SizedBox(width: buttonWidth, child: actions.log),
    ];
    return FocusTraversalGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Only when the keyboard leaves too little height do the rows
          // scroll; the buttons stay in reach below them.
          Flexible(
            child: SingleChildScrollView(
              // Room for the floating label of the first field.
              padding: EdgeInsets.only(top: metrics.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  spaced([
                    flex(4, fields.call),
                    flex(2, fields.band),
                    flex(2, fields.mode),
                    flex(3, fields.freq),
                    flex(3, fields.rstSent),
                    flex(3, fields.rstRcvd),
                  ]),
                  SizedBox(height: metrics.sm),
                  spaced([
                    flex(3, fields.name),
                    flex(2, fields.grid),
                    flex(6, fields.comment),
                    if (fields.theirRef case final theirRef?) flex(3, theirRef),
                    if (fields.station case final station?) flex(4, station),
                  ]),
                  if (!hintsBesideButtons) ...[
                    SizedBox(height: metrics.sm),
                    hints,
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: metrics.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: hintsBesideButtons
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (hintsBesideButtons) ...[Expanded(child: hints), gap],
              ...buttons,
            ],
          ),
        ],
      ),
    );
  }
}

typedef _StripFields = ({
  Widget call,
  Widget band,
  Widget mode,
  Widget freq,
  Widget rstSent,
  Widget rstRcvd,
  Widget name,
  Widget grid,
  Widget comment,
  Widget? theirRef,
  Widget? station,
});

class _TimeRow extends StatelessWidget {
  const new({
    required this.time,
    required this.manual,
    required this.onPick,
    required this.onNow,
  });

  final UtcDateTime time;
  final bool manual;
  final ValueChanged<UtcDateTime> onPick;
  final VoidCallback onNow;

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: time.value,
      firstDate: DateTime.utc(1930),
      lastDate: DateTime.now().toUtc().add(const Duration(days: 1)),
    );
    if (date == null || !context.mounted) return;
    final clock = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: time.value.hour, minute: time.value.minute),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (clock == null) return;
    onPick(
      UtcDateTime(
        DateTime.utc(date.year, date.month, date.day, clock.hour, clock.minute),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = time.value;
    final text =
        '${t.year}-${t.month.toString().padLeft(2, '0')}-'
        '${t.day.toString().padLeft(2, '0')} ${utcClock(time)} ${l10n.unitUtc}';
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: context.metrics.sm,
      children: [
        Icon(Icons.schedule, color: context.colors.textSecondary),
        Text(
          manual ? l10n.timeManual(text) : l10n.timeNow(text),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        TextButton(
          onPressed: () => _pick(context),
          child: Text(l10n.actionChangeTime),
        ),
        if (manual)
          TextButton(onPressed: onNow, child: Text(l10n.actionUseNow)),
      ],
    );
  }
}

class _DxccHint extends ConsumerWidget {
  const new({required this.call});

  final String call;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final db = ref.watch(dxccProvider).value;
    final match = call.length >= 2 ? db?.resolve(call) : null;
    if (match == null) return const SizedBox(height: 24);
    return Padding(
      padding: EdgeInsets.only(top: context.metrics.xs),
      child: Semantics(
        liveRegion: true,
        child: Text(
          l10n.dxccSummary(
            match.entity.name,
            match.continent,
            match.cqz,
            match.ituz,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
