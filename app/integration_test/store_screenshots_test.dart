// Walks the real app through its demo account and stops at each screen the
// store listings show. Run it with `tool/store_screenshots.py`, which takes
// the pictures: this test prints `STORE_SHOT <name>` and waits, and the script
// captures the device screen (real pixels, a clean status bar) when it sees
// that line. Nothing here talks to a network: the demo "server" runs inside
// the app (ADR 0031), and the QSOs are invented.
//
// Direct use (the pictures are then up to you):
//   flutter test integration_test/store_screenshots_test.dart -d <device> \
//     --dart-define=STORE_LOCALE=de --dart-define=STORE_SHOT_WAIT_MS=0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/main.dart' as app;
import 'package:tideline/src/features/onboarding/onboarding_screen.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/settings/app_settings.dart';

const _locale = String.fromEnvironment('STORE_LOCALE', defaultValue: 'en');
const _waitMs = int.fromEnvironment('STORE_SHOT_WAIT_MS', defaultValue: 3000);

/// Invented operators, all with callsigns in the usual placeholder style.
const _fle = '''
date 2026-10-03
20m ssb
1412 DL1ABC 59 57 @Anna
1415 G4XYZ 59 59 @Bob
1419 F5ABC 57 55 @Marc
1423 OK1ABC 59 59 @Petr
1428 SP9ABC 55 59 @Piotr
1433 EA3ABC 59 58 @Jordi
40m cw
1502 OE1ABC 599 579 @Franz
1507 ON4ABC 599 599 @Luc
1511 HB9ABC 579 559 @Urs
''';

const _fleQsos = 9;

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

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
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .whereType<String>();
  throw TestFailure(
    'Timed out waiting for $finder. Texts: ${texts.join(' | ')}',
  );
}

Iterable<String> visibleTexts() => find
    .byType(Text)
    .evaluate()
    .map((e) => (e.widget as Text).data)
    .whereType<String>();

Future<void> tapText(WidgetTester tester, String text) async {
  if (find.text(text).evaluate().isEmpty) {
    throw TestFailure(
      'No "$text" on screen. Texts: ${visibleTexts().join(' | ')}',
    );
  }
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store screenshots', (tester) async {
    Future<void> shot(String name) async {
      // No keyboard or caret in a store picture.
      FocusManager.instance.primaryFocus?.unfocus();
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await pumpFor(tester, const Duration(milliseconds: 800));
      // The script watches stdout for this line.
      // ignore: avoid_print
      print('STORE_SHOT $name');
      await pumpFor(tester, const Duration(milliseconds: _waitMs));
    }

    ProviderContainer container() => ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp).first),
    );
    GoRouter router() =>
        GoRouter.of(tester.element(find.byType(Scaffold).first));

    Future<void> save(AppSettings Function(AppSettings) change) async {
      final c = container();
      final current = c.read(appSettingsProvider).value ?? const AppSettings();
      await c.read(settingsControllerProvider).save(change(current));
      await tester.pump(const Duration(milliseconds: 500));
    }

    await app.main();
    await pumpUntil(tester, find.byType(OnboardingScreen));
    await save(
      (s) => s.copyWith(
        theme: ThemeChoice.light,
        localeOverride: const Locale(_locale),
      ),
    );
    await pumpFor(tester, const Duration(seconds: 1));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(OnboardingScreen)),
    );

    // The demo account: no server, no sign-in.
    await tapText(tester, l10n.onboardingTryDemo);
    await pumpUntil(tester, find.text(l10n.onboardingFinish));
    await tapText(tester, l10n.onboardingFinish);
    await pumpUntil(tester, find.text(l10n.navLog));

    // An activation first, so the QSOs below count toward it.
    router().go('/activation-setup');
    // The station is loaded when its name shows; the button needs it.
    await pumpUntil(tester, find.textContaining('N0CALL'));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.text('SOTA').last);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.widgetWithText(TextField, l10n.activationReferenceLabelSota),
      'G/LD-001',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    await pumpFor(tester, const Duration(milliseconds: 800));
    // In German the title and the button read the same: take the button.
    final start = find.widgetWithText(FilledButton, l10n.activationStart);
    // A small screen builds the button only once it is scrolled near.
    await tester.scrollUntilVisible(
      start,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(start);
    await tester.pump(const Duration(milliseconds: 400));
    // Fail here, not in a picture without the banner, if it did not start.
    router().go('/log');
    await pumpUntil(tester, find.text(l10n.activationEnd));

    // Fast Log Entry: the quickest way to a believable log.
    router().go('/fle');
    await pumpUntil(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField).first, _fle);
    await pumpFor(tester, const Duration(seconds: 1));
    await tapText(tester, l10n.fleLogButton(_fleQsos));
    await pumpFor(tester, const Duration(seconds: 2));

    // The four main destinations, in the order of the navigation.
    // The log has a callsign typed so the entry form shows what is known.
    router().go('/log');
    await pumpFor(tester, const Duration(seconds: 2));
    await tester.enterText(
      find.widgetWithText(TextField, l10n.fieldCallsign),
      'DL1ABC',
    );
    await pumpFor(tester, const Duration(seconds: 1));
    await shot('01-log');

    router().go('/callsigns');
    await pumpFor(tester, const Duration(seconds: 2));
    await shot('02-callsigns');

    router().go('/sync');
    await pumpFor(tester, const Duration(seconds: 2));
    await shot('03-sync');

    router().go('/settings');
    await pumpFor(tester, const Duration(seconds: 1));
    await shot('04-settings');
  });
}
