import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tideline/src/settings/app_settings.dart';

import '../support/pump_app.dart';

Finder field(String label) => find.widgetWithText(TextField, label);

TextEditingController controllerOf(WidgetTester tester, String label) =>
    tester.widget<TextField>(field(label)).controller!;

Future<void> openDialog(WidgetTester tester, {Size? size}) async {
  await pumpTideline(tester, size: size ?? TestSizes.desktop);
  await tester.tap(find.text('Change time'));
  await tester.pumpAndSettle();
}

void main() {
  group('date and time dialog', () {
    testWidgets('both fields are filled, and the date is selected', (
      tester,
    ) async {
      await openDialog(tester);
      final date = controllerOf(tester, 'Date (UTC)');
      final time = controllerOf(tester, 'Time (UTC)');
      expect(date.text, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
      expect(time.text, matches(RegExp(r'^\d{2}:\d{2}$')));
      expect(
        date.selection,
        const TextSelection(baseOffset: 0, extentOffset: 10),
      );
    });

    testWidgets('typing overwrites at once, the time is selected next', (
      tester,
    ) async {
      await openDialog(tester);
      await tester.enterText(field('Date (UTC)'), '20240229');
      await tester.pumpAndSettle();
      // After the eighth digit the focus moves to the time, selected.
      final time = controllerOf(tester, 'Time (UTC)');
      expect(time.selection.isCollapsed, isFalse);
      expect(time.selection.start, 0);
      expect(time.selection.end, time.text.length);
      await tester.enterText(field('Time (UTC)'), '1437');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Date and time (UTC)'), findsNothing);
      expect(find.textContaining('2024-02-29 14:37 UTC'), findsOneWidget);
    });

    testWidgets('a time with colon and a three digit time both work', (
      tester,
    ) async {
      await openDialog(tester);
      await tester.enterText(field('Date (UTC)'), '2024-03-01');
      await tester.enterText(field('Time (UTC)'), '9:05');
      await tester.tap(find.text('Set time'));
      await tester.pumpAndSettle();
      expect(find.textContaining('2024-03-01 09:05 UTC'), findsOneWidget);
    });

    testWidgets('invalid input is refused with a message', (tester) async {
      await openDialog(tester);
      await tester.enterText(field('Date (UTC)'), '20230231');
      await tester.enterText(field('Time (UTC)'), '2460');
      await tester.tap(find.text('Set time'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid date as YYYY-MM-DD.'), findsOneWidget);
      expect(
        find.text('Enter a valid time as HH:MM (24 hours).'),
        findsOneWidget,
      );
      expect(find.text('Date and time (UTC)'), findsOneWidget);
    });

    testWidgets('a date far in the future is refused', (tester) async {
      await openDialog(tester);
      final year = DateTime.now().toUtc().year + 2;
      await tester.enterText(field('Date (UTC)'), '$year-01-01');
      await tester.tap(find.text('Set time'));
      await tester.pumpAndSettle();
      expect(find.text('This date is too far in the future.'), findsOneWidget);
    });

    testWidgets('cancel changes nothing', (tester) async {
      await openDialog(tester);
      await tester.enterText(field('Date (UTC)'), '20200101');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Date and time (UTC)'), findsNothing);
      expect(find.textContaining('2020-01-01'), findsNothing);
    });

    testWidgets('the calendar is available on demand', (tester) async {
      await openDialog(tester);
      await tester.tap(find.byTooltip('Pick date from calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarDatePicker), findsOneWidget);
      await tester.tap(find.text('1').first);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(controllerOf(tester, 'Date (UTC)').text, endsWith('-01'));
    });

    testWidgets('the clock is available on demand', (tester) async {
      await openDialog(tester);
      await tester.tap(find.byTooltip('Pick time from clock'));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });

    testWidgets('German strings', (tester) async {
      await pumpTideline(
        tester,
        size: TestSizes.desktop,
        settings: const AppSettings(localeOverride: Locale('de')),
      );
      await tester.tap(find.text('Zeit ändern'));
      await tester.pumpAndSettle();
      expect(find.text('Datum und Uhrzeit (UTC)'), findsOneWidget);
      expect(find.text('Zeit übernehmen'), findsOneWidget);
    });

    for (final size in [TestSizes.phone, TestSizes.tabletPortrait]) {
      testWidgets('guidelines at ${size.width.toInt()} dp, 200 % text', (
        tester,
      ) async {
        await pumpTideline(tester, size: size, textScale: 2);
        await tester.ensureVisible(find.text('Change time'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Change time'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      });
    }
  });
}
