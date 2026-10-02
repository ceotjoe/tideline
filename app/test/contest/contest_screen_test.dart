// Tests favour readable steps over cascades and tear-offs.
// ignore_for_file: async_return_with_no_await
// ignore_for_file: cascade_invocations
// ignore_for_file: prefer_foreach

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/contest/contest_rates_panel.dart';
import 'package:tideline/src/features/contest/contest_recent_list.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';
import 'contest_harness.dart';

/// Scrolls to the recent-QSO row containing [text] and opens its editor.
Future<void> openRow(WidgetTester tester, String text) async {
  final rows = find.textContaining(text);
  await tester.scrollUntilVisible(
    rows,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(rows.first);
  await tester.pumpAndSettle();
  await tester.tap(rows.first);
  await tester.pumpAndSettle();
  expect(find.byType(ContestInlineEditor), findsOneWidget);
}

void main() {
  group('layout follows the window size class', () {
    testWidgets('phone: entry, then a collapsible panel, then recent QSOs', (
      tester,
    ) async {
      final backend = ContestBackend();
      backend.startSession('cq-wpx-ssb', usesSerial: true);
      seedSessionQsos(backend, 3);
      await pumpContest(tester, size: TestSizes.phone, backend: backend);

      // Collapsed: one line with the score, no metric block.
      expect(find.textContaining('Score and rates · 3 QSOs'), findsOneWidget);
      expect(find.text('Claimed score (estimate)'), findsNothing);
      await tester.tap(find.textContaining('Score and rates'));
      await tester.pumpAndSettle();
      expect(find.text('Claimed score (estimate)'), findsOneWidget);
      expect(
        find.textContaining('log check decides the real result'),
        findsOneWidget,
      );
      final entry = tester.getTopLeft(field('Callsign')).dy;
      final panel = tester.getTopLeft(find.text('Claimed score (estimate)')).dy;
      expect(panel, greaterThan(entry));
      // Collapse again.
      await tester.tap(find.textContaining('Score and rates'));
      await tester.pumpAndSettle();
      expect(find.text('Claimed score (estimate)'), findsNothing);
    });

    testWidgets('tablet portrait: entry and panel stacked, panel open', (
      tester,
    ) async {
      final backend = ContestBackend();
      backend.startSession('cq-wpx-ssb', usesSerial: true);
      seedSessionQsos(backend, 3);
      await pumpContest(
        tester,
        size: TestSizes.tabletPortrait,
        backend: backend,
      );
      final entry = tester.getTopLeft(field('Callsign'));
      final panel = tester.getTopLeft(find.text('Claimed score (estimate)'));
      expect(panel.dy, greaterThan(entry.dy));
      expect((panel.dx - entry.dx).abs(), lessThan(80));
      expect(find.text('Recent QSOs'), findsOneWidget);
    });

    testWidgets('tablet landscape: panel in a side column', (tester) async {
      final backend = ContestBackend();
      backend.startSession('cq-wpx-ssb', usesSerial: true);
      seedSessionQsos(backend, 3);
      await pumpContest(
        tester,
        size: TestSizes.tabletLandscape,
        backend: backend,
      );
      final call = tester.getTopRight(field('Callsign'));
      final panel = tester.getTopLeft(find.text('Claimed score (estimate)'));
      expect(panel.dx, greaterThan(call.dx));
      // Entry and recent QSOs share the main column.
      final recent = tester.getTopLeft(find.text('Recent QSOs'));
      expect(
        recent.dy,
        greaterThan(tester.getBottomLeft(field('Callsign')).dy),
      );
      expect(recent.dx, lessThan(call.dx));
    });

    testWidgets('resizing or rotating never loses typed input', (tester) async {
      final app = await pumpContest(tester, size: TestSizes.phone);
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.enterText(field('Serial no.'), '42');
      await tester.pump(const Duration(milliseconds: 400));

      for (final size in [
        TestSizes.tabletLandscape,
        TestSizes.tabletPortrait,
        TestSizes.phone,
      ]) {
        tester.view.physicalSize = size * tester.view.devicePixelRatio;
        await tester.pumpAndSettle();
        expect(textOf(tester, 'Callsign'), 'DL1ABC', reason: '$size');
        expect(textOf(tester, 'Serial no.'), '42', reason: '$size');
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.logged.single.field('SRX'), '42');
    });

    testWidgets('the panel shows rates, bands and the estimate label', (
      tester,
    ) async {
      final backend = ContestBackend();
      backend.startSession('cq-wpx-ssb', usesSerial: true);
      seedSessionQsos(backend, 3);
      await pumpContest(tester, backend: backend);
      expect(find.text('Claimed score (estimate)'), findsOneWidget);
      expect(find.text('Last 10 minutes'), findsOneWidget);
      expect(find.text('18/h'), findsOneWidget); // 3 QSOs in 10 minutes
      expect(find.text('Last 100 QSOs'), findsOneWidget);
      expect(find.text('Best 60 minutes'), findsOneWidget);
      expect(find.textContaining('3 QSOs from'), findsOneWidget);
      expect(find.text('By band'), findsOneWidget);
      expect(find.text('20 m'), findsWidgets);
      // Logging one more updates the numbers live.
      await tester.enterText(field('Callsign'), 'OH2AA');
      await tester.enterText(field('Serial no.'), '3');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('24/h'), findsOneWidget);
    });

    testWidgets('the rates ticker stops while the panel is not visible', (
      tester,
    ) async {
      await pumpContest(tester);
      expect(ContestRatesPanel.activeTickers, 1);
      final binding = tester.binding;
      // Resumed -> inactive -> hidden -> paused, as the platform reports it.
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
      ]) {
        binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      expect(ContestRatesPanel.activeTickers, 0);
      for (final state in [
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pump();
      expect(ContestRatesPanel.activeTickers, 1);
      // Covered by another route (the sessions page): stopped as well.
      await tester.tap(find.byTooltip('Sessions'));
      await tester.pumpAndSettle();
      expect(ContestRatesPanel.activeTickers, 0);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(ContestRatesPanel.activeTickers, 1);
    });
  });

  group('entry points', () {
    testWidgets('the log screen shows a banner that returns to the contest', (
      tester,
    ) async {
      final backend = ContestBackend();
      backend.startSession('cq-ww-ssb');
      await pumpContest(tester, backend: backend, open: false);
      expect(
        find.text('Contest session active: CQ World Wide DX Contest (SSB)'),
        findsOneWidget,
      );
      await tester.tap(find.text('Return to contest'));
      await tester.pumpAndSettle();
      expect(find.text('Sent: RST 59 · CQ zone 14'), findsOneWidget);
      // Back returns to the log and its banner.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Return to contest'), findsOneWidget);
    });

    testWidgets('no banner without a session', (tester) async {
      await pumpTideline(tester);
      expect(find.text('Return to contest'), findsNothing);
    });

    testWidgets('Ctrl+Shift+C opens contest mode from anywhere', (
      tester,
    ) async {
      final backend = ContestBackend();
      backend.startSession('cq-ww-ssb');
      await pumpContest(tester, backend: backend, open: false);
      await chord(tester, LogicalKeyboardKey.keyC, shift: true);
      await tester.pumpAndSettle();
      expect(find.text('Sent: RST 59 · CQ zone 14'), findsOneWidget);
    });
  });

  group('CQ WW exchange', () {
    testWidgets('report and zone: keyboard types, formatters, hints', (
      tester,
    ) async {
      final app = await pumpContest(tester, definitionId: 'cq-ww-ssb');
      expect(find.text('Sent: RST 59 · CQ zone 14'), findsOneWidget);
      await tester.enterText(field('Callsign'), 'ea8abc');
      await tester.enterText(field('CQ zone'), '4x0');
      expect(textOf(tester, 'CQ zone'), '40');
      await tester.enterText(field('CQ zone'), '99');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(app.contest.logged, isEmpty);
      expect(find.text('CQ zone is out of range.'), findsOneWidget);
      await tester.enterText(field('CQ zone'), '33');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      final qso = app.contest.logged.single;
      expect(qso.field('CQZ'), '33');
      expect(qso.field('STX_STRING'), '14');
      expect(qso.field('STX'), isNull); // no serials in this contest
      expect(qso.field('COUNTRY'), isNotNull);
    });
  });

  group('accessibility', () {
    for (final theme in ThemeChoice.values) {
      for (final size in [TestSizes.phone, TestSizes.tabletLandscape]) {
        testWidgets('${theme.name} at ${size.width.toInt()}', (tester) async {
          final handle = tester.ensureSemantics();
          final backend = ContestBackend(
            scp: ScpDatabase.parse('DL1ABC\nDL1ABD\n'),
          );
          backend.startSession('cq-wpx-ssb', usesSerial: true);
          seedSessionQsos(backend, 6);
          await pumpContest(
            tester,
            size: size,
            settings: AppSettings(theme: theme),
            backend: backend,
          );
          // Show every kind of hint, and an open editor.
          await typeCall(tester, 'DL1ABC');
          expect(find.textContaining('Dupe:'), findsOneWidget);
          await openRow(tester, '59 10');
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          handle.dispose();
        });
      }
    }

    testWidgets('glove mode keeps larger targets than dense', (tester) async {
      await pumpContest(
        tester,
        settings: const AppSettings(density: TidelineDensity.glove),
      );
      final box = tester.getSize(find.widgetWithText(FilledButton, 'Log QSO'));
      expect(box.height, greaterThanOrEqualTo(64));
    });

    testWidgets('callsigns in the list are read letter by letter', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final backend = ContestBackend();
      backend.startSession('cq-wpx-ssb', usesSerial: true);
      seedSessionQsos(backend, 2);
      await pumpContest(tester, backend: backend);
      expect(find.bySemanticsLabel(RegExp('D L 1 A B C')), findsWidgets);
      handle.dispose();
    });

    for (final size in [TestSizes.phone, TestSizes.tabletPortrait]) {
      testWidgets('200 % text at ${size.width.toInt()} dp', (tester) async {
        final backend = ContestBackend();
        backend.startSession('cq-wpx-ssb', usesSerial: true);
        seedSessionQsos(backend, 6);
        await pumpContest(tester, size: size, textScale: 2, backend: backend);
        await typeCall(tester, 'DL1ABC');
        expect(tester.takeException(), isNull);
        await openRow(tester, '59 10');
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('right-to-left and pseudo-locale', () {
    Future<Pumped> pumpPseudo(WidgetTester tester) async {
      final backend = ContestBackend(
        scp: ScpDatabase.parse('DL1ABC\nDL1ABD\n'),
      );
      backend.startSession('cq-wpx-ssb', usesSerial: true);
      seedSessionQsos(backend, 4);
      return pumpContest(
        tester,
        size: TestSizes.tabletLandscape,
        backend: backend,
        settings: const AppSettings(
          localeOverride: Locale('en', 'XA'),
          forceRtl: true,
        ),
      );
    }

    testWidgets('the layout mirrors and nothing overflows', (tester) async {
      await pumpPseudo(tester);
      await typeCall(tester, 'DL1ABC');
      await openRow(tester, '59 10');
      expect(tester.takeException(), isNull);
      // The score column sits on the left in a right-to-left layout.
      final panel = tester.getTopLeft(find.byType(ContestRatesPanel));
      final call = tester.getTopLeft(find.byType(TextField).first);
      expect(panel.dx, lessThan(call.dx));
    });

    testWidgets('every label comes from the pseudo-locale', (tester) async {
      await pumpPseudo(tester);
      await typeCall(tester, 'DL1ABX');
      final data = RegExp(
        r'^([A-Z0-9/]{3,}|\d+ m|SSB|CW|FM|AM|\d+|\d{2}:\d{2} UTC)$',
      );
      final offenders = [
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          if (t.data ?? t.textSpan?.toPlainText() ?? '' case final s
              when RegExp('[A-Za-z]').hasMatch(s) &&
                  !s.contains('[') &&
                  !data.hasMatch(s) &&
                  !s.contains(testStation.name) &&
                  !s.contains('CQ WPX'))
            s,
      ];
      expect(offenders, isEmpty);
    });
  });
}
