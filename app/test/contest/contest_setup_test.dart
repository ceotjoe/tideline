import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';
import 'contest_harness.dart';

/// Opens the setup through the log screen's contest button.
Future<Pumped> pumpSetup(
  WidgetTester tester, {
  ContestBackend? backend,
  Size size = TestSizes.phone,
}) async {
  final contest = backend ?? ContestBackend();
  final app = await pumpTideline(tester, size: size, contest: contest);
  await tester.tap(find.byIcon(Icons.emoji_events_outlined));
  await tester.pumpAndSettle();
  return app;
}

/// Searches for [contest] and picks it, as a user with a long list would.
Future<void> choose(WidgetTester tester, String contest) async {
  await tester.enterText(field('Search contests'), contest);
  await tester.pumpAndSettle();
  final tile = find.widgetWithText(ListTile, contest);
  await tester.ensureVisible(tile);
  await tester.tap(tile);
  await tester.pumpAndSettle();
}

Future<void> start(WidgetTester tester) async {
  final button = find.text('Start session');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists built-in and imported contests and filters them', (
    tester,
  ) async {
    final backend = ContestBackend(
      definitions: [
        ...bundledDefinitions(),
        StoredContestDefinition(
          ContestDefinition.parse('''
{"schema":1,"id":"my-sprint","version":1,"name":"My Club Sprint",
 "modes":["CW"],"bands":["40m"],
 "exchange":{"sent":[{"kind":"rst"}],"rcvd":[{"kind":"rst"}]},
 "dupe":{"per":[]},"score":"qsos"}'''),
          builtin: false,
        ),
      ],
    );
    await pumpSetup(tester, backend: backend);
    expect(find.text('Contest session'), findsOneWidget);
    expect(find.text('Built in'), findsWidgets);
    await tester.enterText(field('Search contests'), 'sprint');
    await tester.pumpAndSettle();
    expect(find.text('My Club Sprint'), findsOneWidget);
    expect(find.text('Imported by you'), findsOneWidget);

    await tester.enterText(field('Search contests'), 'wpx');
    await tester.pumpAndSettle();
    expect(find.textContaining('CQ WPX'), findsNWidgets(2));
    expect(find.text('My Club Sprint'), findsNothing);

    await tester.enterText(field('Search contests'), 'nothing like this');
    await tester.pumpAndSettle();
    expect(find.text('No contest matches your search.'), findsOneWidget);
  });

  testWidgets('CQ WW: my zone comes from the station, the session starts', (
    tester,
  ) async {
    final app = await pumpSetup(tester);
    // Nothing to enter before a contest is chosen.
    expect(find.text('My exchange'), findsNothing);
    await choose(tester, 'CQ World Wide DX Contest (SSB)');

    expect(find.text('My exchange'), findsOneWidget);
    expect(find.text('Home QTH (DO1HOZ)'), findsOneWidget);
    // DO1HOZ is in Germany: CQ zone 14, taken from the offline DXCC data.
    expect(
      tester
          .widget<TextFormField>(find.widgetWithText(TextFormField, 'CQ zone'))
          .initialValue,
      '14',
    );
    expect(find.textContaining('59 for voice'), findsOneWidget);
    // Cabrillo categories offer the protocol tokens, untranslated.
    for (final label in [
      'Operator category',
      'Assistance',
      'Band category',
      'Mode category',
      'Power',
      'Station type',
      'Transmitters',
      'Overlay',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    final power = find.widgetWithText(
      DropdownButtonFormField<String?>,
      'Power',
    );
    await tester.ensureVisible(power);
    await tester.pumpAndSettle();
    await tester.tap(power);
    await tester.pumpAndSettle();
    await tester.tap(find.text('LOW').last);
    await tester.pumpAndSettle();

    await start(tester);

    final session = app.contest.active!;
    expect(session.definitionId, 'cq-ww-ssb');
    expect(session.stationProfileId, testStation.id);
    expect(session.ownExchange, {'cqZone': '14'});
    expect(session.cabrillo['CATEGORY-POWER'], 'LOW');
    expect(session.cabrillo['CATEGORY-OPERATOR'], 'SINGLE-OP');
    expect(session.cabrillo['CATEGORY-MODE'], 'SSB');
    expect(session.cabrillo.containsKey('CATEGORY-OVERLAY'), isFalse);
    // The same route now shows the entry screen.
    expect(find.text('Sent: RST 59 · CQ zone 14'), findsOneWidget);
  });

  testWidgets('a missing value is explained and blocks the start', (
    tester,
  ) async {
    final app = await pumpSetup(tester, size: TestSizes.tabletLandscape);
    await choose(tester, 'Worked All Germany (WAG)');
    // A German station sends its DOK; there is nothing to suggest.
    expect(find.widgetWithText(TextFormField, 'DOK'), findsOneWidget);
    await start(tester);
    expect(app.contest.active, isNull);
    expect(find.text('DOK is required.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'DOK'), 'p09');
    await tester.pumpAndSettle();
    await start(tester);
    expect(app.contest.active!.ownExchange, {'dok': 'P09'});
  });

  testWidgets('what was entered survives a rotation', (tester) async {
    await pumpSetup(tester);
    await choose(tester, 'Worked All Germany (WAG)');
    await tester.enterText(find.widgetWithText(TextFormField, 'DOK'), 'P09');
    await tester.enterText(field('Search contests'), 'wag');
    tester.view.physicalSize =
        TestSizes.tabletLandscape * tester.view.devicePixelRatio;
    await tester.pumpAndSettle();
    expect(find.text('P09'), findsOneWidget);
    expect(textOf(tester, 'Search contests'), 'wag');
  });

  testWidgets('past sessions can be reopened, a running one blocks starting', (
    tester,
  ) async {
    final backend = ContestBackend();
    final old = backend.startSession('cq-wpx-ssb', usesSerial: true);
    await backend.sessionRepository.end(old.id, 1);
    final app = await pumpSetup(tester, backend: backend);
    expect(find.text('Past sessions'), findsOneWidget);
    expect(find.text('Ended'), findsOneWidget);
    expect(find.text('Reopen'), findsOneWidget);
    await tester.tap(find.text('Reopen'));
    await tester.pumpAndSettle();
    expect(app.contest.active!.id, old.id);
    expect(find.text('Sent: RST 59 · Serial no. 1'), findsOneWidget);

    // From the entry, the sessions page explains why starting is off.
    await tester.tap(find.byTooltip('Sessions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('already running'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Reopen'), findsNothing);
    final startButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start session'),
    );
    expect(startButton.onPressed, isNull);
  });
}
