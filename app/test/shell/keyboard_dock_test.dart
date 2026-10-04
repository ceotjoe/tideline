import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/log/qso_entry_form.dart';

import '../support/pump_app.dart';

void main() {
  Future<void> raiseKeyboard(WidgetTester tester, double height) async {
    tester.view.viewInsets = FakeViewPadding(
      bottom: height * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
  }

  group('keyboard dock on a phone', () {
    testWidgets('shows Hide keyboard above the keyboard, instead of the bar', (
      tester,
    ) async {
      await pumpTideline(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Hide keyboard'), findsNothing);

      await raiseKeyboard(tester, 300);

      final size = tester.view.physicalSize / tester.view.devicePixelRatio;
      final hide = tester.getRect(find.text('Hide keyboard'));
      expect(hide.bottom, lessThanOrEqualTo(size.height - 300));
      expect(find.byType(NavigationBar), findsNothing);
      final target = tester.getSize(
        find.ancestor(
          of: find.text('Hide keyboard'),
          matching: find.byType(TextButton),
        ),
      );
      expect(target.height, greaterThanOrEqualTo(48));
    });

    testWidgets('Hide keyboard unfocuses the field and brings the bar back', (
      tester,
    ) async {
      await pumpTideline(tester);
      await tester.tap(find.byType(TextField).first);
      await raiseKeyboard(tester, 300);
      expect(FocusManager.instance.primaryFocus?.hasPrimaryFocus, isTrue);

      await tester.tap(find.text('Hide keyboard'));
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();

      expect(find.byType(EditableText), findsWidgets);
      final focused = FocusManager.instance.primaryFocus;
      expect(
        focused?.context?.findAncestorWidgetOfExactType<EditableText>(),
        isNull,
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Hide keyboard'), findsNothing);
    });

    testWidgets('a tap on empty space closes the keyboard', (tester) async {
      await pumpTideline(tester);
      await tester.tap(find.byType(TextField).first);
      await raiseKeyboard(tester, 300);
      // The tide gauge is not interactive.
      await tester.tapAt(const Offset(2, 2));
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus;
      expect(
        focused?.context?.findAncestorWidgetOfExactType<EditableText>(),
        isNull,
      );
    });

    testWidgets('the form keeps its fields above the keyboard', (tester) async {
      await pumpTideline(tester);
      await raiseKeyboard(tester, 300);
      final size = tester.view.physicalSize / tester.view.devicePixelRatio;
      final form = tester.getRect(find.byType(QsoEntryForm));
      expect(form.top, lessThan(size.height - 300));
    });
  });

  group('keyboard dock on larger windows', () {
    for (final size in [TestSizes.tabletPortrait, TestSizes.tabletLandscape]) {
      testWidgets('${size.width.toInt()} wide is left alone', (tester) async {
        await pumpTideline(tester, size: size);
        await raiseKeyboard(tester, 300);
        expect(find.text('Hide keyboard'), findsNothing);
      });
    }
  });

  group('number keyboards', () {
    testWidgets('report fields use a signed number keyboard', (tester) async {
      await pumpTideline(tester);
      for (final label in ['RST sent', 'RST received']) {
        final field = tester.widget<TextField>(
          find.widgetWithText(TextField, label),
        );
        expect(
          field.keyboardType,
          const TextInputType.numberWithOptions(signed: true),
          reason: label,
        );
      }
    });

    testWidgets('callsign and locator stay text', (tester) async {
      await pumpTideline(tester);
      for (final label in ['Callsign', 'Locator']) {
        final field = tester.widget<TextField>(
          find.widgetWithText(TextField, label),
        );
        expect(field.keyboardType, TextInputType.text);
      }
    });
  });
}
