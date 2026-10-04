import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tideline/src/app.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline/src/features/callsigns/callsign_providers.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/pack_download.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

import 'contest_fakes.dart';

/// Records settings saves without a database.
class FakeSettingsController implements SettingsController {
  final List<AppSettings> saved = [];

  /// Account ids chosen with [setActiveAccount], in order.
  final List<String> activeAccounts = [];

  @override
  Future<void> setActiveAccount(String accountId) async =>
      activeAccounts.add(accountId);

  @override
  Future<void> save(AppSettings settings) async => saved.add(settings);
}

/// Records logged QSOs without a database.
class FakeQsoRepository implements QsoRepository {
  final List<Qso> logged = [];

  @override
  Future<void> log(Qso qso) async => logged.add(qso);

  /// Batches logged in one transaction.
  final List<List<Qso>> batches = [];

  /// When set, a batch fails with it and stores nothing.
  Exception? batchFailure;

  /// Duplicate keys the log already holds.
  Set<(String, int, String, String, String?)> existingKeys = {};

  @override
  Future<int> logAll(List<Qso> qsos) async {
    if (batchFailure != null) throw batchFailure!;
    batches.add(qsos);
    logged.addAll(qsos);
    return qsos.length;
  }

  @override
  Future<Set<(String, int, String, String, String?)>> dupeKeysBetween(
    String accountId,
    int fromMillis,
    int toMillis,
  ) async => {
    for (final k in existingKeys)
      if (k.$2 >= fromMillis && k.$2 <= toMillis) k,
  };

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Reference lists held in memory: none installed unless [references] is
/// given. No database, no network.
class FakeReferencePackStore extends Fake implements ReferencePackStore {
  new({this.references = const []});

  /// What the installed lists contain.
  final List<ProgramReference> references;

  bool _has(ReferenceProgram program) =>
      references.any((r) => r.program == program);

  @override
  Stream<ReferencePackInfo?> watchInfo(ReferenceProgram program) =>
      Stream.value(
        _has(program)
            ? ReferencePackInfo(
                program: program,
                count: references.where((r) => r.program == program).length,
                sha256: 'x',
                sourceUrl: 'https://example.org/list.csv',
                fetchedAt: DateTime.utc(2026, 10, 3).millisecondsSinceEpoch,
                version: '2026-10-03',
              )
            : null,
      );

  @override
  Future<ProgramReference?> find(ReferenceProgram program, String ref) async =>
      references
          .where((r) => r.program == program && r.reference == ref)
          .firstOrNull;

  @override
  Future<List<ProgramReference>> search(
    String query, {
    ReferenceProgram? program,
    int limit = 50,
    bool includeInactive = false,
  }) async {
    final q = query.trim().toLowerCase();
    return [
      for (final r in references)
        if ((program == null || r.program == program) &&
            (r.reference.toLowerCase().contains(q) ||
                r.name.toLowerCase().contains(q)))
          r,
    ].take(limit).toList();
  }

  @override
  Future<List<NearbyReference>> nearest(
    ReferenceProgram program,
    double latitude,
    double longitude, {
    int limit = 20,
    bool includeInactive = false,
  }) async => GeoDistance.nearest(
    references.where((r) => r.program == program),
    latitude,
    longitude,
    limit: limit,
  );
}

/// Activations held in memory; records what is logged in them.
class FakeActivationRepository extends Fake implements ActivationRepository {
  final List<Qso> logged = [];
  final List<({String id, int at})> ended = [];
  final List<Activation> started = [];

  /// Batches logged into an activation: (activation id, QSOs).
  final List<(String, List<Qso>)> batches = [];

  @override
  Future<List<Qso>> logQsos(
    List<Qso> qsos, {
    required String activationId,
  }) async {
    batches.add((activationId, qsos));
    return qsos;
  }

  @override
  Future<Qso> logQso(Qso qso, {required String activationId}) async {
    final stored = qso.copyWith(
      activationId: activationId,
      fields: {'MY_POTA_REF': 'US-0001', ...qso.fields},
    );
    logged.add(stored);
    return stored;
  }

  @override
  Future<void> end(String id, int at) async => ended.add((id: id, at: at));

  @override
  Future<Activation> start({
    required String accountId,
    required ReferenceProgram program,
    required String reference,
    String? myGridsquare,
    String? stationProfileId,
    int? startedAt,
  }) async {
    final a = Activation(
      id: 'act-${started.length + 1}',
      accountId: accountId,
      program: program,
      reference: reference,
      myGridsquare: myGridsquare,
      stationProfileId: stationProfileId,
      startedAt: startedAt ?? 0,
    );
    started.add(a);
    return a;
  }

  @override
  Future<ActivationRules> rulesFor(ReferenceProgram program) async =>
      ActivationRules.defaultFor(program);
}

/// A callsign directory held in memory.
class FakeCallsignDirectory extends Fake
    implements CallsignDirectoryRepository {
  new([this.infos = const {}]);

  /// What is known, by home call.
  final Map<String, CallsignInfo> infos;

  @override
  Future<CallsignInfo?> lookup(String call) async =>
      infos[Callsign.tryParse(call)?.baseCall];

  @override
  Future<List<CallsignInfo>> search(String query, {int limit = 100}) async {
    final q = query.trim().toLowerCase();
    return [
      for (final i in infos.values)
        if (q.isEmpty ||
            i.call.toLowerCase().startsWith(q) ||
            (i.name ?? '').toLowerCase().contains(q) ||
            (i.qth ?? '').toLowerCase().contains(q))
          i,
    ].take(limit).toList();
  }

  @override
  Stream<int> watchCount(String accountId) => Stream.value(infos.length);

  @override
  Future<int> count(String accountId) async => infos.length;
}

/// Callsign notes held in memory.
class FakeCallsignNotes extends Fake implements CallsignNoteRepository {
  new([Map<String, String> initial = const {}]) : notes = {...initial};

  /// The notes by home call.
  final Map<String, String> notes;
  final _changes = StreamController<void>.broadcast();

  @override
  Future<String?> find(String call) async =>
      notes[CallsignNoteRepository.keyOf(call)];

  @override
  Stream<String?> watch(String call) async* {
    yield await find(call);
    await for (final _ in _changes.stream) {
      yield await find(call);
    }
  }

  @override
  Stream<Set<String>> watchCalls() async* {
    yield {...notes.keys};
    await for (final _ in _changes.stream) {
      yield {...notes.keys};
    }
  }

  @override
  Future<void> save(String call, String body) async {
    final key = CallsignNoteRepository.keyOf(call)!;
    if (body.trim().isEmpty) {
      notes.remove(key);
    } else {
      notes[key] = body.trim();
    }
    _changes.add(null);
  }

  @override
  Future<void> delete(String call) async {
    notes.remove(CallsignNoteRepository.keyOf(call));
    _changes.add(null);
  }
}

/// What the free-space screens ask of the repository, answered from memory.
class FakeEvictionRepository extends Fake implements QsoEvictionRepository {
  new({this.eligible = const [], this.blocked = const {}, this.evicted = 0});

  /// QSOs that may be removed.
  final List<LoggedQso> eligible;

  /// QSOs that stay, by reason.
  final Map<EvictionBlock, int> blocked;

  /// How many were removed before.
  final int evicted;

  /// The age limits asked for, in order.
  final List<int?> cutoffs = [];

  @override
  Future<EvictionCandidates> candidates(
    String accountId, {
    int? olderThanMillis,
    Set<String>? ids,
  }) async {
    cutoffs.add(olderThanMillis);
    return EvictionCandidates(
      eligible: [
        for (final i in eligible)
          if (ids == null || ids.contains(i.qso.id)) i,
      ],
      blocked: blocked,
    );
  }

  @override
  Stream<int> watchEvictedCount(String accountId) => Stream.value(evicted);

  @override
  Future<Set<String>> evictedDupeHashes(String accountId) async => {};
}

/// Plans and removals answered from memory.
class FakeEvictionService extends Fake implements QsoEvictionService {
  new({this.confirmed = const [], this.missing = const [], this.problem});

  /// What Wavelog confirms.
  final List<LoggedQso> confirmed;

  /// What it does not find.
  final List<LoggedQso> missing;

  /// If set, the check fails with it.
  final EvictionCheckProblem? problem;

  /// The ids asked for, per plan.
  final List<Set<String>?> planned = [];

  /// The plans carried out.
  final List<EvictionPlan> carried = [];

  @override
  Future<EvictionPlan> plan(
    Account account, {
    int? olderThanMillis,
    Set<String>? ids,
  }) async {
    planned.add(ids);
    if (problem != null) throw EvictionCheckFailed(problem!);
    return EvictionPlan(
      accountId: account.id,
      confirmed: confirmed,
      missingOnServer: missing,
      blocked: const {},
    );
  }

  @override
  Future<int> carryOut(EvictionPlan plan) async {
    carried.add(plan);
    return plan.confirmed.length;
  }
}

/// A sync controller that never touches the network or plugins.
class FakeSyncController extends SyncController {
  int runs = 0;

  @override
  SyncActivity build() => const SyncIdle();

  @override
  Future<SyncRunResult?> syncNow({
    bool reviewed = false,
    String? accountId,
  }) async {
    runs++;
    return null;
  }
}

/// Window sizes used across tests and goldens.
abstract final class TestSizes {
  static const phone = Size(390, 844);
  static const tabletPortrait = Size(820, 1180);
  static const tabletLandscape = Size(1180, 820);

  /// iPad Pro / Air 11" in landscape: just past the `large` breakpoint, where
  /// a wide rail plus three fixed columns once left the log list no room.
  static const tabletLandscapeWide = Size(1210, 834);
  static const desktop = Size(1440, 900);
}

/// A connected test account.
const testAccount = Account(
  id: 'acc-1',
  label: 'Home',
  baseUrl: 'https://log.example.org',
  usesIndexPhp: true,
  allowHttpLan: false,
  scopes: {'qso:read', 'qso:write', 'station:read', 'qso:delete'},
  hasContestSessions: true,
);

/// The test account's station.
const testStation = StationProfile(
  id: 'st-1',
  accountId: 'acc-1',
  remoteId: 3,
  name: 'Home QTH',
  callsign: 'DO1HOZ',
  active: true,
  gridsquare: 'JO40',
);

/// Builds [count] logged QSOs with varied sync states.
List<LoggedQso> sampleLog(int count) => [
  for (var i = 0; i < count; i++)
    LoggedQso(
      Qso(
        id: 'q$i',
        accountId: 'acc-1',
        stationProfileId: 'st-1',
        call: Callsign.tryParse(['DL1ABC', 'G4XYZ', 'EA8/OE3XYZ/P'][i % 3])!,
        timeOn: UtcDateTime(DateTime.utc(2026, 10, 2, 14, i)),
        band: Band.tryParse('20m')!,
        mode: Mode.tryParse('USB')!,
        freqHz: 14205000,
        rstSent: '59',
        rstRcvd: '57',
        fields: const {'NAME': 'Anna'},
      ),
      SyncStatus(state: SyncState.values[i % SyncState.values.length]),
    ),
];

/// The real bundled DXCC data, loaded once (asset loading is asynchronous
/// I/O, which widget tests' fake clock would never complete).
final DxccDatabase testDxcc = DxccDatabase.parseCsv(
  File('assets/reference/cty.csv').readAsStringSync(),
);

/// Everything the harness exposes to tests.
typedef Pumped = ({
  FakeSettingsController settings,
  FakeQsoRepository qsos,
  FakeSyncController sync,
  ContestBackend contest,
  FakeCallsignNotes notes,
});

/// What the app sent to the system menu (macOS), since the last pump.
final List<MethodCall> menuCalls = [];

/// Pumps the full app with providers that need no database or network.
Future<Pumped> pumpTideline(
  WidgetTester tester, {
  Size size = TestSizes.phone,
  AppSettings settings = const AppSettings(),
  int pending = 0,
  Map<String, int> pendingByAccount = const {},
  double textScale = 1,
  bool disableAnimations = true,
  List<Account> accounts = const [testAccount],
  List<LoggedQso> log = const [],
  Map<String, String> settingsValues = const {},
  ContestBackend? contest,
  ContestDefinitionRepository? definitions,
  WorkedBeforeRepository? workedBefore,
  ReferencePackStore? referencePacks,
  Activation? activation,
  ActivationProgress? activationProgress,
  ActivationRepository? activations,
  List<StationProfile> stations = const [testStation],
  Map<String, CallsignInfo> callsigns = const {},
  Map<String, String> callsignNotes = const {},
  FakeEvictionRepository? evictionRepository,
  FakeEvictionService? evictionService,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = size * tester.view.devicePixelRatio
    ..platformDispatcher.textScaleFactorTestValue = textScale
    ..platformDispatcher.accessibilityFeaturesTestValue =
        FakeAccessibilityFeatures(disableAnimations: disableAnimations);
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  // macOS draws the menu bar through the system: accept what the app sends.
  menuCalls.clear();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.menu,
    (call) async {
      menuCalls.add(call);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.menu,
      null,
    ),
  );

  final controller = FakeSettingsController();
  final qsos = FakeQsoRepository();
  final backend = contest ?? ContestBackend(definitions: const []);
  final sync = FakeSyncController();
  final notes = FakeCallsignNotes(callsignNotes);
  Never noDb(Ref ref) => throw StateError('no database in widget tests');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appSettingsProvider.overrideWith((ref) => Stream.value(settings)),
        settingsValuesProvider.overrideWith(
          (ref) => Stream.value({
            'account.acc-1.defaultStation': '3',
            ...settingsValues,
          }),
        ),
        pendingSyncCountProvider.overrideWith((ref) => Stream.value(pending)),
        pendingByAccountProvider.overrideWith(
          (ref) => Stream.value(pendingByAccount),
        ),
        bindingOverridesProvider.overrideWith((ref) => Stream.value(const [])),
        settingsControllerProvider.overrideWithValue(controller),
        accountsProvider.overrideWith((ref) => Stream.value(accounts)),
        stationsProvider.overrideWith((ref) => Stream.value(stations)),
        activeActivationProvider.overrideWith(
          (ref) => Stream.value(activation),
        ),
        activationProgressProvider.overrideWith(
          (ref) => Stream.value(activationProgress),
        ),
        activationRulesProvider.overrideWith(
          (ref, program) => ActivationRules.defaultFor(program),
        ),
        activationRepositoryProvider.overrideWithValue(
          activations ?? FakeActivationRepository(),
        ),
        logProvider.overrideWith((ref) => Stream.value(log)),
        syncCountsProvider.overrideWith(
          (ref) => Stream.value(
            {
              for (final q in log)
                if (q.status != null) q.status!.state: 0,
            }..updateAll(
              (state, _) => log.where((q) => q.status?.state == state).length,
            ),
          ),
        ),
        accountJournalProvider.overrideWith((ref) => Stream.value(const [])),
        qsoRepositoryProvider.overrideWithValue(
          contest == null ? qsos : backend.qsoRepository,
        ),
        contestSeedProvider.overrideWith((ref) async => null),
        referencePackStoreProvider.overrideWithValue(
          referencePacks ?? FakeReferencePackStore(),
        ),
        workedBeforeIndexProvider.overrideWith((ref) async {}),
        contestDefinitionRepositoryProvider.overrideWithValue(
          definitions ?? backend.definitionRepository,
        ),
        contestSessionRepositoryProvider.overrideWithValue(
          backend.sessionRepository,
        ),
        workedBeforeRepositoryProvider.overrideWithValue(
          workedBefore ?? backend.workedRepository,
        ),
        scpDatabaseProvider.overrideWith((ref) async => backend.scp),
        dxccProvider.overrideWith((ref) async => testDxcc),
        syncControllerProvider.overrideWith(() => sync),
        callsignDirectoryRepositoryProvider.overrideWithValue(
          FakeCallsignDirectory(callsigns),
        ),
        callsignNoteRepositoryProvider.overrideWithValue(notes),
        qsoEvictionRepositoryProvider.overrideWithValue(
          evictionRepository ?? FakeEvictionRepository(),
        ),
        qsoEvictionServiceProvider.overrideWithValue(
          evictionService ?? FakeEvictionService(),
        ),
        databaseProvider.overrideWith(noDb),
        shortcutBindingStoreProvider.overrideWith(noDb),
        settingsStoreProvider.overrideWith(noDb),
        ...overrides,
      ],
      child: const TidelineApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (
    settings: controller,
    qsos: qsos,
    sync: sync,
    contest: backend,
    notes: notes,
  );
}
