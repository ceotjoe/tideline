import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/contest/cabrillo_export.dart';
import 'package:tideline/src/features/contest/contest_engine.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline_adif/tideline_adif.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The localised text of a Cabrillo validation problem.
String cabrilloIssueText(
  AppLocalizations l10n,
  CabrilloIssueKind kind,
) => switch (kind) {
  CabrilloIssueKind.missingContest => l10n.cabrilloIssueMissingContest,
  CabrilloIssueKind.missingCallsign => l10n.cabrilloIssueMissingCallsign,
  CabrilloIssueKind.emptyLog => l10n.cabrilloIssueEmptyLog,
  CabrilloIssueKind.exchangeCountMismatch =>
    l10n.cabrilloIssueExchangeCountMismatch,
  CabrilloIssueKind.missingFrequency => l10n.cabrilloIssueMissingFrequency,
  CabrilloIssueKind.missingQsoCall => l10n.cabrilloIssueMissingQsoCall,
  CabrilloIssueKind.emptyExchangeToken => l10n.cabrilloIssueEmptyExchangeToken,
  CabrilloIssueKind.tokenContainsWhitespace =>
    l10n.cabrilloIssueTokenContainsWhitespace,
  CabrilloIssueKind.tooManyAddressLines =>
    l10n.cabrilloIssueTooManyAddressLines,
  CabrilloIssueKind.addressLineTooLong => l10n.cabrilloIssueAddressLineTooLong,
  CabrilloIssueKind.invalidTransmitterId =>
    l10n.cabrilloIssueInvalidTransmitterId,
};

/// Exports the Cabrillo log of [session], running or past.
///
/// Checks the log first. If there are problems they are listed (icon and
/// text) and the user decides whether to save anyway. A contest without a
/// Cabrillo name gets an explanation instead; nothing is written then.
Future<void> exportCabrillo(
  BuildContext context,
  WidgetRef ref,
  ContestSession session,
) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final transfer = ref.read(dataTransferProvider);

  final prepared = await _prepare(ref, session);
  if (!context.mounted) return;
  switch (prepared) {
    case _NoCabrilloName(:final contestName):
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          title: Text(l10n.cabrilloExportTitle),
          content: Text(l10n.cabrilloUnavailableBody(contestName)),
          actions: [
            TextButton(
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.actionClose),
            ),
          ],
        ),
      );
      return;
    case _Failed():
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.cabrilloExportFailed)),
      );
      return;
    case _Ready(:final export):
      if (export.issues.isNotEmpty) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (context) => _IssuesDialog(issues: export.issues),
        );
        if (!(proceed ?? false) || !context.mounted) return;
      }
      try {
        final saved = await transfer.saveFile(
          export.fileName,
          Uint8List.fromList(export.bytes),
          'text/plain',
        );
        if (saved) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.cabrilloExportDone)),
          );
        }
      } on Object {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.cabrilloExportFailed)),
        );
      }
  }
}

sealed class _Prepared {
  const new();
}

class _Ready extends _Prepared {
  const new(this.export);

  final CabrilloExport export;
}

class _NoCabrilloName extends _Prepared {
  const new(this.contestName);

  final String contestName;
}

class _Failed extends _Prepared {
  const new();
}

/// Gathers everything the log needs for any session, running or past.
Future<_Prepared> _prepare(WidgetRef ref, ContestSession session) async {
  try {
    final definitions = await ref.read(contestDefinitionsProvider.future);
    final definition = definitions
        .where((d) => d.definition.id == session.definitionId)
        .firstOrNull
        ?.definition;
    if (definition == null) return const _Failed();
    if (definition.cabrillo == null) return _NoCabrilloName(definition.name);

    final stations = await ref.read(stationsProvider.future);
    final station = stations
        .where((s) => s.id == session.stationProfileId)
        .firstOrNull;
    if (station == null) return const _Failed();
    DxccDatabase? dxcc;
    try {
      dxcc = await ref.read(dxccProvider.future);
    } on Object {
      // Without the resolver the exchange variant and the zones fall back to
      // what the QSOs hold; the log can still be written.
      dxcc = null;
    }
    final call = station.callsign.toUpperCase();
    final me = contestStationFor(
      call: call,
      dxcc: dxcc,
      grid: station.gridsquare,
      ownExchange: session.ownExchange,
    );
    final spec = ContestSpec(
      session: session,
      definition: definition,
      me: me,
      exchange: definition.exchangeFor(me),
    );
    final qsos = await ref
        .read(contestSessionRepositoryProvider)
        .watchSessionQsos(session.id)
        .first;
    final engine = ContestEngine(spec: spec, dxcc: dxcc)..sync(qsos);
    final export = buildCabrilloExport(
      spec: spec,
      qsos: engine.qsos,
      claimedScore: engine.score.total,
      callsign: call,
      gridLocator: station.gridsquare,
    );
    return export == null ? _NoCabrilloName(definition.name) : _Ready(export);
  } on Object {
    return const _Failed();
  }
}

String _describe(
  AppLocalizations l10n,
  CabrilloIssueKind kind,
  List<int> qsos,
) {
  final text = cabrilloIssueText(l10n, kind);
  if (qsos.isEmpty) return text;
  return '$text (${l10n.cabrilloIssueQsos(qsos.length, qsos.first + 1)})';
}

class _IssuesDialog extends StatelessWidget {
  const new({required this.issues});

  final List<CabrilloIssue> issues;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    // One line per kind; QSO problems say which QSOs they concern, so a
    // long log does not produce a thousand lines.
    final byKind = <CabrilloIssueKind, List<int>>{};
    for (final i in issues) {
      final list = byKind.putIfAbsent(i.kind, () => []);
      if (i.qsoIndex != null) list.add(i.qsoIndex!);
    }
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded),
      title: Text(l10n.cabrilloExportTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.cabrilloIssuesIntro),
            SizedBox(height: metrics.sm),
            for (final MapEntry(key: kind, value: qsos) in byKind.entries)
              Padding(
                padding: EdgeInsets.only(bottom: metrics.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.error_outline,
                        size: 18,
                        color: context.colors.error,
                      ),
                    ),
                    SizedBox(width: metrics.sm),
                    Expanded(child: Text(_describe(l10n, kind, qsos))),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.cabrilloExportAnyway),
        ),
      ],
    );
  }
}
