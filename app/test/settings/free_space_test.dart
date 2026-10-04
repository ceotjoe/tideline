import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../support/pump_app.dart';

LoggedQso _synced(int i, {String call = 'DL1ABC'}) => LoggedQso(
  Qso(
    id: 'e$i',
    accountId: 'acc-1',
    stationProfileId: 'st-1',
    call: Callsign.tryParse(call)!,
    timeOn: UtcDateTime(DateTime.utc(2020, 1, 1, 12, i)),
    band: Band.tryParse('20m')!,
    mode: Mode.tryParse('CW')!,
  ),
  SyncStatus(state: SyncState.synced, remoteQsoId: 100 + i),
);

/// Records what would be saved instead of opening a file dialog.
class _Transfer implements DataTransfer {
  final List<String> saved = [];

  /// What the save dialog returns: false means the user cancelled.
  bool accept = true;

  @override
  Uint8List exportAdifOf(Iterable<Qso> qsos) =>
      Uint8List.fromList(utf8.encode('adif ${qsos.length}'));

  @override
  Future<bool> saveFile(String name, Uint8List bytes, String mime) async {
    if (!accept) return false;
    saved.add(utf8.decode(bytes));
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _openPage(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Wavelog accounts'),
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text('Wavelog accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Wavelog accounts'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Home'));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Remove synced QSOs from this device'),
    100,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(find.text('Remove synced QSOs from this device'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Remove synced QSOs from this device'));
  await tester.pumpAndSettle();
}

void main() {
  group('the page', () {
    testWidgets('says what it does and how many QSOs qualify', (tester) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        evictionRepository: FakeEvictionRepository(
          eligible: [_synced(1), _synced(2), _synced(3)],
          blocked: const {
            EvictionBlock.notSynced: 2,
            EvictionBlock.inContest: 1,
          },
          evicted: 5,
        ),
      );
      await _openPage(tester);
      expect(
        find.textContaining('Nothing is deleted on Wavelog'),
        findsOneWidget,
      );
      expect(find.text('3 QSOs can be removed'), findsOneWidget);
      expect(find.text('2 QSOs are not on Wavelog yet'), findsOneWidget);
      expect(find.text('1 QSO belongs to a contest session'), findsOneWidget);
      expect(find.text('5 QSOs removed so far'), findsOneWidget);
      expect(find.text('Check with Wavelog'), findsOneWidget);
    });

    testWidgets('choosing another age asks again', (tester) async {
      final repo = FakeEvictionRepository(eligible: [_synced(1)]);
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        evictionRepository: repo,
      );
      await _openPage(tester);
      expect(repo.cutoffs.last, isNotNull); // older than 1 year
      await tester.tap(find.text('All synced QSOs'));
      await tester.pumpAndSettle();
      expect(repo.cutoffs.last, isNull);
      await tester.tap(find.text('Older than 5 years'));
      await tester.pumpAndSettle();
      final fiveYears = repo.cutoffs.last!;
      final now = DateTime.now().toUtc();
      expect(
        DateTime.fromMillisecondsSinceEpoch(fiveYears, isUtc: true).year,
        now.year - 5,
      );
    });

    testWidgets('with nothing to remove, Check is off', (tester) async {
      await pumpTideline(tester, size: TestSizes.tabletPortrait);
      await _openPage(tester);
      expect(find.text('No QSOs can be removed'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Check with Wavelog'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('checking shows what Wavelog confirms and what stays', (
      tester,
    ) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        evictionRepository: FakeEvictionRepository(
          eligible: [_synced(1), _synced(2), _synced(3)],
        ),
        evictionService: FakeEvictionService(
          confirmed: [_synced(1), _synced(2)],
          missing: [_synced(3)],
        ),
      );
      await _openPage(tester);
      await tester.tap(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      expect(find.text('Wavelog has 2 of them'), findsOneWidget);
      expect(find.text('1 was not found on Wavelog and stays'), findsOneWidget);
      expect(find.text('Remove 2 QSOs from this device'), findsOneWidget);
    });

    for (final (problem, text) in [
      (EvictionCheckProblem.offline, 'Wavelog could not be reached'),
      (EvictionCheckProblem.unauthorized, 'The token no longer works'),
      (EvictionCheckProblem.server, 'Wavelog answered with an error'),
      (EvictionCheckProblem.tooMany, 'too many QSOs in that period'),
    ]) {
      testWidgets('a failed check (${problem.name}) removes nothing', (
        tester,
      ) async {
        final service = FakeEvictionService(problem: problem);
        await pumpTideline(
          tester,
          size: TestSizes.tabletPortrait,
          evictionRepository: FakeEvictionRepository(eligible: [_synced(1)]),
          evictionService: service,
        );
        await _openPage(tester);
        await tester.tap(find.text('Check with Wavelog'));
        await tester.pumpAndSettle();
        expect(find.textContaining(text), findsOneWidget);
        expect(find.textContaining('Remove 1 QSO from'), findsNothing);
        expect(service.carried, isEmpty);
      });
    }

    testWidgets('Cancel in the confirmation removes nothing', (tester) async {
      final service = FakeEvictionService(confirmed: [_synced(1)]);
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        evictionRepository: FakeEvictionRepository(eligible: [_synced(1)]),
        evictionService: service,
      );
      await _openPage(tester);
      await tester.tap(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove 1 QSO from this device'));
      await tester.pumpAndSettle();
      expect(find.text('Remove from this device?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(service.carried, isEmpty);
    });

    testWidgets('Remove carries out the checked plan', (tester) async {
      final service = FakeEvictionService(confirmed: [_synced(1), _synced(2)]);
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        evictionRepository: FakeEvictionRepository(
          eligible: [_synced(1), _synced(2)],
        ),
        evictionService: service,
      );
      await _openPage(tester);
      await tester.tap(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove 2 QSOs from this device'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(service.carried.single.confirmed, hasLength(2));
      expect(
        find.text(
          'Removed 2 QSOs from this device. They are still on Wavelog.',
        ),
        findsWidgets,
      );
    });

    testWidgets('Export, then remove saves the QSOs first', (tester) async {
      final service = FakeEvictionService(confirmed: [_synced(1), _synced(2)]);
      final transfer = _Transfer();
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        evictionRepository: FakeEvictionRepository(
          eligible: [_synced(1), _synced(2)],
        ),
        evictionService: service,
        overrides: [dataTransferProvider.overrideWithValue(transfer)],
      );
      await _openPage(tester);
      await tester.tap(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove 2 QSOs from this device'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export, then remove'));
      await tester.pumpAndSettle();
      expect(transfer.saved, ['adif 2']);
      expect(service.carried, hasLength(1));
    });

    testWidgets('a cancelled export keeps everything', (tester) async {
      final service = FakeEvictionService(confirmed: [_synced(1)]);
      final transfer = _Transfer()..accept = false;
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        evictionRepository: FakeEvictionRepository(eligible: [_synced(1)]),
        evictionService: service,
        overrides: [dataTransferProvider.overrideWithValue(transfer)],
      );
      await _openPage(tester);
      await tester.tap(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove 1 QSO from this device'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Export, then remove'));
      await tester.pumpAndSettle();
      expect(service.carried, isEmpty);
    });

    testWidgets('meets the guidelines at 200 % text', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpTideline(
        tester,
        textScale: 2,
        evictionRepository: FakeEvictionRepository(
          eligible: [_synced(1)],
          blocked: const {EvictionBlock.inActivation: 1},
        ),
        evictionService: FakeEvictionService(confirmed: [_synced(1)]),
      );
      await _openPage(tester);
      await tester.scrollUntilVisible(
        find.text('Check with Wavelog'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check with Wavelog'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });

  group('one QSO from its details', () {
    Future<void> openDetail(WidgetTester tester, LoggedQso item) async {
      await tester.tap(find.text(item.qso.call.value).first);
      await tester.pumpAndSettle();
    }

    testWidgets('a synced QSO can be removed after Wavelog confirms', (
      tester,
    ) async {
      final item = _synced(1);
      final service = FakeEvictionService(confirmed: [item]);
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        log: [item],
        evictionService: service,
      );
      await openDetail(tester, item);
      await tester.tap(find.text('Remove from this device'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(service.planned.single, {'e1'});
      expect(service.carried, hasLength(1));
    });

    testWidgets('a QSO Wavelog cannot confirm stays', (tester) async {
      final item = _synced(1);
      final service = FakeEvictionService(missing: [item]);
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        log: [item],
        evictionService: service,
      );
      await openDetail(tester, item);
      await tester.tap(find.text('Remove from this device'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(service.carried, isEmpty);
      expect(
        find.text('Not removed: Wavelog could not confirm this QSO.'),
        findsOneWidget,
      );
    });

    testWidgets('no answer from Wavelog: nothing is removed', (tester) async {
      final item = _synced(1);
      final service = FakeEvictionService(
        problem: EvictionCheckProblem.offline,
      );
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        log: [item],
        evictionService: service,
      );
      await openDetail(tester, item);
      await tester.tap(find.text('Remove from this device'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Remove'));
      await tester.pumpAndSettle();
      expect(service.carried, isEmpty);
      expect(find.textContaining('could not be reached'), findsOneWidget);
    });

    testWidgets('a QSO that is not synced has no such button', (tester) async {
      final item = LoggedQso(
        _synced(1).qso,
        const SyncStatus(state: SyncState.queued),
      );
      await pumpTideline(tester, size: TestSizes.tabletPortrait, log: [item]);
      await openDetail(tester, item);
      expect(find.text('Remove from this device'), findsNothing);
      expect(find.text('Delete QSO'), findsOneWidget);
    });
  });
}
