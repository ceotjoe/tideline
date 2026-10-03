import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline/src/features/log/qso_entry_controller.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Problems the setup screen can show.
enum ActivationSetupIssue {
  /// The reference does not have the shape of the programme's references.
  invalidReference,

  /// The grid square is not a valid locator.
  invalidGrid,

  /// No Wavelog station location is available.
  noStation,
}

/// Where the grid square that will be used comes from.
enum GridSource {
  /// Typed by the operator.
  typed,

  /// The position of the chosen reference.
  reference,

  /// The Wavelog station location.
  station,

  /// Nowhere: there is none.
  none,
}

/// What the operator has chosen so far. Kept outside the widgets, so
/// rotating the device keeps it.
@immutable
class ActivationSetup {
  /// Creates the setup state.
  const new({
    this.program = ReferenceProgram.pota,
    this.reference = '',
    this.selected,
    this.gridTyped,
    this.stationId,
    this.showErrors = false,
    this.starting = false,
    this.startFailed = false,
  });

  /// The programme.
  final ReferenceProgram program;

  /// The reference as typed.
  final String reference;

  /// The list entry the operator picked, if any.
  final ProgramReference? selected;

  /// A grid square the operator typed; null means "use the default".
  final String? gridTyped;

  /// The chosen station profile, null for the default.
  final String? stationId;

  /// Whether to show validation messages (after a start attempt).
  final bool showErrors;

  /// A start is running.
  final bool starting;

  /// The last start failed.
  final bool startFailed;

  /// The reference as it will be stored.
  String get normalizedReference => reference.trim().toUpperCase();

  /// Whether the reference has the right shape.
  bool get referenceValid => program.isValidReference(normalizedReference);

  /// A copy with changes. [clearSelected] and [clearGrid] reset those
  /// fields, which a plain null argument cannot.
  ActivationSetup copyWith({
    ReferenceProgram? program,
    String? reference,
    ProgramReference? selected,
    bool clearSelected = false,
    String? gridTyped,
    bool clearGrid = false,
    String? stationId,
    bool? showErrors,
    bool? starting,
    bool? startFailed,
  }) => ActivationSetup(
    program: program ?? this.program,
    reference: reference ?? this.reference,
    selected: clearSelected ? null : (selected ?? this.selected),
    gridTyped: clearGrid ? null : (gridTyped ?? this.gridTyped),
    stationId: stationId ?? this.stationId,
    showErrors: showErrors ?? this.showErrors,
    starting: starting ?? this.starting,
    startFailed: startFailed ?? this.startFailed,
  );
}

/// The setup resolved against the stations: the station, the grid square
/// that will be used and where it comes from.
@immutable
class ResolvedActivationSetup {
  /// Creates the resolution.
  const new({
    required this.station,
    required this.grid,
    required this.gridSource,
    required this.gridValid,
    required this.issues,
  });

  /// The chosen station location, null when there is none.
  final StationProfile? station;

  /// The grid square that will be stored, normalised; empty when none.
  final String grid;

  /// Where [grid] comes from.
  final GridSource gridSource;

  /// Whether [grid] is a valid locator (an empty one is valid).
  final bool gridValid;

  /// What stops the start.
  final List<ActivationSetupIssue> issues;
}

/// Resolves [setup] against [stations].
ResolvedActivationSetup resolveActivationSetup({
  required ActivationSetup setup,
  required List<StationProfile> stations,
  required int? defaultStationRemoteId,
}) {
  final station =
      stations.where((s) => s.id == setup.stationId).firstOrNull ??
      stations.where((s) => s.remoteId == defaultStationRemoteId).firstOrNull ??
      stations.where((s) => s.active).firstOrNull ??
      stations.firstOrNull;
  final typed = setup.gridTyped?.trim() ?? '';
  final selected = setup.selected;
  final fromReference =
      selected != null &&
          selected.reference == setup.normalizedReference &&
          selected.latitude != null &&
          selected.longitude != null
      ? Maidenhead.fromLatLon(selected.latitude!, selected.longitude!)
      : null;
  final stationGrid = station?.gridsquare?.trim() ?? '';
  final (String raw, GridSource source) = typed.isNotEmpty
      ? (typed, GridSource.typed)
      : fromReference != null
      ? (fromReference, GridSource.reference)
      : stationGrid.isNotEmpty
      ? (stationGrid, GridSource.station)
      : ('', GridSource.none);
  final normalized = raw.isEmpty ? null : Maidenhead.normalize(raw);
  final gridValid = raw.isEmpty || normalized != null;
  return ResolvedActivationSetup(
    station: station,
    grid: normalized ?? (gridValid ? '' : raw),
    gridSource: source,
    gridValid: gridValid,
    issues: [
      if (!setup.referenceValid) ActivationSetupIssue.invalidReference,
      if (!gridValid) ActivationSetupIssue.invalidGrid,
      if (station == null) ActivationSetupIssue.noStation,
    ],
  );
}

/// The Wavelog location to suggest for [reference]: the chosen one if it
/// carries the reference, otherwise any other that does.
({StationProfile? carrying, bool chosenCarries}) locationCarrying(
  ReferenceProgram program,
  String reference,
  StationProfile? chosen,
  List<StationProfile> stations,
) {
  if (chosen != null && chosen.references.matches(program, reference)) {
    return (carrying: chosen, chosenCarries: true);
  }
  final other = stations
      .where((s) => s.references.matches(program, reference))
      .firstOrNull;
  return (carrying: other, chosenCarries: false);
}

/// Edits the setup and starts the activation.
class ActivationSetupController extends Notifier<ActivationSetup> {
  @override
  ActivationSetup build() => const ActivationSetup();

  /// Chooses the programme. The reference typed for another programme is
  /// cleared, because it cannot be right.
  void selectProgram(ReferenceProgram program) {
    if (program == state.program) return;
    state = ActivationSetup(
      program: program,
      stationId: state.stationId,
      gridTyped: state.gridTyped,
    );
  }

  /// Sets the typed reference. A picked list entry stays picked only while
  /// the text still names it.
  void setReference(String text) {
    final keep =
        state.selected?.reference == text.trim().toUpperCase() &&
        state.selected != null;
    state = state.copyWith(
      reference: text,
      clearSelected: !keep,
      startFailed: false,
    );
  }

  /// Picks a reference from the list.
  void selectReference(ProgramReference reference) => state = state.copyWith(
    reference: reference.reference,
    selected: reference,
    startFailed: false,
  );

  /// Sets the grid square; an empty text means "use the default".
  void setGrid(String text) => state = text.trim().isEmpty
      ? state.copyWith(clearGrid: true)
      : state.copyWith(gridTyped: text, startFailed: false);

  /// Chooses the station profile.
  void selectStation(String id) =>
      state = state.copyWith(stationId: id, startFailed: false);

  /// Starts the activation and makes its station the one new QSOs use.
  /// Returns it, or null if something is missing (the messages show) or
  /// saving failed.
  Future<Activation?> start() async {
    final account = ref.read(activeAccountProvider);
    final resolved = resolveActivationSetup(
      setup: state,
      stations: ref.read(stationsProvider).value ?? const [],
      defaultStationRemoteId: int.tryParse(
        ref
                .read(settingsValuesProvider)
                .value?['account.${account?.id}.defaultStation'] ??
            '',
      ),
    );
    if (account == null || state.starting) return null;
    if (resolved.issues.isNotEmpty) {
      state = state.copyWith(showErrors: true);
      return null;
    }
    state = state.copyWith(starting: true, startFailed: false);
    try {
      final activation = await ref
          .read(activationRepositoryProvider)
          .start(
            accountId: account.id,
            program: state.program,
            reference: state.normalizedReference,
            myGridsquare: resolved.grid.isEmpty ? null : resolved.grid,
            stationProfileId: resolved.station!.id,
          );
      ref
          .read(qsoEntryProvider.notifier)
          .edit((e) => e.copyWith(stationProfileId: resolved.station!.id));
      state = const ActivationSetup();
      return activation;
    } on Object {
      state = state.copyWith(starting: false, startFailed: true);
      return null;
    }
  }
}

/// The setup state.
final activationSetupProvider =
    NotifierProvider<ActivationSetupController, ActivationSetup>(
      ActivationSetupController.new,
    );
