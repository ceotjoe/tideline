import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/services/app_services.dart';

/// The worked-before index: rebuild it from the log.
class WorkedBeforeSection extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(activeAccountProvider);
    // The pull cursor is reset, so a sync must not be writing it right now.
    final syncing = ref.watch(syncControllerProvider) is SyncRunning;
    return ListTile(
      leading: const Icon(Icons.manage_search),
      title: Text(l10n.actionRebuildWorkedBefore),
      subtitle: Text(l10n.rebuildWorkedBeforeHint),
      enabled: account != null && !syncing,
      onTap: () => _rebuild(context, ref, account!.id),
    );
  }

  Future<void> _rebuild(
    BuildContext context,
    WidgetRef ref,
    String accountId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final index = ref.read(workedBeforeRepositoryProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rebuildWorkedBeforeConfirmTitle),
        content: Text(l10n.rebuildWorkedBeforeConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionRebuild),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !context.mounted) return;

    // Progress: a modal dialog that cannot be dismissed while the index is
    // being rebuilt, with a live-region label for screen readers.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  const SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(width: context.metrics.md),
                  Expanded(child: Text(l10n.rebuildWorkedBeforeProgress)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    String message;
    try {
      // Atomic: if it fails, the old index stays.
      await index.rebuildAll(accountId);
      message = l10n.rebuildWorkedBeforeDone;
    } on Object {
      message = l10n.rebuildWorkedBeforeFailed;
    }
    navigator.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
