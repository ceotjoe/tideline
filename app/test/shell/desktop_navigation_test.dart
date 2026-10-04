import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/commands/command.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/layout/adaptive_shell.dart';

import '../support/pump_app.dart';

void _platform(TargetPlatform p) => debugDefaultTargetPlatformOverride = p;

/// A widget test that always puts the platform back: Flutter checks the
/// override before tear-down callbacks run.
void _tw(String name, Future<void> Function(WidgetTester) body) =>
    testWidgets(name, (tester) async {
      try {
        await body(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

Future<void> _openAppearance(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Appearance and language'));
  await tester.pumpAndSettle();
}

void main() {
  group('navigation follows the input environment', () {
    for (final platform in [
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      _tw('${platform.name}: a narrow window still has a sidebar, '
          'no bottom bar', (tester) async {
        _platform(platform);
        await pumpTideline(tester);
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      });
    }

    _tw('touch platforms keep the bottom bar on a phone', (tester) async {
      _platform(TargetPlatform.android);
      await pumpTideline(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    _tw('the sidebar names its places from 1100 dp on desktop only', (
      tester,
    ) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester, size: const Size(1100, 800));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
    });

    _tw('a tablet at 1100 dp keeps the compact rail', (tester) async {
      _platform(TargetPlatform.android);
      await pumpTideline(tester, size: const Size(1100, 800));
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isFalse,
      );
      expect(desktopExtendedRailMinWidth, lessThan(extendedRailMinWidth));
    });
  });

  group('menu bar', () {
    _tw('Windows: menus in the window, commands from the registry', (
      tester,
    ) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester, size: const Size(1000, 800));
      expect(find.byType(MenuBar), findsOneWidget);
      for (final menu in ['Go', 'Operate', 'Help']) {
        expect(find.widgetWithText(SubmenuButton, menu), findsOneWidget);
      }
      await tester.tap(find.widgetWithText(SubmenuButton, 'Go'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(MenuItemButton, 'Go to log'), findsOneWidget);
      expect(find.text('Ctrl+1'), findsOneWidget);
      expect(
        find.widgetWithText(MenuItemButton, 'Open settings'),
        findsOneWidget,
      );
    });

    _tw('Windows: choosing a menu item runs the command', (tester) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester, size: const Size(1000, 800));
      await tester.tap(find.widgetWithText(SubmenuButton, 'Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Open settings'));
      await tester.pumpAndSettle();
      expect(find.text('Appearance and language'), findsOneWidget);
    });

    _tw('Windows: Go back is disabled where there is no page to leave', (
      tester,
    ) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester, size: const Size(1000, 800));
      await tester.tap(find.widgetWithText(SubmenuButton, 'Go'));
      await tester.pumpAndSettle();
      final back = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Go back'),
      );
      expect(back.onPressed, isNull);
    });

    _tw('macOS: the menus go to the system, none in the window', (
      tester,
    ) async {
      _platform(TargetPlatform.macOS);
      await pumpTideline(tester, size: const Size(1000, 800));
      expect(find.byType(MenuBar), findsNothing);
      expect(find.byType(PlatformMenuBar), findsOneWidget);
      final sent = menuCalls.map((c) => '${c.arguments}').join();
      for (final label in ['Tideline', 'Go', 'Operate', 'Help', 'Window']) {
        expect(sent, contains(label), reason: label);
      }
      expect(sent, contains('Go to log'));
    });

    _tw('touch platforms have no menu bar', (tester) async {
      _platform(TargetPlatform.android);
      await pumpTideline(tester, size: const Size(1000, 800));
      expect(find.byType(MenuBar), findsNothing);
      expect(find.byType(PlatformMenuBar), findsNothing);
    });
  });

  group('going back', () {
    _tw('Esc leaves a settings page', (tester) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester);
      await _openAppearance(tester);
      expect(find.text('Theme'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Theme'), findsNothing);
      expect(find.text('Appearance and language'), findsOneWidget);
    });

    _tw('Alt+Left leaves a settings page', (tester) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester);
      await _openAppearance(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();
      expect(find.text('Theme'), findsNothing);
    });

    _tw('⌘[ leaves a settings page on macOS', (tester) async {
      _platform(TargetPlatform.macOS);
      await pumpTideline(tester);
      await _openAppearance(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pumpAndSettle();
      expect(find.text('Theme'), findsNothing);
    });

    _tw('Esc at the top of a tab does nothing and does not fail', (
      tester,
    ) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Log QSO'), findsOneWidget);
    });

    _tw('on the log screen Esc still clears the entry', (tester) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(tester);
      await tester.enterText(find.byType(TextField).first, 'DL1ABC');
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        isEmpty,
      );
    });
  });

  group('command registry', () {
    test('Esc: the own command of a screen comes first, Go back last', () {
      final map = CommandRegistry(tidelineCommands)
          .shortcutMap(ShortcutPlatform.other);
      final escape =
          map.entries
                  .firstWhere(
                    (e) =>
                        e.key is SingleActivator &&
                        (e.key as SingleActivator).trigger ==
                            LogicalKeyboardKey.escape,
                  )
                  .value
              as CommandIntent;
      final ids = escape.candidates.toList();
      expect(ids.last, CommandIds.goBack);
      expect(ids, containsAll([CommandIds.clearEntry, CommandIds.contestWipe]));
    });

    test('a fallback is not reported as a conflict', () {
      expect(CommandRegistry(tidelineCommands).conflicts(), isEmpty);
    });
  });

  group('log list context menu', () {
    _tw('a right click offers Open QSO and Copy callsign', (tester) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(
        tester,
        size: const Size(1000, 800),
        log: sampleLog(3),
      );
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      final row = find.text('G4XYZ').first;
      await tester.tap(row, buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();
      expect(find.text('Open QSO'), findsOneWidget);
      await tester.tap(find.text('Copy callsign'));
      await tester.pumpAndSettle();
      expect(copied, ['G4XYZ']);
      expect(find.text('Copied G4XYZ'), findsOneWidget);
    });

    _tw('Open QSO from the menu opens the details', (tester) async {
      _platform(TargetPlatform.windows);
      await pumpTideline(
        tester,
        size: const Size(1000, 800),
        log: sampleLog(3),
      );
      await tester.tap(
        find.text('G4XYZ').first,
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open QSO'));
      await tester.pumpAndSettle();
      expect(find.text('G4XYZ'), findsWidgets);
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}
