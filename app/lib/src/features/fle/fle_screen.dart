import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline/src/features/fle/fle_controller.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart' show StationProfile;
import 'package:tideline_domain/tideline_domain.dart';

/// The sentence for [problem] about [token].
String fleProblemText(
  AppLocalizations l10n,
  FleProblem problem,
  String? token,
) {
  final t = token ?? '';
  return switch (problem) {
    FleProblem.unknownToken => l10n.fleProblemUnknownToken(t),
    FleProblem.unclosedBracket => l10n.fleProblemUnclosedBracket,
    FleProblem.invalidTime => l10n.fleProblemInvalidTime(t),
    FleProblem.missingTime => l10n.fleProblemMissingTime,
    FleProblem.missingCall => l10n.fleProblemMissingCall,
    FleProblem.missingBand => l10n.fleProblemMissingBand,
    FleProblem.missingMode => l10n.fleProblemMissingMode,
    FleProblem.unsupportedBand => l10n.fleProblemUnsupportedBand(t),
    FleProblem.frequencyOutsideBands => l10n.fleProblemFrequencyOutsideBands(t),
    FleProblem.invalidDate => l10n.fleProblemInvalidDate(t),
    FleProblem.invalidDayShift => l10n.fleProblemInvalidDayShift,
    FleProblem.invalidTimezone => l10n.fleProblemInvalidTimezone(t),
    FleProblem.secondCallsign => l10n.fleProblemSecondCallsign(t),
    FleProblem.duplicateSegment => l10n.fleProblemDuplicateSegment(t),
    FleProblem.reportBeforeCall => l10n.fleProblemReportBeforeCall(t),
    FleProblem.tooManyReports => l10n.fleProblemTooManyReports(t),
    FleProblem.invalidReport => l10n.fleProblemInvalidReport(t),
    FleProblem.invalidFieldName => l10n.fleProblemInvalidFieldName(t),
    FleProblem.reservedField => l10n.fleProblemReservedField(t),
    FleProblem.valueTooLong => l10n.fleProblemValueTooLong(t),
    FleProblem.lineTooLong => l10n.fleProblemLineTooLong,
    FleProblem.tooManyLines => l10n.fleProblemTooManyLines,
  };
}

/// A station location as `Name · CALL`.
String _stationLabel(StationProfile s) => [s.name, s.callsign].join(' · ');

/// Type QSOs as shorthand, see how each line was read, and log them all at
/// once (ADR 0028).
class FleScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<FleScreen> createState() => _FleScreenState();
}

class _FleScreenState extends ConsumerState<FleScreen> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    // What was typed before a rotation or a resize is still in the state.
    _text.text = ref.read(fleProvider).text;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _log() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final sync = ref.read(syncControllerProvider.notifier);
    try {
      final count = await ref.read(fleProvider.notifier).submit();
      if (count == null) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.fleLogged(count))));
      // Opportunistic: upload right away if a connection exists.
      unawaited(sync.syncNow());
      if (navigator.canPop()) navigator.pop();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.fleLogFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme;
    final state = ref.watch(fleProvider);
    final controller = ref.read(fleProvider.notifier);
    final stations = ref.watch(stationsProvider).value ?? const [];
    final activation = ref.watch(activeActivationProvider).value;
    final stationId = controller.effectiveStationId();
    // Cleared after logging: follow the state, never fight typing.
    if (state.text.isEmpty && _text.text.isNotEmpty) _text.clear();

    final lines = state.result.lines;
    final toLog = state.toLog.length;
    final dupes = state.duplicateLines.length;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fleTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.all(metrics.md),
              children: [
                Text(l10n.fleIntro),
                if (activation != null) ...[
                  SizedBox(height: metrics.sm),
                  Row(
                    children: [
                      const ExcludeSemantics(
                        child: Icon(Icons.terrain_outlined),
                      ),
                      SizedBox(width: metrics.sm),
                      Expanded(
                        child: Text(
                          l10n.fleActivationNotice(activation.reference),
                          style: text.titleSmall,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: metrics.md),
                if (stations.length > 1)
                  DropdownButtonFormField<String>(
                    initialValue: stationId,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.fleStation),
                    items: [
                      for (final s in stations)
                        DropdownMenuItem(
                          value: s.id,
                          child: Text(_stationLabel(s)),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) controller.setStation(id);
                    },
                  ),
                SizedBox(height: metrics.md),
                TextField(
                  controller: _text,
                  minLines: 6,
                  maxLines: 14,
                  keyboardType: TextInputType.multiline,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: l10n.fleTextLabel,
                    hintText: l10n.fleExample,
                    alignLabelWithHint: true,
                  ),
                  onChanged: controller.setText,
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(l10n.fleSyntaxTitle),
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(l10n.fleSyntaxBody, style: text.bodyMedium),
                    ),
                  ],
                ),
                SizedBox(height: metrics.sm),
                Semantics(
                  header: true,
                  child: Text(l10n.flePreview, style: text.titleMedium),
                ),
                if (lines.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: metrics.md),
                    child: Text(l10n.fleEmpty),
                  ),
                for (final line in lines)
                  _LineTile(
                    line: line,
                    duplicate: state.duplicateLines.contains(line.number),
                  ),
              ],
            ),
          ),
          Material(
            elevation: 2,
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(metrics.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.problemCount > 0)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.fleSkipProblems),
                        value: state.skipProblems,
                        onChanged: (v) => controller.setSkipProblems(value: v),
                      ),
                    if (dupes > 0)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.fleLogDuplicates),
                        value: state.logDuplicates,
                        onChanged: (v) => controller.setLogDuplicates(value: v),
                      ),
                    if (lines.isNotEmpty)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          l10n.fleSummary(toLog, state.problemCount, dupes),
                          style: text.bodySmall,
                        ),
                      ),
                    SizedBox(height: metrics.sm),
                    FilledButton(
                      onPressed: state.canLog && stationId != null
                          ? _log
                          : null,
                      child: Text(l10n.fleLogButton(toLog)),
                    ),
                    if (stations.isNotEmpty && stationId == null)
                      Text(l10n.fleNoStation, style: text.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How one line was read: an icon and text, never colour alone.
class _LineTile extends StatelessWidget {
  const new({required this.line, required this.duplicate});

  final FleLine line;
  final bool duplicate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final (icon, title, subtitle) = switch (line) {
      FleErrorLine(:final problem, :final token) => (
        Icons.error_outline,
        fleProblemText(l10n, problem, token),
        line.text,
      ),
      FleHeaderLine() => (Icons.tune, line.text, l10n.fleHeaderLine),
      FleQsoLine(:final qso, :final warnings) => (
        duplicate || warnings.isNotEmpty
            ? Icons.warning_amber_outlined
            : Icons.check_circle_outline,
        '${qso.call}'
            '${qso.fields['NAME'] == null ? '' : ' · ${qso.fields['NAME']}'}',
        [
          l10n.fleQsoDetails(
            utcClock(qso.timeOn),
            qso.band.name,
            qso.mode.label,
            '${qso.rstSent}/${qso.rstRcvd}',
          ),
          if (duplicate) l10n.fleDuplicate,
          for (final w in warnings)
            switch (w) {
              FleWarning.timeWentBackwards => l10n.fleWarnBackwards,
              FleWarning.futureTime => l10n.fleWarnFuture,
            },
        ].join('\n'),
      ),
    };
    return MergeSemantics(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: Icon(
          icon,
          color: line is FleErrorLine ? colors.error : colors.textSecondary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          l10n.fleLine(line.number),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        isThreeLine: subtitle.contains('\n'),
      ),
    );
  }
}
