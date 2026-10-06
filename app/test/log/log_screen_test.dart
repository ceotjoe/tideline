import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/log/qso_detail.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../contest/contest_harness.dart' show pumpContest;
import '../support/contest_fakes.dart';
import '../support/pump_app.dart';

Finder field(String label) => find.widgetWithText(TextField, label);

void main() {
  group('logging', () {
    testWidgets('Enter logs the QSO locally with sensible defaults', (
      tester,
    ) async {
      final app = await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Callsign'), 'dl1abc');
      await tester.pump();
      // Offline DXCC hint appears while typing.
      expect(find.textContaining('Fed. Rep. of Germany'), findsWidgets);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      final qso = app.qsos.logged.single;
      expect(qso.call.value, 'DL1ABC');
      expect(qso.band.name, '20m');
      expect(qso.mode.mode, 'SSB');
      expect((qso.rstSent, qso.rstRcvd), ('59', '59'));
      expect(qso.stationProfileId, testStation.id);
      expect(qso.field('DXCC'), '230');
      expect(qso.timeOn.value.isUtc, isTrue);
      // The form is ready for the next QSO, and sync was nudged.
      expect(tester.widget<TextField>(field('Callsign')).controller!.text, '');
      expect(app.sync.runs, 1);
    });

    testWidgets('invalid callsign is explained and nothing is logged', (
      tester,
    ) async {
      final app = await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Callsign'), 'HELLO');
      await tester.ensureVisible(find.text('Log QSO'));
      await tester.tap(find.text('Log QSO'));
      await tester.pumpAndSettle();
      expect(app.qsos.logged, isEmpty);
      expect(find.textContaining('Enter a callsign'), findsOneWidget);
    });

    testWidgets('a frequency selects its band', (tester) async {
      final app = await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Frequency'), '7074');
      await tester.enterText(field('Callsign'), 'G4XYZ');
      await tester.ensureVisible(find.text('Log QSO'));
      await tester.tap(find.text('Log QSO'));
      await tester.pumpAndSettle();
      final qso = app.qsos.logged.single;
      expect(qso.band.name, '40m');
      expect(qso.freqHz, 7074000);
    });

    testWidgets('Esc clears the entry', (tester) async {
      await pumpTideline(tester, size: TestSizes.desktop);
      await tester.enterText(field('Callsign'), 'G4XYZ');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field('Callsign')).controller!.text, '');
    });
  });

  group('layouts', () {
    testWidgets('phone: form above the recent QSOs', (tester) async {
      await pumpTideline(tester, log: sampleLog(3));
      await tester.scrollUntilVisible(
        find.text('Recent QSOs'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Recent QSOs'), findsOneWidget);
      expect(find.text('Log QSO'), findsOneWidget);
    });

    testWidgets('tablet landscape: entry strip above the full-width log', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletLandscape,
        log: sampleLog(3),
      );
      // The log lies below the fields, not beside them.
      expect(
        tester.getTopLeft(find.text('Anna').first).dy,
        greaterThan(tester.getBottomLeft(find.text('Log QSO')).dy),
      );
      // A QSO opens over the log (sheet), so the entry form stays put.
      await tester.tap(find.text('Anna').first);
      await tester.pumpAndSettle();
      expect(find.byType(QsoDetail), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      expect(find.text('Log QSO'), findsOneWidget);
    });

    testWidgets('phone: a QSO opens on its own page', (tester) async {
      await pumpTideline(tester, log: sampleLog(1));
      await tester.scrollUntilVisible(
        find.text('Anna'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Anna'));
      await tester.pumpAndSettle();
      expect(find.text('QSO details'), findsOneWidget);
    });
  });

  testWidgets('switching accounts picks a station of the new account', (
    tester,
  ) async {
    const clubStation = StationProfile(
      id: 'st-2',
      accountId: 'acc-2',
      remoteId: 7,
      name: 'Club QTH',
      callsign: 'DL0CLB',
      active: true,
    );
    final stations = StreamController<List<StationProfile>>();
    addTearDown(stations.close);
    stations.add(const [testStation]);
    await pumpTideline(tester, stationStream: stations.stream);
    expect(find.text('Home QTH (DO1HOZ)'), findsOneWidget);

    // The other account's stations arrive; the entry still names st-1.
    stations.add(const [clubStation]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Club QTH (DL0CLB)'), findsOneWidget);
    expect(find.text('Home QTH (DO1HOZ)'), findsNothing);
  });

  group('tablet landscape with the keyboard up', () {
    const keyboard = 430.0; // iPad landscape software keyboard, measured
    const labels = [
      'Callsign',
      'Band',
      'Mode',
      'Frequency',
      'RST sent',
      'RST received',
      'Name',
      'Locator',
      'Comment',
    ];

    for (final (size, scale) in [
      (const Size(1180, 820), 1.0),
      (TestSizes.tabletLandscapeWide, 1.0),
      (const Size(1366, 1024), 1.0),
      (TestSizes.tabletLandscapeWide, 1.3),
    ]) {
      testWidgets('all fields are visible above it at $size, ${scale}x text', (
        tester,
      ) async {
        // A running contest adds its banner above the log.
        await pumpContest(
          tester,
          size: size,
          textScale: scale,
          backend: ContestBackend(),
          open: false,
          log: sampleLog(5),
        );
        final dpr = tester.view.devicePixelRatio;
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard * dpr);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        final visibleBottom = size.height - keyboard;
        for (final label in [...labels, 'Log QSO', 'Clear entry']) {
          // Hit-testable: really inside the visible part of any scroll view.
          final finder =
              (label.startsWith('Log') || label.startsWith('Clear')
                      ? find.text(label)
                      : find.widgetWithText(InputDecorator, label))
                  .hitTestable();
          expect(finder, findsWidgets, reason: label);
          final rect = tester.getRect(finder.first);
          expect(rect.top, greaterThanOrEqualTo(0), reason: label);
          expect(rect.bottom, lessThanOrEqualTo(visibleBottom), reason: label);
        }
      });
    }
  });

  group('landscape strip with too little room', () {
    for (final (keyboard, scale) in [(520.0, 1.0), (400.0, 2.0)]) {
      testWidgets('Clear and Log stay pinned with a ${keyboard}dp keyboard, '
          '${scale}x text', (tester) async {
        const size = TestSizes.tabletLandscapeWide;
        await pumpTideline(
          tester,
          size: size,
          textScale: scale,
          log: sampleLog(5),
        );
        tester.view.viewInsets = FakeViewPadding(
          bottom: keyboard * tester.view.devicePixelRatio,
        );
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        for (final label in ['Log QSO', 'Clear entry']) {
          final button = find.text(label);
          final rect = tester.getRect(button);
          expect(rect.top, greaterThanOrEqualTo(0), reason: label);
          expect(
            rect.bottom,
            lessThanOrEqualTo(size.height - keyboard),
            reason: label,
          );
          // Not inside any scrollable, so no scroll position can hide them.
          expect(
            find.ancestor(of: button, matching: find.byType(Scrollable)),
            findsNothing,
            reason: label,
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('tablet portrait with the keyboard up', () {
    const keyboard = 380.0; // iPad portrait software keyboard, with margin
    const labels = [
      'Callsign',
      'Band',
      'Mode',
      'Frequency',
      'RST sent',
      'RST received',
      'Name',
      'Locator',
      'Comment',
      'Station location',
    ];

    for (final (size, scale) in [
      (TestSizes.tabletPortrait, 1.0),
      (const Size(834, 1210), 1.0),
      (const Size(1024, 1366), 1.0),
      (const Size(834, 1210), 1.5),
    ]) {
      testWidgets('all fields and buttons stay above it at $size, ${scale}x', (
        tester,
      ) async {
        await pumpTideline(
          tester,
          size: size,
          textScale: scale,
          log: sampleLog(5),
        );
        final dpr = tester.view.devicePixelRatio;
        tester.view.viewInsets = FakeViewPadding(bottom: keyboard * dpr);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();

        final visibleBottom = size.height - keyboard;
        for (final label in [...labels, 'Log QSO', 'Clear entry']) {
          final finder =
              (label.startsWith('Log') || label.startsWith('Clear')
                      ? find.text(label)
                      : find.widgetWithText(InputDecorator, label))
                  .hitTestable();
          expect(finder, findsWidgets, reason: label);
          final rect = tester.getRect(finder.first);
          expect(rect.top, greaterThanOrEqualTo(0), reason: label);
          expect(rect.bottom, lessThanOrEqualTo(visibleBottom), reason: label);
        }
        // The log stays usable beside the form.
        expect(find.text('Anna'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('rotation and direction', () {
    testWidgets(
      'typed input survives rotating between landscape and portrait',
      (tester) async {
        await pumpTideline(
          tester,
          size: TestSizes.tabletLandscapeWide,
          log: sampleLog(2),
        );
        await tester.enterText(field('Callsign'), 'dl1abc');
        await tester.enterText(field('Name'), 'Anna');
        await tester.pump();

        for (final size in [
          TestSizes.tabletPortrait,
          TestSizes.tabletLandscapeWide,
        ]) {
          tester.view.physicalSize = size * tester.view.devicePixelRatio;
          await tester.pumpAndSettle();
          expect(
            tester.widget<TextField>(field('Callsign')).controller!.text,
            'DL1ABC',
          );
          expect(
            tester.widget<TextField>(field('Name')).controller!.text,
            'Anna',
          );
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'the strip mirrors in right-to-left and fits the pseudo-locale',
      (tester) async {
        await pumpTideline(
          tester,
          size: TestSizes.tabletLandscapeWide,
          settings: const AppSettings(
            localeOverride: Locale('en', 'XA'),
            forceRtl: true,
          ),
        );
        tester.view.viewInsets = FakeViewPadding(
          bottom: 400 * tester.view.devicePixelRatio,
        );
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        final callsign = tester.getRect(find.byType(TextField).first);
        final last = tester.getRect(find.byType(TextField).at(5));
        // Reading order runs right to left; the row stays above the keyboard.
        expect(callsign.left, greaterThan(last.left));
        expect(
          tester.getRect(find.byType(TextField).last).bottom,
          lessThanOrEqualTo(TestSizes.tabletLandscapeWide.height - 400),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('accessibility with the keyboard up', () {
    testWidgets('tap targets, labels and contrast in the strip', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpTideline(
        tester,
        size: TestSizes.tabletLandscapeWide,
        log: sampleLog(4),
      );
      tester.view.viewInsets = FakeViewPadding(
        bottom: 400 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });

    testWidgets('fields are reached left to right, row by row', (tester) async {
      await pumpTideline(tester, size: TestSizes.tabletLandscapeWide);
      await tester.tap(field('Callsign'));
      await tester.pump();
      var previous = FocusManager.instance.primaryFocus!.rect;
      for (var i = 0; i < 9; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final next = FocusManager.instance.primaryFocus!.rect;
        // Either further right in the same row, or on a lower row.
        final sameRow = (next.top - previous.top).abs() < 20;
        expect(
          sameRow ? next.left > previous.left : next.top > previous.top,
          isTrue,
          reason: 'step ${i + 1}: $previous -> $next',
        );
        previous = next;
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('sync status is explained', () {
    testWidgets('a conflict offers both choices in plain language', (
      tester,
    ) async {
      final log = [
        LoggedQso(
          sampleLog(1).single.qso,
          const SyncStatus(
            state: SyncState.conflict,
            remoteQsoId: 5,
            problem: SyncProblem.readOnlyFieldsChanged,
          ),
        ),
      ];
      await pumpTideline(tester, size: TestSizes.tabletLandscape, log: log);
      await tester.tap(find.text('Anna').first);
      await tester.pumpAndSettle();
      expect(find.text('Needs decision'), findsWidgets);
      expect(find.textContaining("Wavelog can't change these"), findsOneWidget);
      expect(find.text('Replace in Wavelog'), findsOneWidget);
      expect(find.text("I'll fix it in Wavelog"), findsOneWidget);
    });

    testWidgets('a rejection shows the server message', (tester) async {
      final log = [
        LoggedQso(
          sampleLog(1).single.qso,
          const SyncStatus(
            state: SyncState.rejected,
            problem: SyncProblem.invalidData,
            serverMessage: 'Unknown band',
          ),
        ),
      ];
      await pumpTideline(tester, size: TestSizes.tabletLandscape, log: log);
      await tester.tap(find.text('Anna').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('Wavelog said: Unknown band'), findsOneWidget);
    });
  });

  testWidgets('callsigns are read letter by letter', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpTideline(tester, size: TestSizes.desktop, log: sampleLog(1));
    expect(find.bySemanticsLabel(RegExp('D L 1 A B C')), findsWidgets);
    handle.dispose();
  });

  group('accessibility with a full log', () {
    for (final theme in ThemeChoice.values) {
      for (final size in [TestSizes.phone, TestSizes.tabletLandscape]) {
        testWidgets('${theme.name} at ${size.width.toInt()}', (tester) async {
          final handle = tester.ensureSemantics();
          await pumpTideline(
            tester,
            size: size,
            settings: AppSettings(theme: theme),
            log: sampleLog(8),
          );
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    }

    testWidgets('200 % text on a phone with a full log', (tester) async {
      await pumpTideline(tester, textScale: 2, log: sampleLog(8));
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('first run shows onboarding', (tester) async {
    await pumpTideline(tester, accounts: const []);
    expect(find.text('Welcome to Tideline'), findsOneWidget);
    await tester.tap(find.text('Connect to Wavelog'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Server address'), 'http://log.example.org');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('only possible for servers in your own network'),
      findsOneWidget,
    );
  });
}
