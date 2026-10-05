@Tags(['golden'])
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart'
    show Account, CallsignInfo, EvictionBlock, LoggedQso;
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

void main() {
  const sizes = {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
    'tablet_landscape_wide': TestSizes.tabletLandscapeWide,
  };

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets('log screen, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        log: sampleLog(6),
        pending: 4,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/log_$sizeName.png'),
      );
    });

    testWidgets('welcome with demo button, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        accounts: const [],
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/welcome_$sizeName.png'),
      );
    });

    testWidgets('settings, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_$sizeName.png'),
      );
    });

    testWidgets('settings appearance page, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Appearance and language'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings_appearance_$sizeName.png'),
      );
    });
  }

  testWidgets('log screen, tablet landscape with the keyboard up', (
    tester,
  ) async {
    await pumpTideline(
      tester,
      size: TestSizes.tabletLandscapeWide,
      settings: const AppSettings(theme: ThemeChoice.light),
      log: sampleLog(6),
      pending: 4,
    );
    tester.view.viewInsets = FakeViewPadding(
      bottom: 400 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/log_tablet_landscape_keyboard.png'),
    );
  });

  testWidgets('log screen, phone with the keyboard up', (tester) async {
    await pumpTideline(
      tester,
      settings: const AppSettings(theme: ThemeChoice.light),
      log: sampleLog(6),
      pending: 4,
    );
    tester.view.viewInsets = FakeViewPadding(
      bottom: 300 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/log_phone_keyboard.png'),
    );
  });

  const club = Account(
    id: 'acc-2',
    label: 'Club station',
    baseUrl: 'https://club.example.org',
    usesIndexPhp: true,
    allowHttpLan: false,
    scopes: {'qso:write'},
    hasContestSessions: false,
  );

  testWidgets('log screen with two accounts, phone', (tester) async {
    await pumpTideline(
      tester,
      settings: const AppSettings(theme: ThemeChoice.light),
      accounts: const [testAccount, club],
      log: sampleLog(3),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/log_phone_two_accounts.png'),
    );
  });

  for (final MapEntry(key: sizeName, value: size) in {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
  }.entries) {
    testWidgets('accounts page, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        accounts: const [testAccount, club],
        pendingByAccount: const {'acc-1': 2, 'acc-2': 5},
      );
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wavelog accounts'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/accounts_$sizeName.png'),
      );
    });
  }

  for (final (name, platform, size) in [
    ('windows', TargetPlatform.windows, TestSizes.desktop),
    ('macos', TargetPlatform.macOS, TestSizes.desktop),
    ('windows_narrow', TargetPlatform.windows, TestSizes.phone),
  ]) {
    testWidgets('log screen on a desktop, $name', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await pumpTideline(
          tester,
          size: size,
          settings: const AppSettings(theme: ThemeChoice.light),
          log: sampleLog(6),
          pending: 4,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/log_desktop_$name.png'),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  const anna = CallsignInfo(
    call: 'DL1ABC',
    lastTime: 1_700_000_000_000,
    name: 'Anna',
    qth: 'Berlin',
    gridsquare: 'JO62',
    dxcc: 230,
    cqz: 14,
    ituz: 28,
  );

  for (final MapEntry(key: sizeName, value: size) in {
    'phone': TestSizes.phone,
    'tablet_landscape': TestSizes.tabletLandscape,
  }.entries) {
    testWidgets('log screen with what is known about the call, $sizeName', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        log: sampleLog(3),
        callsigns: const {'DL1ABC': anna},
        callsignNotes: const {'DL1ABC': 'Calls on 40 m around 06 UTC'},
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Callsign'),
        'DL1ABC',
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/log_callsign_context_$sizeName.png'),
      );
    });
  }

  for (final MapEntry(key: sizeName, value: size) in {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
  }.entries) {
    testWidgets('callsign directory page, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        callsigns: const {
          'DL1ABC': anna,
          'G4XYZ': CallsignInfo(
            call: 'G4XYZ',
            lastTime: 1_600_000_000_000,
            name: 'Bob',
            qth: 'Leeds',
          ),
        },
        callsignNotes: const {'DL1ABC': 'x'},
      );
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .go('/settings/callsigns');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/callsigns_$sizeName.png'),
      );
    });
  }

  for (final MapEntry(key: sizeName, value: size) in {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
  }.entries) {
    testWidgets('free up space, checked, $sizeName', (tester) async {
      final synced = [
        for (var i = 0; i < 3; i++)
          LoggedQso(
            Qso(
              id: 'e$i',
              accountId: 'acc-1',
              call: Callsign.tryParse('DL1ABC')!,
              timeOn: UtcDateTime(DateTime.utc(2020, 1, 1, 12, i)),
              band: Band.tryParse('20m')!,
              mode: Mode.tryParse('CW')!,
            ),
            SyncStatus(state: SyncState.synced, remoteQsoId: 100 + i),
          ),
      ];
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
        evictionRepository: FakeEvictionRepository(
          eligible: synced,
          blocked: const {
            EvictionBlock.notSynced: 4,
            EvictionBlock.inActivation: 1,
          },
          evicted: 12,
        ),
        evictionService: FakeEvictionService(
          confirmed: synced.take(2).toList(),
          missing: synced.skip(2).toList(),
        ),
      );
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .go('/settings/account/acc-1/free-space');
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Check with Wavelog'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/free_space_$sizeName.png'),
      );
    });
  }

  for (final MapEntry(key: sizeName, value: size) in {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
  }.entries) {
    testWidgets('fast log entry with a preview, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings(theme: ThemeChoice.light),
      );
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/fle');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'date 2020-01-02\n20m cw\n1734 DL1ABC 599 579 @Anna\n'
        '5 G4XYZ blah\n1800 F5ABC jn18',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/fle_$sizeName.png'),
      );
    });
  }

  for (final MapEntry(key: sizeName, value: size) in {
    'phone': TestSizes.phone,
    'tablet_portrait': TestSizes.tabletPortrait,
    'tablet_landscape': TestSizes.tabletLandscape,
  }.entries) {
    testWidgets('field mode page, on, $sizeName', (tester) async {
      await pumpTideline(
        tester,
        size: size,
        settings: const AppSettings().withFieldMode(on: true),
      );
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .go('/settings/field-mode');
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/field_mode_$sizeName.png'),
      );
    });
  }
}
