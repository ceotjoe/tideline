import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/features/accounts/account_switching.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/data_transfer.dart';
import 'package:tideline/src/widgets/app_lock.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:wavelog_client/wavelog_client.dart';

void _snack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// One Wavelog account: server, token and the actions on it.
class AccountSection extends ConsumerWidget {
  /// Creates the section for [account].
  const new({required this.account, super.key});

  /// The account shown.
  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeAccountProvider)?.id == account.id;
    final block = ref.watch(accountSwitchBlockProvider);
    final expires = account.tokenExpiresAt;
    final date = DateFormat.yMMMd(l10n.localeName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(
            active ? Icons.check_circle_outline : Icons.dns_outlined,
          ),
          title: Text(account.label),
          subtitle: Text(
            [
              account.baseUrl,
              if (active) l10n.accountsInUse,
              if (account.certPinSha256 != null) l10n.accountPinned,
              if (expires != null)
                l10n.accountTokenExpires(
                  date.format(DateTime.fromMillisecondsSinceEpoch(expires)),
                )
              else
                l10n.accountTokenNoExpiry,
            ].join('\n'),
          ),
        ),
        if (!active) ...[
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(l10n.accountsUseForLogging),
            subtitle: block == null ? null : Text(blockText(l10n, block)),
            enabled: block == null,
            onTap: () async {
              final blocked = await switchAccount(ref, account);
              if (blocked != null || !context.mounted) return;
              _snack(context, l10n.accountsSwitchedTo(account.label));
            },
          ),
        ],
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: Text(l10n.accountsRename),
          onTap: () => _rename(context, ref, account),
        ),
        ListTile(
          leading: const Icon(Icons.key_outlined),
          title: Text(l10n.actionReplaceToken),
          onTap: () => _replaceToken(context, ref, account),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(l10n.actionRemoveAccount),
          onTap: () => _remove(context, ref, account),
        ),
      ],
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _RenameDialog(initial: account.label),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref.read(accountRepositoryProvider).rename(account.id, name);
  }

  Future<void> _replaceToken(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.actionReplaceToken),
        content: TextField(
          controller: controller,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(labelText: l10n.fieldToken),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.certCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.actionCheckToken),
          ),
        ],
      ),
    );
    controller.dispose();
    if (token == null || token.isEmpty || !context.mounted) return;
    // Read providers before awaiting; the widget may be gone afterwards.
    final accounts = ref.read(accountRepositoryProvider);
    final sync = ref.read(syncControllerProvider.notifier);
    try {
      final info = await clientForAccount(account, token).tokenInfo();
      await accounts.replaceToken(
        account.id,
        token: token,
        scopes: info.scopes,
        tokenExpiresAt: info.expiresAt?.millisecondsSinceEpoch,
      );
      if (context.mounted) _snack(context, l10n.tokenReplaced);
      unawaited(sync.syncNow());
    } on WavelogUnauthorized {
      if (context.mounted) _snack(context, l10n.problemTokenInvalid);
    } on WavelogException {
      if (context.mounted) _snack(context, l10n.problemUnreachable);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final pending = ref.read(pendingByAccountProvider).value?[account.id] ?? 0;
    final choice = await showDialog<_RemoveChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeAccountTitle),
        content: Text(
          pending > 0
              ? l10n.removeAccountUnsynced(pending)
              : l10n.removeAccountBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.certCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_RemoveChoice.exportFirst),
            child: Text(l10n.accountsExportRemove),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_RemoveChoice.remove),
            child: Text(l10n.actionRemoveAccount),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    if (choice == _RemoveChoice.exportFirst) {
      final transfer = ref.read(dataTransferProvider);
      final bytes = await transfer.exportAdif(account);
      final saved = await transfer.saveFile(
        'tideline-${DataSection._stamp()}.adi',
        bytes,
        'text/plain',
      );
      // Not saved (cancelled or failed): the account stays.
      if (!saved || !context.mounted) return;
    }
    // Leave the page first: the account it shows is about to be gone, and
    // the last account sends the app back to the welcome screen.
    final accounts = ref.read(accountRepositoryProvider);
    context.go(Routes.settingsAccount);
    await accounts.remove(account.id);
  }
}

enum _RemoveChoice { exportFirst, remove }

/// Asks for a new account name. Owns its text controller, so the field is
/// not used after disposal while the dialog fades out.
class _RenameDialog extends StatefulWidget {
  const new({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.accountsRenameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l10n.fieldAccountLabel),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }
}

/// The sentence for [block] (why the account cannot be switched).
String blockText(AppLocalizations l10n, AccountSwitchBlock block) =>
    switch (block) {
      AccountSwitchBlock.contestRunning => l10n.accountsBlockedContest,
      AccountSwitchBlock.activationRunning => l10n.accountsBlockedActivation,
    };

/// Import, export and backups: the user is never locked in.
class DataSection extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final account = ref.watch(activeAccountProvider);
    final several = (ref.watch(accountsProvider).value?.length ?? 0) > 1;
    // Import and export act on the account in use; say which.
    String withAccount(String hint) => several && account != null
        ? '$hint\n${l10n.accountsActsOn(account.label)}'
        : hint;
    final transfer = ref.read(dataTransferProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.file_download_outlined),
          title: Text(l10n.actionImportAdif),
          subtitle: Text(withAccount(l10n.importAdifHint)),
          enabled: account != null,
          onTap: () => _import(context, ref, transfer, account!),
        ),
        ListTile(
          leading: const Icon(Icons.file_upload_outlined),
          title: Text(l10n.actionExportAdif),
          subtitle: Text(withAccount(l10n.exportAdifHint)),
          enabled: account != null,
          onTap: () async {
            final bytes = await transfer.exportAdif(account!);
            final saved = await transfer.saveFile(
              'tideline-${_stamp()}.adi',
              bytes,
              'text/plain',
            );
            if (saved && context.mounted) _snack(context, l10n.exportDone);
          },
        ),
        ListTile(
          leading: const Icon(Icons.enhanced_encryption_outlined),
          title: Text(l10n.actionCreateBackup),
          subtitle: Text(l10n.backupHint),
          onTap: () async {
            final passphrase = await _askPassphrase(context, confirm: true);
            if (passphrase == null) return;
            final bytes = await transfer.createBackup(passphrase);
            final saved = await transfer.saveFile(
              'tideline-${_stamp()}.tlbackup',
              bytes,
              'application/octet-stream',
            );
            if (saved && context.mounted) _snack(context, l10n.backupDone);
          },
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: Text(l10n.actionRestoreBackup),
          onTap: () async {
            final bytes = await transfer.pickFile(['tlbackup']);
            if (bytes == null || !context.mounted) return;
            final passphrase = await _askPassphrase(context, confirm: false);
            if (passphrase == null) return;
            try {
              final report = await transfer.restoreBackup(bytes, passphrase);
              if (context.mounted) {
                _snack(
                  context,
                  l10n.restoreDone(report.qsosAdded, report.qsosSkipped),
                );
              }
            } on BackupPassphraseException {
              if (context.mounted) _snack(context, l10n.restoreWrongPassphrase);
            } on BackupFormatException {
              if (context.mounted) _snack(context, l10n.restoreInvalidFile);
            }
          },
        ),
      ],
    );
  }

  static String _stamp() {
    final n = DateTime.now().toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}${two(n.month)}${two(n.day)}-'
        '${two(n.hour)}${two(n.minute)}';
  }

  Future<void> _import(
    BuildContext context,
    WidgetRef ref,
    DataTransfer transfer,
    Account account,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bytes = await transfer.pickFile(['adi', 'adif']);
    if (bytes == null || !context.mounted) return;
    final stations = ref.read(stationsProvider).value ?? const [];
    final defaultRemote = int.tryParse(
      ref
              .read(settingsValuesProvider)
              .value?['account.${account.id}.defaultStation'] ??
          '',
    );
    final station =
        stations.where((s) => s.remoteId == defaultRemote).firstOrNull ??
        stations.firstOrNull;
    try {
      final summary = await transfer.importAdif(
        bytes,
        account: account,
        stationProfileId: station?.id,
      );
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.importDoneTitle),
          content: Text(
            [
              l10n.importImported(summary.imported),
              if (summary.duplicates > 0)
                l10n.importDuplicates(summary.duplicates),
              if (summary.rejected > 0) l10n.importRejected(summary.rejected),
              if (summary.warnings > 0) l10n.importWarnings(summary.warnings),
              if (station != null) l10n.importStation(station.name),
            ].join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.shortcutsClose),
            ),
          ],
        ),
      );
    } on ImportTooLargeException {
      if (context.mounted) _snack(context, l10n.importTooLarge);
    }
  }

  Future<String?> _askPassphrase(
    BuildContext context, {
    required bool confirm,
  }) async {
    final l10n = AppLocalizations.of(context);
    final first = TextEditingController();
    final second = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final tooShort = first.text.length < 8;
          final mismatch = confirm && first.text != second.text;
          return AlertDialog(
            title: Text(l10n.backupPassphraseTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (confirm) Text(l10n.backupPassphraseHint),
                TextField(
                  controller: first,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(labelText: l10n.fieldPassphrase),
                  onChanged: (_) => setState(() {}),
                ),
                if (confirm)
                  TextField(
                    controller: second,
                    obscureText: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      labelText: l10n.fieldPassphraseRepeat,
                      errorText: mismatch && second.text.isNotEmpty
                          ? l10n.passphraseMismatch
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.certCancel),
              ),
              TextButton(
                onPressed:
                    (confirm && (tooShort || mismatch)) || first.text.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(first.text),
                child: Text(l10n.actionContinue),
              ),
            ],
          );
        },
      ),
    );
    first.dispose();
    second.dispose();
    return result;
  }
}

/// App lock and related privacy settings.
class SecuritySection extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final on = ref.watch(settingsValuesProvider).value?[appLockSetting] == 'on';
    return SwitchListTile(
      secondary: const Icon(Icons.lock_outline),
      title: Text(l10n.settingsAppLock),
      subtitle: Text(l10n.settingsAppLockHint),
      value: on,
      onChanged: (v) => ref
          .read(settingsStoreProvider)
          .write(appLockSetting, v ? 'on' : null),
    );
  }
}
