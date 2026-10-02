// End-to-end test of the real app (encrypted DB, platform secure store,
// pinned HTTP client) against the mock Wavelog.
//
// 1. Start the mock on the host:  dart run wavelog_mock:serve 8765
// 2. Run on a simulator/desktop:  flutter test integration_test -d <device>
//
// The test reads the device's language, so it works in English and German.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/main.dart' as app;
import 'package:tideline/src/features/onboarding/onboarding_screen.dart';

const _server = 'http://127.0.0.1:8765';
const _token = 'wl2_demo_token';

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Finder field(String label) => find.widgetWithText(TextField, label);

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.tap(find.text(text).last);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboard, log offline-first and sync to Wavelog', (tester) async {
    // A fresh callsign per run, so repeated runs against one mock work.
    final suffix = String.fromCharCodes([
      for (var i = 0; i < 3; i++)
        65 + (DateTime.now().microsecondsSinceEpoch >> (i * 5)) % 26,
    ]);
    final call = 'DL1$suffix';
    await app.main();
    await pumpUntil(tester, find.byType(OnboardingScreen));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );

    // Onboarding: LAN server over plain HTTP needs the explicit opt-in.
    await tapText(tester, l10n.onboardingStart);
    await tester.enterText(field(l10n.fieldServerUrl), _server);
    await tester.enterText(field(l10n.fieldAccountLabel), 'Test station');
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tapText(tester, l10n.actionContinue);
    await tester.enterText(field(l10n.fieldToken), _token);
    await tapText(tester, l10n.actionCheckToken);
    await pumpUntil(tester, find.text(l10n.onboardingFinish));
    expect(find.text(l10n.onboardingServerVersion32), findsOneWidget);
    await tapText(tester, l10n.onboardingFinish);

    // Logging is local and instant; sync follows on its own.
    await pumpUntil(tester, field(l10n.fieldCallsign));
    await tester.enterText(field(l10n.fieldCallsign), call);
    await tester.enterText(field(l10n.fieldName), 'Anna');
    await tapText(tester, l10n.commandLogQso);
    await pumpUntil(tester, find.text(l10n.statusSynced));

    // The QSO really is on the server, exactly once.
    final response = await http.get(
      Uri.parse('$_server/index.php/api/v2/qso?callsign=$call'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    final data = (jsonDecode(response.body) as Map)['data'] as List;
    expect(data, hasLength(1));
    expect((data.single as Map)['name'], 'Anna');
    expect((data.single as Map)['station_id'], 3);
  });
}
