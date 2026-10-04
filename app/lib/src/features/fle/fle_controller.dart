import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart' show StationProfile;
import 'package:tideline_domain/tideline_domain.dart';

/// What the Fast Log Entry screen holds. It lives outside the widget, so
/// rotating or resizing never loses the text.
class FleState {
  /// Creates the state.
  const new({
    this.text = '',
    this.stationId,
    this.skipProblems = false,
    this.logDuplicates = false,
    this.result = const FleResult([]),
    this.duplicateLines = const {},
    this.busy = false,
  });

  /// What was typed.
  final String text;

  /// The chosen station location (local id), or null for the default.
  final String? stationId;

  /// Log the QSOs of a text that also has problem lines.
  final bool skipProblems;

  /// Log QSOs that are already in the log or earlier in the text.
  final bool logDuplicates;

  /// What the text was read as.
  final FleResult result;

  /// Line numbers of QSOs that duplicate one in the log or an earlier line.
  final Set<int> duplicateLines;

  /// A batch is being logged.
  final bool busy;

  /// The QSO lines that would be logged with the current switches.
  List<FleQsoLine> get toLog => [
    for (final l in result.lines)
      if (l is FleQsoLine &&
          (logDuplicates || !duplicateLines.contains(l.number)))
        l,
  ];

  /// Number of lines that cannot be used.
  int get problemCount => result.errors.length;

  /// Whether logging is allowed now: something to log, and no problem lines
  /// unless they are skipped.
  bool get canLog =>
      !busy && toLog.isNotEmpty && (problemCount == 0 || skipProblems);

  /// A copy with changes.
  FleState copyWith({
    String? text,
    String? stationId,
    bool? skipProblems,
    bool? logDuplicates,
    FleResult? result,
    Set<int>? duplicateLines,
    bool? busy,
  }) => FleState(
    text: text ?? this.text,
    stationId: stationId ?? this.stationId,
    skipProblems: skipProblems ?? this.skipProblems,
    logDuplicates: logDuplicates ?? this.logDuplicates,
    result: result ?? this.result,
    duplicateLines: duplicateLines ?? this.duplicateLines,
    busy: busy ?? this.busy,
  );
}

/// Reads the typed shorthand (debounced), marks duplicates, and logs.
class FleController extends Notifier<FleState> {
  Timer? _debounce;
  int _generation = 0;

  @override
  FleState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const FleState();
  }

  /// The text changed. It is read again shortly after the last keystroke.
  void setText(String text) {
    state = state.copyWith(text: text);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), _reparse);
  }

  /// Chooses the station location the QSOs are logged for.
  void setStation(String id) {
    state = state.copyWith(stationId: id);
    unawaited(_reparse());
  }

  /// Switch: log the QSOs of a text that has problem lines.
  void setSkipProblems({required bool value}) =>
      state = state.copyWith(skipProblems: value);

  /// Switch: also log duplicates.
  void setLogDuplicates({required bool value}) =>
      state = state.copyWith(logDuplicates: value);

  /// Forgets the text (after logging).
  void clear() {
    _debounce?.cancel();
    _generation++;
    state = FleState(
      stationId: state.stationId,
      skipProblems: state.skipProblems,
      logDuplicates: state.logDuplicates,
    );
  }

  /// The station location the QSOs go to: the chosen one, else the account's
  /// default, else the active one, else the first. Null without any.
  String? effectiveStationId() {
    final stations = ref.read(stationsProvider).value ?? const [];
    StationProfile? pick(bool Function(StationProfile) test) =>
        stations.where(test).firstOrNull;
    final chosen = state.stationId;
    if (chosen != null) {
      final hit = pick((s) => s.id == chosen);
      if (hit != null) return hit.id;
    }
    final account = ref.read(activeAccountProvider);
    final defaultRemote = int.tryParse(
      ref
              .read(settingsValuesProvider)
              .value?['account.${account?.id}.defaultStation'] ??
          '',
    );
    return (pick((s) => s.remoteId == defaultRemote) ??
            pick((s) => s.active) ??
            stations.firstOrNull)
        ?.id;
  }

  Future<void> _reparse() async {
    final generation = ++_generation;
    final now = DateTime.now().toUtc();
    final result = const FleParser().parse(
      state.text,
      todayUtc: now,
      nowUtc: now,
    );
    final dupes = await _duplicates(result);
    if (!ref.mounted || generation != _generation) return;
    state = state.copyWith(result: result, duplicateLines: dupes);
  }

  /// QSO lines that are already in the log or repeat an earlier line.
  Future<Set<int>> _duplicates(FleResult result) async {
    final account = ref.read(activeAccountProvider);
    final qsoLines = [
      for (final l in result.lines)
        if (l is FleQsoLine) l,
    ];
    if (account == null || qsoLines.isEmpty) return const {};
    final station = effectiveStationId();
    ({String call, int minute, String band, String mode}) keyOf(FleQso q) {
      final k = q
          .toQso(id: '-', accountId: account.id, stationProfileId: station)
          .dupeKey;
      return (call: k.call, minute: k.minuteMillis, band: k.band, mode: k.mode);
    }

    final keys = [for (final l in qsoLines) keyOf(l.qso)];
    final from = keys.map((k) => k.minute).reduce((a, b) => a < b ? a : b);
    final to = keys.map((k) => k.minute).reduce((a, b) => a > b ? a : b);
    final existing = await ref
        .read(qsoRepositoryProvider)
        .dupeKeysBetween(account.id, from, to + 60000);
    final seen = <(String, int, String, String)>{};
    final out = <int>{};
    for (var i = 0; i < qsoLines.length; i++) {
      final k = keys[i];
      final tuple = (k.call, k.minute, k.band, k.mode);
      final inLog = existing.contains((
        k.call,
        k.minute,
        k.band,
        k.mode,
        station,
      ));
      if (inLog || !seen.add(tuple)) out.add(qsoLines[i].number);
    }
    return out;
  }

  /// Logs what the screen shows, in one transaction: into the running
  /// activation if there is one. Returns how many were logged, or null when
  /// logging is not allowed now.
  Future<int?> submit() async {
    // Read what was typed last, not the debounced result.
    _debounce?.cancel();
    await _reparse();
    final account = ref.read(activeAccountProvider);
    if (account == null || !state.canLog) return null;
    final station = effectiveStationId();
    final qsos = [
      for (final l in state.toLog)
        l.qso.toQso(
          id: newUuidV4(),
          accountId: account.id,
          stationProfileId: station,
        ),
    ];
    state = state.copyWith(busy: true);
    try {
      final activation = ref.read(activeActivationProvider).value;
      final count = activation == null
          ? await ref.read(qsoRepositoryProvider).logAll(qsos)
          : (await ref
                    .read(activationRepositoryProvider)
                    .logQsos(qsos, activationId: activation.id))
                .length;
      clear();
      return count;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }
}

/// The Fast Log Entry screen's state.
final NotifierProvider<FleController, FleState> fleProvider =
    NotifierProvider<FleController, FleState>(FleController.new);
