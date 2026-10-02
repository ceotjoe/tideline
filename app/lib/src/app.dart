import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/commands/command.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/features/settings/settings_screen.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/routing/router.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/settings/app_settings.dart';
import 'package:tideline/src/widgets/app_lock.dart';

/// Family name of the bundled reading font (pubspec.yaml).
const readingFontFamily = 'AtkinsonHyperlegible';

/// The Tideline app.
class TidelineApp extends ConsumerStatefulWidget {
  /// Creates the app. [router] is injectable for tests.
  const new({this.router, super.key});

  /// Router to use; defaults to [createRouter].
  final GoRouter? router;

  @override
  ConsumerState<TidelineApp> createState() => _TidelineAppState();
}

class _TidelineAppState extends ConsumerState<TidelineApp> {
  final _hasAccount = ValueNotifier<bool?>(null);
  late final GoRouter _router =
      widget.router ?? createRouter(hasAccount: _hasAccount);

  @override
  void initState() {
    super.initState();
    // Load the bundled contest definitions in the background. Nothing waits
    // for it and a failure is only logged, so logging is never blocked.
    ref.read(contestSeedProvider);
  }

  @override
  void dispose() {
    _hasAccount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final registry = ref.watch(commandRegistryProvider);
    final accounts = ref.watch(accountsProvider);
    if (accounts.hasValue) _hasAccount.value = accounts.value!.isNotEmpty;
    // Keep the sync triggers (foreground, connectivity) alive.
    ref.watch(syncControllerProvider);

    ThemeData themeFor(TidelineThemeVariant v) => buildTidelineTheme(
      variant: v,
      density: settings.density,
      textSpacing: settings.textSpacing,
      fontFamily: settings.readingFont ? readingFontFamily : null,
    );

    final followSystem = settings.theme == ThemeChoice.system;
    final fixed = settings.theme.resolve(Brightness.light);

    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: themeFor(followSystem ? TidelineThemeVariant.light : fixed),
      darkTheme: themeFor(followSystem ? TidelineThemeVariant.dark : fixed),
      // The OS "increase contrast" setting maps to the sunlight theme.
      highContrastTheme: followSystem
          ? themeFor(TidelineThemeVariant.sunlight)
          : null,
      themeMode: followSystem ? ThemeMode.system : ThemeMode.light,
      locale: settings.localeOverride,
      supportedLocales: selectableLocales(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        Widget result = AppLock(
          child: Shortcuts(
            shortcuts: registry.shortcutMap(
              ShortcutPlatform.of(Theme.of(context).platform),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
        if (kDebugMode && settings.forceRtl) {
          result = Directionality(
            textDirection: TextDirection.rtl,
            child: result,
          );
        }
        return result;
      },
    );
  }
}
