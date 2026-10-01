import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Everything the app needs before the first frame.
typedef BootstrapResult = ({TidelineDatabase database, String deviceId});

/// File name of the encrypted database inside the app-support directory.
const databaseFileName = 'tideline.sqlite';

/// Opens the encrypted database, creating its key on first launch.
///
/// Throws [DatabaseKeyMissingException] when a database exists but its key
/// is gone; the app then shows a recovery screen instead of starting fresh.
Future<BootstrapResult> bootstrap(SecretStore secrets) async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  final file = File('${dir.path}/$databaseFileName');

  final key = await DatabaseKeyManager(secrets)
      .obtainKey(databaseExists: file.existsSync());
  final database = TidelineDatabase(openEncryptedExecutor(file, hexKey: key));
  // Fail fast (wrong key, missing cipher) before the UI starts.
  await database.customSelect('SELECT 1').get();

  final deviceId = await DeviceIdProvider(secrets).obtain();
  return (database: database, deviceId: deviceId);
}
