import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tideline/src/features/contest/exchange_field.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';
import 'contest_harness.dart';

void main() {
  const sizes = {
    'tablet landscape': TestSizes.tabletLandscape,
    'desktop': TestSizes.desktop,
    'phone': TestSizes.phone,
  };

  for (final scale in [1.0, 2.0]) {
    for (final MapEntry(key: name, value: size) in sizes.entries) {
      testWidgets('Log is fully visible: $name at ${scale * 100}% text', (
        tester,
      ) async {
        await pumpContest(
          tester,
          size: size,
          textScale: scale,
          backend: ContestBackend(),
        );
        final log = find.widgetWithText(FilledButton, 'Log QSO');
        expect(log, findsOneWidget);
        // The phone page scrolls, the wide layouts pin the action row: on
        // the wide layouts Log must be on screen without scrolling.
        if (size.width > 600) {
          final rect = tester.getRect(log);
          expect(rect.top, greaterThanOrEqualTo(0));
          expect(rect.bottom, lessThanOrEqualTo(size.height));
          expect(log.hitTestable(), findsOneWidget);
          // Not inside any scrollable, so no scroll position can clip it.
          expect(
            find.ancestor(of: log, matching: find.byType(Scrollable)),
            findsNothing,
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  group('with the keyboard up in landscape', () {
    const keyboard = 400.0;

    for (final (size, scale) in [
      (TestSizes.tabletLandscape, 1.0),
      (TestSizes.tabletLandscapeWide, 1.0),
      (const Size(1366, 1024), 1.0),
      (TestSizes.tabletLandscapeWide, 1.3),
    ]) {
      testWidgets(
        'entry, hints and buttons stay above it at $size, ${scale}x',
        (tester) async {
          await pumpContest(
            tester,
            size: size,
            textScale: scale,
            backend: ContestBackend(),
          );
          tester.view.viewInsets = FakeViewPadding(
            bottom: keyboard * tester.view.devicePixelRatio,
          );
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();
          await typeCall(tester, 'DL1ABC');
          await tester.pumpAndSettle();

          final visibleBottom = size.height - keyboard;
          final targets = <String, Finder>{
            'Callsign': find.text('Callsign'),
            'Band': find.text('Band'),
            'Mode': find.text('Mode'),
            'Frequency': find.text('Frequency'),
            'Log': find.text('Log QSO'),
            'Edit last': find.text('Edit last QSO'),
            'Exchange': find.byType(ExchangeField),
          };
          for (final MapEntry(:key, :value) in targets.entries) {
            expect(value, findsWidgets, reason: key);
            for (final element in value.evaluate()) {
              final rect = tester.getRect(find.byWidget(element.widget).first);
              expect(rect.top, greaterThanOrEqualTo(0), reason: key);
              expect(
                rect.bottom,
                lessThanOrEqualTo(visibleBottom),
                reason: key,
              );
            }
          }
          // The dupe/multiplier/country hints are shown too.
          expect(find.textContaining('Germany'), findsWidgets);
          expect(
            find.ancestor(
              of: find.widgetWithText(FilledButton, 'Log QSO'),
              matching: find.byType(Scrollable),
            ),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  group('with the keyboard up in portrait', () {
    const keyboard = 360.0;

    for (final (size, scale) in [
      (TestSizes.tabletPortrait, 1.0),
      (const Size(834, 1210), 1.0),
      (const Size(1024, 1366), 1.0),
      (const Size(834, 1210), 1.5),
    ]) {
      testWidgets('entry, hints and Log stay above it at $size, ${scale}x', (
        tester,
      ) async {
        await pumpContest(
          tester,
          size: size,
          textScale: scale,
          backend: ContestBackend(),
        );
        tester.view.viewInsets = FakeViewPadding(
          bottom: keyboard * tester.view.devicePixelRatio,
        );
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await typeCall(tester, 'DL1ABC');
        await tester.pumpAndSettle();

        final visibleBottom = size.height - keyboard;
        for (final label in ['Callsign', 'Band', 'Mode', 'Log QSO']) {
          final finder = find.text(label);
          expect(finder, findsWidgets, reason: label);
          final rect = tester.getRect(finder.first);
          expect(rect.top, greaterThanOrEqualTo(0), reason: label);
          expect(
            rect.bottom,
            lessThanOrEqualTo(visibleBottom),
            reason: '$label at $rect',
          );
        }
        for (final element in find.byType(ExchangeField).evaluate()) {
          final rect = tester.getRect(find.byWidget(element.widget));
          expect(rect.bottom, lessThanOrEqualTo(visibleBottom));
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
