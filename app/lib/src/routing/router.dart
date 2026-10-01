import 'package:go_router/go_router.dart';
import 'package:tideline/src/features/log/log_screen.dart';
import 'package:tideline/src/features/settings/settings_screen.dart';
import 'package:tideline/src/features/sync/sync_screen.dart';
import 'package:tideline/src/layout/adaptive_shell.dart';

/// Route paths.
abstract final class Routes {
  static const log = '/log';
  static const sync = '/sync';
  static const settings = '/settings';
}

/// Creates the app router. Multi-pane layouts live inside screens, so
/// resizing a window never changes the route (ADR 0004).
GoRouter createRouter() => GoRouter(
  initialLocation: Routes.log,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AdaptiveShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.log,
              builder: (context, state) => const LogScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.sync,
              builder: (context, state) => const SyncScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
