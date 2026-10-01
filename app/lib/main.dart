import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/app.dart';
import 'package:tideline/src/features/startup_error_app.dart';
import 'package:tideline/src/platform/bootstrap.dart';
import 'package:tideline/src/platform/platform_secret_store.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline_data/tideline_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final result = await bootstrap(PlatformSecretStore());
    runApp(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(result.database)],
        child: const TidelineApp(),
      ),
    );
  } on DatabaseKeyMissingException {
    runApp(const StartupErrorApp(keyMissing: true));
  } on Object catch (error) {
    // Developer-facing only; never includes key material (see
    // DatabaseEncryptionException).
    debugPrint('Startup failed: ${error.runtimeType}');
    runApp(const StartupErrorApp(keyMissing: false));
  }
}
