import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/services/screen_wake.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline/src/widgets/tide_gauge.dart';

import '../support/pump_app.dart';

void main() {
  group('AppSettings field mode', () {
    test('is on only when all four parts are on', () {
      const on = AppSettings(
        theme: ThemeChoice.sunlight,
        density: TidelineDensity.glove,
        batterySaver: true,
        keepScreenOn: true,
      );
      expect(on.fieldMode, isTrue);
      expect(on.copyWith(batterySaver: false).fieldMode, isFalse);
      expect(on.copyWith(theme: ThemeChoice.dark).fieldMode, isFalse);
      expect(const AppSettings().fieldMode, isFalse);
    });

    test('switching on and off brings the theme and density back', () {
      const before = AppSettings(theme: ThemeChoice.dark, readingFont: true);
      final on = before.withFieldMode(on: true);
      expect(on.fieldMode, isTrue);
      expect(on.readingFont, isTrue, reason: 'other settings stay');
      // What the database holds is enough to come back, also after a restart.
      final stored = {
        for (final e in on.toStore().entries)
          if (e.value != null) e.key: e.value!,
      };
      final off = AppSettings.fromStore(stored).withFieldMode(on: false);
      expect(off.theme, ThemeChoice.dark);
      expect(off.density, TidelineDensity.comfortable);
      expect(off.batterySaver, isFalse);
      expect(off.keepScreenOn, isFalse);
      expect(off.fieldMode, isFalse);
    });

    test('with nothing to come back to the defaults stand in', () {
      const sunny = AppSettings(
        theme: ThemeChoice.sunlight,
        density: TidelineDensity.glove,
      );
      final off = sunny.withFieldMode(on: true).withFieldMode(on: false);
      expect(off.theme, ThemeChoice.system);
      expect(off.density, TidelineDensity.comfortable);
      expect(
        const AppSettings().withFieldMode(on: false).theme,
        ThemeChoice.system,
      );
    });

    test('a damaged restore value is ignored', () {
      final s = AppSettings.fromStore(const {
        'ui.fieldModeRestore': 'nonsense|also',
      });
      expect(s.fieldModeRestore, isNull);
      expect(s.withFieldMode(on: false).theme, ThemeChoice.system);
    });
  });

  group('ScreenWake', () {
    test('holds the lock until the last screen lets go', () async {
      final calls = <bool>[];
      final wake = ScreenWake(apply: ({required on}) async => calls.add(on));
      await wake.acquire();
      await wake.acquire();
      expect(calls, [true]);
      await wake.release();
      expect(calls, [true]);
      await wake.release();
      expect(calls, [true, false]);
      await wake.release();
      expect(wake.holders, 0, reason: 'never below zero');
    });

    test('a platform without the feature does not break logging', () async {
      final wake = ScreenWake(
        apply: ({required on}) async => throw StateError('no plugin'),
      );
      await wake.acquire();
      await wake.release();
    });
  });

  group('the page', () {
    Future<void> openPage(WidgetTester tester) async {
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Field mode'));
      await tester.pumpAndSettle();
    }

    testWidgets('the switch saves all four parts', (tester) async {
      final app = await pumpTideline(tester, size: TestSizes.tabletPortrait);
      await openPage(tester);
      await tester.tap(find.widgetWithText(SwitchListTile, 'Field mode'));
      await tester.pumpAndSettle();
      expect(app.settings.saved.single.fieldMode, isTrue);
    });

    testWidgets('a single part saves on its own', (tester) async {
      final app = await pumpTideline(tester, size: TestSizes.tabletPortrait);
      await openPage(tester);
      await tester.tap(find.text('Battery saver'));
      await tester.pumpAndSettle();
      final saved = app.settings.saved.single;
      expect(saved.batterySaver, isTrue);
      expect(saved.keepScreenOn, isFalse);
      expect(saved.fieldMode, isFalse);
    });

    testWidgets('the switch shows the state of the parts', (tester) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        settings: const AppSettings().withFieldMode(on: true),
      );
      await openPage(tester);
      final tile = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Field mode'),
      );
      expect(tile.value, isTrue);
    });
  });

  group('while it is on', () {
    testWidgets('the log keeps the screen on and lets go on leaving', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        settings: const AppSettings(keepScreenOn: true),
      );
      expect(wakeCalls, [true]);
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(wakeCalls, [true], reason: 'the log stays mounted in its tab');
    });

    testWidgets('the screen is left alone when the setting is off', (
      tester,
    ) async {
      await pumpTideline(tester);
      expect(wakeCalls, isEmpty);
    });

    testWidgets('the tide gauge stands still when it may not animate', (
      tester,
    ) async {
      Future<void> pumpGauge({required bool animate}) => tester.pumpWidget(
        MaterialApp(
          theme: buildTidelineTheme(variant: TidelineThemeVariant.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TideGauge(pendingCount: 3, animate: animate),
        ),
      );

      await pumpGauge(animate: true);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.hasScheduledFrame, isTrue, reason: 'moving');
      await pumpGauge(animate: false);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.hasScheduledFrame, isFalse, reason: 'still');
      expect(find.text('3 QSOs waiting to sync'), findsOneWidget);
    });
  });
}
