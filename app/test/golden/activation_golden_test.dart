@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

const _acadia = ProgramReference(
  program: ReferenceProgram.pota,
  reference: 'US-0001',
  name: 'Acadia National Park',
  region: 'US-ME',
  latitude: 44.31,
  longitude: -68.2034,
);
const _alagnak = ProgramReference(
  program: ReferenceProgram.pota,
  reference: 'US-0002',
  name: 'Alagnak Wild River',
  region: 'US-AK',
  latitude: 59.09,
  longitude: -156.46,
);
const _wwff = ProgramReference(
  program: ReferenceProgram.wwff,
  reference: 'DLFF-0001',
  name: 'Nationalpark Bayerischer Wald',
  latitude: 48.9,
  longitude: 13.4,
);

const _home = StationProfile(
  id: 'st-1',
  accountId: 'acc-1',
  remoteId: 3,
  name: 'Home QTH',
  callsign: 'DO1HOZ',
  active: true,
  gridsquare: 'JO40',
);
const _park = StationProfile(
  id: 'st-2',
  accountId: 'acc-1',
  remoteId: 4,
  name: 'Acadia',
  callsign: 'DO1HOZ',
  active: false,
  references: StationReferences(pota: 'US-0001'),
);

const _running = Activation(
  id: 'act-1',
  accountId: 'acc-1',
  program: ReferenceProgram.pota,
  reference: 'US-0001',
  startedAt: 1000,
  myGridsquare: 'FN54vh',
  stationProfileId: 'st-2',
);

ActivationProgress _progress(int n) => ActivationProgress.evaluate(
  ActivationRules.defaultFor(ReferenceProgram.pota),
  [
    for (var i = 0; i < n; i++)
      ActivationQso(
        time: UtcDateTime(DateTime.utc(2026, 10, 3, 10, i)),
        call: 'DL${i}ABC',
        band: '20m',
        mode: 'SSB',
      ),
  ],
);

void main() {
  const sizes = {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
  };
  final store = FakeReferencePackStore(references: [_acadia, _alagnak, _wwff]);

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('activation setup, $name', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        referencePacks: store,
        stations: [_home, _park],
      );
      await tester.tap(find.byTooltip('Start an activation'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Park reference'),
        'acadia',
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/activation_setup_$name.png'),
      );
    });

    testWidgets('log with a running activation, $name', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        activation: _running,
        activationProgress: _progress(7),
        referencePacks: store,
        stations: [_home, _park],
        log: sampleLog(4),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/activation_log_$name.png'),
      );
    });
  }

  for (final MapEntry(key: name, value: size) in {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
  }.entries) {
    testWidgets('reference lists in settings, $name', (tester) async {
      await pumpTideline(tester, size: size, referencePacks: store);
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Parks on the Air (POTA)'),
        200,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .last,
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/packs_$name.png'),
      );
    });
  }
}
