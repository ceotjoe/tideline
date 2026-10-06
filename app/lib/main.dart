import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/app.dart';
import 'package:tideline/src/features/startup_error_app.dart';
import 'package:tideline/src/platform/bootstrap.dart';
import 'package:tideline/src/platform/platform_secret_store.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final secrets = PlatformSecretStore();
    final result = await bootstrap(secrets);
    runApp(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(result.database),
          secretStoreProvider.overrideWithValue(secrets),
          deviceIdProvider.overrideWithValue(result.deviceId),
          legacyDatabaseNoticeProvider.overrideWithValue(
            result.legacyDatabaseMovedAside,
          ),
        ],
        child: const TidelineApp(),
      ),
    );
  } on Object catch (error) {
    debugPrint('Startup failed: ${error.runtimeType}');
    runApp(const StartupErrorApp());
  }
}
