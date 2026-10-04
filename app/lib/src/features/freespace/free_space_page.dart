import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/settings/settings_screen.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline_data/tideline_data.dart';

/// How far back the QSOs to remove reach.
enum FreeSpaceScope {
  /// Older than one year.
  olderThan1,

  /// Older than two years.
  olderThan2,

  /// Older than five years.
  olderThan5,

  /// Every synced QSO.
  all;

  /// The start time before which QSOs are in scope (UTC millis), or null for
  /// all of them.
  int? cutoffMillis(DateTime nowUtc) {
    final years = switch (this) {
      olderThan1 => 1,
      olderThan2 => 2,
      olderThan5 => 5,
      all => null,
    };
    if (years == null) return null;
    return DateTime.utc(
      nowUtc.year - years,
      nowUtc.month,
      nowUtc.day,
    ).millisecondsSinceEpoch;
  }
}

/// Removes the copies on this device of QSOs that Wavelog already has, after
/// asking Wavelog (ADR 0027). Nothing is deleted on Wavelog.
class FreeSpacePage extends ConsumerStatefulWidget {
  /// Creates the page for the account with [accountId].
  const new({required this.accountId, super.key});

  /// The account whose QSOs are removed.
  final String accountId;

  @override
  ConsumerState<FreeSpacePage> createState() => _FreeSpacePageState();
}

sealed class _Phase {
  const new();
}

final class _Choosing extends _Phase {
  const new();
}

final class _Checking extends _Phase {
  const new();
}

final class _Checked extends _Phase {
  const new(this.plan);

  final EvictionPlan plan;
}

final class _Problem extends _Phase {
  const new(this.problem);

  final EvictionCheckProblem problem;
}

final class _Done extends _Phase {
  const new(this.removed);

  final int removed;
}

class _FreeSpacePageState extends ConsumerState<FreeSpacePage> {
  FreeSpaceScope _scope = FreeSpaceScope.olderThan1;
  _Phase _phase = const _Choosing();
  EvictionCandidates? _local;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocal());
  }

  int? get _cutoff => _scope.cutoffMillis(DateTime.now().toUtc());

  Future<void> _loadLocal() async {
    final generation = ++_generation;
    final local = await ref
        .read(qsoEvictionRepositoryProvider)
        .candidates(widget.accountId, olderThanMillis: _cutoff);
    if (!mounted || generation != _generation) return;
    setState(() => _local = local);
  }

  Account? get _account => ref
      .read(accountsProvider)
      .value
      ?.where((a) => a.id == widget.accountId)
      .firstOrNull;

  Future<void> _check() async {
    final account = _account;
    if (account == null) return;
    setState(() => _phase = const _Checking());
    try {
      final plan = await ref
          .read(qsoEvictionServiceProvider)
          .plan(account, olderThanMillis: _cutoff);
      if (!mounted) return;
      setState(() => _phase = _Checked(plan));
    } on EvictionCheckFailed catch (e) {
      if (!mounted) return;
      setState(() => _phase = _Problem(e.problem));
    }
  }

  Future<void> _remove(EvictionPlan plan) async {
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_RemoveChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.freeSpaceConfirmTitle),
        content: Text(l10n.freeSpaceConfirmBody(plan.confirmed.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_RemoveChoice.exportFirst),
            child: Text(l10n.freeSpaceExportRemove),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_RemoveChoice.remove),
            child: Text(l10n.freeSpaceRemoveOnly),
          ),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    final transfer = ref.read(dataTransferProvider);
    final service = ref.read(qsoEvictionServiceProvider);
    if (choice == _RemoveChoice.exportFirst) {
      final bytes = transfer.exportAdifOf([
        for (final i in plan.confirmed) i.qso,
      ]);
      final saved = await transfer.saveFile(
        'tideline-removed-${_stamp()}.adi',
        bytes,
        'text/plain',
      );
      // Not saved (cancelled or failed): nothing is removed.
      if (!saved || !mounted) return;
    }
    final removed = await service.carryOut(plan);
    if (!mounted) return;
    setState(() => _phase = _Done(removed));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.freeSpaceDone(removed))));
    await _loadLocal();
  }

  static String _stamp() {
    final n = DateTime.now().toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}-'
        '${two(n.hour)}${two(n.minute)}';
  }

  String _scopeLabel(AppLocalizations l10n, FreeSpaceScope s) => switch (s) {
    FreeSpaceScope.olderThan1 => l10n.freeSpaceOlder1,
    FreeSpaceScope.olderThan2 => l10n.freeSpaceOlder2,
    FreeSpaceScope.olderThan5 => l10n.freeSpaceOlder5,
    FreeSpaceScope.all => l10n.freeSpaceAll,
  };

  String _problemText(AppLocalizations l10n, EvictionCheckProblem p) =>
      switch (p) {
        EvictionCheckProblem.offline => l10n.freeSpaceOffline,
        EvictionCheckProblem.unauthorized => l10n.freeSpaceUnauthorized,
        EvictionCheckProblem.server => l10n.freeSpaceServerProblem,
        EvictionCheckProblem.tooMany => l10n.freeSpaceTooMany,
      };

  List<String> _blockedLines(
    AppLocalizations l10n,
    Map<EvictionBlock, int> blocked,
  ) => [
    for (final MapEntry(:key, :value) in blocked.entries)
      switch (key) {
        EvictionBlock.notSynced => l10n.freeSpaceBlockedNotSynced(value),
        EvictionBlock.changedSinceSync => l10n.freeSpaceBlockedChanged(value),
        EvictionBlock.inContest => l10n.freeSpaceBlockedContest(value),
        EvictionBlock.inActivation => l10n.freeSpaceBlockedActivation(value),
      },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final text = Theme.of(context).textTheme;
    final local = _local;
    final eligible = local?.eligible.length ?? 0;
    final soFar = ref.watch(evictedCountProvider(widget.accountId)).value ?? 0;
    final phase = _phase;
    final busy = phase is _Checking;

    // Which QSOs: an age, changing it discards an earlier check.
    final scopeGroup = RadioGroup<FreeSpaceScope>(
      groupValue: _scope,
      onChanged: (v) {
        if (v == null || busy) return;
        setState(() {
          _scope = v;
          _phase = const _Choosing();
          _local = null;
        });
        unawaited(_loadLocal());
      },
      child: Column(
        children: [
          for (final s in FreeSpaceScope.values)
            RadioListTile<FreeSpaceScope>(
              value: s,
              title: Text(_scopeLabel(l10n, s)),
            ),
        ],
      ),
    );

    final blockedLines = local == null
        ? const <String>[]
        : _blockedLines(l10n, local.blocked);

    return SettingsPage(
      title: l10n.freeSpaceTitle,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.md),
          child: Text(l10n.freeSpaceIntro),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            metrics.md,
            metrics.md,
            metrics.md,
            metrics.xs,
          ),
          child: Semantics(
            header: true,
            child: Text(l10n.freeSpaceScope, style: text.titleMedium),
          ),
        ),
        scopeGroup,
        if (local != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.md),
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.freeSpaceEligible(eligible),
                style: text.titleSmall,
              ),
            ),
          ),
        if (blockedLines.isNotEmpty)
          Padding(
            padding: EdgeInsets.fromLTRB(metrics.md, metrics.sm, metrics.md, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.freeSpaceStaying, style: text.labelLarge),
                for (final line in blockedLines)
                  Padding(
                    padding: EdgeInsets.only(top: metrics.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ExcludeSemantics(
                          child: Padding(
                            padding: EdgeInsets.only(top: 6, right: 8),
                            child: Icon(Icons.circle, size: 6),
                          ),
                        ),
                        Expanded(child: Text(line)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: EdgeInsets.all(metrics.md),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.icon(
              onPressed: busy || eligible == 0 ? null : _check,
              icon: busy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_done_outlined),
              label: Text(busy ? l10n.freeSpaceChecking : l10n.freeSpaceCheck),
            ),
          ),
        ),
        switch (phase) {
          _Problem(:final problem) => Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.md),
            child: Semantics(
              liveRegion: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ExcludeSemantics(child: Icon(Icons.error_outline)),
                  SizedBox(width: metrics.sm),
                  Expanded(child: Text(_problemText(l10n, problem))),
                ],
              ),
            ),
          ),
          _Checked(:final plan) => Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.md),
            child: Semantics(
              liveRegion: true,
              container: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ExcludeSemantics(
                        child: Icon(Icons.cloud_done_outlined),
                      ),
                      SizedBox(width: metrics.sm),
                      Expanded(
                        child: Text(
                          l10n.freeSpaceConfirmedCount(plan.confirmed.length),
                          style: text.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  if (plan.missingOnServer.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: metrics.xs),
                      child: Text(
                        l10n.freeSpaceMissingCount(plan.missingOnServer.length),
                      ),
                    ),
                  SizedBox(height: metrics.md),
                  FilledButton.tonalIcon(
                    onPressed: plan.confirmed.isEmpty
                        ? null
                        : () => _remove(plan),
                    icon: const Icon(Icons.cleaning_services_outlined),
                    label: Text(
                      l10n.freeSpaceRemoveButton(plan.confirmed.length),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _Done(:final removed) => Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.md),
            child: Semantics(
              liveRegion: true,
              child: Text(l10n.freeSpaceDone(removed)),
            ),
          ),
          _ => const SizedBox.shrink(),
        },
        Padding(
          padding: EdgeInsets.all(metrics.md),
          child: Text(l10n.freeSpaceSoFar(soFar), style: text.bodySmall),
        ),
      ],
    );
  }
}

enum _RemoveChoice { exportFirst, remove }
