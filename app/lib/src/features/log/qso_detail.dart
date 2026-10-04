import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show StreamProviderFamily;
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/log/qso_tile.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/callsign_text.dart';
import 'package:tideline/src/widgets/status_chip.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// The plain-language explanation of a sync status (CLAUDE.md: say why).
String explainStatus(AppLocalizations l10n, SyncStatus? status) {
  if (status == null) return l10n.explainSynced;
  final problem = switch (status.problem) {
    SyncProblem.network => l10n.problemSyncNetwork,
    SyncProblem.rateLimited => l10n.problemSyncRateLimited,
    SyncProblem.serverError => l10n.problemSyncServerError,
    SyncProblem.invalidData => l10n.problemSyncInvalidData,
    SyncProblem.stationNotAllowed => l10n.problemSyncStationNotAllowed,
    SyncProblem.missingPermission => l10n.problemSyncMissingPermission,
    SyncProblem.tokenInvalid => l10n.problemSyncTokenInvalid,
    SyncProblem.tokenExpired => l10n.problemSyncTokenExpired,
    SyncProblem.readOnlyFieldsChanged => l10n.problemSyncReadOnlyFields,
    SyncProblem.sameMinuteTwin => l10n.problemSyncSameMinuteTwin,
    null => null,
  };
  final base = switch (status.state) {
    SyncState.local => l10n.explainLocal,
    SyncState.queued => l10n.explainQueued,
    SyncState.uploading => l10n.explainUploading,
    SyncState.verifying => l10n.explainVerifying,
    SyncState.synced => l10n.explainSynced,
    SyncState.conflict => l10n.explainConflict,
    SyncState.rejected => l10n.explainRejected,
    SyncState.blocked => l10n.explainBlocked,
  };
  return problem == null ? base : '$base $problem';
}

/// Details of one QSO: data, sync status with explanation, actions.
class QsoDetail extends ConsumerWidget {
  /// Creates the detail view for [qsoId].
  const new({required this.qsoId, this.onClosed, super.key});

  /// The QSO.
  final String qsoId;

  /// Called after the QSO was deleted.
  final VoidCallback? onClosed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final log = ref.watch(logProvider).value ?? const [];
    final item = log.where((q) => q.qso.id == qsoId).firstOrNull;
    if (item == null) {
      return Center(child: Text(l10n.qsoNotFound));
    }
    final q = item.qso;
    final status = item.status;
    final account = ref.watch(activeAccountProvider);
    final metrics = context.metrics;
    final style = syncStateStyle(context, status?.state);

    Widget fact(String label, String? value) => value == null || value.isEmpty
        ? const SizedBox.shrink()
        : MergeSemantics(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: metrics.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(child: Text(value)),
                ],
              ),
            ),
          );

    final t = q.timeOn.value;
    final date =
        '${t.year}-${t.month.toString().padLeft(2, '0')}-'
        '${t.day.toString().padLeft(2, '0')}';
    return ListView(
      padding: EdgeInsets.all(metrics.md),
      children: [
        CallsignText(q.call.value),
        SizedBox(height: metrics.sm),
        Container(
          padding: EdgeInsets.all(metrics.md),
          decoration: BoxDecoration(
            color: style.colors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SyncStatusChip(state: status?.state),
              SizedBox(height: metrics.sm),
              Text(
                explainStatus(l10n, status),
                style: TextStyle(color: style.colors.foreground),
              ),
              if (status?.serverMessage case final msg?) ...[
                SizedBox(height: metrics.xs),
                Text(
                  l10n.serverSaid(msg),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: style.colors.foreground),
                ),
              ],
              if (status?.state == SyncState.conflict &&
                  status?.problem == SyncProblem.readOnlyFieldsChanged) ...[
                SizedBox(height: metrics.sm),
                Wrap(
                  spacing: metrics.sm,
                  runSpacing: metrics.sm,
                  children: [
                    if (account?.canDeleteOnServer ?? false)
                      FilledButton(
                        onPressed: () => ref
                            .read(qsoRepositoryProvider)
                            .resolveConflict(q.id, replaceOnServer: true),
                        child: Text(l10n.conflictReplace),
                      ),
                    OutlinedButton(
                      onPressed: () => ref
                          .read(qsoRepositoryProvider)
                          .resolveConflict(q.id, replaceOnServer: false),
                      child: Text(l10n.conflictKeepServer),
                    ),
                  ],
                ),
                if (!(account?.canDeleteOnServer ?? false))
                  Padding(
                    padding: EdgeInsets.only(top: metrics.xs),
                    child: Text(
                      l10n.conflictReplaceNeedsDelete,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ],
          ),
        ),
        SizedBox(height: metrics.md),
        fact(l10n.fieldDateUtc, '$date ${utcClock(q.timeOn)} ${l10n.unitUtc}'),
        fact(l10n.fieldBand, q.band.name),
        fact(l10n.fieldMode, q.mode.label),
        fact(
          l10n.fieldFrequency,
          q.freqHz == null
              ? null
              : '${Frequency.toAdifMhz(q.freqHz!)} ${l10n.unitMhz}',
        ),
        fact(l10n.fieldRstSent, q.rstSent),
        fact(l10n.fieldRstRcvd, q.rstRcvd),
        fact(l10n.fieldName, q.field('NAME')),
        fact(l10n.fieldGrid, q.field('GRIDSQUARE')),
        fact(l10n.fieldCountry, q.field('COUNTRY')),
        fact(l10n.fieldComment, q.field('COMMENT')),
        SizedBox(height: metrics.lg),
        Wrap(
          spacing: metrics.sm,
          runSpacing: metrics.sm,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.actionDeleteQso),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.deleteQsoTitle),
                    content: Text(
                      status?.remoteQsoId != null &&
                              !(account?.canDeleteOnServer ?? false)
                          ? l10n.deleteQsoLocalOnly
                          : l10n.deleteQsoBody,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.certCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.actionDeleteQso),
                      ),
                    ],
                  ),
                );
                if (confirmed ?? false) {
                  await ref
                      .read(qsoRepositoryProvider)
                      .delete(
                        q.id,
                        canDeleteOnServer: account?.canDeleteOnServer ?? false,
                      );
                  onClosed?.call();
                }
              },
            ),
            if (status?.state == SyncState.synced &&
                status?.remoteQsoId != null &&
                item.qso.contestSessionId == null &&
                item.qso.activationId == null)
              OutlinedButton.icon(
                icon: const Icon(Icons.cleaning_services_outlined),
                label: Text(l10n.qsoRemoveFromDevice),
                onPressed: () => _removeFromDevice(context, ref, item),
              ),
          ],
        ),
        if (status?.state == SyncState.synced)
          Padding(
            padding: EdgeInsets.only(top: metrics.xs),
            child: Text(
              l10n.qsoRemoveFromDeviceHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        SizedBox(height: metrics.lg),
        _QsoJournal(qsoId: q.id),
      ],
    );
  }

  /// Removes the local copy of one synced QSO, after Wavelog confirmed it.
  Future<void> _removeFromDevice(
    BuildContext context,
    WidgetRef ref,
    LoggedQso item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final account = ref
        .read(accountsProvider)
        .value
        ?.where((a) => a.id == item.qso.accountId)
        .firstOrNull;
    if (account == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.freeSpaceConfirmTitle),
        content: Text(l10n.freeSpaceConfirmBody(1)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.freeSpaceRemoveOnly),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;
    final service = ref.read(qsoEvictionServiceProvider);
    try {
      final plan = await service.plan(account, ids: {item.qso.id});
      if (plan.confirmed.isEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.qsoNotRemoved)));
        return;
      }
      final removed = await service.carryOut(plan);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.freeSpaceDone(removed))),
      );
      onClosed?.call();
    } on EvictionCheckFailed catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (e.problem) {
            EvictionCheckProblem.offline => l10n.freeSpaceOffline,
            EvictionCheckProblem.unauthorized => l10n.freeSpaceUnauthorized,
            EvictionCheckProblem.server => l10n.freeSpaceServerProblem,
            EvictionCheckProblem.tooMany => l10n.freeSpaceTooMany,
          }),
        ),
      );
    }
  }
}

/// The QSO's own journal: every sync step.
class _QsoJournal extends ConsumerWidget {
  const new({required this.qsoId});

  final String qsoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(qsoJournalProvider(qsoId)).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.syncHistory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        for (final e in entries) JournalTile(entry: e),
      ],
    );
  }
}

/// The journal of one QSO.
final StreamProviderFamily<List<JournalEntry>, String> qsoJournalProvider =
    StreamProvider.family<List<JournalEntry>, String>(
      (ref, qsoId) =>
          ref.watch(journalRepositoryProvider).watch(qsoId: qsoId, limit: 50),
    );

/// One journal line in plain language.
class JournalTile extends StatelessWidget {
  /// Creates the tile.
  const new({required this.entry, super.key});

  /// The entry.
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final at = DateTime.fromMillisecondsSinceEpoch(entry.at, isUtc: true);
    final when =
        '${at.year}-${at.month.toString().padLeft(2, '0')}-'
        '${at.day.toString().padLeft(2, '0')} '
        '${at.hour.toString().padLeft(2, '0')}:'
        '${at.minute.toString().padLeft(2, '0')} ${l10n.unitUtc}';
    final call = entry.detail['call'] as String?;
    final text = switch (entry.event) {
      JournalEvent.logged => l10n.journalLogged,
      JournalEvent.imported => l10n.journalImported,
      JournalEvent.editQueued => l10n.journalEditQueued,
      JournalEvent.requestStarted => l10n.journalRequestStarted,
      JournalEvent.uploaded => l10n.journalUploaded,
      JournalEvent.patched => l10n.journalPatched,
      JournalEvent.deletedOnServer => l10n.journalDeletedOnServer,
      JournalEvent.deletedLocallyOnly => l10n.journalDeletedLocallyOnly,
      JournalEvent.evictedLocally => l10n.journalEvictedLocally(
        (entry.detail['count'] as int?) ?? 0,
      ),
      JournalEvent.verifiedOnServer => l10n.journalVerified,
      JournalEvent.notOnServer => l10n.journalNotOnServer,
      JournalEvent.retryScheduled => l10n.journalRetry,
      JournalEvent.rejected => l10n.journalRejected,
      JournalEvent.conflict => l10n.journalConflict,
      JournalEvent.conflictResolved => l10n.journalConflictResolved,
      JournalEvent.accountBlocked => l10n.journalAccountBlocked,
      JournalEvent.runStarted => l10n.journalRunStarted,
      JournalEvent.runFinished => l10n.journalRunFinished,
      JournalEvent.contestSessionCreated => l10n.journalContestSessionCreated,
      JournalEvent.contestQsosLinked => l10n.journalContestQsosLinked,
      JournalEvent.contestSessionLocalOnly =>
        l10n.journalContestSessionLocalOnly,
      JournalEvent.contestSessionRetry => l10n.journalContestSessionRetry,
    };
    final server = entry.detail['server'] as String?;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(call == null ? text : '$call · $text'),
      subtitle: Text(
        server == null ? when : '$when · ${l10n.serverSaid(server)}',
      ),
    );
  }
}
