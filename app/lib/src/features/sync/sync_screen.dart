import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command_handlers.dart';
import 'package:tideline/src/commands/command_registry.dart';
import 'package:tideline/src/widgets/empty_state.dart';

/// Sync status and history. The sync engine arrives in the MVP.
class SyncScreen extends StatelessWidget {
  /// Creates the sync screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSync)),
      body: EmptyState(
        icon: Icons.waves,
        title: l10n.syncEmptyTitle,
        body: l10n.syncEmptyBody,
        action: Builder(
          builder: (context) => FilledButton.icon(
            onPressed: () =>
                CommandHandlers.invoke(context, CommandIds.syncNow),
            icon: const Icon(Icons.sync),
            label: Text(l10n.commandSyncNow),
          ),
        ),
      ),
    );
  }
}
