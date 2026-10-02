import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';
import 'contest_harness.dart';

/// Records what would be saved instead of opening a file dialog.
class FakeTransfer implements DataTransfer {
  final List<({String name, String text})> saved = [];

  /// What the save dialog returns: false means the user cancelled.
  bool accept = true;

  @override
  Future<bool> saveFile(String name, Uint8List bytes, String mime) async {
    if (!accept) return false;
    saved.add((name: name, text: utf8.decode(bytes)));
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Seeds QSOs that are complete for Cabrillo (with a frequency).
void seedComplete(ContestBackend backend, {int count = 3}) {
  final session = backend.active!;
  final now = DateTime.now().toUtc();
  for (var i = 0; i < count; i++) {
    backend.seedQso(
      Qso(
        id: 'c$i',
        accountId: 'acc-1',
        stationProfileId: 'st-1',
        call: Callsign.tryParse(['DL1ABC', 'G4XYZ', 'W1AW'][i % 3])!,
        timeOn: UtcDateTime(now.subtract(Duration(minutes: count - i))),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('SSB')!,
        freqHz: 14250000,
        rstSent: '59',
        rstRcvd: '59',
        fields: {
          'STX': '${i + 1}',
          'SRX': '${10 + i}',
          'STX_STRING': '59 ${i + 1}',
          'SRX_STRING': '59 ${10 + i}',
        },
        contestSessionId: session.id,
      ),
    );
  }
}

/// Lets the export gather its data: provider futures resolve on timers, which
/// `pumpAndSettle` alone does not advance when no frame is scheduled.
Future<void> settleExport(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

Future<void> openMenu(WidgetTester tester) async {
  await tester.tap(find.byTooltip('More actions'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menu entry exports a clean log through the saver', (
    tester,
  ) async {
    final transfer = FakeTransfer();
    final backend = ContestBackend()
      ..startSession('cq-wpx-ssb', usesSerial: true);
    seedComplete(backend);
    await pumpContest(
      tester,
      backend: backend,
      overrides: [dataTransferProvider.overrideWithValue(transfer)],
    );
    await openMenu(tester);
    await tester.tap(find.text('Export Cabrillo log'));
    await settleExport(tester);

    expect(transfer.saved, hasLength(1));
    final year = DateTime.now().toUtc().year;
    expect(transfer.saved.single.name, 'DO1HOZ-CQ-WPX-SSB-$year.log');
    final text = transfer.saved.single.text;
    expect(text, startsWith('START-OF-LOG: 3.0\r\n'));
    expect(text, contains('CALLSIGN: DO1HOZ\r\n'));
    expect(text, contains('CONTEST: CQ-WPX-SSB\r\n'));
    expect('QSO:'.allMatches(text), hasLength(3));
    expect(find.text('Cabrillo log saved.'), findsOneWidget);
    // Clean log: no warning dialog on the way.
    expect(find.text('Export anyway'), findsNothing);
  });

  testWidgets('problems are listed and can be confirmed or cancelled', (
    tester,
  ) async {
    final transfer = FakeTransfer();
    final backend = ContestBackend()
      ..startSession('cq-wpx-ssb', usesSerial: true);
    // Seeded without frequency: an HF line cannot be written.
    seedSessionQsos(backend, 2);
    await pumpContest(
      tester,
      backend: backend,
      overrides: [dataTransferProvider.overrideWithValue(transfer)],
    );

    await openMenu(tester);
    await tester.tap(find.text('Export Cabrillo log'));
    await settleExport(tester);
    expect(
      find.textContaining('The frequency or band cannot be determined.'),
      findsOneWidget,
    );
    expect(find.textContaining('2 QSOs, the first is no. 1'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsWidgets);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(transfer.saved, isEmpty);

    await openMenu(tester);
    await tester.tap(find.text('Export Cabrillo log'));
    await settleExport(tester);
    await tester.tap(find.text('Export anyway'));
    await settleExport(tester);
    expect(transfer.saved, hasLength(1));
    expect(find.text('Cabrillo log saved.'), findsOneWidget);
  });

  testWidgets('the shortcut runs the export', (tester) async {
    final transfer = FakeTransfer();
    final backend = ContestBackend()
      ..startSession('cq-wpx-ssb', usesSerial: true);
    seedComplete(backend);
    await pumpContest(
      tester,
      backend: backend,
      overrides: [dataTransferProvider.overrideWithValue(transfer)],
    );
    await chord(tester, LogicalKeyboardKey.keyX, shift: true);
    await settleExport(tester);
    expect(transfer.saved, hasLength(1));
  });

  testWidgets('a cancelled save dialog says nothing', (tester) async {
    final transfer = FakeTransfer()..accept = false;
    final backend = ContestBackend()
      ..startSession('cq-wpx-ssb', usesSerial: true);
    seedComplete(backend);
    await pumpContest(
      tester,
      backend: backend,
      overrides: [dataTransferProvider.overrideWithValue(transfer)],
    );
    await openMenu(tester);
    await tester.tap(find.text('Export Cabrillo log'));
    await settleExport(tester);
    expect(find.text('Cabrillo log saved.'), findsNothing);
  });

  testWidgets('a contest without a Cabrillo name warns and exports nothing', (
    tester,
  ) async {
    final transfer = FakeTransfer();
    final backend = ContestBackend();
    await pumpContest(
      tester,
      definitionId: 'generic-serial',
      backend: backend,
      overrides: [dataTransferProvider.overrideWithValue(transfer)],
    );
    seedComplete(backend);
    expect(
      find.text(
        'Cabrillo export is not available: this contest has no Cabrillo name.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);

    await openMenu(tester);
    await tester.tap(find.text('Export Cabrillo log'));
    await settleExport(tester);
    expect(find.textContaining('has no Cabrillo contest name'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(transfer.saved, isEmpty);
  });

  testWidgets('the past-sessions list exports and shows the sync state', (
    tester,
  ) async {
    final transfer = FakeTransfer();
    final backend = ContestBackend();
    final session = backend.startSession(
      'cq-wpx-ssb',
      usesSerial: true,
      remoteErrorKey: 'contestServerTooOld',
    );
    await backend.sessionRepository.end(
      session.id,
      DateTime.now().toUtc().millisecondsSinceEpoch,
    );
    await pumpTideline(
      tester,
      contest: backend,
      overrides: [dataTransferProvider.overrideWithValue(transfer)],
    );
    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();
    // The session is over, so the setup screen with its list is shown.
    expect(
      find.textContaining('Your Wavelog server is older than version 3.2'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

    final export = find.widgetWithText(OutlinedButton, 'Export Cabrillo log');
    await tester.ensureVisible(export);
    await tester.pumpAndSettle();
    await tester.tap(export);
    await settleExport(tester);
    // No QSOs: the check says so, and the user can still go on.
    expect(find.text('The session has no QSOs.'), findsOneWidget);
    await tester.tap(find.text('Export anyway'));
    await settleExport(tester);
    expect(transfer.saved, hasLength(1));
    expect(transfer.saved.single.text, contains('START-OF-LOG: 3.0'));
  });
}
