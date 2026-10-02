import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/log/qso_detail.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

Finder field(String label) => find.widgetWithText(TextField, label);

void main() {
  group('logging', () {
    testWidgets('Enter logs the QSO locally with sensible defaults', (
      tester,
    ) async {
      final app = await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Callsign'), 'dl1abc');
      await tester.pump();
      // Offline DXCC hint appears while typing.
      expect(find.textContaining('Fed. Rep. of Germany'), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      final qso = app.qsos.logged.single;
      expect(qso.call.value, 'DL1ABC');
      expect(qso.band.name, '20m');
      expect(qso.mode.mode, 'SSB');
      expect((qso.rstSent, qso.rstRcvd), ('59', '59'));
      expect(qso.stationProfileId, testStation.id);
      expect(qso.field('DXCC'), '230');
      expect(qso.timeOn.value.isUtc, isTrue);
      // The form is ready for the next QSO, and sync was nudged.
      expect(tester.widget<TextField>(field('Callsign')).controller!.text, '');
      expect(app.sync.runs, 1);
    });

    testWidgets('invalid callsign is explained and nothing is logged', (
      tester,
    ) async {
      final app = await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Callsign'), 'HELLO');
      await tester.ensureVisible(find.text('Log QSO'));
      await tester.tap(find.text('Log QSO'));
      await tester.pumpAndSettle();
      expect(app.qsos.logged, isEmpty);
      expect(find.textContaining('Enter a callsign'), findsOneWidget);
    });

    testWidgets('a frequency selects its band', (tester) async {
      final app = await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Frequency'), '7074');
      await tester.enterText(field('Callsign'), 'G4XYZ');
      await tester.ensureVisible(find.text('Log QSO'));
      await tester.tap(find.text('Log QSO'));
      await tester.pumpAndSettle();
      final qso = app.qsos.logged.single;
      expect(qso.band.name, '40m');
      expect(qso.freqHz, 7074000);
    });

    testWidgets('Esc clears the entry', (tester) async {
      await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Callsign'), 'G4XYZ');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field('Callsign')).controller!.text, '');
    });
  });

  group('layouts', () {
    testWidgets('phone: form above the recent QSOs', (tester) async {
      await pumpTideline(tester, log: sampleLog(3));
      await tester.scrollUntilVisible(
        find.text('Recent QSOs'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Recent QSOs'), findsOneWidget);
      expect(find.text('Log QSO'), findsOneWidget);
    });

    testWidgets('tablet landscape: entry, log and context side by side', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletLandscape,
        log: sampleLog(3),
      );
      expect(find.textContaining('This works offline'), findsOneWidget);
      // Selecting a QSO shows it in the third pane, not on a new page.
      await tester.tap(find.text('Anna').first);
      await tester.pumpAndSettle();
      expect(find.byType(QsoDetail), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('phone: a QSO opens on its own page', (tester) async {
      await pumpTideline(tester, log: sampleLog(1));
      await tester.scrollUntilVisible(
        find.text('Anna'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Anna'));
      await tester.pumpAndSettle();
      expect(find.text('QSO details'), findsOneWidget);
    });
  });

  group('sync status is explained', () {
    testWidgets('a conflict offers both choices in plain language', (
      tester,
    ) async {
      final log = [
        LoggedQso(
          sampleLog(1).single.qso,
          const SyncStatus(
            state: SyncState.conflict,
            remoteQsoId: 5,
            problem: SyncProblem.readOnlyFieldsChanged,
          ),
        ),
      ];
      await pumpTideline(tester, size: TestSizes.tabletLandscape, log: log);
      await tester.tap(find.text('Anna').first);
      await tester.pumpAndSettle();
      expect(find.text('Needs decision'), findsWidgets);
      expect(find.textContaining("Wavelog can't change these"), findsOneWidget);
      expect(find.text('Replace in Wavelog'), findsOneWidget);
      expect(find.text("I'll fix it in Wavelog"), findsOneWidget);
    });

    testWidgets('a rejection shows the server message', (tester) async {
      final log = [
        LoggedQso(
          sampleLog(1).single.qso,
          const SyncStatus(
            state: SyncState.rejected,
            problem: SyncProblem.invalidData,
            serverMessage: 'Unknown band',
          ),
        ),
      ];
      await pumpTideline(tester, size: TestSizes.tabletLandscape, log: log);
      await tester.tap(find.text('Anna').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Wavelog said: Unknown band'), findsOneWidget);
    });
  });

  testWidgets('callsigns are read letter by letter', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpTideline(tester, size: TestSizes.desktop, log: sampleLog(1));
    expect(find.bySemanticsLabel(RegExp('D L 1 A B C')), findsWidgets);
    handle.dispose();
  });

  group('accessibility with a full log', () {
    for (final theme in ThemeChoice.values) {
      for (final size in [TestSizes.phone, TestSizes.tabletLandscape]) {
        testWidgets('${theme.name} at ${size.width.toInt()}', (tester) async {
          final handle = tester.ensureSemantics();
          await pumpTideline(
            tester,
            size: size,
            settings: AppSettings(theme: theme),
            log: sampleLog(8),
          );
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    }

    testWidgets('200 % text on a phone with a full log', (tester) async {
      await pumpTideline(tester, textScale: 2, log: sampleLog(8));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('first run shows onboarding', (tester) async {
    await pumpTideline(tester, accounts: const []);
    expect(find.text('Welcome to Tideline'), findsOneWidget);
    await tester.tap(find.text('Connect to Wavelog'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Server address'), 'http://log.example.org');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('only possible for servers in your own network'),
      findsOneWidget,
    );
  });
}
