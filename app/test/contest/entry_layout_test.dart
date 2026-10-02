import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
