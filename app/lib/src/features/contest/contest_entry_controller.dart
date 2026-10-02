import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_qso_codec.dart';
import 'package:tideline/src/features/contest/contest_spec.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The contact being entered in contest mode. Lives in a provider, so
/// rotating or resizing the window never loses typed input.
@immutable
class ContestEntry {
  /// Creates an entry.
  const new({
    this.call = '',
    this.rcvd = const [],
    this.band,
    this.mode,
    this.frequency = '',
    this.issues = const [],
    this.revision = 0,
  });

  /// Callsign as typed.
  final String call;

  /// Received exchange as typed, aligned with the exchange elements. May be
  /// shorter than the exchange; missing entries are empty.
  final List<String> rcvd;

  /// Selected band (sticky between QSOs).
  final Band? band;

  /// Selected mode (sticky between QSOs).
  final Mode? mode;

  /// Frequency as typed (sticky between QSOs).
  final String frequency;

  /// Problems found on the last attempt to log.
  final List<ContestIssue> issues;

  /// Increases whenever the text fields must be reloaded from this state
  /// (after a wipe or a suggestion was applied).
  final int revision;

  /// The typed value of received element [index].
  String rcvdAt(int index) => index < rcvd.length ? rcvd[index] : '';

  /// The problem of received element [index], if any.
  ExchangeError? errorAt(int index) => issues
      .where(
        (i) => i.field == ContestIssueField.element && i.elementIndex == index,
      )
      .firstOrNull
      ?.error;

  /// Whether [field] has a problem.
  ContestIssue? issueOf(ContestIssueField field) =>
      issues.where((i) => i.field == field).firstOrNull;

  /// A copy with changes. Edits clear the issues unless [issues] is given.
  ContestEntry copyWith({
    String? call,
    List<String>? rcvd,
    Band? band,
    Mode? mode,
    String? frequency,
    List<ContestIssue>? issues,
    int? revision,
  }) => ContestEntry(
    call: call ?? this.call,
    rcvd: rcvd ?? this.rcvd,
    band: band ?? this.band,
    mode: mode ?? this.mode,
    frequency: frequency ?? this.frequency,
    issues: issues ?? const [],
    revision: revision ?? this.revision,
  );
}

/// What [ContestEntryController.submit] did.
sealed class ContestSubmit {
  const new();
}

/// The call is empty: focus it, log nothing.
final class SubmitNeedsCall extends ContestSubmit {
  /// Creates the result.
  const new();
}

/// Something is missing or invalid; focus [first].
final class SubmitInvalid extends ContestSubmit {
  /// Creates the result.
  const new(this.first);

  /// The first problem, in focus order.
  final ContestIssue first;
}

/// The QSO was saved locally.
final class SubmitLogged extends ContestSubmit {
  /// Creates the result.
  const new(this.qso, {required this.serial, required this.dupe});

  /// The stored QSO.
  final Qso qso;

  /// The allocated serial, if the contest uses serials.
  final int? serial;

  /// Whether the QSO was a dupe when it was logged.
  final bool dupe;
}

/// Saving failed; the entry is untouched.
final class SubmitFailed extends ContestSubmit {
  /// Creates the result.
  const new();
}

/// Nothing happened (no session, or a save is already running).
final class SubmitIgnored extends ContestSubmit {
  /// Creates the result.
  const new();
}

/// Edits and logs the contest entry. Logging is a local transaction that
/// never waits for the network.
class ContestEntryController extends Notifier<ContestEntry> {
  bool _busy = false;

  @override
  ContestEntry build() {
    // A new session starts with a clean entry in the contest's first band.
    ref.watch(contestSpecProvider.select((s) => s?.session.id));
    final spec = ref.read(contestSpecProvider);
    if (spec == null) return const ContestEntry();
    final bands = contestBands(spec.definition);
    final preferred = Band.tryParse('20m');
    final band = preferred != null && bands.contains(preferred)
        ? preferred
        : bands.firstOrNull;
    return ContestEntry(
      band: band,
      mode: defaultModeFor(firstCategory(spec.definition)),
    );
  }

  /// Sets the callsign.
  void setCall(String value) => state = state.copyWith(call: value);

  /// Applies a suggestion (super check partial): replaces the call and asks
  /// the field to reload.
  void fillCall(String value) =>
      state = state.copyWith(call: value, revision: state.revision + 1);

  /// Sets received element [index].
  void setRcvd(int index, String value) {
    final list = [...state.rcvd];
    while (list.length <= index) {
      list.add('');
    }
    list[index] = value;
    state = state.copyWith(rcvd: list);
  }

  /// Sets the band; a frequency outside the new band is cleared.
  void setBand(Band band) {
    final hz = Frequency.parseUserInput(state.frequency);
    final keep = hz != null && band.contains(hz);
    state = state.copyWith(
      band: band,
      frequency: keep ? state.frequency : '',
      revision: keep ? state.revision : state.revision + 1,
    );
  }

  /// Sets the mode.
  void setMode(Mode mode) => state = state.copyWith(mode: mode);

  /// Sets the frequency text and, if it lies in a band, selects that band.
  void setFrequency(String text) {
    final hz = Frequency.parseUserInput(text);
    final band = hz == null ? null : Band.forFrequency(hz);
    state = state.copyWith(frequency: text, band: band);
  }

  /// Moves to the next ([steps] > 0) or previous band of the contest.
  void stepBand(int steps) {
    final spec = ref.read(contestSpecProvider);
    if (spec == null) return;
    final bands = contestBands(spec.definition);
    if (bands.isEmpty) return;
    final i = state.band == null ? -1 : bands.indexOf(state.band!);
    final next = i < 0
        ? (steps > 0 ? 0 : bands.length - 1)
        : (i + steps) % bands.length;
    setBand(bands[next]);
  }

  /// Moves to the next mode the contest allows.
  void stepMode() {
    final spec = ref.read(contestSpecProvider);
    if (spec == null) return;
    final modes = contestModes(spec.definition);
    if (modes.isEmpty) return;
    final i = state.mode == null ? -1 : modes.indexOf(state.mode!);
    setMode(modes[(i + 1) % modes.length]);
  }

  /// Clears the call and the received exchange; band, mode and frequency
  /// stay.
  void wipe() => state = ContestEntry(
    band: state.band,
    mode: state.mode,
    frequency: state.frequency,
    revision: state.revision + 1,
  );

  /// Enter-sends-message behaviour: with no call, asks to focus the call;
  /// with an incomplete exchange, reports the first missing element;
  /// otherwise logs.
  Future<ContestSubmit> submit() async {
    final spec = ref.read(contestSpecProvider);
    final account = ref.read(activeAccountProvider);
    if (spec == null || account == null || _busy) {
      return const SubmitIgnored();
    }
    final snapshot = state;
    if (snapshot.call.trim().isEmpty) return const SubmitNeedsCall();

    final validation = validateContestEntry(
      spec: spec,
      call: snapshot.call,
      band: snapshot.band,
      mode: snapshot.mode,
      frequency: snapshot.frequency,
      rcvd: snapshot.rcvd,
    );
    final entry = validation.entry;
    if (entry == null) {
      state = snapshot.copyWith(issues: validation.issues);
      return SubmitInvalid(validation.issues.first);
    }

    _busy = true;
    try {
      final live = ref.read(contestLiveProvider);
      final dupe =
          live?.engine
              .preview(
                call: entry.call.value,
                band: entry.band,
                mode: entry.mode,
                rcvd: const {},
              )
              .isDupe ??
          false;
      final qso = buildContestQso(
        spec: spec,
        entry: entry,
        accountId: account.id,
        stationProfileId: spec.session.stationProfileId,
        dxcc: ref.read(dxccProvider).value,
      );
      final result = await ref
          .read(contestSessionRepositoryProvider)
          .logContestQso(
            qso,
            sessionId: spec.session.id,
            fieldsForSerial: contestSerialFields(
              spec: spec,
              category: ModeCategory.of(entry.mode),
            ),
          );
      // Keep what the operator typed while the write ran.
      if (state.revision == snapshot.revision && state.call == snapshot.call) {
        wipe();
      }
      return SubmitLogged(result.qso, serial: result.serial, dupe: dupe);
    } on Object {
      return const SubmitFailed();
    } finally {
      _busy = false;
    }
  }
}

/// The entry controller.
final contestEntryProvider =
    NotifierProvider<ContestEntryController, ContestEntry>(
      ContestEntryController.new,
    );
