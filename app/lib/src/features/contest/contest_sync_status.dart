import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline_data/tideline_data.dart';

/// The localised reason for a [ContestSyncProblem] key (the value stored in
/// `ContestSession.remoteErrorKey`). Unknown keys, for example from a newer
/// version, get a generic text.
String contestSyncProblemText(
  AppLocalizations l10n,
  String key,
) => switch (key) {
  ContestSyncProblem.contestNotActive => l10n.contestSyncProblemNotActive,
  ContestSyncProblem.missingPermission =>
    l10n.contestSyncProblemMissingPermission,
  ContestSyncProblem.serverTooOld => l10n.contestSyncProblemServerTooOld,
  ContestSyncProblem.deletedOnServer => l10n.contestSyncProblemDeletedOnServer,
  ContestSyncProblem.noAdifName => l10n.contestSyncProblemNoAdifName,
  ContestSyncProblem.stationUnknown => l10n.contestSyncProblemStationUnknown,
  ContestSyncProblem.rejected => l10n.contestSyncProblemRejected,
  _ => l10n.contestSyncProblemUnknown,
};

/// The icon of a session's Wavelog state. Always shown with the text.
IconData contestSyncIcon(ContestRemoteState state) => switch (state) {
  ContestRemoteState.local => Icons.cloud_off_outlined,
  ContestRemoteState.pending => Icons.cloud_upload_outlined,
  ContestRemoteState.verifying => Icons.sync,
  ContestRemoteState.created => Icons.cloud_done_outlined,
};

/// The localised Wavelog state of [session], with the reason if there is
/// one (for example "Only on this device: Your Wavelog server is older than
/// version 3.2 ...").
String contestSyncText(AppLocalizations l10n, ContestSession session) {
  final state = switch (session.remoteState) {
    ContestRemoteState.local => l10n.contestSyncLocal,
    ContestRemoteState.pending => l10n.contestSyncPending,
    ContestRemoteState.verifying => l10n.contestSyncVerifying,
    ContestRemoteState.created => l10n.contestSyncCreated,
  };
  final key = session.remoteErrorKey;
  if (key == null) return state;
  return l10n.contestSyncWithReason(state, contestSyncProblemText(l10n, key));
}

/// One line (icon and text) telling where a contest session stands on
/// Wavelog.
class ContestSyncStatus extends StatelessWidget {
  /// Creates the status line.
  const new({required this.session, super.key});

  /// The session to describe.
  final ContestSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = contestSyncText(l10n, session);
    return Semantics(
      container: true,
      label: l10n.contestSyncStatusLabel(text),
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            contestSyncIcon(session.remoteState),
            size: 18,
            color: context.colors.textSecondary,
          ),
          SizedBox(width: context.metrics.xs),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
