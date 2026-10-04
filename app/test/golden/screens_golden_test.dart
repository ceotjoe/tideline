@Tags(['golden'])
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart' show Account;

import '../support/pump_app.dart';

void main() {
  const sizes = {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
    'tablet_landscape_wide': TestSizes.tabletLandscapeWide,
  };

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets('log screen, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        log: sampleLog(6),
        pending: 4,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/log_$sizeName.png'),
      );
    });

    testWidgets('settings, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_$sizeName.png'),
      );
    });

    testWidgets('settings appearance page, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appearance and language'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_appearance_$sizeName.png'),
      );
    });
  }

  testWidgets('log screen, tablet landscape with the keyboard up', (
    tester,
  ) async {
    await pumpTideline(
      tester,
      size: TestSizes.tabletLandscapeWide,
      settings: const AppSettings(theme: ThemeChoice.light),
      log: sampleLog(6),
      pending: 4,
    );
    tester.view.viewInsets = FakeViewPadding(
      bottom: 400 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/log_tablet_landscape_keyboard.png'),
    );
  });

  testWidgets('log screen, phone with the keyboard up', (tester) async {
    await pumpTideline(
      tester,
      settings: const AppSettings(theme: ThemeChoice.light),
      log: sampleLog(6),
      pending: 4,
    );
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/log_phone_keyboard.png'),
    );
  });

  const club = Account(
    id: 'acc-2',
    label: 'Club station',
    baseUrl: 'https://club.example.org',
    usesIndexPhp: true,
    allowHttpLan: false,
    scopes: {'qso:write'},
    hasContestSessions: false,
  );

  testWidgets('log screen with two accounts, phone', (tester) async {
    await pumpTideline(
      tester,
      settings: const AppSettings(theme: ThemeChoice.light),
      accounts: const [testAccount, club],
      log: sampleLog(3),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/log_phone_two_accounts.png'),
    );
  });

  for (final MapEntry(key: sizeName, value: size) in {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
  }.entries) {
    testWidgets('accounts page, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        accounts: const [testAccount, club],
        pendingByAccount: const {'acc-1': 2, 'acc-2': 5},
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wavelog accounts'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/accounts_$sizeName.png'),
      );
    });
  }

  for (final (name, platform, size) in [
    ('windows', TargetPlatform.windows, TestSizes.desktop),
    ('macos', TargetPlatform.macOS, TestSizes.desktop),
    ('windows_narrow', TargetPlatform.windows, TestSizes.phone),
  ]) {
    testWidgets('log screen on a desktop, $name', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await pumpTideline(
          tester,
          size: size,
          settings: const AppSettings(theme: ThemeChoice.light),
          log: sampleLog(6),
          pending: 4,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/log_desktop_$name.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}
