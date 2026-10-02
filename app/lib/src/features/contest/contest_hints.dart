import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/contest/contest_entry_controller.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Debounce between a keystroke and the hints, so typing never waits for
/// them.
const Duration hintDebounce = Duration(milliseconds: 150);

/// Most Super Check Partial matches shown.
const int maxScpSuggestions = 6;

/// Live information about the call being typed.
@immutable
class ContestHints {
  /// Creates hints.
  const new({
    this.call = '',
    this.dxcc,
    this.status,
    this.points,
    this.previous,
    this.multipliers = const [],
    this.worked,
    this.scpAvailable = false,
    this.inScp = false,
    this.scpMatches = const [],
    this.nPlusOne = const [],
  });

  /// No call, no hints.
  static const empty = ContestHints();

  /// The call the hints were computed for.
  final String call;

  /// Country, zones and continent of the call.
  final DxccMatch? dxcc;

  /// What logging now would count as; null until band and mode are known.
  final QsoScoreStatus? status;

  /// Points logging now would score.
  final int? points;

  /// Earlier contacts with the call in this session.
  final DupeResult? previous;

  /// Multipliers logging now would add.
  final List<MultiplierHit> multipliers;

  /// How the call relates to the main log; null while unknown.
  final WorkedSlotStatus? worked;

  /// Whether a Super Check Partial database is loaded.
  final bool scpAvailable;

  /// Whether the full call is in the database.
  final bool inScp;

  /// Calls containing what was typed.
  final List<String> scpMatches;

  /// Calls one edit away from what was typed.
  final List<String> nPlusOne;

  /// Whether the QSO would be a dupe.
  bool get isDupe => status == QsoScoreStatus.dupe;

  /// Whether there is anything to show.
  bool get isEmpty => call.isEmpty;

  /// A copy with the main-log answer filled in.
  ContestHints withWorked(WorkedSlotStatus? value) => ContestHints(
    call: call,
    dxcc: dxcc,
    status: status,
    points: points,
    previous: previous,
    multipliers: multipliers,
    worked: value,
    scpAvailable: scpAvailable,
    inScp: inScp,
    scpMatches: scpMatches,
    nPlusOne: nPlusOne,
  );
}

/// Computes [ContestHints] for the entry, debounced. Everything is cheap
/// except the worked-before lookup, which is one indexed query and arrives
/// as a second update.
class ContestHintsNotifier extends Notifier<ContestHints> {
  Timer? _timer;
  int _sequence = 0;

  @override
  ContestHints build() {
    ref
      ..listen(
        contestEntryProvider.select(
          (e) => (e.call, e.band, e.mode, e.rcvd.join('\u0000')),
        ),
        (_, _) => _schedule(),
      )
      ..listen(contestLiveProvider, (_, _) => _schedule())
      ..listen(scpDatabaseProvider, (_, _) => _schedule())
      ..onDispose(() => _timer?.cancel());
    return ContestHints.empty;
  }

  void _schedule() {
    _timer?.cancel();
    final empty = ref.read(contestEntryProvider).call.trim().isEmpty;
    if (empty) {
      _sequence++;
      state = ContestHints.empty;
      return;
    }
    _timer = Timer(hintDebounce, _compute);
  }

  Future<void> _compute() async {
    final seq = ++_sequence;
    final entry = ref.read(contestEntryProvider);
    final spec = ref.read(contestSpecProvider);
    final call = entry.call.trim().toUpperCase();
    if (spec == null || call.isEmpty) {
      state = ContestHints.empty;
      return;
    }
    final parsed = Callsign.tryParse(call);
    final dxcc = call.length >= 2
        ? ref.read(dxccProvider).value?.resolve(call)
        : null;

    QsoScore? preview;
    DupeResult? previous;
    final band = entry.band;
    final mode = entry.mode;
    final live = ref.read(contestLiveProvider);
    if (parsed != null && band != null && mode != null && live != null) {
      final rcvd = <ExchangeKind, String>{};
      for (final (i, element) in spec.exchange.rcvd.indexed) {
        final value = element.check(entry.rcvdAt(i)).value;
        if (value != null && value.isNotEmpty) rcvd[element.kind] = value;
      }
      preview = live.engine.preview(
        call: call,
        band: band,
        mode: mode,
        rcvd: rcvd,
      );
      previous = live.engine.dupeCheck(call: call, band: band, mode: mode);
    }

    final scp = ref.read(scpDatabaseProvider).value;
    final inScp = scp != null && scp.contains(call);
    var partial = const <String>[];
    var plusOne = const <String>[];
    if (scp != null) {
      if (call.length >= 3) {
        partial = [
          for (final c in scp.partial(call, limit: maxScpSuggestions + 1))
            if (c != call) c,
        ].take(maxScpSuggestions).toList();
      }
      if (parsed != null && !inScp) {
        // Calls already offered as partial matches are not repeated.
        plusOne = [
          for (final c in scp.nPlusOne(call, limit: maxScpSuggestions))
            if (!partial.contains(c)) c,
        ];
      }
    }

    final hints = ContestHints(
      call: call,
      dxcc: dxcc,
      status: preview?.status,
      points: preview?.points,
      previous: previous,
      multipliers: preview?.newMultipliers ?? const [],
      scpAvailable: scp != null,
      inScp: inScp,
      scpMatches: partial,
      nPlusOne: plusOne,
    );
    state = hints;

    final account = ref.read(activeAccountProvider);
    if (parsed == null || band == null || mode == null || account == null) {
      return;
    }
    try {
      final summary = await ref
          .read(workedBeforeRepositoryProvider)
          .lookupBase(account.id, call);
      if (seq != _sequence) return;
      state = hints.withWorked(summary.slotStatus(band.name, mode.mode));
    } on Object {
      // The main-log hint is a nicety; contest logging must not depend on it.
    }
  }
}

/// Hints for the call being entered. Disposed with the contest screen.
final NotifierProvider<ContestHintsNotifier, ContestHints>
contestHintsProvider =
    NotifierProvider.autoDispose<ContestHintsNotifier, ContestHints>(
      ContestHintsNotifier.new,
    );
