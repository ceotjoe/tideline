import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/log/qso_detail.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/status_chip.dart';
import 'package:tideline/src/widgets/tide_gauge.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Plain-language result of the last sync run.
String? describeRun(AppLocalizations l10n, SyncActivity activity) =>
    switch (activity) {
      SyncRunning() => l10n.syncRunning,
      SyncNeedsReview(:final count) => l10n.syncNeedsReview(count),
      SyncIdle(last: null) => null,
      SyncIdle(:final last?) => switch (last.outcome) {
        SyncRunOutcome.completed => l10n.syncCompleted(last.processed),
        SyncRunOutcome.offline => l10n.syncOffline,
        SyncRunOutcome.blocked => l10n.syncBlocked,
        SyncRunOutcome.rateLimited => l10n.syncRateLimited,
        SyncRunOutcome.alreadyRunning => l10n.syncRunning,
      },
    };

/// Sync status, history and the upload preview.
class SyncScreen extends ConsumerWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final metrics = context.metrics;
    final counts = ref.watch(syncCountsProvider).value ?? const {};
    final pending = ref.watch(pendingSyncCountProvider).value ?? 0;
    final activity = ref.watch(syncControllerProvider);
    final journal = ref.watch(accountJournalProvider).value ?? const [];
    final status = describeRun(l10n, activity);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSync)),
      body: ListView(
        padding: EdgeInsets.all(metrics.md),
        children: [
          // Decorative: the count is the headline below (and the shell's
          // gauge), so screen readers hear it once.
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: TideGauge(
              pendingCount: pending,
              height: 120,
              showLabel: false,
            ),
          ),
          SizedBox(height: metrics.md),
          Text(l10n.tideGaugeLabel(pending), style: textTheme.headlineMedium),
          SizedBox(height: metrics.sm),
          Wrap(
            spacing: metrics.sm,
            runSpacing: metrics.sm,
            children: [
              for (final state in SyncState.values)
                if ((counts[state] ?? 0) > 0)
                  MergeSemantics(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SyncStatusChip(state: state),
                        SizedBox(width: metrics.xs),
                        Text(
                          NumberFormat.decimalPattern(l10n.localeName)
                              .format(counts[state]),
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
            ],
          ),
          SizedBox(height: metrics.md),
          if (status != null)
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: EdgeInsets.only(bottom: metrics.md),
                child: Text(status, style: textTheme.bodyLarge),
              ),
            ),
          Wrap(
            spacing: metrics.sm,
            runSpacing: metrics.sm,
            children: [
              FilledButton.icon(
                onPressed: activity is SyncRunning
                    ? null
                    : () => CommandHandlers.invoke(context, CommandIds.syncNow),
                icon: const Icon(Icons.sync),
                label: Text(l10n.commandSyncNow),
              ),
              if ((counts[SyncState.queued] ?? 0) > 0)
                OutlinedButton.icon(
                  onPressed: () => showUploadPreview(context, ref),
                  icon: const Icon(Icons.preview_outlined),
                  label: Text(l10n.actionPreviewUpload),
                ),
            ],
          ),
          SizedBox(height: metrics.lg),
          Semantics(
            header: true,
            child: Text(l10n.syncHistory, style: textTheme.titleMedium),
          ),
          if (journal.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: metrics.md),
              child: Text(l10n.syncEmptyBody),
            ),
          for (final e in journal) JournalTile(entry: e),
        ],
      ),
    );
  }
}

/// Shows the dry-run preview and, on confirmation, uploads.
Future<void> showUploadPreview(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final account = ref.read(activeAccountProvider);
  if (account == null) return;
  final preview = ref.read(syncEngineProvider).preview(account.id);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.previewTitle),
      content: FutureBuilder<SyncPreview>(
        future: preview,
        builder: (context, snap) {
          final p = snap.data;
          if (p == null) {
            return Semantics(
              label: l10n.onboardingChecking,
              child: const SizedBox(
                height: 64,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.previewToUpload(p.toUpload)),
              if (p.localDuplicates > 0)
                Text(l10n.previewDuplicates(p.localDuplicates)),
              Text(
                !p.serverReachable
                    ? l10n.previewServerUnreachable
                    : p.serverParsed == null
                    ? ''
                    : l10n.previewServerParsed(p.serverParsed!, p.toUpload),
              ),
              SizedBox(height: context.metrics.sm),
              Text(
                l10n.previewSafety,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.certCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.previewUpload),
        ),
      ],
    ),
  );
  if (confirmed ?? false) {
    await ref.read(syncControllerProvider.notifier).syncNow(reviewed: true);
  }
}
