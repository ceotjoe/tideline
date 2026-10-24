import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/widgets/empty_state.dart';

/// Shown instead of the app when the database or the secure store cannot be
/// opened. Never deletes or replaces anything.
class StartupErrorApp extends StatelessWidget {
  /// Creates the error app. `secretStoreUnavailable` explains a missing
  /// system keyring instead of the generic message.
  const new({super.key, this.secretStoreUnavailable = false});

  /// Whether the platform secure store was the cause.
  final bool secretStoreUnavailable;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: buildTidelineTheme(variant: TidelineThemeVariant.light),
    darkTheme: buildTidelineTheme(variant: TidelineThemeVariant.dark),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          body: EmptyState(
            icon: Icons.error_outline,
            title: l10n.startupErrorTitle,
            body: secretStoreUnavailable
                ? l10n.startupSecretStoreBody
                : l10n.startupErrorBody,
          ),
        );
      },
    ),
  );
}
