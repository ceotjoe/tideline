import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/src/features/log/log_screen.dart';
import 'package:tideline/src/features/onboarding/onboarding_screen.dart';
import 'package:tideline/src/features/settings/settings_screen.dart';
import 'package:tideline/src/features/sync/sync_screen.dart';
import 'package:tideline/src/layout/adaptive_shell.dart';

/// Route paths.
abstract final class Routes {
  static const welcome = '/welcome';
  static const log = '/log';
  static const sync = '/sync';
  static const settings = '/settings';
}

/// Creates the app router. Multi-pane layouts live inside screens, so
/// resizing a window never changes the route (ADR 0004).
///
/// [hasAccount] drives first-run onboarding: null while loading, false
/// until a Wavelog account exists.
GoRouter createRouter({ValueListenable<bool?>? hasAccount}) => GoRouter(
  initialLocation: Routes.log,
  refreshListenable: hasAccount,
  redirect: (context, state) {
    final value = hasAccount?.value;
    final atWelcome = state.matchedLocation == Routes.welcome;
    if (value == false && !atWelcome) return Routes.welcome;
    if (value == true && atWelcome) return Routes.log;
    return null;
  },
  routes: [
    GoRoute(
      path: Routes.welcome,
      builder: (context, state) => const OnboardingScreen(),
    ),
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
