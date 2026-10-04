import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/src/features/activation/activation_setup_screen.dart';
import 'package:tideline/src/features/callsigns/callsigns_page.dart';
import 'package:tideline/src/features/contest/contest_screen.dart';
import 'package:tideline/src/features/contest/contest_setup_screen.dart';
import 'package:tideline/src/features/freespace/free_space_page.dart';
import 'package:tideline/src/features/log/log_screen.dart';
import 'package:tideline/src/features/onboarding/onboarding_screen.dart';
import 'package:tideline/src/features/settings/settings_pages.dart';
import 'package:tideline/src/features/settings/settings_screen.dart';
import 'package:tideline/src/features/sync/sync_screen.dart';
import 'package:tideline/src/layout/adaptive_shell.dart';
import 'package:tideline/src/routing/routes.dart';

export 'package:tideline/src/routing/routes.dart';

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
    // Contest mode is a focused full-screen mode above the shell, so the
    // log screen (and its state) stays underneath and Back returns to it.
    GoRoute(
      path: Routes.addAccount,
      builder: (context, state) => const OnboardingScreen(addAccount: true),
    ),
    GoRoute(
      path: Routes.contest,
      builder: (context, state) => const ContestRoute(),
    ),
    GoRoute(
      path: Routes.contestSetup,
      builder: (context, state) => const ContestSetupScreen(),
    ),
    GoRoute(
      path: Routes.activationSetup,
      builder: (context, state) => const ActivationSetupScreen(),
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
              routes: [
                GoRoute(
                  path: 'account',
                  builder: (context, state) => const AccountsSettingsPage(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => AccountDetailSettingsPage(
                        accountId: state.pathParameters['id']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'free-space',
                          builder: (context, state) => FreeSpacePage(
                            accountId: state.pathParameters['id']!,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearanceSettingsPage(),
                ),
                GoRoute(
                  path: 'reference-data',
                  builder: (context, state) =>
                      const ReferenceDataSettingsPage(),
                ),
                GoRoute(
                  path: 'callsigns',
                  builder: (context, state) => const CallsignsPage(),
                ),
                GoRoute(
                  path: 'security',
                  builder: (context, state) => const SecuritySettingsPage(),
                ),
                GoRoute(
                  path: 'developer',
                  builder: (context, state) => const DeveloperSettingsPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
