import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';

import '../support/pump_app.dart';

/// The sync controller without the connectivity and lifecycle plugins.
class _Sync extends SyncController {
  @override
  SyncActivity build() => const SyncIdle();
}

class _Engine extends Fake implements SyncEngine {
  final List<String> recovered = [];
  final List<String> synced = [];

  @override
  Future<void> recoverAfterRestart(String accountId) async =>
      recovered.add(accountId);

  @override
  Future<SyncRunResult> sync(String accountId) async {
    synced.add(accountId);
    return SyncRunResult(SyncRunOutcome.completed, processed: synced.length);
  }
}

/// Reports a number of new QSOs per account.
class _Qsos extends Fake implements QsoRepository {
  new(this.waiting);

  final Map<String, int> waiting;

  @override
  Future<List<LoggedQso>> pendingCreates(String accountId) async => [
    for (var i = 0; i < (waiting[accountId] ?? 0); i++) ...sampleLog(1),
  ];
}

const _b = Account(
  id: 'acc-2',
  label: 'Club',
  baseUrl: 'https://club.example.org',
  usesIndexPhp: true,
  allowHttpLan: false,
  scopes: {'qso:write'},
  hasContestSessions: false,
);

ProviderContainer _container(
  _Engine engine, {
  Map<String, int> waiting = const {},
  String active = 'acc-2',
}) {
  final overrides = <Override>[
    accountsProvider.overrideWith((ref) => Stream.value([testAccount, _b])),
    settingsValuesProvider.overrideWith(
      (ref) => Stream.value({'account.active': active}),
    ),
    qsoRepositoryProvider.overrideWithValue(_Qsos(waiting)),
    syncEngineProvider.overrideWithValue(engine),
    syncControllerProvider.overrideWith(_Sync.new),
  ];
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

/// Waits until the providers have their first values. A listener keeps them
/// alive meanwhile.
Future<void> _ready(ProviderContainer c) async {
  c
    ..listen(accountsProvider, (_, _) {})
    ..listen(settingsValuesProvider, (_, _) {});
  await c.read(accountsProvider.future);
  await c.read(settingsValuesProvider.future);
}

void main() {
  test('syncs every account, the active one first', () async {
    final engine = _Engine();
    final c = _container(engine);
    await _ready(c);
    final result = await c.read(syncControllerProvider.notifier).syncNow();
    expect(engine.synced, ['acc-2', 'acc-1']);
    // The result shown is the active account's.
    expect(result?.processed, 1);
    expect(c.read(syncControllerProvider), isA<SyncIdle>());
  });

  test('recovers each account once, not only the first', () async {
    final engine = _Engine();
    final c = _container(engine);
    await _ready(c);
    final sync = c.read(syncControllerProvider.notifier);
    await sync.syncNow();
    await sync.syncNow();
    expect(engine.recovered, ['acc-2', 'acc-1']);
  });

  test(
    'a large first upload of one account waits; the others still sync',
    () async {
      final engine = _Engine();
      final c = _container(engine, waiting: {'acc-2': previewThreshold + 1});
      await _ready(c);
      await c.read(syncControllerProvider.notifier).syncNow();
      expect(engine.synced, ['acc-1']);
      final state = c.read(syncControllerProvider);
      expect(state, isA<SyncNeedsReview>());
      expect((state as SyncNeedsReview).accountId, 'acc-2');
      expect(state.count, previewThreshold + 1);
    },
  );

  test('a reviewed upload covers only the account asked for', () async {
    final engine = _Engine();
    final c = _container(engine, waiting: {'acc-2': previewThreshold + 1});
    await _ready(c);
    await c
        .read(syncControllerProvider.notifier)
        .syncNow(reviewed: true, accountId: 'acc-2');
    expect(engine.synced, ['acc-2']);
  });
}
