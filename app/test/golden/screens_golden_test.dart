@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/settings/app_settings.dart';

import '../support/pump_app.dart';

void main() {
  const sizes = {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
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
  }
}
