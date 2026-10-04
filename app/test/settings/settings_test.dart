import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/app.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline/src/widgets/app_lock.dart';

import '../support/pump_app.dart';

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
}

void main() {
  Future<void> openPage(WidgetTester tester, String title) async {
    await tester.scrollUntilVisible(
      find.text(title),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  testWidgets('the hub lists the groups', (tester) async {
    await pumpTideline(tester, size: TestSizes.tabletPortrait);
    await openSettings(tester);
    for (final title in [
      'Wavelog accounts',
      'Appearance and language',
      'Reference data',
      'Security and backup',
      'Keyboard shortcuts',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    // The settings themselves are on the pages, not on the hub.
    expect(find.text('Enter a new token'), findsNothing);
    expect(find.text('App lock'), findsNothing);
  });

  testWidgets('the account page has the token actions and a way back', (
    tester,
  ) async {
    await pumpTideline(tester, size: TestSizes.tabletPortrait);
    await openSettings(tester);
    await openPage(tester, 'Wavelog accounts');
    await openPage(tester, 'Home');
    expect(find.text('Enter a new token'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Appearance and language'), findsOneWidget);
  });

  testWidgets('the settings tab returns to the hub from a page', (
    tester,
  ) async {
    await pumpTideline(tester, size: TestSizes.tabletPortrait);
    await openSettings(tester);
    await openPage(tester, 'Security and backup');
    expect(find.text('App lock'), findsOneWidget);
    await openSettings(tester);
    expect(find.text('Security and backup'), findsOneWidget);
    expect(find.text('App lock'), findsNothing);
  });

  testWidgets('security and backup holds the lock, import, export, backup', (
    tester,
  ) async {
    await pumpTideline(tester, size: TestSizes.tabletPortrait);
    await openSettings(tester);
    await openPage(tester, 'Security and backup');
    expect(find.text('App lock'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Create encrypted backup'),
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .last,
    );
    expect(find.text('Import ADIF file'), findsOneWidget);
    expect(find.text('Export log as ADIF'), findsOneWidget);
  });

  testWidgets('every settings page meets guidelines at 200 % text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpTideline(tester, textScale: 2);
    await openSettings(tester);
    for (final page in [
      null,
      'Wavelog accounts',
      'Appearance and language',
      'Reference data',
      'Security and backup',
    ]) {
      if (page != null) await openPage(tester, page);
      expect(tester.takeException(), isNull, reason: '$page');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      if (page != null) {
        expect(find.byType(BackButton), findsOneWidget, reason: page);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    }
    handle.dispose();
  });

  testWidgets('the appearance page changes the theme', (tester) async {
    final app = await pumpTideline(tester);
    await openSettings(tester);
    await openPage(tester, 'Appearance and language');
    expect(find.text('Theme'), findsOneWidget);
    await tester.tap(find.text('Sunlight (maximum contrast)'));
    await tester.pumpAndSettle();
    expect(app.settings.saved.single.theme, ThemeChoice.sunlight);
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

  testWidgets('the reading font changes the whole theme', (tester) async {
    await pumpTideline(tester, settings: const AppSettings(readingFont: true));
    final theme = Theme.of(tester.element(find.text('Log QSO')));
    expect(theme.textTheme.bodyLarge?.fontFamily, readingFontFamily);
  });
}
