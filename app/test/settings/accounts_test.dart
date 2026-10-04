import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import '../contest/contest_harness.dart';
import '../support/pump_app.dart';

const _club = Account(
  id: 'acc-2',
  label: 'Club',
  baseUrl: 'https://club.example.org',
  usesIndexPhp: true,
  allowHttpLan: false,
  scopes: {'qso:read', 'qso:write', 'station:read'},
  hasContestSessions: false,
);

/// Records what the account screens ask of the repository.
class _FakeAccounts extends Fake implements AccountRepository {
  final List<(String, String)> renamed = [];
  final List<String> removed = [];

  @override
  Future<void> rename(String accountId, String label) async =>
      renamed.add((accountId, label));

  @override
  Future<void> remove(String accountId) async => removed.add(accountId);
}

const List<Account> _two = [testAccount, _club];

Future<void> _openAccounts(WidgetTester tester) async {
  await tester.tap(find.text('Settings').last);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Wavelog accounts'));
  await tester.pumpAndSettle();
}

void main() {
  group('account menu on the log screen', () {
    testWidgets('is absent with one account', (tester) async {
      await pumpTideline(tester);
      expect(find.byTooltip('Switch account'), findsNothing);
    });

    testWidgets('shows the active account and switches', (tester) async {
      final app = await pumpTideline(tester, accounts: _two);
      expect(find.byTooltip('Switch account'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      await tester.tap(find.byTooltip('Switch account'));
      await tester.pumpAndSettle();
      expect(find.text('Club'), findsOneWidget);
      expect(find.text('Manage accounts'), findsOneWidget);
      await tester.tap(find.text('Club'));
      await tester.pumpAndSettle();

      expect(app.settings.activeAccounts, ['acc-2']);
      expect(find.text('Logging to Club'), findsOneWidget);
    });

    testWidgets('refuses to switch while an activation runs', (tester) async {
      final app = await pumpTideline(
        tester,
        accounts: _two,
        activation: const Activation(
          id: 'act-1',
          accountId: 'acc-1',
          program: ReferenceProgram.pota,
          reference: 'US-0001',
          startedAt: 1000,
        ),
      );
      await tester.tap(find.byTooltip('Switch account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Club'));
      await tester.pumpAndSettle();
      expect(app.settings.activeAccounts, isEmpty);
      expect(
        find.text(
          'An activation is running. End it before you switch accounts.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('refuses to switch while a contest runs', (tester) async {
      final app = await pumpContest(
        tester,
        open: false,
        size: TestSizes.phone,
        accounts: _two,
      );
      await tester.tap(find.byTooltip('Switch account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Club'));
      await tester.pumpAndSettle();
      expect(app.settings.activeAccounts, isEmpty);
      expect(
        find.text(
          'A contest session is running. End it before you switch accounts.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Manage accounts opens the settings page', (tester) async {
      await pumpTideline(tester, accounts: _two);
      await tester.tap(find.byTooltip('Switch account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Manage accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Add account'), findsOneWidget);
    });
  });

  group('accounts page', () {
    testWidgets('lists accounts with their state in text', (tester) async {
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        accounts: _two,
        pendingByAccount: const {'acc-1': 1, 'acc-2': 4},
      );
      await _openAccounts(tester);
      expect(find.textContaining('In use for logging'), findsOneWidget);
      expect(find.textContaining('1 QSO waiting'), findsOneWidget);
      expect(find.textContaining('4 QSOs waiting'), findsOneWidget);
      expect(find.text('Add account'), findsOneWidget);
    });

    testWidgets('Add account starts at the server step, with a way out', (
      tester,
    ) async {
      await pumpTideline(tester, size: TestSizes.tabletPortrait);
      await _openAccounts(tester);
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();
      expect(find.text('Your Wavelog server'), findsOneWidget);
      expect(find.text('Welcome to Tideline'), findsNothing);

      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Add account'), findsOneWidget);
    });
  });

  group('account page', () {
    Future<_FakeAccounts> open(
      WidgetTester tester, {
      String account = 'Club',
      Map<String, int> pending = const {},
      Activation? activation,
    }) async {
      final repo = _FakeAccounts();
      await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        accounts: _two,
        activation: activation,
        pendingByAccount: pending,
        overrides: [accountRepositoryProvider.overrideWithValue(repo)],
      );
      await _openAccounts(tester);
      await tester.tap(find.text(account).last);
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('another account can be put into use', (tester) async {
      final repo = _FakeAccounts();
      final app = await pumpTideline(
        tester,
        size: TestSizes.tabletPortrait,
        accounts: _two,
        overrides: [accountRepositoryProvider.overrideWithValue(repo)],
      );
      await _openAccounts(tester);
      await tester.tap(find.text('Club'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use for logging'));
      await tester.pumpAndSettle();
      expect(app.settings.activeAccounts, ['acc-2']);
    });

    testWidgets('the active account has no Use for logging', (tester) async {
      await open(tester, account: 'Home');
      expect(find.text('Use for logging'), findsNothing);
      expect(find.textContaining('In use for logging'), findsOneWidget);
    });

    testWidgets('Use for logging says why it is not possible', (tester) async {
      await open(
        tester,
        activation: const Activation(
          id: 'act-1',
          accountId: 'acc-1',
          program: ReferenceProgram.pota,
          reference: 'US-0001',
          startedAt: 1000,
        ),
      );
      expect(
        find.text(
          'An activation is running. End it before you switch accounts.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('rename saves the new name', (tester) async {
      final repo = await open(tester);
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Club station');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repo.renamed, [('acc-2', 'Club station')]);
    });

    testWidgets('remove asks first; Cancel changes nothing', (tester) async {
      final repo = await open(tester);
      await tester.tap(find.text('Remove account from this device'));
      await tester.pumpAndSettle();
      expect(find.text('Remove this account?'), findsOneWidget);
      expect(find.text('Export log, then remove'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repo.removed, isEmpty);
    });

    testWidgets('remove removes only this account, and leaves the page', (
      tester,
    ) async {
      final repo = await open(tester);
      await tester.tap(find.text('Remove account from this device'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Remove account from this device'),
        ),
      );
      await tester.pumpAndSettle();
      expect(repo.removed, ['acc-2']);
      expect(find.text('Add account'), findsOneWidget);
    });

    testWidgets('the removal dialog warns about waiting QSOs', (tester) async {
      await open(tester, pending: const {'acc-2': 3});
      await tester.tap(find.text('Remove account from this device'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('3 QSOs have not reached Wavelog'),
        findsOneWidget,
      );
    });
  });

  testWidgets('the sync screen breaks the waiting QSOs down per account', (
    tester,
  ) async {
    await pumpTideline(
      tester,
      accounts: _two,
      pending: 5,
      pendingByAccount: const {'acc-1': 2, 'acc-2': 3},
    );
    await tester.tap(find.text('Sync').last);
    await tester.pumpAndSettle();
    expect(find.text('Waiting, per account'), findsOneWidget);
    expect(find.textContaining('2 QSOs waiting'), findsOneWidget);
    expect(find.textContaining('3 QSOs waiting'), findsOneWidget);
  });
}
