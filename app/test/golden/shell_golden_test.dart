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
  const themes = [ThemeChoice.light, ThemeChoice.dark, ThemeChoice.nightRed];

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    for (final theme in themes) {
      testWidgets('sync screen, $sizeName, ${theme.name}', (tester) async {
        await pumpTideline(
          tester,
          size: size,
          settings: AppSettings(theme: theme),
          pending: 12,
        );
        await tester.tap(find.text('Sync').last);
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/sync_${sizeName}_${theme.name}.png'),
        );
      });
    }
  }
}
