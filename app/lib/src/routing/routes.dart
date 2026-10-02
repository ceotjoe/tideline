/// Route paths.
abstract final class Routes {
  static const welcome = '/welcome';
  static const log = '/log';
  static const sync = '/sync';
  static const settings = '/settings';

  /// Contest mode: the entry screen, or the setup when no session runs.
  static const contest = '/contest';

  /// Contest session setup and the list of past sessions.
  static const contestSetup = '/contest-setup';
}
