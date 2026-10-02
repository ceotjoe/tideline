import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline/src/widgets/tide_gauge.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

Future<void> expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  group('adaptive navigation', () {
    testWidgets('phone uses a bottom navigation bar', (tester) async {
      await pumpTideline(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    for (final size in [
      TestSizes.tabletPortrait,
      TestSizes.tabletLandscape,
      TestSizes.desktop,
    ]) {
      testWidgets('${size.width.toInt()} wide uses a navigation rail', (
        tester,
      ) async {
        await pumpTideline(tester, size: size);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      });
    }

    testWidgets('resizing keeps the selected section', (tester) async {
      await pumpTideline(tester);
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      tester.view.physicalSize =
          TestSizes.tabletLandscape * tester.view.devicePixelRatio;
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
    });
  });

  group('accessibility', () {
    for (final theme in ThemeChoice.values) {
      for (final size in [TestSizes.phone, TestSizes.tabletLandscape]) {
        testWidgets('${theme.name} at ${size.width.toInt()} meets guidelines', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await pumpTideline(
            tester,
            size: size,
            settings: AppSettings(theme: theme),
            pending: 12,
          );
          await expectAccessible(tester);
          handle.dispose();
        });
      }
    }

    testWidgets('glove mode enlarges touch targets to 64 dp', (tester) async {
      await pumpTideline(
        tester,
        settings: const AppSettings(density: TidelineDensity.glove),
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      final tile = tester.getSize(
        find.byType(RadioListTile<ThemeChoice>).first,
      );
      expect(tile.height, greaterThanOrEqualTo(48));
      final navBar = tester.getSize(find.byType(NavigationBar));
      expect(navBar.height, greaterThanOrEqualTo(64));
    });

    for (final size in [TestSizes.phone, TestSizes.tabletPortrait]) {
      testWidgets('200 % text at ${size.width.toInt()} has no overflow', (
        tester,
      ) async {
        await pumpTideline(tester, size: size, textScale: 2, pending: 120);
        for (final label in ['Log', 'Sync', 'Settings']) {
          await tester.tap(find.text(label).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: label);
        }
      });
    }

    testWidgets('tide gauge announces the count as text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTideline(tester, pending: 3);
      expect(find.bySemanticsLabel('3 QSOs waiting to sync'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('tide gauge does not animate with reduced motion', (
      tester,
    ) async {
      await pumpTideline(tester, pending: 5);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('localisation', () {
    testWidgets('German UI', (tester) async {
      await pumpTideline(
        tester,
        settings: const AppSettings(localeOverride: Locale('de')),
        pending: 2,
      );
      expect(find.text('Einstellungen'), findsOneWidget);
      expect(find.text('2 QSOs warten auf Synchronisierung'), findsOneWidget);
    });

    testWidgets('pseudo-locale shows only localised text and no overflow', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        settings: const AppSettings(localeOverride: Locale('en', 'XA')),
        pending: 7,
      );
      // Every visible label comes from the pseudo-locale (bracketed).
      // Data is never translated: band and mode names, callsigns, station
      // names from the server.
      final data = {
        for (final b in Band.all) b.name,
        for (final m in Mode.common) m.label,
      };
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
          .where((s) => RegExp('[A-Za-z]').hasMatch(s))
          .where((s) => !data.contains(s) && !s.contains(testStation.name));
      for (final text in texts) {
        expect(text, contains('['), reason: 'Not localised: "$text"');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('forced right-to-left mirrors the layout', (tester) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletLandscape,
        settings: const AppSettings(
          localeOverride: Locale('en', 'XA'),
          forceRtl: true,
        ),
      );
      final rail = tester.getRect(find.byType(NavigationRail));
      expect(rail.left, greaterThan(TestSizes.tabletLandscape.width / 2));
      expect(tester.takeException(), isNull);
    });
  });

  group('keyboard', () {
    testWidgets('Ctrl+/ opens the shortcut overview', (tester) async {
      await pumpTideline(tester, size: TestSizes.desktop);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('Keyboard shortcuts'), findsOneWidget);
      expect(find.text('Ctrl+/ or F1'), findsOneWidget);
    });

    testWidgets('⌘2 switches to sync on Apple platforms', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await pumpTideline(tester, size: TestSizes.desktop);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();
      expect(find.text('Nothing to sync'), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  test('tide level rises with the queue and is zero when synced', () {
    expect(TideGauge.levelFor(0), 0);
    expect(TideGauge.levelFor(1), greaterThan(0));
    expect(TideGauge.levelFor(10), greaterThan(TideGauge.levelFor(1)));
    expect(TideGauge.levelFor(100000), 1);
  });
}
