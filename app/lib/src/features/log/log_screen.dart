import 'package:flutter/material.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/widgets/empty_state.dart';

/// The QSO log. Logging itself arrives in the MVP.
class LogScreen extends StatelessWidget {
  /// Creates the log screen.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navLog)),
      body: EmptyState(
        icon: Icons.edit_note,
        title: l10n.logEmptyTitle,
        body: l10n.logEmptyBody,
      ),
    );
  }
}
