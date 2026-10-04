import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_data/tideline_data.dart';

import '../support/pump_app.dart';

const _anna = CallsignInfo(
  call: 'DL1ABC',
  lastTime: 1000,
  name: 'Anna',
  qth: 'Berlin',
  gridsquare: 'JO62',
  country: 'Germany',
);

Finder _field(String label) => find.widgetWithText(TextField, label);

Future<void> _type(WidgetTester tester, String call) async {
  await tester.enterText(_field('Callsign'), call);
  await tester.pumpAndSettle();
}

void main() {
  group('what earlier contacts say', () {
    testWidgets('is shown under the callsign, with the details', (
      tester,
    ) async {
      await pumpTideline(tester, callsigns: {'DL1ABC': _anna});
      expect(find.textContaining('Known from earlier contacts'), findsNothing);
      await _type(tester, 'DL1ABC');
      expect(
        find.text('Known from earlier contacts: Anna · Berlin · JO62'),
        findsOneWidget,
      );
    });

    testWidgets('also for a portable call of the same station', (tester) async {
      await pumpTideline(tester, callsigns: {'DL1ABC': _anna});
      await _type(tester, 'EA8/DL1ABC/P');
      expect(find.textContaining('Anna'), findsWidgets);
    });

    testWidgets('nothing for an unknown station or one without details', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        callsigns: {
          'DL1ABC': _anna,
          'G4XYZ': const CallsignInfo(call: 'G4XYZ', lastTime: 1),
        },
      );
      await _type(tester, 'W1AW');
      expect(find.textContaining('Known from earlier contacts'), findsNothing);
      await _type(tester, 'G4XYZ');
      expect(find.textContaining('Known from earlier contacts'), findsNothing);
    });

    testWidgets('Fill in copies name and locator into empty fields', (
      tester,
    ) async {
      await pumpTideline(tester, callsigns: {'DL1ABC': _anna});
      await _type(tester, 'DL1ABC');
      await tester.tap(find.text('Fill in'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(_field('Name')).controller!.text, 'Anna');
      expect(
        tester.widget<TextField>(_field('Locator')).controller!.text,
        'JO62',
      );
      // Nothing left to fill: the button is gone.
      expect(find.text('Fill in'), findsNothing);
    });

    testWidgets('Fill in never replaces what was typed', (tester) async {
      await pumpTideline(tester, callsigns: {'DL1ABC': _anna});
      await tester.enterText(_field('Name'), 'Annie');
      await _type(tester, 'DL1ABC');
      await tester.tap(find.text('Fill in'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_field('Name')).controller!.text,
        'Annie',
      );
      expect(
        tester.widget<TextField>(_field('Locator')).controller!.text,
        'JO62',
      );
    });

    testWidgets('no Fill in when both fields are already typed', (
      tester,
    ) async {
      await pumpTideline(tester, callsigns: {'DL1ABC': _anna});
      await tester.enterText(_field('Name'), 'Annie');
      await tester.enterText(_field('Locator'), 'JN58');
      await _type(tester, 'DL1ABC');
      expect(
        find.textContaining('Known from earlier contacts'),
        findsOneWidget,
      );
      expect(find.text('Fill in'), findsNothing);
    });

    testWidgets('meets the accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTideline(
        tester,
        callsigns: {'DL1ABC': _anna},
        callsignNotes: {'DL1ABC': 'Calls on 40 m'},
      );
      await _type(tester, 'DL1ABC');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('the note about a station', () {
    testWidgets('the button is off until the call can be a callsign', (
      tester,
    ) async {
      await pumpTideline(tester);
      IconButton button() => tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.sticky_note_2_outlined),
      );
      expect(button().onPressed, isNull);
      await _type(tester, 'DL1ABC');
      expect(button().onPressed, isNotNull);
    });

    testWidgets('a note is shown under the callsign and opens for editing', (
      tester,
    ) async {
      await pumpTideline(tester, callsignNotes: {'DL1ABC': 'Calls on 40 m'});
      await _type(tester, 'DL1ABC');
      expect(find.text('Note: Calls on 40 m'), findsOneWidget);
      expect(find.byTooltip('Callsign note (there is one)'), findsOneWidget);
      await tester.tap(find.text('Note: Calls on 40 m'));
      await tester.pumpAndSettle();
      expect(find.text('Note for DL1ABC'), findsOneWidget);
      expect(find.text('Calls on 40 m'), findsOneWidget);
      expect(find.textContaining('Not sent to Wavelog'), findsOneWidget);
    });

    testWidgets('a new note is saved for the home call', (tester) async {
      final app = await pumpTideline(tester);
      await _type(tester, 'EA8/DL1ABC/P');
      await tester.tap(find.byTooltip('Callsign note'));
      await tester.pumpAndSettle();
      expect(find.text('Delete note'), findsNothing);
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Always on 40 m',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(app.notes.notes, {'DL1ABC': 'Always on 40 m'});
      expect(find.text('Note: Always on 40 m'), findsOneWidget);
    });

    testWidgets('Cancel changes nothing', (tester) async {
      final app = await pumpTideline(tester, callsignNotes: {'DL1ABC': 'keep'});
      await _type(tester, 'DL1ABC');
      await tester.tap(find.text('Note: keep'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'changed',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(app.notes.notes, {'DL1ABC': 'keep'});
    });

    testWidgets('a note can be deleted', (tester) async {
      final app = await pumpTideline(tester, callsignNotes: {'DL1ABC': 'old'});
      await _type(tester, 'DL1ABC');
      await tester.tap(find.text('Note: old'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete note'));
      await tester.pumpAndSettle();
      expect(app.notes.notes, isEmpty);
      expect(find.textContaining('Note: '), findsNothing);
    });
  });
}
