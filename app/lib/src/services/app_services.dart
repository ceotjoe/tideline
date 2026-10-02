import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/tls.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';

/// Platform secure store. Overridden at startup.
final secretStoreProvider = Provider<SecretStore>(
  (ref) => throw UnimplementedError('secretStoreProvider must be overridden'),
);

/// This installation's device id. Overridden at startup.
final deviceIdProvider = Provider<String>(
  (ref) => throw UnimplementedError('deviceIdProvider must be overridden'),
);

/// The sync state machine.
final syncMachineProvider = Provider<SyncMachine>((ref) => SyncMachine());

/// QSO storage.
final qsoRepositoryProvider = Provider<QsoRepository>(
  (ref) => QsoRepository(
    ref.watch(databaseProvider),
    HlcClock(ref.watch(deviceIdProvider)),
    ref.watch(syncMachineProvider),
  ),
);

/// Accounts and station profiles.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(
    ref.watch(databaseProvider),
    ref.watch(secretStoreProvider),
  ),
);

/// The sync journal.
final journalRepositoryProvider = Provider<SyncJournalRepository>(
  (ref) => SyncJournalRepository(ref.watch(databaseProvider)),
);

/// All accounts.
final accountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(accountRepositoryProvider).watchAll(),
);

/// The account in use: the one chosen in settings, else the first.
final activeAccountProvider = Provider<Account?>((ref) {
  final accounts = ref.watch(accountsProvider).value ?? const [];
  if (accounts.isEmpty) return null;
  final chosen = ref.watch(settingsValuesProvider).value?['account.active'];
  return accounts.where((a) => a.id == chosen).firstOrNull ?? accounts.first;
});

/// Raw settings map (for keys that are not part of AppSettings).
final settingsValuesProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(settingsStoreProvider).watchAll(),
);

/// Station profiles of the active account.
final stationsProvider = StreamProvider<List<StationProfile>>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return Stream.value(const []);
  return ref.watch(accountRepositoryProvider).watchStations(account.id);
});

/// QSO counts per sync state for the active account.
final syncCountsProvider = StreamProvider<Map<SyncState, int>>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return Stream.value(const {});
  return ref.watch(qsoRepositoryProvider).watchCounts(account.id);
});

/// The sync journal of the active account.
final accountJournalProvider = StreamProvider<List<JournalEntry>>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return Stream.value(const []);
  return ref
      .watch(journalRepositoryProvider)
      .watch(accountId: account.id, limit: 100);
});

/// The log of the active account.
final logProvider = StreamProvider<List<LoggedQso>>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return Stream.value(const []);
  return ref.watch(qsoRepositoryProvider).watchLog(account.id);
});

/// Offline DXCC data, loaded once from the bundled AD1C country files.
final dxccProvider = FutureProvider<DxccDatabase>((ref) async {
  final csv = await rootBundle.loadString('assets/reference/cty.csv');
  return DxccDatabase.parseCsv(csv);
});

/// Builds a pinned API client for an account (ADR 0009).
WavelogClient clientForAccount(Account account, String token) {
  final base = Uri.parse(account.baseUrl);
  return WavelogClient(
    endpoint: WavelogEndpoint(base, usesIndexPhp: account.usesIndexPhp),
    token: token,
    httpClient: pinnedHttpClient(
      host: base.host,
      pinnedSha256: account.certPinSha256,
    ),
  );
}

/// The sync engine.
final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    qsos: ref.watch(qsoRepositoryProvider),
    accounts: ref.watch(accountRepositoryProvider),
    journal: ref.watch(journalRepositoryProvider),
    machine: ref.watch(syncMachineProvider),
    clientFor: clientForAccount,
  ),
);

/// What the sync controller is doing.
sealed class SyncActivity {
  const new();
}

/// Not syncing.
final class SyncIdle extends SyncActivity {
  /// Creates the state with the [last] run's result, if any.
  const new({this.last});

  /// Result of the previous run.
  final SyncRunResult? last;
}

/// A run is in progress.
final class SyncRunning extends SyncActivity {
  /// Creates the state.
  const new();
}

/// Many new QSOs are waiting; the user should review the upload first.
final class SyncNeedsReview extends SyncActivity {
  /// Creates the state for [count] waiting QSOs.
  const new(this.count);

  /// QSOs waiting for their first upload.
  final int count;
}

/// Uploads larger than this wait for the user's review (dry-run preview).
const int previewThreshold = 50;

/// Runs sync on the triggers from CLAUDE.md: app foreground, connectivity
/// regained and manual "Sync now". Never runs in the background on iOS.
class SyncController extends Notifier<SyncActivity> {
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  AppLifecycleListener? _lifecycle;
  bool _recovered = false;

  @override
  SyncActivity build() {
    _lifecycle = AppLifecycleListener(onResume: syncNow);
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      // An interface came up; the probe inside the run checks real reach.
      if (!results.contains(ConnectivityResult.none)) unawaited(syncNow());
    });
    ref.onDispose(() {
      _lifecycle?.dispose();
      unawaited(_connectivity?.cancel());
    });
    return const SyncIdle();
  }

  /// Starts a run for the active account unless one is running. Large
  /// first uploads wait for review unless [reviewed] is true.
  Future<SyncRunResult?> syncNow({bool reviewed = false}) async {
    final account = ref.read(activeAccountProvider);
    if (account == null || state is SyncRunning) return null;
    final engine = ref.read(syncEngineProvider);
    if (!reviewed) {
      final waiting =
          (await ref.read(qsoRepositoryProvider).pendingCreates(account.id))
              .length;
      if (waiting > previewThreshold) {
        state = SyncNeedsReview(waiting);
        return null;
      }
    }
    state = const SyncRunning();
    try {
      if (!_recovered) {
        await engine.recoverAfterRestart(account.id);
        _recovered = true;
      }
      final result = await engine.sync(account.id);
      state = SyncIdle(last: result);
      return result;
    } on Object {
      state = const SyncIdle();
      rethrow;
    }
  }
}

/// The sync controller.
final syncControllerProvider = NotifierProvider<SyncController, SyncActivity>(
  SyncController.new,
);
