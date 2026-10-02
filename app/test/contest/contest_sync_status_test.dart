import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/features/contest/contest_sync_status.dart';
import 'package:tideline_data/tideline_data.dart';

import '../support/contest_fakes.dart';
import 'contest_harness.dart';

ContestSession session(ContestRemoteState state, {String? error}) =>
    ContestSession(
      id: 's1',
      definitionId: 'cq-wpx-ssb',
      definitionVersion: 1,
      accountId: 'acc-1',
      startedAt: 0,
      ownExchange: const {},
      cabrillo: const {},
      usesSerial: true,
      remoteState: state,
      remoteErrorKey: error,
    );

Widget host(ContestSession s, Locale locale) => MaterialApp(
  locale: locale,
  theme: buildTidelineTheme(variant: TidelineThemeVariant.light),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: ContestSyncStatus(session: s)),
);

void main() {
  const problems = [
    ContestSyncProblem.contestNotActive,
    ContestSyncProblem.missingPermission,
    ContestSyncProblem.serverTooOld,
    ContestSyncProblem.deletedOnServer,
    ContestSyncProblem.noAdifName,
    ContestSyncProblem.stationUnknown,
    ContestSyncProblem.rejected,
  ];

  testWidgets('each state has its own icon and text', (tester) async {
    final expected = {
      ContestRemoteState.local: (
        'Only on this device',
        Icons.cloud_off_outlined,
      ),
      ContestRemoteState.pending: (
        'Waiting for upload to Wavelog',
        Icons.cloud_upload_outlined,
      ),
      ContestRemoteState.verifying: ('Being checked on Wavelog', Icons.sync),
      ContestRemoteState.created: ('On Wavelog', Icons.cloud_done_outlined),
    };
    for (final MapEntry(key: state, value: (text, icon)) in expected.entries) {
      await tester.pumpWidget(host(session(state), const Locale('en')));
      expect(find.text(text), findsOneWidget, reason: '$state');
      expect(find.byIcon(icon), findsOneWidget, reason: '$state');
    }
  });

  for (final locale in ['en', 'de']) {
    test('every ContestSyncProblem key is localised ($locale)', () {
      final l10n = lookupAppLocalizations(Locale(locale));
      final unknown = l10n.contestSyncProblemUnknown;
      final seen = <String>{};
      for (final key in problems) {
        final text = contestSyncProblemText(l10n, key);
        expect(text, isNot(unknown), reason: key);
        expect(seen.add(text), isTrue, reason: 'duplicate text for $key');
      }
      expect(contestSyncProblemText(l10n, 'somethingNew'), unknown);
    });
  }

  testWidgets('the reason follows the state, in German too', (tester) async {
    await tester.pumpWidget(
      host(
        session(
          ContestRemoteState.local,
          error: ContestSyncProblem.serverTooOld,
        ),
        const Locale('de'),
      ),
    );
    expect(
      find.text(
        'Nur auf diesem Gerät: Dein Wavelog-Server ist älter als Version 3.2 '
        'und kennt keine Contest-Sitzungen.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('the contest screen header shows the live state', (tester) async {
    final backend = ContestBackend()
      ..startSession(
        'cq-wpx-ssb',
        usesSerial: true,
        remoteState: ContestRemoteState.pending,
      );
    await pumpContest(tester, backend: backend, open: false);
    await tester.tap(find.text('Return to contest'));
    await tester.pumpAndSettle();
    expect(find.text('Waiting for upload to Wavelog'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
  });
}
