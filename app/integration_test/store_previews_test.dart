// Plays one App Preview scene (a short, scripted walk through the demo
// account) while `tool/store_previews.py` records the window. The script
// starts recording when this test prints `PREVIEW_START` and stops it at
// `PREVIEW_END`. Nothing here talks to a network: the demo "server" runs
// inside the app (ADR 0031), and the QSOs are invented.
//
//   flutter test integration_test/store_previews_test.dart -d macos \
//     --dart-define=PREVIEW=log
//
// PREVIEW is one of: log (Fast Log Entry and sync), contest, activation.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/main.dart' as app;
import 'package:tideline/src/features/contest/contest_entry_panel.dart';
import 'package:tideline/src/features/onboarding/onboarding_screen.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/settings/app_settings.dart';

const _scene = String.fromEnvironment('PREVIEW', defaultValue: 'log');
const _locale = String.fromEnvironment('STORE_LOCALE', defaultValue: 'en');

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
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
  throw TestFailure('Timed out waiting for $finder. Texts: ${texts.join(' | ')}');
}

/// Types [text] into [field] one character at a time, like a person.
Future<void> typeSlowly(
  WidgetTester tester,
  Finder field,
  String text, {
  int msPerChar = 90,
}) async {
  for (var i = 1; i <= text.length; i++) {
    await tester.enterText(field, text.substring(0, i));
    await pumpFor(tester, Duration(milliseconds: msPerChar));
  }
}

Future<void> tapText(WidgetTester tester, String text) async {
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.tap(f);
  await pumpFor(tester, const Duration(milliseconds: 600));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app preview: $_scene', (tester) async {
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

    Future<void> go(String location, {int settleMs = 1200}) async {
      router().go(location);
      await pumpFor(tester, Duration(milliseconds: settleMs));
    }

    // Setup, not recorded: the demo account and a light theme.
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
    await tapText(tester, l10n.onboardingTryDemo);
    await pumpUntil(tester, find.text(l10n.onboardingFinish));
    await tapText(tester, l10n.onboardingFinish);
    await pumpUntil(tester, find.text(l10n.navLog));
    await pumpFor(tester, const Duration(seconds: 2));

    Future<void> startActivation() async {
      await go('/activation-setup', settleMs: 500);
      await pumpUntil(tester, find.textContaining('N0CALL'));
      await pumpFor(tester, const Duration(milliseconds: 800));
      await tester.tap(find.text('SOTA').last);
      await pumpFor(tester, const Duration(milliseconds: 700));
      await typeSlowly(
        tester,
        find.widgetWithText(TextField, l10n.activationReferenceLabelSota),
        'G/LD-001',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await pumpFor(tester, const Duration(milliseconds: 900));
      final start = find.widgetWithText(FilledButton, l10n.activationStart);
      await tester.scrollUntilVisible(
        start,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(start);
      await pumpFor(tester, const Duration(milliseconds: 600));
    }

    Future<void> logCall(String call, {String? name}) async {
      final field = find.widgetWithText(TextField, l10n.fieldCallsign).first;
      await tester.tap(field);
      await typeSlowly(tester, field, call);
      await pumpFor(tester, const Duration(milliseconds: 700));
      await tester.tap(find.text(l10n.commandLogQso).last);
      await pumpFor(tester, const Duration(milliseconds: 1000));
    }

    // Prepare silently what the recording should start from.
    if (_scene == 'activation') {
      // Recorded: the start of the activation itself.
    }

    // ignore: avoid_print
    print('PREVIEW_START');
    await pumpFor(tester, const Duration(seconds: 1));

    switch (_scene) {
      case 'log':
        await go('/fle', settleMs: 1500);
        const lines = [
          'date 2026-10-03\n',
          '20m ssb\n',
          '1412 DL1ABC 59 57 @Anna\n',
          '1415 G4XYZ 59 59 @Bob\n',
          '1419 F5ABC 57 55 @Marc\n',
          '1423 OK1ABC 59 59 @Petr\n',
          '40m cw\n',
          '1502 OE1ABC 599 579 @Franz\n',
          '1507 ON4ABC 599 599 @Luc\n',
        ];
        final field = find.byType(TextField).first;
        var typed = '';
        for (final line in lines) {
          for (var i = 1; i <= line.length; i++) {
            await tester.enterText(field, typed + line.substring(0, i));
            await pumpFor(tester, const Duration(milliseconds: 35));
          }
          typed += line;
          await pumpFor(tester, const Duration(milliseconds: 500));
        }
        await pumpFor(tester, const Duration(milliseconds: 600));
        await tapText(tester, l10n.fleLogButton(6));
        await pumpFor(tester, const Duration(seconds: 1));
        await go('/log', settleMs: 2200);
        await go('/callsigns', settleMs: 2000);
        await go('/sync', settleMs: 2500);
      case 'contest':
        await go('/contest-setup', settleMs: 1500);
        await tapText(tester, 'CQ WPX Contest (SSB)');
        await pumpFor(tester, const Duration(seconds: 2));
        await tapText(tester, l10n.contestStart);
        await pumpFor(tester, const Duration(seconds: 2));
        if (find.byType(ContestEntryPanel).evaluate().isEmpty) {
          await go('/contest', settleMs: 1000);
        }
        await pumpUntil(tester, find.byType(ContestEntryPanel));
        await pumpFor(tester, const Duration(seconds: 1));
        const calls = [
          ('DL1ABC', '001'),
          ('G4XYZ', '014'),
          ('F5ABC', '102'),
          ('OK1ABC', '007'),
          ('SP9ABC', '230'),
          ('EA3ABC', '019'),
        ];
        for (final (call, serial) in calls) {
          final fields = find.descendant(
            of: find.byType(ContestEntryPanel),
            matching: find.byType(TextField),
          );
          await typeSlowly(tester, fields.first, call);
          await pumpFor(tester, const Duration(milliseconds: 500));
          // The received serial is the last exchange field before frequency.
          await tester.enterText(fields.at(2), serial);
          await pumpFor(tester, const Duration(milliseconds: 500));
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await pumpFor(tester, const Duration(milliseconds: 1200));
        }
        await pumpFor(tester, const Duration(seconds: 3));
      case 'activation':
        await startActivation();
        await go('/log', settleMs: 1500);
        for (final call in const ['DL1ABC', 'G4XYZ', 'F5ABC', 'OK1ABC']) {
          await logCall(call);
        }
        await pumpFor(tester, const Duration(seconds: 2));
        await go('/sync', settleMs: 3500);
      default:
        throw TestFailure('Unknown PREVIEW "$_scene"');
    }

    // ignore: avoid_print
    print('PREVIEW_END');
    await pumpFor(tester, const Duration(milliseconds: 500));
  });
}
