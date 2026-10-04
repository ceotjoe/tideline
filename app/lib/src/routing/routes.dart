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
  static const sync = '/sync';
  static const settings = '/settings';

  /// Pages of the settings hub.
  static const settingsAccount = '/settings/account';

  /// The page of one account.
  static String settingsAccountDetail(String accountId) =>
      '/settings/account/$accountId';

  /// Connecting another Wavelog account (a full-screen flow above the shell).
  static const addAccount = '/add-account';
  static const settingsAppearance = '/settings/appearance';
  static const settingsReferenceData = '/settings/reference-data';
  static const settingsSecurity = '/settings/security';
  static const settingsDeveloper = '/settings/developer';

  /// The offline callsign directory and its notes.
  static const settingsCallsigns = '/settings/callsigns';

  /// Contest mode: the entry screen, or the setup when no session runs.
  static const contest = '/contest';

  /// Contest session setup and the list of past sessions.
  static const contestSetup = '/contest-setup';

  /// Starting a SOTA, POTA or WWFF activation.
  static const activationSetup = '/activation-setup';
}
