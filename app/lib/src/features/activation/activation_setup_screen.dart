import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/metrics.dart';
import 'package:tideline/src/features/activation/activation_labels.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline/src/features/activation/activation_setup_controller.dart';
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/pack_download.dart';
import 'package:tideline/src/widgets/error_box.dart';
import 'package:tideline/src/widgets/note.dart';
import 'package:tideline/src/widgets/upper_case_formatter.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Starts a SOTA, POTA or WWFF activation: which reference, where, and
/// which Wavelog location the QSOs go to.
class ActivationSetupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<ActivationSetupScreen> createState() =>
      _ActivationSetupScreenState();
}

class _ActivationSetupScreenState extends ConsumerState<ActivationSetupScreen> {
  late final TextEditingController _reference = TextEditingController(
    text: ref.read(activationSetupProvider).reference,
  );
  late final TextEditingController _grid = TextEditingController(
    text: ref.read(activationSetupProvider).gridTyped ?? '',
  );

  @override
  void initState() {
    super.initState();
    // A reference picked from a list replaces the text.
    ref.listenManual(activationSetupProvider.select((s) => s.reference), (
      _,
      text,
    ) {
      if (_reference.text != text) _reference.text = text;
    });
  }

  @override
  void dispose() {
    _reference.dispose();
    _grid.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final activation = await ref.read(activationSetupProvider.notifier).start();
    if (activation != null && mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final setup = ref.watch(activationSetupProvider);
    final controller = ref.read(activationSetupProvider.notifier);
    final account = ref.watch(activeAccountProvider);
    final stations = ref.watch(stationsProvider).value ?? const [];
    final defaultRemote = int.tryParse(
      ref
              .watch(settingsValuesProvider)
              .value?['account.${account?.id}.defaultStation'] ??
          '',
    );
    final resolved = resolveActivationSetup(
      setup: setup,
      stations: stations,
      defaultStationRemoteId: defaultRemote,
    );
    final running = ref.watch(activeActivationProvider).value;
    final program = setup.program;
    final pack = ref.watch(referencePackInfoProvider(program));
    final packInstalled = pack.value != null;
    final theme = Theme.of(context);
    final gap = SizedBox(height: metrics.md);
    final carrying = locationCarrying(
      program,
      setup.normalizedReference,
      resolved.station,
      stations,
    );

    String? gridHelper() => switch (resolved.gridSource) {
      GridSource.typed => null,
      GridSource.reference => l10n.activationGridFromReference,
      GridSource.station => l10n.activationGridFromStation,
      GridSource.none => l10n.activationGridNone,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activationSetupTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: EdgeInsets.all(metrics.md),
            children: [
              if (running != null) ...[
                Note(l10n.activationRunning(running.reference)),
                gap,
              ],
              Semantics(
                header: true,
                child: Text(
                  l10n.activationProgramLabel,
                  style: theme.textTheme.labelLarge,
                ),
              ),
              SizedBox(height: metrics.xs),
              SegmentedButton<ReferenceProgram>(
                segments: [
                  for (final p in ReferenceProgram.values)
                    ButtonSegment(value: p, label: Text(p.code)),
                ],
                selected: {program},
                onSelectionChanged: (s) => controller.selectProgram(s.single),
              ),
              gap,
              if (!packInstalled && !pack.isLoading) ...[
                Note(
                  l10n.activationNoPack(program.code),
                  action: TextButton(
                    onPressed: () => context.go(Routes.settings),
                    child: Text(l10n.activationOpenSettings),
                  ),
                ),
                gap,
              ],
              TextField(
                controller: _reference,
                autocorrect: false,
                enableSuggestions: false,
                textCapitalization: TextCapitalization.characters,
                textDirection: TextDirection.ltr,
                inputFormatters: [UpperCaseFormatter()],
                style: TidelineType.callsign.copyWith(
                  fontSize: 22,
                  color: context.colors.text,
                ),
                decoration: InputDecoration(
                  labelText: referenceFieldLabel(l10n, program),
                  helperText: l10n.activationReferenceExample(
                    exampleReference(program),
                  ),
                  errorText: setup.showErrors && !setup.referenceValid
                      ? l10n.activationReferenceInvalid(
                          program.code,
                          exampleReference(program),
                        )
                      : null,
                ),
                onChanged: controller.setReference,
              ),
              if (setup.referenceValid && packInstalled) ...[
                SizedBox(height: metrics.sm),
                _KnownReference(
                  program: program,
                  reference: setup.normalizedReference,
                ),
              ],
              gap,
              _Suggestions(
                program: program,
                query: setup.normalizedReference,
                grid: resolved.grid,
                picked: setup.selected?.reference == setup.normalizedReference,
                onPick: controller.selectReference,
              ),
              TextField(
                controller: _grid,
                autocorrect: false,
                textDirection: TextDirection.ltr,
                inputFormatters: [UpperCaseFormatter()],
                decoration: InputDecoration(
                  labelText: l10n.activationGridLabel,
                  helperText: gridHelper(),
                  helperMaxLines: 2,
                  hintText: resolved.gridSource == GridSource.typed
                      ? null
                      : resolved.grid,
                  errorText: resolved.gridValid ? null : l10n.issueInvalidGrid,
                ),
                onChanged: controller.setGrid,
              ),
              gap,
              if (stations.isEmpty)
                Note(l10n.activationErrorNoStation, kind: NoteKind.warning)
              else
                DropdownButtonFormField<String>(
                  initialValue: resolved.station?.id,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.fieldStation),
                  items: [
                    for (final s in stations)
                      DropdownMenuItem(
                        value: s.id,
                        child: Text(
                          '${s.name} (${s.callsign})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (id) {
                    if (id != null) controller.selectStation(id);
                  },
                ),
              if (stations.isNotEmpty && setup.referenceValid) ...[
                SizedBox(height: metrics.sm),
                _LocationAdvice(
                  reference: setup.normalizedReference,
                  carrying: carrying,
                  onUse: (s) => controller.selectStation(s.id),
                ),
              ],
              gap,
              if (setup.startFailed) ...[
                ErrorBox(l10n.activationStartFailed),
                gap,
              ],
              FilledButton.icon(
                onPressed: setup.starting ? null : _start,
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.activationStart),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Says whether the typed reference is in the installed list.
class _KnownReference extends ConsumerWidget {
  const new({required this.program, required this.reference});

  final ReferenceProgram program;
  final String reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final found = ref
        .watch(
          activationReferenceProvider((program: program, reference: reference)),
        )
        .value;
    final loading = ref
        .watch(
          activationReferenceProvider((program: program, reference: reference)),
        )
        .isLoading;
    if (loading) return const SizedBox.shrink();
    if (found == null) {
      return Note(l10n.activationReferenceUnknown(program.code));
    }
    final where = found.region == null ? '' : ' (${found.region})';
    return Note(
      l10n.activationReferenceKnown(program.code, '${found.name}$where'),
      kind: NoteKind.good,
    );
  }
}

/// Search results while typing; the nearest references while the field is
/// empty. Nothing shows once a reference was picked.
class _Suggestions extends ConsumerWidget {
  const new({
    required this.program,
    required this.query,
    required this.grid,
    required this.picked,
    required this.onPick,
  });

  final ReferenceProgram program;
  final String query;
  final String grid;
  final bool picked;
  final ValueChanged<ProgramReference> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final theme = Theme.of(context);
    if (picked) return const SizedBox.shrink();

    final searching = query.length >= minReferenceSearchLength;
    final List<({ProgramReference reference, int? km})> items;
    final String header;
    if (searching) {
      final found = ref
          .watch(referenceSearchProvider((program: program, query: query)))
          .value;
      if (found == null) return const SizedBox.shrink();
      items = [for (final r in found) (reference: r, km: null)];
      header = l10n.activationMatches;
    } else {
      final near = ref
          .watch(nearbyReferencesProvider((program: program, grid: grid)))
          .value;
      if (near == null || near.isEmpty) return const SizedBox.shrink();
      items = [
        for (final n in near) (reference: n.reference, km: n.km.round()),
      ];
      header = l10n.activationNearby(grid);
    }
    final packInstalled =
        ref.watch(referencePackInfoProvider(program)).value != null;
    if (searching && items.isEmpty) {
      return packInstalled
          ? Padding(
              padding: EdgeInsets.only(bottom: metrics.md),
              child: Text(
                l10n.activationNoMatches,
                style: theme.textTheme.bodyMedium,
              ),
            )
          : const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: metrics.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(header, style: theme.textTheme.labelLarge),
          ),
          for (final item in items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  item.reference.reference,
                  style: TidelineType.callsign.copyWith(
                    fontSize: 16,
                    color: context.colors.text,
                  ),
                ),
              ),
              subtitle: Text(item.reference.name),
              trailing: item.km == null
                  ? null
                  : Text(l10n.unitKilometers(item.km!)),
              onTap: () => onPick(item.reference),
            ),
        ],
      ),
    );
  }
}

/// Tells whether the Wavelog location the QSOs will go to carries the
/// reference, because only then does Wavelog store it (docs/architecture/
/// wavelog-api.md, "Own references").
class _LocationAdvice extends StatelessWidget {
  const new({
    required this.reference,
    required this.carrying,
    required this.onUse,
  });

  final String reference;
  final ({StationProfile? carrying, bool chosenCarries}) carrying;
  final ValueChanged<StationProfile> onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final station = carrying.carrying;
    if (carrying.chosenCarries) {
      return Note(
        l10n.activationLocationCarries(reference),
        kind: NoteKind.good,
      );
    }
    if (station != null) {
      return Note(
        l10n.activationLocationSuggest(station.name, reference),
        action: TextButton(
          onPressed: () => onUse(station),
          child: Text(l10n.activationUseLocation),
        ),
      );
    }
    return Note(l10n.activationLocationNone(reference), kind: NoteKind.warning);
  }
}
