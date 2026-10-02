import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/features/contest/contest_qso_codec.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// A QSO open for inline editing. The sent exchange and the time are not
/// part of it: the serial is immutable.
@immutable
class ContestEdit {
  /// Creates an edit.
  const new({
    required this.qsoId,
    required this.call,
    required this.rcvd,
    required this.band,
    required this.mode,
    this.issues = const [],
    this.saveFailed = false,
    this.revision = 0,
  });

  /// The QSO being edited.
  final String qsoId;

  /// Callsign as typed.
  final String call;

  /// Received exchange as typed.
  final List<String> rcvd;

  /// Band.
  final Band band;

  /// Mode.
  final Mode mode;

  /// Problems found when saving.
  final List<ContestIssue> issues;

  /// The last save attempt failed.
  final bool saveFailed;

  /// Reload counter for the text fields.
  final int revision;

  /// The problem of received element [index], if any.
  ExchangeError? errorAt(int index) => issues
      .where(
        (i) => i.field == ContestIssueField.element && i.elementIndex == index,
      )
      .firstOrNull
      ?.error;

  /// A copy with changes; edits clear the issues.
  ContestEdit copyWith({
    String? call,
    List<String>? rcvd,
    Band? band,
    Mode? mode,
    List<ContestIssue>? issues,
    bool saveFailed = false,
  }) => ContestEdit(
    qsoId: qsoId,
    call: call ?? this.call,
    rcvd: rcvd ?? this.rcvd,
    band: band ?? this.band,
    mode: mode ?? this.mode,
    issues: issues ?? const [],
    saveFailed: saveFailed,
    revision: revision,
  );
}

/// Opens, edits, saves and deletes session QSOs without leaving contest
/// mode.
class ContestEditController extends Notifier<ContestEdit?> {
  @override
  ContestEdit? build() {
    // A different session never inherits an open edit.
    ref.watch(contestSpecProvider.select((s) => s?.session.id));
    return null;
  }

  /// Opens [qso] for editing.
  void begin(Qso qso) {
    final spec = ref.read(contestSpecProvider);
    if (spec == null) return;
    state = ContestEdit(
      qsoId: qso.id,
      call: qso.call.value,
      rcvd: rcvdValuesOf(spec, qso),
      band: qso.band,
      mode: qso.mode,
    );
  }

  /// Opens the newest QSO, if there is one.
  void beginLast() {
    final qsos = ref.read(contestLiveProvider)?.qsos;
    if (qsos == null || qsos.isEmpty) return;
    begin(qsos.last);
  }

  /// Closes the editor without saving.
  void cancel() => state = null;

  /// Sets the callsign.
  void setCall(String value) => state = state?.copyWith(call: value);

  /// Sets received element [index].
  void setRcvd(int index, String value) {
    final current = state;
    if (current == null) return;
    final list = [...current.rcvd];
    while (list.length <= index) {
      list.add('');
    }
    list[index] = value;
    state = current.copyWith(rcvd: list);
  }

  /// Sets the band.
  void setBand(Band band) => state = state?.copyWith(band: band);

  /// Sets the mode.
  void setMode(Mode mode) => state = state?.copyWith(mode: mode);

  /// Validates and stores the edit. Returns whether it was saved; on false
  /// [state] carries the problems. The sent serial is kept by the
  /// repository whatever is passed.
  Future<bool> save() async {
    final edit = state;
    final spec = ref.read(contestSpecProvider);
    final live = ref.read(contestLiveProvider);
    if (edit == null || spec == null || live == null) return false;
    final original = live.qsos.where((q) => q.id == edit.qsoId).firstOrNull;
    if (original == null) {
      state = null;
      return false;
    }
    final validation = validateContestEntry(
      spec: spec,
      call: edit.call,
      band: edit.band,
      mode: edit.mode,
      frequency: '',
      rcvd: edit.rcvd,
    );
    final entry = validation.entry;
    if (entry == null) {
      state = edit.copyWith(issues: validation.issues);
      return false;
    }
    final edited = applyContestEdit(
      spec: spec,
      original: original,
      entry: entry,
      dxcc: ref.read(dxccProvider).value,
    );
    try {
      await ref.read(qsoRepositoryProvider).update(edited);
    } on Object {
      state = edit.copyWith(saveFailed: true);
      return false;
    }
    state = null;
    return true;
  }

  /// Deletes [qsoId]. Its serial is never given out again.
  Future<void> delete(String qsoId) async {
    final account = ref.read(activeAccountProvider);
    if (account == null) return;
    await ref
        .read(qsoRepositoryProvider)
        .delete(qsoId, canDeleteOnServer: account.canDeleteOnServer);
    if (state?.qsoId == qsoId) state = null;
  }
}

/// The QSO open for editing, or null.
final contestEditProvider =
    NotifierProvider<ContestEditController, ContestEdit?>(
      ContestEditController.new,
    );
