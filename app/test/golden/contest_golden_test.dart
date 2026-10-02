@Tags(['golden'])
library;

// Tests favour readable steps over cascades and tear-offs.
// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../contest/contest_harness.dart';
import '../support/contest_fakes.dart';
import '../support/pump_app.dart';

void main() {
  const sizes = {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
  };

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets('contest entry, $sizeName', (tester) async {
      final backend = ContestBackend(
        scp: ScpDatabase.parse('DL1ABC\nDL1ABD\nDL1ABE\n'),
      );
      backend.startSession('cq-wpx-ssb', usesSerial: true);
      seedSessionQsos(backend, 5);
      await pumpContest(tester, size: size, backend: backend);
      // A call being worked: dupe, country and suggestions are visible.
      await typeCall(tester, 'DL1ABC');
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/contest_$sizeName.png'),
      );
    });
  }
}
