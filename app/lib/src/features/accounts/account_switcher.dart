import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/accounts/account_switching.dart';
import 'package:tideline/src/features/settings/settings_sections.dart'
    show blockText;
import 'package:tideline/src/routing/routes.dart';
import 'package:tideline/src/services/app_services.dart';

/// The account menu of the log screen: shows which account logging goes to
/// and switches it. Absent while there is only one account.
class AccountSwitcher extends ConsumerWidget {
  /// Creates the switcher.
  const new({super.key});

  static const _manage = '\u0000manage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final active = ref.watch(activeAccountProvider);
    if (accounts.length < 2 || active == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final target = context.metrics.minTouchTarget;

    return PopupMenuButton<String>(
      tooltip: l10n.accountsSwitch,
      onSelected: (id) async {
        if (id == _manage) {
          context.go(Routes.settingsAccount);
          return;
        }
        final account = accounts.firstWhere((a) => a.id == id);
        if (account.id == active.id) return;
        final blocked = await switchAccount(ref, account);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              blocked == null
                  ? l10n.accountsSwitchedTo(account.label)
                  : blockText(l10n, blocked),
            ),
          ),
        );
      },
      itemBuilder: (context) => [
        for (final a in accounts)
          PopupMenuItem<String>(
            value: a.id,
            child: Row(
              children: [
                // The mark is an icon plus the text of the item's state:
                // never colour alone.
                Icon(
                  a.id == active.id ? Icons.check : null,
                  size: 20,
                  semanticLabel: a.id == active.id ? l10n.accountsInUse : null,
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(a.label)),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: _manage,
          child: Row(
            children: [
              const Icon(Icons.manage_accounts_outlined, size: 20),
              const SizedBox(width: 8),
              Flexible(child: Text(l10n.accountsManage)),
            ],
          ),
        ),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: target, minWidth: target),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swap_horiz),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  active.label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
