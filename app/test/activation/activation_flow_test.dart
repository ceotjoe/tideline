import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

Finder field(String label) => find.widgetWithText(TextField, label);

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
const _scafell = ProgramReference(
  program: ReferenceProgram.sota,
  reference: 'G/LD-001',
  name: 'Scafell Pike',
  latitude: 54.45,
  longitude: -3.21,
);

const _homeStation = StationProfile(
  id: 'st-1',
  accountId: 'acc-1',
  remoteId: 3,
  name: 'Home QTH',
  callsign: 'DO1HOZ',
  active: true,
  gridsquare: 'JO40',
);
const _parkStation = StationProfile(
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
  stationProfileId: 'st-1',
);

ActivationProgress progressOf(int n, {int dupes = 0}) =>
    ActivationProgress.evaluate(
      ActivationRules.defaultFor(ReferenceProgram.pota),
      [
        for (var i = 0; i < n; i++)
          ActivationQso(
            time: UtcDateTime(DateTime.utc(2026, 10, 3, 10, i)),
            call: 'DL${i}ABC',
            band: '20m',
            mode: 'SSB',
          ),
        for (var i = 0; i < dupes; i++)
          ActivationQso(
            time: UtcDateTime(DateTime.utc(2026, 10, 3, 11, i)),
            call: 'DL0ABC',
            band: '20m',
            mode: 'SSB',
          ),
      ],
    );

/// The button is below the fold on small windows.
Future<void> tapStart(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Start activation'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Start activation'));
  await tester.pumpAndSettle();
}

Future<void> openSetup(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Start an activation'));
  await tester.pumpAndSettle();
}

void main() {
  group('banner', () {
    testWidgets('nothing shows without an activation', (tester) async {
      await pumpTideline(tester, size: TestSizes.tabletPortrait);
      expect(find.text('End activation'), findsNothing);
      expect(find.byTooltip('Start an activation'), findsOneWidget);
    });

    testWidgets('shows the reference, its name and the progress in words', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        activation: _running,
        activationProgress: progressOf(3, dupes: 1),
        referencePacks: FakeReferencePackStore(references: [_acadia]),
      );
      expect(find.text('POTA US-0001 · Acadia National Park'), findsOneWidget);
      expect(find.text('3 of 10 QSOs · 7 to go'), findsOneWidget);
      expect(find.text('Counted per UTC day.'), findsOneWidget);
      expect(
        find.text('1 QSO not counted (same call, band and mode).'),
        findsOneWidget,
      );
    });

    testWidgets('a valid activation says so with an icon and text', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        activation: _running,
        activationProgress: progressOf(12),
      );
      expect(find.text('Valid activation: 12 QSOs (needs 10)'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      // Without a list the name is simply missing.
      expect(find.text('POTA US-0001'), findsOneWidget);
    });

    testWidgets('End asks first, then ends the activation', (tester) async {
      final repo = FakeActivationRepository();
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        activation: _running,
        activationProgress: progressOf(2),
        activations: repo,
      );
      await tester.tap(find.text('End activation'));
      await tester.pumpAndSettle();
      expect(find.text('End US-0001?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.ended, isEmpty);

      await tester.tap(find.text('End activation'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('End activation'),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.ended.single.id, 'act-1');
      expect(find.text('Activation ended.'), findsOneWidget);
    });

    testWidgets('the end shortcut works while an activation runs', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: TestSizes.desktop,
        activation: _running,
        activationProgress: progressOf(2),
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('End US-0001?'), findsOneWidget);
    });
  });

  group('setup', () {
    testWidgets('without a list the reference can still be typed', (
      tester,
    ) async {
      final repo = FakeActivationRepository();
      await pumpTideline(tester, activations: repo);
      await openSetup(tester);
      expect(find.text('Start an activation'), findsWidgets);
      expect(find.textContaining('No POTA list is installed'), findsOneWidget);
      expect(find.text('Open settings'), findsOneWidget);

      await tester.enterText(field('Park reference'), 'us-0001');
      await tester.pump();
      await tapStart(tester);

      final a = repo.started.single;
      expect(a.program, ReferenceProgram.pota);
      expect(a.reference, 'US-0001');
      expect(a.stationProfileId, 'st-1');
      // The Wavelog location's grid is the fallback.
      expect(a.myGridsquare, 'JO40');
      // Back on the log screen.
      expect(find.text('Start activation'), findsNothing);
      expect(field('Callsign'), findsOneWidget);
    });

    testWidgets('an invalid reference is explained and nothing starts', (
      tester,
    ) async {
      final repo = FakeActivationRepository();
      await pumpTideline(tester, activations: repo);
      await openSetup(tester);
      await tester.enterText(field('Park reference'), 'hello');
      await tapStart(tester);
      expect(
        find.text('This is not a POTA reference. Example: US-0001'),
        findsOneWidget,
      );
      expect(repo.started, isEmpty);
    });

    testWidgets('searching offers matches; picking one fills the form', (
      tester,
    ) async {
      final repo = FakeActivationRepository();
      await pumpTideline(
        tester,
        activations: repo,
        referencePacks: FakeReferencePackStore(
          references: [_acadia, _alagnak, _scafell],
        ),
      );
      await openSetup(tester);
      expect(find.textContaining('No POTA list'), findsNothing);

      await tester.enterText(field('Park reference'), 'acadia');
      await tester.pumpAndSettle();
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Acadia National Park'), findsOneWidget);
      expect(find.text('Alagnak Wild River'), findsNothing);

      await tester.tap(find.text('Acadia National Park'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(field('Park reference')).controller!.text,
        'US-0001',
      );
      expect(
        find.text('In your POTA list: Acadia National Park (US-ME)'),
        findsOneWidget,
      );
      // The grid comes from the position of the park.
      expect(
        find.text('Taken from the position of the reference.'),
        findsOneWidget,
      );
      expect(find.text('Matches'), findsNothing);

      await tapStart(tester);
      expect(
        repo.started.single.myGridsquare,
        Maidenhead.fromLatLon(44.31, -68.2034),
      );
    });

    testWidgets('the nearest references to the grid are listed', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        referencePacks: FakeReferencePackStore(references: [_acadia, _alagnak]),
        stations: [
          const StationProfile(
            id: 'st-1',
            accountId: 'acc-1',
            remoteId: 3,
            name: 'Home QTH',
            callsign: 'DO1HOZ',
            active: true,
            gridsquare: 'FN54',
          ),
        ],
      );
      await openSetup(tester);
      expect(find.text('Nearest to FN54'), findsOneWidget);
      expect(find.text('US-0001'), findsOneWidget);
      expect(find.textContaining(' km'), findsWidgets);
      // The closer one comes first.
      expect(
        tester.getTopLeft(find.text('US-0001')).dy,
        lessThan(tester.getTopLeft(find.text('US-0002')).dy),
      );
    });

    testWidgets('a valid reference missing from the list is only a hint', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        referencePacks: FakeReferencePackStore(references: [_acadia]),
      );
      await openSetup(tester);
      await tester.enterText(field('Park reference'), 'US-0999');
      await tester.pumpAndSettle();
      expect(
        find.text('Not in your POTA list. You can still use it.'),
        findsOneWidget,
      );
    });

    testWidgets('switching the program clears a reference of another one', (
      tester,
    ) async {
      await pumpTideline(tester);
      await openSetup(tester);
      await tester.enterText(field('Park reference'), 'US-0001');
      await tester.tap(find.text('SOTA'));
      await tester.pumpAndSettle();
      expect(field('Summit reference'), findsOneWidget);
      expect(
        tester.widget<TextField>(field('Summit reference')).controller!.text,
        '',
      );
      expect(find.text('Example: G/LD-001'), findsOneWidget);
    });

    group('Wavelog location advice', () {
      testWidgets('a location without the reference: a plain warning', (
        tester,
      ) async {
        await pumpTideline(tester, stations: [_homeStation, _parkStation]);
        await openSetup(tester);
        await tester.enterText(field('Park reference'), 'DE-0123');
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.textContaining('No Wavelog location carries DE-0123'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.textContaining('ignores the one in the upload'),
          findsOneWidget,
        );
      });

      testWidgets('another location carries it: offered, and one tap uses it', (
        tester,
      ) async {
        final repo = FakeActivationRepository();
        await pumpTideline(
          tester,
          activations: repo,
          stations: [_homeStation, _parkStation],
        );
        await openSetup(tester);
        await tester.enterText(field('Park reference'), 'US-0001');
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Use this location'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.text('The Wavelog location “Acadia” carries US-0001.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Use this location'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('This Wavelog location carries US-0001'),
          findsOneWidget,
        );
        expect(find.text('Use this location'), findsNothing);

        await tapStart(tester);
        expect(repo.started.single.stationProfileId, 'st-2');
      });
    });

    testWidgets('no Wavelog location at all blocks the start', (tester) async {
      final repo = FakeActivationRepository();
      await pumpTideline(tester, activations: repo, stations: const []);
      await openSetup(tester);
      expect(find.textContaining('No Wavelog location yet'), findsOneWidget);
      await tester.enterText(field('Park reference'), 'US-0001');
      await tapStart(tester);
      expect(repo.started, isEmpty);
    });

    testWidgets('a running activation is mentioned', (tester) async {
      await pumpTideline(
        tester,
        activation: _running,
        activationProgress: progressOf(1),
      );
      await openSetup(tester);
      expect(
        find.text(
          'US-0001 is still running. Starting a new activation ends it.',
        ),
        findsOneWidget,
      );
    });

    for (final (name, size, scale) in [
      ('phone', TestSizes.phone, 1.0),
      ('phone at 200 % text', TestSizes.phone, 2.0),
      ('tablet portrait', TestSizes.tabletPortrait, 1.0),
      ('tablet landscape', TestSizes.tabletLandscape, 1.0),
    ]) {
      testWidgets('layout and accessibility: $name', (tester) async {
        await pumpTideline(
          tester,
          size: size,
          textScale: scale,
          referencePacks: FakeReferencePackStore(
            references: [_acadia, _alagnak],
          ),
          stations: [_homeStation, _parkStation],
        );
        await openSetup(tester);
        await tester.enterText(field('Park reference'), 'acadia');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        handle.dispose();
      });
    }
  });

  group('logging in an activation', () {
    testWidgets('the QSO goes through the activation with their reference', (
      tester,
    ) async {
      final repo = FakeActivationRepository();
      final app = await pumpTideline(
        tester,
        size: TestSizes.desktop,
        activation: _running,
        activationProgress: progressOf(1),
        activations: repo,
      );
      expect(field('Their park (P2P)'), findsOneWidget);
      await tester.enterText(field('Callsign'), 'k1abc');
      await tester.enterText(field('Their park (P2P)'), 'us-0002');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(app.qsos.logged, isEmpty, reason: 'not the plain path');
      final qso = repo.logged.single;
      expect(qso.call.value, 'K1ABC');
      expect(qso.activationId, 'act-1');
      expect(qso.fields['POTA_REF'], 'US-0002');
      expect(qso.fields['MY_POTA_REF'], 'US-0001');
      // Ready for the next one.
      expect(
        tester.widget<TextField>(field('Their park (P2P)')).controller!.text,
        '',
      );
    });

    testWidgets('without their reference no reference field is stored', (
      tester,
    ) async {
      final repo = FakeActivationRepository();
      await pumpTideline(
        tester,
        size: TestSizes.desktop,
        activation: _running,
        activationProgress: progressOf(1),
        activations: repo,
      );
      await tester.enterText(field('Callsign'), 'K1ABC');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(repo.logged.single.fields.containsKey('POTA_REF'), isFalse);
    });

    testWidgets('a malformed reference is explained and nothing is logged', (
      tester,
    ) async {
      final repo = FakeActivationRepository();
      await pumpTideline(
        tester,
        size: TestSizes.desktop,
        activation: _running,
        activationProgress: progressOf(1),
        activations: repo,
      );
      await tester.enterText(field('Callsign'), 'K1ABC');
      await tester.enterText(field('Their park (P2P)'), 'park');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(repo.logged, isEmpty);
      expect(find.text('This is not a valid reference.'), findsOneWidget);
    });

    testWidgets('without an activation the form is unchanged', (tester) async {
      final app = await pumpTideline(tester, size: TestSizes.desktop);
      expect(field('Their park (P2P)'), findsNothing);
      await tester.enterText(field('Callsign'), 'K1ABC');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.qsos.logged.single.activationId, isNull);
    });

    for (final (name, size) in [
      ('phone', TestSizes.phone),
      ('tablet portrait', TestSizes.tabletPortrait),
      ('tablet landscape', TestSizes.tabletLandscape),
    ]) {
      testWidgets('the extra field fits: $name', (tester) async {
        await pumpTideline(
          tester,
          size: size,
          activation: _running,
          activationProgress: progressOf(4),
        );
        expect(tester.takeException(), isNull);
        expect(field('Their park (P2P)'), findsOneWidget);
        final handle = tester.ensureSemantics();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        handle.dispose();
      });
    }
  });

  group('right-to-left and pseudo-locale', () {
    const rtl = AppSettings(localeOverride: Locale('en', 'XA'), forceRtl: true);

    testWidgets('setup and banner mirror and nothing overflows', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletLandscape,
        settings: rtl,
        activation: _running,
        activationProgress: progressOf(3),
        referencePacks: FakeReferencePackStore(references: [_acadia]),
        stations: [_homeStation, _parkStation],
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.terrain_outlined));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('every label of the setup comes from the pseudo-locale', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        settings: rtl,
        referencePacks: FakeReferencePackStore(references: [_acadia]),
        stations: [_homeStation, _parkStation],
      );
      await tester.tap(find.byIcon(Icons.terrain_outlined));
      await tester.pumpAndSettle();
      final data = RegExp(
        r'^(US-0001|[A-R]{2}\d\d([a-x]{2})?|DO1HOZ|SOTA|POTA|WWFF|\d+ km|Example: .*)$',
      );
      final offenders = [
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          if (t.data ?? t.textSpan?.toPlainText() ?? '' case final s
              when RegExp('[A-Za-z]').hasMatch(s) &&
                  !s.contains('[') &&
                  !data.hasMatch(s) &&
                  !s.contains(_homeStation.name) &&
                  !s.contains('Acadia'))
            s,
      ];
      expect(offenders, isEmpty);
    });
  });
}
