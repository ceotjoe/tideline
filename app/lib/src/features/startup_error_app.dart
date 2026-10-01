import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/design/tokens/color_tokens.dart';
import 'package:tideline/src/widgets/empty_state.dart';

/// Shown instead of the app when the database cannot be opened. Never
/// deletes or replaces anything: the user decides how to recover.
class StartupErrorApp extends StatelessWidget {
  /// Creates the error app; [keyMissing] selects the explanation.
  const new({required this.keyMissing, super.key});

  /// Whether the database key is missing (as opposed to another failure).
  final bool keyMissing;

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
            icon: Icons.lock_outline,
            title: keyMissing
                ? l10n.startupKeyMissingTitle
                : l10n.startupErrorTitle,
            body: keyMissing
                ? l10n.startupKeyMissingBody
                : l10n.startupErrorBody,
          ),
        );
      },
    ),
  );
}
