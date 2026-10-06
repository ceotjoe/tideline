import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_data/tideline_data.dart';

import '../support/pump_app.dart';

const _stations = {
  'DL1ABC': CallsignInfo(
    call: 'DL1ABC',
    lastTime: 1_700_000_000_000,
    name: 'Anna',
    qth: 'Berlin',
    gridsquare: 'JO62',
    dxcc: 230,
    cqz: 14,
    ituz: 28,
  ),
  'G4XYZ': CallsignInfo(
    call: 'G4XYZ',
    lastTime: 1_600_000_000_000,
    name: 'Bob',
    qth: 'Leeds',
  ),
};

Future<void> _openTab(WidgetTester tester) async {
  await tester.tap(find.text('Callsigns').last);
  await tester.pumpAndSettle();
}

Future<void> _openSettingsSection(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Reference data'),
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text('Reference data'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Reference data'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('2 stations'),
    200,
    scrollable: find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .last,
  );
}

void main() {
  testWidgets('the directory is a main destination, not hidden in settings', (
    tester,
  ) async {
    await pumpTideline(tester, callsigns: _stations);
    expect(find.byType(NavigationBar), findsOneWidget);
    await _openTab(tester);
    expect(find.text('Callsign directory'), findsOneWidget);
    expect(find.text('DL1ABC'), findsOneWidget);
  });

  testWidgets(
    'the settings section says what the directory holds and how many stations',
    (tester) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        callsigns: _stations,
      );
      await _openSettingsSection(tester);
      expect(find.text('2 stations'), findsOneWidget);
      expect(find.textContaining('kept on this device'), findsOneWidget);
    },
  );

  testWidgets('the page lists the stations, newest first, with details', (
    tester,
  ) async {
    await pumpTideline(
      tester,
      size: TestSizes.tabletPortrait,
      callsigns: _stations,
    );
    await _openTab(tester);
    expect(find.text('DL1ABC'), findsOneWidget);
    expect(find.textContaining('Anna · Berlin · JO62'), findsOneWidget);
    expect(find.textContaining('DXCC 230 · CQ 14 · ITU 28'), findsOneWidget);
    expect(find.textContaining('Last worked'), findsNWidgets(2));
  });

  testWidgets('searching narrows the list; nothing found says so', (
    tester,
  ) async {
    await pumpTideline(
      tester,
      size: TestSizes.tabletPortrait,
      callsigns: _stations,
    );
    await _openTab(tester);
    await tester.enterText(find.byType(TextField), 'leeds');
    await tester.pumpAndSettle();
    expect(find.text('G4XYZ'), findsOneWidget);
    expect(find.text('DL1ABC'), findsNothing);
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing found'), findsOneWidget);
  });

  testWidgets('tapping a station opens its note; saving adds the mark', (
    tester,
  ) async {
    final app = await pumpTideline(
      tester,
      size: TestSizes.tabletPortrait,
      callsigns: _stations,
    );
    await _openTab(tester);
    expect(find.byIcon(Icons.sticky_note_2), findsNothing);
    await tester.tap(find.text('G4XYZ'));
    await tester.pumpAndSettle();
    expect(find.text('Note for G4XYZ'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'QSL via bureau',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(app.notes.notes, {'G4XYZ': 'QSL via bureau'});
    expect(find.byIcon(Icons.sticky_note_2), findsOneWidget);
  });

  testWidgets('the page meets the guidelines at 200 % text', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpTideline(
      tester,
      textScale: 2,
      callsigns: _stations,
      callsignNotes: {'DL1ABC': 'x'},
    );
    await _openTab(tester);
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
