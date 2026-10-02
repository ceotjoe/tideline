import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The QSO being entered. Lives in a provider, so rotating or resizing the
/// window never loses input.
class QsoEntry {
  /// Creates an entry.
  const new({
    this.call = '',
    this.band,
    this.mode,
    this.frequency = '',
    this.rstSent = '',
    this.rstRcvd = '',
    this.name = '',
    this.grid = '',
    this.comment = '',
    this.stationProfileId,
    this.manualTime,
    this.issues = const [],
    this.revision = 0,
  });

  /// Callsign as typed.
  final String call;

  /// Selected band (kept after logging).
  final Band? band;

  /// Selected mode (kept after logging).
  final Mode? mode;

  /// Frequency as typed (kept after logging).
  final String frequency;

  /// Report sent; empty means the mode's default.
  final String rstSent;

  /// Report received; empty means the mode's default.
  final String rstRcvd;

  /// Operator name.
  final String name;

  /// Contacted station's locator.
  final String grid;

  /// Comment.
  final String comment;

  /// Local station profile id (kept after logging).
  final String? stationProfileId;

  /// Set when the user entered the time manually (UTC); null = now.
  final UtcDateTime? manualTime;

  /// Problems found on the last attempt to log.
  final List<EntryIssue> issues;

  /// Increases on every reset, so the form can clear its text fields.
  final int revision;

  /// A copy with changes.
  QsoEntry copyWith({
    String? call,
    Band? band,
    Mode? mode,
    String? frequency,
    String? rstSent,
    String? rstRcvd,
    String? name,
    String? grid,
    String? comment,
    String? stationProfileId,
    UtcDateTime? manualTime,
    bool clearManualTime = false,
    List<EntryIssue>? issues,
    int? revision,
  }) => QsoEntry(
    call: call ?? this.call,
    band: band ?? this.band,
    mode: mode ?? this.mode,
    frequency: frequency ?? this.frequency,
    rstSent: rstSent ?? this.rstSent,
    rstRcvd: rstRcvd ?? this.rstRcvd,
    name: name ?? this.name,
    grid: grid ?? this.grid,
    comment: comment ?? this.comment,
    stationProfileId: stationProfileId ?? this.stationProfileId,
    manualTime: clearManualTime ? null : (manualTime ?? this.manualTime),
    issues: issues ?? this.issues,
    revision: revision ?? this.revision,
  );
}

/// Problems shown on the entry form.
enum EntryIssue {
  /// Callsign missing or invalid.
  invalidCall,

  /// No band and no frequency inside a band.
  missingBand,

  /// No mode.
  missingMode,

  /// Frequency not understood.
  invalidFrequency,

  /// Frequency outside the selected band.
  frequencyOutsideBand,

  /// Locator invalid.
  invalidGrid,

  /// Time in the future (clock?). Warning only.
  timeInFuture,

  /// No station location: saved, but cannot sync yet. Warning only.
  noStation,
}

/// Result of [QsoEntryController.log].
typedef LogResult = ({Qso? logged, List<EntryIssue> issues});

/// Edits and logs the current entry.
class QsoEntryController extends Notifier<QsoEntry> {
  @override
  QsoEntry build() =>
      QsoEntry(band: Band.tryParse('20m'), mode: Mode.tryParse('SSB'));

  /// Applies [update] to the entry.
  void edit(QsoEntry Function(QsoEntry e) update) =>
      state = update(state).copyWith(issues: const []);

  /// Sets the frequency and, if it lies in a band, selects that band.
  void setFrequency(String text) {
    final hz = Frequency.parseUserInput(text);
    final band = hz == null ? null : Band.forFrequency(hz);
    state = state.copyWith(frequency: text, band: band, issues: const []);
  }

  /// Clears per-QSO fields; band, mode, frequency and station stay.
  void clear() => state = QsoEntry(
    band: state.band,
    mode: state.mode,
    frequency: state.frequency,
    stationProfileId: state.stationProfileId,
    revision: state.revision + 1,
  );

  /// Validates and saves the entry locally. Never touches the network.
  Future<LogResult> log({required String accountId}) async {
    final e = state;
    final issues = <EntryIssue>[];
    final call = Callsign.tryParse(e.call);
    if (call == null) issues.add(EntryIssue.invalidCall);
    int? freq;
    if (e.frequency.trim().isNotEmpty) {
      freq = Frequency.parseUserInput(e.frequency);
      if (freq == null) issues.add(EntryIssue.invalidFrequency);
    }
    final band = e.band ?? (freq == null ? null : Band.forFrequency(freq));
    if (band == null) issues.add(EntryIssue.missingBand);
    final mode = e.mode;
    if (mode == null) issues.add(EntryIssue.missingMode);
    final grid = e.grid.trim();
    if (grid.isNotEmpty && Maidenhead.normalize(grid) == null) {
      issues.add(EntryIssue.invalidGrid);
    }
    if (issues.isNotEmpty) {
      state = e.copyWith(issues: issues);
      return (logged: null, issues: issues);
    }

    final dxcc = ref.read(dxccProvider).value?.resolve(call!.value);
    final qso = Qso(
      id: newUuidV4(),
      accountId: accountId,
      stationProfileId: e.stationProfileId,
      call: call!,
      timeOn: e.manualTime ?? UtcDateTime.now(),
      band: band!,
      mode: mode!,
      freqHz: freq,
      rstSent: e.rstSent.trim().isEmpty ? mode.defaultReport : e.rstSent.trim(),
      rstRcvd: e.rstRcvd.trim().isEmpty ? mode.defaultReport : e.rstRcvd.trim(),
      fields: {
        'NAME': e.name.trim(),
        'GRIDSQUARE': ?Maidenhead.normalize(grid),
        'COMMENT': e.comment.trim(),
        if (dxcc != null) ...{
          'DXCC': '${dxcc.entity.dxcc}',
          'COUNTRY': dxcc.entity.name,
          'CQZ': '${dxcc.cqz}',
          'ITUZ': '${dxcc.ituz}',
          'CONT': dxcc.continent,
        },
      },
    );
    final blocking = validateQso(qso).where((i) => i.blocking);
    if (blocking.isNotEmpty) {
      final mapped = [
        for (final i in blocking)
          if (i == QsoIssue.frequencyOutsideBand)
            EntryIssue.frequencyOutsideBand
          else
            EntryIssue.invalidGrid,
      ];
      state = e.copyWith(issues: mapped);
      return (logged: null, issues: mapped);
    }
    await ref.read(qsoRepositoryProvider).log(qso);
    final warnings = [
      if (validateQso(qso).contains(QsoIssue.timeInFuture))
        EntryIssue.timeInFuture,
      if (qso.stationProfileId == null) EntryIssue.noStation,
    ];
    clear();
    state = state.copyWith(issues: warnings);
    return (logged: qso, issues: warnings);
  }
}

/// The entry controller.
final qsoEntryProvider = NotifierProvider<QsoEntryController, QsoEntry>(
  QsoEntryController.new,
);
