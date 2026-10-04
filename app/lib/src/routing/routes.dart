/// Route paths.
abstract final class Routes {
  static const welcome = '/welcome';
  static const log = '/log';
  static const sync = '/sync';
  static const settings = '/settings';

  /// Pages of the settings hub.
  static const settingsAccount = '/settings/account';
  static const settingsAppearance = '/settings/appearance';
  static const settingsReferenceData = '/settings/reference-data';
  static const settingsSecurity = '/settings/security';
  static const settingsDeveloper = '/settings/developer';

  /// Contest mode: the entry screen, or the setup when no session runs.
  static const contest = '/contest';

  /// Contest session setup and the list of past sessions.
  static const contestSetup = '/contest-setup';

  /// Starting a SOTA, POTA or WWFF activation.
  static const activationSetup = '/activation-setup';
}
