import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tideline_domain/tideline_domain.dart';

/// [SecretStore] backed by the platform secure store: Keychain (iOS,
/// macOS), Android Keystore, DPAPI-protected file (Windows).
/// See docs/adr/0006-secrets-secure-storage.md.
class PlatformSecretStore implements SecretStore {
  /// Creates the store with Tideline's hardened platform options.
  new()
    : _storage = const FlutterSecureStorage(
        // Available after first unlock (the app may resume in the background);
        // never synced to iCloud or migrated to another device.
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
        // The legacy (file-based) login keychain works without a provisioning
        // profile. Revisit with the data-protection keychain once release
        // signing is set up (ADR 0006).
        mOptions: MacOsOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
          usesDataProtectionKeychain: false,
        ),
      );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
