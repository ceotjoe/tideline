import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';
import 'contest_harness.dart';

bool hasFocus(WidgetTester tester, String label) =>
    tester.widget<TextField>(field(label)).focusNode!.hasFocus;

Future<void> logWpx(
  WidgetTester tester,
  String call, {
  String serial = '12',
}) async {
  await tester.enterText(field('Callsign'), call);
  await tester.enterText(field('Serial no.'), serial);
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pumpAndSettle();
}

void main() {
  group('entry flow (CQ WPX: report and serial)', () {
    testWidgets('Enter logs, the serial counts up and the entry is ready', (
      tester,
    ) async {
      final app = await pumpContest(tester);
      expect(find.text('Sent: RST 59 · Serial no. 1'), findsOneWidget);

      await logWpx(tester, 'dl1abc');

      final qso = app.contest.logged.single;
      expect(qso.call.value, 'DL1ABC');
      expect(qso.field('STX'), '1');
      expect(qso.field('SRX'), '12');
      expect((qso.rstSent, qso.rstRcvd), ('59', '59'));
      expect(qso.field('CONTEST_ID'), isNull); // set by the real repository
      expect(qso.contestSessionId, app.contest.active!.id);
      expect(qso.stationProfileId, testStation.id);
      // Cleared, ready, serial preview moved on, band and mode stay.
      expect(textOf(tester, 'Callsign'), '');
      expect(textOf(tester, 'Serial no.'), '');
      expect(hasFocus(tester, 'Callsign'), isTrue);
      expect(find.text('Sent: RST 59 · Serial no. 2'), findsOneWidget);
      expect(find.text('20 m'), findsWidgets);
      // The sync was nudged, but logging did not wait for it.
      expect(app.sync.runs, 1);

      await logWpx(tester, 'g4xyz', serial: '7');
      expect(app.contest.logged.last.field('STX'), '2');
      expect(find.text('Sent: RST 59 · Serial no. 3'), findsOneWidget);
    });

    testWidgets('an empty call only focuses the call', (tester) async {
      final app = await pumpContest(tester);
      await tester.enterText(field('Serial no.'), '5');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.logged, isEmpty);
      expect(hasFocus(tester, 'Callsign'), isTrue);
    });

    testWidgets('an incomplete exchange focuses the first missing element', (
      tester,
    ) async {
      final app = await pumpContest(tester);
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.logged, isEmpty);
      expect(hasFocus(tester, 'Serial no.'), isTrue);
      expect(find.text('Serial no. is required.'), findsOneWidget);
      // Typing clears the message; completing the exchange logs.
      await tester.enterText(field('Serial no.'), '3');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.logged, hasLength(1));
    });

    testWidgets('an invalid callsign is explained', (tester) async {
      final app = await pumpContest(tester);
      await tester.enterText(field('Callsign'), 'HELLO');
      await tester.enterText(field('Serial no.'), '3');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.logged, isEmpty);
      expect(find.textContaining('Enter a callsign'), findsOneWidget);
      expect(hasFocus(tester, 'Callsign'), isTrue);
    });

    testWidgets('Space moves to the next field and types no space', (
      tester,
    ) async {
      await pumpContest(tester);
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(hasFocus(tester, 'RST'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(hasFocus(tester, 'Serial no.'), isTrue);
      // The formatters reject spaces and letters in a number field.
      await tester.enterText(field('Serial no.'), '1 2a');
      expect(textOf(tester, 'Serial no.'), '12');
    });

    testWidgets('a save error keeps what was typed', (tester) async {
      final app = await pumpContest(tester);
      app.contest.failNextLog = true;
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.enterText(field('Serial no.'), '4');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.textContaining('could not be saved'), findsOneWidget);
      expect(textOf(tester, 'Callsign'), 'DL1ABC');
      expect(textOf(tester, 'Serial no.'), '4');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.logged, hasLength(1));
    });

    testWidgets('the log button logs, wipe clears', (tester) async {
      final app = await pumpContest(tester);
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.tap(find.text('Wipe entry'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'Callsign'), '');
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.enterText(field('Serial no.'), '4');
      await tester.tap(find.text('Log QSO'));
      await tester.pumpAndSettle();
      expect(app.contest.logged, hasLength(1));
    });
  });

  group('live hints', () {
    testWidgets('a dupe is flagged with the bands and modes worked', (
      tester,
    ) async {
      final app = await pumpContest(tester);
      await logWpx(tester, 'DL1ABC');
      await typeCall(tester, 'DL1ABC');
      expect(find.textContaining('Dupe: already worked on 20 m'), findsOne);
      expect(find.byIcon(Icons.block), findsWidgets);
      // On another band it is no dupe, but the earlier contact is shown.
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.textContaining('Dupe:'), findsNothing);
      expect(find.textContaining('not a dupe here'), findsOneWidget);
      expect(app.contest.logged, hasLength(1));
    });

    testWidgets('a new multiplier is announced from the score preview', (
      tester,
    ) async {
      await pumpContest(tester, definitionId: 'cq-ww-ssb');
      await typeCall(tester, 'EA8ABC');
      expect(find.textContaining('New multiplier: Country'), findsOneWidget);
      // Fully worked later: no longer new.
    });

    testWidgets('the main log history is shown', (tester) async {
      final backend = ContestBackend();
      backend.worked['DL1ABC'] = const WorkedSummary(
        bands: {'40m'},
        modes: {'CW'},
        slots: {('40m', 'CW')},
      );
      await pumpContest(tester, backend: backend);
      await typeCall(tester, 'DL1ABC');
      await tester.pump();
      expect(find.textContaining('In your log: worked before'), findsOne);
    });

    testWidgets('super check partial suggestions fill the call', (
      tester,
    ) async {
      final backend = ContestBackend(
        scp: ScpDatabase.parse('DL1ABC\nDL1ABD\nDK1ABC\n'),
      );
      await pumpContest(tester, backend: backend);
      await typeCall(tester, 'DL1AB');
      expect(find.text('Super check:'), findsOneWidget);
      await tester.tap(find.text('DL1ABD'));
      await tester.pumpAndSettle();
      expect(textOf(tester, 'Callsign'), 'DL1ABD');
      // The cursor moved on to the exchange.
      expect(hasFocus(tester, 'RST'), isTrue);
    });

    testWidgets('N+1 suggestions appear when the call is not in the list', (
      tester,
    ) async {
      final backend = ContestBackend(
        scp: ScpDatabase.parse('DL1ABC\nDL1ABD\n'),
      );
      await pumpContest(tester, backend: backend);
      await typeCall(tester, 'DL1ABX');
      expect(find.text('Did you mean:'), findsOneWidget);
      expect(find.text('DL1ABC'), findsOneWidget);
      // A call in the list says so instead.
      await typeCall(tester, 'DL1ABC');
      expect(find.textContaining('is in the super check'), findsOneWidget);
      expect(find.text('Did you mean:'), findsNothing);
    });
  });

  group('recent QSOs and inline editing', () {
    testWidgets('a row opens an editor; the serial stays', (tester) async {
      final app = await pumpContest(tester);
      await logWpx(tester, 'DL1ABC');
      await logWpx(tester, 'G4XYZ', serial: '7');
      expect(find.text('G4XYZ'), findsOneWidget);

      await tester.tap(find.textContaining('59 7').first);
      await tester.pumpAndSettle();
      expect(find.text('Edit QSO'), findsOneWidget);
      expect(
        find.text('Sent (cannot be changed): RST 59 · Serial no. 2'),
        findsOneWidget,
      );
      // Fix the received serial and the call, then save with Enter.
      final serial = find.widgetWithText(TextField, 'Serial no.');
      await tester.enterText(serial.last, '70');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Edit QSO'), findsNothing);
      final updated = app.contest.qsoRepository.updates.single;
      expect(updated.field('SRX'), '70');
      expect(updated.call.value, 'G4XYZ');
      final stored = app.contest.qsos.firstWhere((q) => q.id == updated.id);
      expect(stored.field('STX'), '2');
      expect(stored.field('SRX'), '70');
      // The next serial is untouched by the edit.
      expect(find.text('Sent: RST 59 · Serial no. 3'), findsOneWidget);
    });

    testWidgets('an invalid edit keeps the editor open and focuses the error', (
      tester,
    ) async {
      final app = await pumpContest(tester);
      await logWpx(tester, 'DL1ABC');
      await tester.tap(find.textContaining('59 12').first);
      await tester.pumpAndSettle();
      final serial = find.widgetWithText(TextField, 'Serial no.').last;
      await tester.enterText(serial, '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Serial no. is required.'), findsOneWidget);
      expect(app.contest.qsoRepository.updates, isEmpty);
      expect(tester.widget<TextField>(serial).focusNode!.hasFocus, isTrue);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Edit QSO'), findsNothing);
    });

    testWidgets('editing the call rescores', (tester) async {
      final app = await pumpContest(tester);
      await logWpx(tester, 'DL1ABC');
      await logWpx(tester, 'DL1ABX', serial: '3');
      // Fix the busted call: now a dupe of the first QSO.
      await tester.tap(find.text('DL1ABX').first);
      await tester.pumpAndSettle();
      await tester.enterText(field('Callsign').last, 'DL1ABC');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.qsoRepository.updates.single.call.value, 'DL1ABC');
      expect(find.text('Dupe'), findsOneWidget);
    });

    testWidgets('delete asks first and never reuses the serial', (
      tester,
    ) async {
      final app = await pumpContest(tester);
      await logWpx(tester, 'DL1ABC');
      await logWpx(tester, 'G4XYZ', serial: '7');
      await tester.tap(find.textContaining('59 7').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete QSO'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this QSO?'), findsOneWidget);
      expect(find.textContaining('Serial 2 stays used'), findsOneWidget);
      // Cancel keeps it.
      final dialog = find.byType(AlertDialog);
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Cancel')),
      );
      await tester.pumpAndSettle();
      expect(app.contest.qsoRepository.deleted, isEmpty);
      await tester.tap(find.text('Delete QSO'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: dialog, matching: find.text('Delete QSO')),
      );
      await tester.pumpAndSettle();
      expect(app.contest.qsoRepository.deleted, hasLength(1));
      expect(find.text('G4XYZ'), findsNothing);
      // 1 and 2 were given out; the next QSO gets 3.
      expect(find.text('Sent: RST 59 · Serial no. 3'), findsOneWidget);
    });

    testWidgets('Edit last QSO opens the newest one', (tester) async {
      await pumpContest(tester);
      await logWpx(tester, 'DL1ABC');
      await logWpx(tester, 'G4XYZ', serial: '7');
      await chord(tester, LogicalKeyboardKey.keyE);
      await tester.pumpAndSettle();
      expect(find.text('Edit QSO'), findsOneWidget);
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .any((t) => t.controller?.text == 'G4XYZ'),
        isTrue,
      );
    });
  });

  group('keyboard commands', () {
    testWidgets('Esc wipes, Page Up/Down change the band, Ctrl+M the mode', (
      tester,
    ) async {
      await pumpContest(tester);
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(textOf(tester, 'Callsign'), '');

      expect(find.text('20 m'), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();
      expect(find.text('15 m'), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();
      expect(find.text('40 m'), findsWidgets);

      expect(find.text('SSB'), findsWidgets);
      await chord(tester, LogicalKeyboardKey.keyM);
      await tester.pumpAndSettle();
      // CQ WPX SSB only allows voice: the mode stays SSB (FM, AM are voice).
      expect(find.text('SSB'), findsNothing);
    });

    testWidgets('Ctrl+L focuses the call, Ctrl+R toggles the panel', (
      tester,
    ) async {
      await pumpContest(tester);
      await tester.tap(field('Serial no.'));
      await tester.pump();
      expect(hasFocus(tester, 'Callsign'), isFalse);
      await chord(tester, LogicalKeyboardKey.keyL);
      await tester.pump();
      expect(hasFocus(tester, 'Callsign'), isTrue);

      expect(find.text('Score and rates'), findsOneWidget);
      await chord(tester, LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();
      expect(find.text('Score and rates'), findsNothing);
      await chord(tester, LogicalKeyboardKey.keyR);
      await tester.pumpAndSettle();
      expect(find.text('Score and rates'), findsOneWidget);
    });

    testWidgets('Ctrl+Shift+E ends the session after a confirmation', (
      tester,
    ) async {
      final app = await pumpContest(tester);
      await chord(tester, LogicalKeyboardKey.keyE, shift: true);
      await tester.pumpAndSettle();
      expect(find.text('End the contest session?'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(FilledButton, 'End contest session'),
      );
      await tester.pumpAndSettle();
      expect(app.contest.active, isNull);
      // Back on the setup screen, with the session in the past list.
      expect(find.text('Past sessions'), findsOneWidget);
      expect(find.text('Reopen'), findsOneWidget);
    });

    testWidgets('Enter on the log screen still logs a normal QSO', (
      tester,
    ) async {
      final app = await pumpContest(tester, open: false);
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.qsoRepository.plainLogged, hasLength(1));
      expect(app.contest.logged, isEmpty);
      expect(tester.widget<TextField>(field('Callsign')).controller!.text, '');
    });
  });
}
