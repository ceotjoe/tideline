import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/contest/contest_engine.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// All contest definitions, built-in and imported, by name.
final contestDefinitionsProvider =
    StreamProvider<List<StoredContestDefinition>>(
      (ref) => ref.watch(contestDefinitionRepositoryProvider).watchAll(),
    );

/// The account's running contest session, or null.
final activeContestSessionProvider = StreamProvider<ContestSession?>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return Stream.value(null);
  return ref.watch(contestSessionRepositoryProvider).watchActive(account.id);
});

/// All contest sessions of the account, newest first.
final contestSessionsProvider = StreamProvider<List<ContestSession>>((ref) {
  final account = ref.watch(activeAccountProvider);
  if (account == null) return Stream.value(const []);
  return ref.watch(contestSessionRepositoryProvider).watchAll(account.id);
});

/// The Super Check Partial database, or null when the user has none. Loaded
/// once; large, so it is parsed off the database stream.
final scpDatabaseProvider = FutureProvider<ScpDatabase?>(
  (ref) => ref.watch(scpStoreProvider).load(),
);

/// The running session resolved with its definition and my station. Null
/// when no session runs or the data it needs is still loading.
final contestSpecProvider = Provider<ContestSpec?>((ref) {
  final session = ref.watch(activeContestSessionProvider).value;
  if (session == null) return null;
  final definitions = ref.watch(contestDefinitionsProvider).value;
  final definition = definitions
      ?.where((d) => d.definition.id == session.definitionId)
      .firstOrNull
      ?.definition;
  if (definition == null) return null;
  final dxccState = ref.watch(dxccProvider);
  // Variants depend on my DXCC entity: wait for the resolver. If it can
  // never load, continue without it rather than blocking the contest.
  if (dxccState.isLoading && !dxccState.hasValue) return null;
  final station = ref
      .watch(stationsProvider)
      .value
      ?.where((s) => s.id == session.stationProfileId)
      .firstOrNull;
  final me = contestStationFor(
    call: station?.callsign.toUpperCase() ?? '',
    dxcc: dxccState.value,
    grid: station?.gridsquare,
    ownExchange: session.ownExchange,
  );
  return ContestSpec(
    session: session,
    definition: definition,
    me: me,
    exchange: definition.exchangeFor(me),
  );
});

/// The QSOs of the running session, oldest first.
final contestSessionQsosProvider = StreamProvider<List<Qso>>((ref) {
  final id = ref.watch(contestSpecProvider.select((s) => s?.session.id));
  if (id == null) return Stream.value(const []);
  return ref.watch(contestSessionRepositoryProvider).watchSessionQsos(id);
});

/// The serial the next QSO will get (a preview: the number is taken on
/// save).
final contestNextSerialProvider = StreamProvider<int>((ref) {
  final id = ref.watch(contestSpecProvider.select((s) => s?.session.id));
  if (id == null) return Stream.value(1);
  return ref.watch(contestSessionRepositoryProvider).watchNextSerial(id);
});

/// Keeps a [ContestEngine] in step with the session's QSOs and publishes a
/// snapshot after each change.
class ContestLiveNotifier extends Notifier<ContestLive?> {
  @override
  ContestLive? build() {
    final spec = ref.watch(contestSpecProvider);
    if (spec == null) return null;
    final engine = ContestEngine(
      spec: spec,
      dxcc: ref.watch(dxccProvider).value,
    );
    final initial = ref.read(contestSessionQsosProvider).value;
    if (initial != null) engine.sync(initial);
    ref.listen(contestSessionQsosProvider, (_, next) {
      final qsos = next.value;
      if (qsos != null && engine.sync(qsos)) state = ContestLive(engine);
    });
    return ContestLive(engine);
  }
}

/// Scoring, dupes and rates of the running session; null without one.
final contestLiveProvider = NotifierProvider<ContestLiveNotifier, ContestLive?>(
  ContestLiveNotifier.new,
);
