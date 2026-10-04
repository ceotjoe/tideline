import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Fast Log Entry'));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField).first, text);
  // Reading is debounced.
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

const _activation = Activation(
  id: 'act-1',
  accountId: 'acc-1',
  program: ReferenceProgram.pota,
  reference: 'US-0001',
  startedAt: 1000,
  stationProfileId: 'st-1',
);

void main() {
  group('reading', () {
    testWidgets('opens from the log screen and starts empty', (tester) async {
      await pumpTideline(tester);
      await _open(tester);
      expect(find.text('Fast Log Entry'), findsWidgets);
      expect(
        find.textContaining('Nothing is logged until you confirm'),
        findsOneWidget,
      );
      expect(find.text('Nothing to read yet.'), findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('every line is shown as read, in UTC', (tester) async {
      await pumpTideline(tester);
      await _open(tester);
      await _type(tester, '20m cw\n1734 DL1ABC 599 579 @Anna\n5 G4XYZ');
      expect(find.text('Sets what follows'), findsOneWidget);
      expect(find.text('DL1ABC · Anna'), findsOneWidget);
      expect(
        find.textContaining('17:34 UTC · 20m CW · 599/579'),
        findsOneWidget,
      );
      expect(
        find.textContaining('17:35 UTC · 20m CW · 599/599'),
        findsOneWidget,
      );
      expect(find.text('Line 3'), findsOneWidget);
      expect(
        find.text('2 QSOs to log · no problems · no duplicates'),
        findsOneWidget,
      );
      expect(find.text('Log 2 QSOs'), findsOneWidget);
    });

    testWidgets('a problem line says what is wrong, with the word', (
      tester,
    ) async {
      await pumpTideline(tester);
      await _open(tester);
      await _type(tester, '20m cw\n1734 DL1ABC blah\n1735 G4XYZ');
      expect(find.text('Not understood: blah'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      // The text of the line stays visible next to it.
      expect(find.text('1734 DL1ABC blah'), findsOneWidget);
      // Logging waits until the problem is fixed or skipped.
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(
        find.text('1 QSO to log · 1 problem · no duplicates'),
        findsOneWidget,
      );
    });

    testWidgets('missing band and a time that goes backwards are explained', (
      tester,
    ) async {
      await pumpTideline(tester);
      await _open(tester);
      await _type(tester, '1200 DL1ABC');
      expect(find.textContaining('No band yet'), findsOneWidget);
      await _type(tester, '20m cw\n1200 DL1ABC\n1100 G4XYZ');
      expect(
        find.textContaining('Earlier than the QSO before'),
        findsOneWidget,
      );
    });

    testWidgets('the text survives a resize', (tester) async {
      await pumpTideline(tester);
      await _open(tester);
      await _type(tester, '20m cw\n1200 DL1ABC');
      tester.view.physicalSize =
          TestSizes.tabletLandscape * tester.view.devicePixelRatio;
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '20m cw\n1200 DL1ABC',
      );
      expect(find.text('Log 1 QSO'), findsOneWidget);
    });
  });

  group('logging', () {
    testWidgets('logs every QSO in one batch, closes, and reports', (
      tester,
    ) async {
      final app = await pumpTideline(tester);
      await _open(tester);
      await _type(tester, '20m cw\n1734 DL1ABC 599 579 jo62\n5 G4XYZ');
      await tester.tap(find.text('Log 2 QSOs'));
      await tester.pumpAndSettle();

      expect(app.qsos.batches, hasLength(1));
      final batch = app.qsos.batches.single;
      expect(batch.map((q) => q.call.value), ['DL1ABC', 'G4XYZ']);
      expect(batch.first.accountId, 'acc-1');
      expect(batch.first.stationProfileId, 'st-1');
      expect(batch.first.source, QsoSource.fle);
      expect(batch.first.field('GRIDSQUARE'), 'JO62');
      expect((batch.first.rstSent, batch.first.rstRcvd), ('599', '579'));
      expect(batch[1].timeOn.value.minute, 35);
      expect(find.text('Logged 2 QSOs'), findsOneWidget);
      // Back on the log screen.
      expect(find.text('Log QSO'), findsOneWidget);
    });

    testWidgets('lines with problems wait, then can be skipped', (
      tester,
    ) async {
      final app = await pumpTideline(tester);
      await _open(tester);
      await _type(tester, '20m cw\n1734 DL1ABC\n1735 G4XYZ blah');
      await tester.tap(find.text('Skip lines with problems'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log 1 QSO'));
      await tester.pumpAndSettle();
      expect(app.qsos.batches.single.map((q) => q.call.value), ['DL1ABC']);
    });

    testWidgets('duplicates are marked and skipped unless asked', (
      tester,
    ) async {
      // A tall window: the preview list builds only what is on screen.
      final app = await pumpTideline(tester, size: const Size(820, 2400));
      final minute = DateTime.now().toUtc();
      // Yesterday 12:00, so the QSO is not in the future.
      final day = DateTime.utc(
        minute.year,
        minute.month,
        minute.day,
      ).subtract(const Duration(days: 1));
      final at = day.add(const Duration(hours: 12)).millisecondsSinceEpoch;
      app.qsos.existingKeys = {('DL1ABC', at, '20m', 'CW', 'st-1')};
      await _open(tester);
      final date =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-'
          '${day.day.toString().padLeft(2, '0')}';
      await _type(
        tester,
        'date $date\n20m cw\n1200 DL1ABC\n1201 G4XYZ\n1201 G4XYZ',
      );
      expect(
        find.textContaining('Duplicate: already in the log'),
        findsNWidgets(2),
      );
      expect(find.text('Log 1 QSO'), findsOneWidget);
      await tester.tap(find.text('Log 1 QSO'));
      await tester.pumpAndSettle();
      expect(app.qsos.batches.single.map((q) => q.call.value), ['G4XYZ']);
    });

    testWidgets('Also log duplicates logs them too', (tester) async {
      final app = await pumpTideline(tester);
      await _open(tester);
      await _type(tester, '20m cw\n1200 DL1ABC\n1200 DL1ABC');
      await tester.tap(find.text('Also log duplicates'));
      await tester.pumpAndSettle();
      expect(find.text('Log 2 QSOs'), findsOneWidget);
      await tester.tap(find.text('Log 2 QSOs'));
      await tester.pumpAndSettle();
      expect(app.qsos.batches.single, hasLength(2));
    });

    testWidgets('a running activation takes the QSOs', (tester) async {
      final activations = FakeActivationRepository();
      final app = await pumpTideline(
        tester,
        activation: _activation,
        activations: activations,
      );
      await _open(tester);
      expect(
        find.textContaining('your running activation US-0001'),
        findsOneWidget,
      );
      await _type(tester, '20m ssb\n1200 DL1ABC de-0034');
      await tester.tap(find.text('Log 1 QSO'));
      await tester.pumpAndSettle();
      expect(app.qsos.batches, isEmpty);
      final (id, qsos) = activations.batches.single;
      expect(id, 'act-1');
      expect(qsos.single.field('POTA_REF'), 'DE-0034');
    });

    testWidgets('a failed batch says so and keeps the text', (tester) async {
      final app = await pumpTideline(tester);
      app.qsos.batchFailure = Exception('disk full');
      await _open(tester);
      await _type(tester, '20m cw\n1200 DL1ABC');
      await tester.tap(find.text('Log 1 QSO'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Nothing was logged'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '20m cw\n1200 DL1ABC',
      );
    });
  });

  group('around it', () {
    testWidgets('Ctrl+Shift+F opens it from anywhere', (tester) async {
      await pumpTideline(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Nothing to read yet.'), findsOneWidget);
    });

    testWidgets('meets the guidelines at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTideline(tester, textScale: 2);
      await _open(tester);
      await _type(tester, '20m cw\n1734 DL1ABC blah\n1735 G4XYZ');
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });
}
