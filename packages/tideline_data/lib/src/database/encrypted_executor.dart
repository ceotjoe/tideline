import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

/// Thrown when the database cannot be opened with encryption.
class DatabaseEncryptionException implements Exception {
  /// Creates the exception with a developer-facing [message].
  const new(this.message);

  /// Developer-facing description; never contains key material.
  final String message;

  @override
  String toString() => 'DatabaseEncryptionException: $message';
}

final RegExp _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// Opens [file] as an encrypted database using [hexKey] (64 lowercase hex
/// characters, i.e. 256 bits), on a background isolate.
///
/// Refuses to open the database if the linked SQLite library has no
/// encryption support. See `docs/adr/0005-encrypted-database-sqlite3mc.md`.
QueryExecutor openEncryptedExecutor(File file, {required String hexKey}) {
  _checkKey(hexKey);
  return NativeDatabase.createInBackground(
    file,
    setup: (db) => applyEncryption(db, hexKey),
  );
}

/// Configures SQLite3MultipleCiphers on a freshly opened connection and
/// verifies that [hexKey] decrypts the database.
///
/// Must run before any other statement on the connection.
void applyEncryption(Database db, String hexKey) {
  _checkKey(hexKey);
  if (db.select('PRAGMA cipher').isEmpty) {
    throw const DatabaseEncryptionException(
      'SQLite library without encryption support. Ensure the sqlite3 build '
      'hook uses "source: sqlite3mc".',
    );
  }
  // The cipher must be chosen before the key is applied.
  db.execute("PRAGMA cipher = 'chacha20'");
  try {
    // Safe to interpolate: _checkKey guarantees exactly 64 hex characters.
    db.execute("PRAGMA hexkey = '$hexKey'");
  } on SqliteException catch (e) {
    // SqliteException.toString() includes the statement, i.e. the key.
    // Rethrow without it so the key can never reach a log.
    throw DatabaseEncryptionException(
      'Setting the database key failed (SQLite code ${e.extendedResultCode}). '
      'Note: in-memory databases cannot be encrypted.',
    );
  }
  try {
    // Touch the schema so a wrong key fails here, not on first query.
    db.select('SELECT count(*) FROM sqlite_master');
  } on SqliteException {
    throw const DatabaseEncryptionException(
      'The database key does not match this database.',
    );
  }
}

void _checkKey(String hexKey) {
  if (!_hexKey.hasMatch(hexKey)) {
    throw ArgumentError.value(
      '<redacted>',
      'hexKey',
      'must be 64 lowercase hex characters',
    );
  }
}
