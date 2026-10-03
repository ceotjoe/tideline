import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/log/qso_entry_controller.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/features/log/worked_hint.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/frequency_field.dart';
import 'package:tideline/src/widgets/upper_case_formatter.dart';
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
}

/// The QSO entry form. Logging is local and instant: it never waits for the
/// network.
class QsoEntryForm extends ConsumerStatefulWidget {
  /// Creates the form.
  const new({
    this.pinActions = false,
    this.layout = QsoEntryLayout.stacked,
    super.key,
  });

  /// The arrangement of the fields. Only the arrangement differs; the
  /// controllers and the entry state are shared, so a switch (rotation)
  /// keeps typed input and focus.
  final QsoEntryLayout layout;

  /// Keeps Clear and Log at the bottom while the fields scroll above them.
  /// Needs a bounded height (the tablet layouts); phones scroll the whole
  /// form instead.
  final bool pinActions;

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
  int _revision = -1;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // Keep the displayed UTC time current.
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && ref.read(qsoEntryProvider).manualTime == null) {
        setState(() {});
      }
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
    final freqField = FrequencyField(
      controller: _freq,
      errorText:
          errorFor(EntryIssue.invalidFrequency, l10n.issueInvalidFrequency) ??
          errorFor(
            EntryIssue.frequencyOutsideBand,
            l10n.issueFrequencyOutsideBand,
          ),
      onChanged: controller.setFrequency,
    );
    final rstSentField = TextField(
      controller: _rstSent,
      decoration: InputDecoration(
        labelText: l10n.fieldRstSent,
        hintText: mode?.defaultReport,
      ),
      onChanged: (v) => controller.edit((e) => e.copyWith(rstSent: v)),
    );
    final rstRcvdField = TextField(
      controller: _rstRcvd,
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

    if (widget.layout == QsoEntryLayout.strip) {
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
          station: stationField,
        ),
        hints: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            timeRow,
            _DxccHint(call: entry.call),
            WorkedHintLine(
              call: entry.call,
              band: entry.band,
              mode: entry.mode,
            ),
            ?issueText,
          ],
        ),
        actions: (clear: clear, log: log),
      );
    }

    final fields = FocusTraversalGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          callField,
          _DxccHint(call: entry.call),
          WorkedHintLine(call: entry.call, band: entry.band, mode: entry.mode),
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
          ?stationField,
          gap,
          timeRow,
          ?issueText,
          if (!widget.pinActions) ...[gap, actions],
        ],
      ),
    );
    if (!widget.pinActions) return fields;
    // As tall as the fields need; only when they do not fit do they scroll,
    // with Clear and Log pinned under them.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            // Room for the floating label of the first field, which would
            // otherwise be clipped at the top of the scroll area.
            padding: EdgeInsets.only(top: metrics.sm),
            child: fields,
          ),
        ),
        gap,
        actions,
      ],
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
    final buttonWidth = 130 * MediaQuery.textScalerOf(context).scale(1);
    return FocusTraversalGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          spaced([
            flex(5, fields.call),
            flex(2, fields.band),
            flex(2, fields.mode),
            flex(3, fields.freq),
            flex(2, fields.rstSent),
            flex(2, fields.rstRcvd),
          ]),
          SizedBox(height: metrics.sm),
          spaced([
            flex(3, fields.name),
            flex(2, fields.grid),
            flex(6, fields.comment),
            if (fields.station case final station?) flex(4, station),
          ]),
          SizedBox(height: metrics.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: hints),
              gap,
              SizedBox(width: buttonWidth, child: actions.clear),
              SizedBox(width: metrics.sm),
              SizedBox(width: buttonWidth, child: actions.log),
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
