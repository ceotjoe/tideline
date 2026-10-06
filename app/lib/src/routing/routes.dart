/// Route paths.
abstract final class Routes {
  /// The page one level up in the path (`/settings/account/x` →
  /// `/settings/account`), or null for a top-level tab. Pages that belong to
  /// a tab are nested in its path, so "back" on a desktop is "up".
  static String? parentOf(Uri location) {
    final segments = location.pathSegments;
    if (segments.length < 2) return null;
    return '/${segments.sublist(0, segments.length - 1).join('/')}';
  }

  static const welcome = '/welcome';
  static const log = '/log';
  static const callsigns = '/callsigns';
  static const sync = '/sync';
  static const settings = '/settings';

  /// Pages of the settings hub.
  static const settingsAccount = '/settings/account';

  /// The page of one account.
  static String settingsAccountDetail(String accountId) =>
      '/settings/account/$accountId';

  /// Removing synced QSOs of one account from this device.
  static String settingsFreeSpace(String accountId) =>
      '/settings/account/$accountId/free-space';

  /// Connecting another Wavelog account (a full-screen flow above the shell).
  static const addAccount = '/add-account';
  static const settingsAppearance = '/settings/appearance';
  static const settingsFieldMode = '/settings/field-mode';
  static const settingsReferenceData = '/settings/reference-data';
  static const settingsSecurity = '/settings/security';
  static const settingsDeveloper = '/settings/developer';

  /// Contest mode: the entry screen, or the setup when no session runs.
  static const contest = '/contest';

  /// Contest session setup and the list of past sessions.
  static const contestSetup = '/contest-setup';

  /// Fast Log Entry: QSOs typed as shorthand.
  static const fle = '/fle';

  /// Starting a SOTA, POTA or WWFF activation.
  static const activationSetup = '/activation-setup';
}
