import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/widgets/app_lock.dart';

import '../support/pump_app.dart';

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('settings offer account, data and security sections', (
    tester,
  ) async {
    await pumpTideline(tester, size: TestSizes.tabletPortrait);
    await openSettings(tester);
    expect(find.text('Wavelog account'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Enter a new token'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Create encrypted backup'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Import ADIF file'), findsOneWidget);
    expect(find.text('Export log as ADIF'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('App lock'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('App lock'), findsOneWidget);
  });

  testWidgets('settings meet accessibility guidelines at 200 % text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTideline(tester, textScale: 2);
    await openSettings(tester);
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('the app lock covers the app until unlocked', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpTideline(
      tester,
      settingsValues: const {appLockSetting: 'on'},
      log: sampleLog(2),
    );
    expect(find.text('Tideline is locked'), findsOneWidget);
    expect(find.text('Unlock'), findsOneWidget);
    // The log underneath is hidden from screen readers.
    expect(find.bySemanticsLabel(RegExp('D L 1 A B C')), findsNothing);
    handle.dispose();
  });

  testWidgets('without the app lock there is no lock screen', (tester) async {
    await pumpTideline(tester);
    expect(find.text('Tideline is locked'), findsNothing);
  });
}
