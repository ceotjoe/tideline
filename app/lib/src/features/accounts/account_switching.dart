import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/features/activation/activation_providers.dart';
import 'package:tideline/src/features/contest/contest_providers.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline_data/tideline_data.dart';

/// Why the account cannot be switched right now.
enum AccountSwitchBlock {
  /// A contest session is running: its QSOs belong to this account.
  contestRunning,

  /// An activation is running: its QSOs belong to this account.
  activationRunning,
}

/// What stops a switch of the account, or null when it is allowed. Logging
/// to the wrong account in the middle of a contest or an activation would be
/// hard to notice and to undo, so these end first.
final accountSwitchBlockProvider = Provider<AccountSwitchBlock?>((ref) {
  if (ref.watch(activeContestSessionProvider).value != null) {
    return AccountSwitchBlock.contestRunning;
  }
  if (ref.watch(activeActivationProvider).value != null) {
    return AccountSwitchBlock.activationRunning;
  }
  return null;
});

/// Makes [account] the active one unless a switch is blocked. Returns the
/// block, or null when the account was switched (or already active).
Future<AccountSwitchBlock?> switchAccount(
  WidgetRef ref,
  Account account,
) async {
  final block = ref.read(accountSwitchBlockProvider);
  if (block != null) return block;
  await ref.read(settingsControllerProvider).setActiveAccount(account.id);
  return null;
}
