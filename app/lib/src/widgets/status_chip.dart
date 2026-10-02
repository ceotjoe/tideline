import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Icon, colours and label for a sync state. Never colour alone.
({IconData icon, StatusColors colors, String label}) syncStateStyle(
  BuildContext context,
  SyncState? state,
) {
  final c = context.colors;
  final l10n = AppLocalizations.of(context);
  return switch (state) {
    null || SyncState.synced => (
      icon: Icons.cloud_done_outlined,
      colors: c.synced,
      label: l10n.statusSynced,
    ),
    SyncState.local => (
      icon: Icons.phone_android_outlined,
      colors: c.pending,
      label: l10n.statusLocal,
    ),
    SyncState.queued => (
      icon: Icons.schedule,
      colors: c.pending,
      label: l10n.statusQueued,
    ),
    SyncState.uploading => (
      icon: Icons.cloud_upload_outlined,
      colors: c.pending,
      label: l10n.statusUploading,
    ),
    SyncState.verifying => (
      icon: Icons.manage_search,
      colors: c.pending,
      label: l10n.statusVerifying,
    ),
    SyncState.conflict => (
      icon: Icons.call_split,
      colors: c.conflict,
      label: l10n.statusConflict,
    ),
    SyncState.blocked => (
      icon: Icons.key_off_outlined,
      colors: c.conflict,
      label: l10n.statusBlocked,
    ),
    SyncState.rejected => (
      icon: Icons.block,
      colors: c.rejected,
      label: l10n.statusRejected,
    ),
  };
}

/// A small chip showing a QSO's sync state with icon and text.
class SyncStatusChip extends StatelessWidget {
  /// Creates the chip for [state] (null = no sync needed).
  const new({required this.state, super.key});

  /// The state to show.
  final SyncState? state;

  @override
  Widget build(BuildContext context) {
    final style = syncStateStyle(context, state);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.metrics.sm,
        vertical: context.metrics.xs,
      ),
      decoration: BoxDecoration(
        color: style.colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: style.colors.foreground.withValues(alpha: .4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 16, color: style.colors.foreground),
          SizedBox(width: context.metrics.xs),
          Text(
            style.label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: style.colors.foreground),
          ),
        ],
      ),
    );
  }
}
