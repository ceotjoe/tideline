import 'dart:math';

import 'package:tideline_domain/tideline_domain.dart';

/// Thrown when a database exists but its key is missing from the secure
/// store. Tideline never silently replaces the key: that would orphan every
/// unsynced QSO. The UI offers restore-from-backup instead.
class DatabaseKeyMissingException implements Exception {
  /// Creates the exception.
  const new();

  @override
  String toString() => 'DatabaseKeyMissingException';
}

/// Provides the 256-bit database key from the [SecretStore].
class DatabaseKeyManager {
  /// Creates a manager backed by the secure `store`.
  new(this._store, {Random? random}) : _random = random ?? Random.secure();

  final SecretStore _store;
  final Random _random;

  /// Returns the stored key, or creates one when [databaseExists] is false.
  ///
  /// Throws [DatabaseKeyMissingException] if a database exists but no key
  /// is stored.
  Future<String> obtainKey({required bool databaseExists}) async {
    final existing = await _store.read(SecretKeys.databaseKey);
    if (existing != null) return existing;
    if (databaseExists) throw const DatabaseKeyMissingException();

    final key = List<int>.generate(
      32,
      (_) => _random.nextInt(256),
    ).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _store.write(SecretKeys.databaseKey, key);

    // Read back to make sure the store really persisted it before any data
    // is encrypted with it.
    final persisted = await _store.read(SecretKeys.databaseKey);
    if (persisted != key) {
      throw StateError('Secure store did not persist the database key.');
    }
    return key;
  }
}

/// Provides this installation's stable device id from the [SecretStore].
class DeviceIdProvider {
  /// Creates a provider backed by the secure `store`.
  new(this._store);

  final SecretStore _store;

  /// Returns the device id, creating it on first use.
  Future<String> obtain() async {
    final existing = await _store.read(SecretKeys.deviceId);
    if (existing != null && isUuid(existing)) return existing;
    final id = newUuidV4();
    await _store.write(SecretKeys.deviceId, id);
    return id;
  }
}
