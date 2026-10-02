import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/log/qso_tile.dart';

import '../support/pump_app.dart';

// The tablet layouts pick their columns from the width the body really has.
// A wide navigation rail plus fixed columns once left the QSO list ~130 dp
// at 1210 dp (iPad Pro 11" in landscape): the rows failed to lay out and the
// whole log body stayed empty. Every width from tablet portrait to desktop
// must lay out cleanly, keep the list readable and the Log button in view.
void main() {
  const widths = <double>[
    840,
    900,
    1000,
    1100,
    1180,
    1210,
    1280,
    1376,
    1440,
    1600,
  ];

  for (final width in widths) {
    testWidgets('log screen at $width dp lays out cleanly', (tester) async {
      await pumpTideline(tester, size: Size(width, 834), log: sampleLog(6));
      expect(tester.takeException(), isNull);

      final tile = tester.getSize(find.byType(QsoTile).first);
      expect(tile.width, greaterThanOrEqualTo(300), reason: 'list too narrow');

      // The Log button stays on screen without scrolling.
      final log = tester.getRect(find.text('Log QSO'));
      expect(log.bottom, lessThanOrEqualTo(834));
      expect(log.top, greaterThanOrEqualTo(0));
    });
  }
}
