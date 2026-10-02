import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';

Finder field(String label) => find.widgetWithText(TextField, label);

String textOf(WidgetTester tester, String label) =>
    tester.widget<TextField>(field(label)).controller!.text;

/// Pumps the app with a running contest and opens contest mode through the
/// log screen's button, the way an operator would.
Future<Pumped> pumpContest(
  WidgetTester tester, {
  String definitionId = 'cq-wpx-ssb',
  Size size = TestSizes.desktop,
  AppSettings settings = const AppSettings(theme: ThemeChoice.light),
  double textScale = 1,
  ContestBackend? backend,
  Map<String, String> ownExchange = const {},
  bool open = true,
  List<Override> overrides = const [],
}) async {
  final contest = backend ?? ContestBackend();
  if (contest.active == null) {
    contest.startSession(
      definitionId,
      usesSerial: contest.definitions
          .firstWhere((d) => d.definition.id == definitionId)
          .definition
          .exchange
          .sent
          .any((e) => e.kind.name == 'serial'),
      ownExchange: ownExchange,
    );
  }
  final app = await pumpTideline(
    tester,
    size: size,
    settings: settings,
    textScale: textScale,
    contest: contest,
    overrides: overrides,
  );
  if (open) {
    await tester.tap(find.byIcon(Icons.emoji_events_outlined));
    await tester.pumpAndSettle();
  }
  return app;
}

/// Types a call and lets the debounced hints appear.
Future<void> typeCall(WidgetTester tester, String call) async {
  // The callsign is the first text field of the screen in every language.
  await tester.enterText(find.byType(TextField).first, call);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

/// Presses [key] with Ctrl (and Shift) held, like a hardware keyboard.
Future<void> chord(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
}

/// Seeds [count] earlier QSOs of the running session, [minutesAgo] apart,
/// so rates and lists have something to show.
void seedSessionQsos(
  ContestBackend backend,
  int count, {
  int minutesAgo = 1,
  String band = '20m',
  bool receivedSerial = true,
}) {
  final session = backend.active!;
  final now = DateTime.now().toUtc();
  const calls = ['DL1ABC', 'G4XYZ', 'EA8ABC', 'W1AW', 'JA1ZZZ', 'VK2ABC'];
  for (var i = 0; i < count; i++) {
    backend.seedQso(
      Qso(
        id: 'seed$i',
        accountId: 'acc-1',
        stationProfileId: 'st-1',
        call: Callsign.tryParse(calls[i % calls.length])!,
        timeOn: UtcDateTime(
          now.subtract(Duration(minutes: minutesAgo * (count - i))),
        ),
        band: Band.tryParse(band)!,
        mode: Mode.tryParse('SSB')!,
        rstSent: '59',
        rstRcvd: '59',
        fields: {
          'STX': '${i + 1}',
          if (receivedSerial) 'SRX': '${10 + i}',
          'STX_STRING': '59 ${i + 1}',
          'SRX_STRING': receivedSerial ? '59 ${10 + i}' : '59',
        },
        contestSessionId: session.id,
      ),
    );
    backend.highestSerial[session.id] = i + 1;
  }
  backend.refreshSerial();
}
