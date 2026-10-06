import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:tideline/src/features/contest/contest_seed.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/sync_scheduler.dart';
import 'package:tideline/src/services/tls.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';
import 'package:wavelog_client/wavelog_client.dart';
import 'package:wavelog_mock/wavelog_mock.dart' show isDemoHost;

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

/// The hybrid logical clock of this device. One instance serves every
/// repository, so timestamps stay strictly increasing across tables.
final hlcClockProvider = Provider<HlcClock>(
  (ref) => HlcClock(ref.watch(deviceIdProvider)),
);

/// QSO storage.
final qsoRepositoryProvider = Provider<QsoRepository>(
  (ref) => QsoRepository(
    ref.watch(databaseProvider),
    ref.watch(hlcClockProvider),
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

/// QSOs waiting to sync, per account id (accounts with none are absent).
final pendingByAccountProvider = StreamProvider<Map<String, int>>(
  (ref) =>
      SyncStatusRepository(ref.watch(databaseProvider)).watchPendingByAccount(),
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

/// Contest definitions (bundled and imported).
final contestDefinitionRepositoryProvider =
    Provider<ContestDefinitionRepository>(
      (ref) => ContestDefinitionRepository(ref.watch(databaseProvider)),
    );

/// Contest sessions and atomic serial allocation.
final contestSessionRepositoryProvider = Provider<ContestSessionRepository>(
  (ref) => ContestSessionRepository(
    ref.watch(databaseProvider),
    ref.watch(hlcClockProvider),
    ref.watch(qsoRepositoryProvider),
  ),
);

/// The worked-before index of the main log.
final workedBeforeRepositoryProvider = Provider<WorkedBeforeRepository>(
  (ref) => WorkedBeforeRepository(ref.watch(databaseProvider)),
);

/// The Super Check Partial pack the user downloaded, if any.
final scpStoreProvider = Provider<ScpStore>(
  (ref) => ScpStore(ref.watch(databaseProvider)),
);

/// Loads the bundled contest definitions into the database once per start.
///
/// Runs off the critical path: nothing waits for it, and a failure only
/// ends up in the log (contest names and rule errors, never personal data).
final contestSeedProvider = FutureProvider<ContestSeedReport?>(
  (ref) => seedBundledContests(
    bundle: rootBundle,
    repository: ref.watch(contestDefinitionRepositoryProvider),
  ),
);

/// Whether [account] is the built-in demo account (ADR 0031).
bool isDemoAccount(Account account) =>
    isDemoHost(Uri.tryParse(account.baseUrl)?.host);

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

/// Removing the local copy of QSOs that Wavelog has (ADR 0027).
final qsoEvictionRepositoryProvider = Provider<QsoEvictionRepository>(
  (ref) => QsoEvictionRepository(
    ref.watch(databaseProvider),
    ref.watch(journalRepositoryProvider),
  ),
);

/// Plans the removal by asking the account's Wavelog first.
final qsoEvictionServiceProvider = Provider<QsoEvictionService>(
  (ref) => QsoEvictionService(
    eviction: ref.watch(qsoEvictionRepositoryProvider),
    accounts: ref.watch(accountRepositoryProvider),
    clientFor: clientForAccount,
  ),
);

/// How many QSOs of an account were removed from this device so far.
final StreamProviderFamily<int, String> evictedCountProvider = StreamProvider
    .autoDispose
    .family<int, String>(
      (ref, accountId) =>
          ref.watch(qsoEvictionRepositoryProvider).watchEvictedCount(accountId),
    );

/// The sync engine, with the optional steps after the QSO pass: mirroring
/// contest sessions on Wavelog 3.2+ and pulling the worked-before index.
final syncEngineProvider = Provider<SyncEngine>(
  (ref) => SyncEngine(
    qsos: ref.watch(qsoRepositoryProvider),
    accounts: ref.watch(accountRepositoryProvider),
    journal: ref.watch(journalRepositoryProvider),
    machine: ref.watch(syncMachineProvider),
    clientFor: clientForAccount,
    contestSessions: ContestSessionSync(
      sessions: ref.watch(contestSessionRepositoryProvider),
      definitions: ref.watch(contestDefinitionRepositoryProvider),
      journal: ref.watch(journalRepositoryProvider),
    ),
    workedBefore: ref.watch(workedBeforeRepositoryProvider),
  ),
);

/// Builds the local worked-before index once per account, in the
/// background, when it was never built (a log that predates the index, or a
/// restored backup). Afterwards every QSO write keeps it current. Nothing
/// waits for this and a failure only ends up in the log.
final workedBeforeIndexProvider = FutureProvider<void>((ref) async {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return;
  try {
    await ref.watch(workedBeforeRepositoryProvider).ensureBuilt(account.id);
  } on Object catch (e) {
    debugPrint('worked-before index build failed: ${e.runtimeType}');
  }
});

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
  /// Creates the state for [count] QSOs of [accountId] waiting for their
  /// first upload.
  const new(this.count, {required this.accountId});

  /// QSOs waiting for their first upload.
  final int count;

  /// The account whose upload waits for review.
  final String accountId;
}

/// Uploads larger than this wait for the user's review (dry-run preview).
const int previewThreshold = 50;

/// Runs sync on the triggers from CLAUDE.md: app foreground, connectivity
/// regained and manual "Sync now". Never runs in the background on iOS.
class SyncController extends Notifier<SyncActivity> {
  AppLifecycleListener? _lifecycle;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;
  // Bursts of resume and connectivity events become one run; a 429 is
  // retried when the server said so, in the foreground only (ADR 0033).
  late final SyncScheduler _scheduler = SyncScheduler(
    run: () => unawaited(syncNow()),
  );
  final _recovered = <String>{};

  @override
  SyncActivity build() {
    _lifecycle = AppLifecycleListener(
      onResume: _scheduler.requestAutomatic,
      onStateChange: (s) => _scheduler.setForeground(
        s == AppLifecycleState.resumed || s == AppLifecycleState.inactive,
      ),
    );
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      // An interface came up; the probe inside the run checks real reach.
      if (!results.contains(ConnectivityResult.none)) {
        _scheduler.requestAutomatic();
      }
    });
    ref.onDispose(() {
      _lifecycle?.dispose();
      unawaited(_connectivity?.cancel());
      _scheduler.dispose();
    });
    return const SyncIdle();
  }

  /// Starts a run unless one is running. It covers every account, the
  /// active one first, so QSOs of an account you switched away from still
  /// reach their server. With [accountId] it covers that account only (the
  /// confirmed upload of a review). A [manual] run also refreshes the token
  /// and station list when they were checked recently.
  ///
  /// A large first upload waits for the user's review unless [reviewed] is
  /// true: the other accounts still sync, and the state becomes
  /// [SyncNeedsReview] for the first account that waits. The result is that
  /// of the active account (or of the first account that ran).
  Future<SyncRunResult?> syncNow({
    bool reviewed = false,
    String? accountId,
    bool manual = false,
  }) async {
    if (state is SyncRunning) return null;
    _scheduler.cancelRetry();
    final active = ref.read(activeAccountProvider);
    final all = ref.read(accountsProvider).value ?? const <Account>[];
    final accounts = [
      ?active,
      for (final a in all)
        if (a.id != active?.id) a,
    ].where((a) => accountId == null || a.id == accountId).toList();
    if (accounts.isEmpty) return null;

    final engine = ref.read(syncEngineProvider);
    SyncNeedsReview? review;
    final toRun = <Account>[];
    for (final account in accounts) {
      if (!reviewed) {
        final waiting =
            (await ref.read(qsoRepositoryProvider).pendingCreates(account.id))
                .length;
        if (waiting > previewThreshold) {
          review ??= SyncNeedsReview(waiting, accountId: account.id);
          continue;
        }
      }
      toRun.add(account);
    }
    if (toRun.isEmpty) {
      state = review ?? const SyncIdle();
      return null;
    }

    state = const SyncRunning();
    SyncRunResult? result;
    Duration? retryAfter;
    try {
      for (final account in toRun) {
        if (_recovered.add(account.id)) {
          await engine.recoverAfterRestart(account.id);
        }
        final r = await engine.sync(account.id, force: manual);
        result ??= r;
        final wait = r.retryAfter;
        if (r.outcome == SyncRunOutcome.rateLimited &&
            wait != null &&
            (retryAfter == null || wait > retryAfter)) {
          retryAfter = wait;
        }
      }
      if (retryAfter != null) _scheduler.scheduleRetry(retryAfter);
      state = review ?? SyncIdle(last: result);
      return result;
    } on Object {
      state = review ?? const SyncIdle();
      rethrow;
    }
  }
}

/// The sync controller.
final syncControllerProvider = NotifierProvider<SyncController, SyncActivity>(
  SyncController.new,
);
