import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tideline_data/tideline_data.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// Everything the app needs before the first frame.
///
/// `legacyDatabaseMovedAside` is true when an encrypted database of Tideline
/// 0.5.x was found and set aside, so the app starts with an empty log.
typedef BootstrapResult = ({
  TidelineDatabase database,
  String deviceId,
  bool legacyDatabaseMovedAside,
});

/// File name of the database inside the app-support directory.
const databaseFileName = 'tideline.sqlite';

/// The platform secure store could not be used, for example on Linux when no
/// secret service (GNOME Keyring, KWallet) is running. Tideline never falls
/// back to storing secrets elsewhere (ADR 0006).
class SecretStoreUnavailableException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() => 'SecretStoreUnavailableException';
}

/// Opens the database and sets an unreadable 0.5.x one aside (ADR 0034).
Future<BootstrapResult> bootstrap(SecretStore secrets) async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  final file = File('${dir.path}/$databaseFileName');

  final movedAside = await moveUnreadableDatabaseAside(
    file,
    now: DateTime.now(),
  );

  final database = TidelineDatabase(openDatabaseExecutor(file));
  // Fail fast before the UI starts.
  await database.customSelect('SELECT 1').get();

  // The old key is only useful for a file that was just set aside (someone
  // technical may want to open it); otherwise do not leave it behind.
  final String deviceId;
  try {
    if (movedAside == null) await secrets.delete(SecretKeys.legacyDatabaseKey);
    deviceId = await DeviceIdProvider(secrets).obtain();
  } on PlatformException {
    await database.close();
    throw const SecretStoreUnavailableException();
  }
  return (
    database: database,
    deviceId: deviceId,
    legacyDatabaseMovedAside: movedAside != null,
  );
}
