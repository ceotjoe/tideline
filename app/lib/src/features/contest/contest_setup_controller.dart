import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/contest/cabrillo_categories.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// What the operator has chosen so far on the session setup screen. Kept
/// outside the widgets, so rotating the device keeps it.
@immutable
class ContestSetup {
  /// Creates the setup state.
  const new({
    this.query = '',
    this.definitionId,
    this.stationId,
    this.typed = const {},
    this.categories = const {},
    this.showErrors = false,
    this.starting = false,
    this.startFailed = false,
  });

  /// The contest search text.
  final String query;

  /// The chosen contest, if any.
  final String? definitionId;

  /// The chosen station profile, null for the default.
  final String? stationId;

  /// Exchange values the operator typed, by [ownExchangeKey]. Values that
  /// were not typed show the default.
  final Map<String, String> typed;

  /// Cabrillo choices; a missing entry means "not set".
  final Map<CabrilloCategory, String> categories;

  /// Whether to show validation messages (after a start attempt).
  final bool showErrors;

  /// A start is running.
  final bool starting;

  /// The last start failed.
  final bool startFailed;

  /// A copy with changes.
  ContestSetup copyWith({
    String? query,
    String? definitionId,
    String? stationId,
    Map<String, String>? typed,
    Map<CabrilloCategory, String>? categories,
    bool? showErrors,
    bool? starting,
    bool? startFailed,
  }) => ContestSetup(
    query: query ?? this.query,
    definitionId: definitionId ?? this.definitionId,
    stationId: stationId ?? this.stationId,
    typed: typed ?? this.typed,
    categories: categories ?? this.categories,
    showErrors: showErrors ?? this.showErrors,
    starting: starting ?? this.starting,
    startFailed: startFailed ?? this.startFailed,
  );
}

/// The setup choices resolved against the data: the station, the exchange
/// that applies to it and what each of my exchange fields shows.
@immutable
class ResolvedSetup {
  /// Creates the resolution.
  const new({
    required this.definition,
    required this.station,
    required this.me,
    required this.exchange,
    required this.values,
  });

  /// The chosen contest.
  final ContestDefinition definition;

  /// The chosen station profile.
  final StationProfile station;

  /// My station for variant selection and defaults.
  final ContestStation me;

  /// The exchange that applies.
  final ResolvedExchange exchange;

  /// What each sent element will contain, by [ownExchangeKey]. Report and
  /// serial are not listed: they are automatic.
  final Map<String, String> values;

  /// Whether sent element [index] is entered by the operator.
  bool isEditable(int index) {
    final kind = exchange.sent[index].kind;
    return kind != ExchangeKind.rst && kind != ExchangeKind.serial;
  }

  /// Validation problem of sent element [index], if any.
  ExchangeError? errorAt(int index) {
    if (!isEditable(index)) return null;
    final key = ownExchangeKey(exchange.sent, index);
    return exchange.sent[index].check(values[key] ?? '').error;
  }

  /// Whether every field I must fill in is valid.
  bool get isComplete =>
      [for (var i = 0; i < exchange.sent.length; i++) errorAt(i)]
          .every((e) => e == null);
}

/// Resolves [setup] against [definitions], [stations] and [dxcc]. Null when
/// no contest or no station is chosen yet.
ResolvedSetup? resolveSetup({
  required ContestSetup setup,
  required List<StoredContestDefinition> definitions,
  required List<StationProfile> stations,
  required DxccDatabase? dxcc,
  required int? defaultStationRemoteId,
}) {
  final definition = definitions
      .where((d) => d.definition.id == setup.definitionId)
      .firstOrNull
      ?.definition;
  if (definition == null) return null;
  final station =
      stations.where((s) => s.id == setup.stationId).firstOrNull ??
      stations.where((s) => s.remoteId == defaultStationRemoteId).firstOrNull ??
      stations.where((s) => s.active).firstOrNull ??
      stations.firstOrNull;
  if (station == null) return null;
  final me = contestStationFor(
    call: station.callsign.toUpperCase(),
    dxcc: dxcc,
    grid: station.gridsquare,
  );
  final exchange = definition.exchangeFor(me);
  final values = <String, String>{};
  for (final (i, e) in exchange.sent.indexed) {
    final key = ownExchangeKey(exchange.sent, i);
    final fallback =
        e.defaultFor(me) ??
        (e.kind == ExchangeKind.grid ? _gridDefault(station.gridsquare) : null);
    values[key] = setup.typed[key] ?? fallback ?? '';
  }
  return ResolvedSetup(
    definition: definition,
    station: station,
    me: me,
    exchange: exchange,
    values: values,
  );
}

String? _gridDefault(String? grid) {
  final value = grid?.trim().toUpperCase();
  if (value == null || value.length < 4) return null;
  return value.length >= 6 ? value.substring(0, 6) : value.substring(0, 4);
}

/// Edits the setup and starts the session.
class ContestSetupController extends Notifier<ContestSetup> {
  @override
  ContestSetup build() => const ContestSetup();

  /// Sets the search text.
  void setQuery(String value) => state = state.copyWith(query: value);

  /// Chooses a contest and loads its Cabrillo defaults.
  void selectDefinition(ContestDefinition definition) {
    state = state.copyWith(
      definitionId: definition.id,
      categories: defaultCabrilloCategories(definition),
      showErrors: false,
      startFailed: false,
    );
  }

  /// Chooses the station profile.
  void selectStation(String id) =>
      state = state.copyWith(stationId: id, startFailed: false);

  /// Records what the operator typed for the exchange field [key].
  void setValue(String key, String value) => state = state.copyWith(
    typed: {...state.typed, key: value},
    startFailed: false,
  );

  /// Chooses a Cabrillo value; null clears it.
  void setCategory(CabrilloCategory category, String? value) {
    final map = {...state.categories};
    if (value == null) {
      map.remove(category);
    } else {
      map[category] = value;
    }
    state = state.copyWith(categories: map);
  }

  /// Starts the session. Returns it, or null if something is missing
  /// (the messages show) or saving failed.
  Future<ContestSession?> start() async {
    final account = ref.read(activeAccountProvider);
    final resolved = resolveSetup(
      setup: state,
      definitions: ref.read(contestDefinitionsProvider).value ?? const [],
      stations: ref.read(stationsProvider).value ?? const [],
      dxcc: ref.read(dxccProvider).value,
      defaultStationRemoteId: int.tryParse(
        ref
                .read(settingsValuesProvider)
                .value?['account.${account?.id}.defaultStation'] ??
            '',
      ),
    );
    if (account == null || resolved == null || state.starting) return null;
    if (!resolved.isComplete) {
      state = state.copyWith(showErrors: true);
      return null;
    }
    final own = <String, String>{};
    for (final (i, e) in resolved.exchange.sent.indexed) {
      if (!resolved.isEditable(i)) continue;
      final key = ownExchangeKey(resolved.exchange.sent, i);
      final value = e.check(resolved.values[key] ?? '').value;
      if (value != null && value.isNotEmpty) own[key] = value;
    }
    state = state.copyWith(starting: true, startFailed: false);
    try {
      final me = contestStationFor(
        call: resolved.station.callsign.toUpperCase(),
        dxcc: ref.read(dxccProvider).value,
        grid: resolved.station.gridsquare,
        ownExchange: own,
      );
      final session = await ref
          .read(contestSessionRepositoryProvider)
          .start(
            accountId: account.id,
            definitionId: resolved.definition.id,
            me: me,
            accountSupportsSessions: account.hasContestSessions,
            stationProfileId: resolved.station.id,
            ownExchange: own,
            cabrillo: {
              for (final e in state.categories.entries) e.key.tag: e.value,
            },
          );
      state = const ContestSetup();
      return session;
    } on Object {
      state = state.copyWith(starting: false, startFailed: true);
      return null;
    }
  }
}

/// The setup state.
final contestSetupProvider =
    NotifierProvider<ContestSetupController, ContestSetup>(
      ContestSetupController.new,
    );
