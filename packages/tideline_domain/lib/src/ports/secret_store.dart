/// Platform secure storage (Keychain, Android Keystore, Windows protected
/// storage) for API tokens and the database key.
///
/// Implementations must never write values to logs, preferences or backups.
abstract interface class SecretStore {
  /// Returns the value for [key], or `null` if none is stored.
  Future<String?> read(String key);

  /// Stores [value] under [key], replacing any previous value.
  Future<void> write(String key, String value);

  /// Removes [key]. Does nothing if it does not exist.
  Future<void> delete(String key);
}

/// Well-known [SecretStore] keys.
abstract final class SecretKeys {
  /// Hex-encoded 256-bit key of the local database.
  static const String databaseKey = 'tideline.db.key.v1';

  /// Stable identifier of this installation, used in HLC timestamps.
  static const String deviceId = 'tideline.device.id';

  /// The Wavelog API token for the account with [accountId].
  static String accountToken(String accountId) => 'account.$accountId.token';
}
