import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/features/log/worked_hint.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/contest_fakes.dart';
import '../support/pump_app.dart';

Finder field(String label) => find.widgetWithText(TextField, label);

final int _first = DateTime.utc(2024, 3, 5, 12).millisecondsSinceEpoch;

WorkedSummary _summary(Set<(String, String)> slots) => WorkedSummary(
  bands: {for (final s in slots) s.$1},
  modes: {for (final s in slots) s.$2},
  slots: slots,
  firstTime: _first,
);

Future<ContestBackend> _typeCall(
  WidgetTester tester, {
  WorkedSummary? worked,
  Size size = TestSizes.desktop,
}) async {
  final backend = ContestBackend(definitions: const []);
  if (worked != null) backend.worked['DL1ABC'] = worked;
  await pumpTideline(tester, size: size, contest: backend);
  await tester.enterText(field('Callsign'), 'dl1abc');
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  group('worked-before hint in the normal log', () {
    testWidgets('a new call', (tester) async {
      await _typeCall(tester);
      expect(find.text('New call: not in your log yet'), findsOneWidget);
      expect(find.byIcon(Icons.fiber_new_outlined), findsOneWidget);
    });

    testWidgets('worked on this band and mode, with date and bands', (
      tester,
    ) async {
      await _typeCall(
        tester,
        worked: _summary({('20m', 'SSB'), ('40m', 'CW')}),
      );
      expect(
        find.text(
          'Worked before on this band and mode · '
          'first contact Mar 5, 2024, bands 40 m, 20 m',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
    });

    testWidgets('a new band', (tester) async {
      await _typeCall(tester, worked: _summary({('40m', 'SSB')}));
      expect(
        find.textContaining('Worked before, but not on this band ·'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.add_chart), findsOneWidget);
    });

    testWidgets('a new mode', (tester) async {
      await _typeCall(tester, worked: _summary({('20m', 'CW')}));
      expect(
        find.textContaining('Worked before, but not in this mode ·'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
    });

    testWidgets('a new combination of band and mode', (tester) async {
      await _typeCall(
        tester,
        worked: _summary({('20m', 'CW'), ('40m', 'SSB')}),
      );
      expect(
        find.textContaining('not on this band and mode together'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.grid_view_outlined), findsOneWidget);
    });

    testWidgets('no hint before a callsign is typed', (tester) async {
      await pumpTideline(
        tester,
        size: TestSizes.desktop,
        contest: ContestBackend(definitions: const []),
      );
      expect(find.textContaining('New call'), findsNothing);
      expect(find.byIcon(Icons.fiber_new_outlined), findsNothing);
    });

    testWidgets('a hint is announced and stays readable at 200 % text', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpTideline(
        tester,
        contest: ContestBackend(definitions: const []),
        textScale: 2,
      );
      await tester.enterText(field('Callsign'), 'DL1ABC');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('New call: not in your log yet'), findsOneWidget);
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('lookupWorkedInfo', () {
    test('is the one lookup behind both hints', () async {
      final backend = ContestBackend(definitions: const [])
        ..worked['DL1ABC'] = _summary({('20m', 'CW')});
      final info = await lookupWorkedInfo(
        backend.workedRepository,
        'acc-1',
        call: 'DL1ABC',
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('CW')!,
      );
      expect(info!.status, WorkedSlotStatus.workedBefore);
      expect(info.summary.firstTime, _first);
    });

    test('an invalid call has no answer', () async {
      final info = await lookupWorkedInfo(
        ContestBackend(definitions: const []).workedRepository,
        'acc-1',
        call: 'HELLO',
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('CW')!,
      );
      expect(info, isNull);
    });
  });
}
