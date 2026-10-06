# 0006. Secrets: flutter_secure_storage

- Status: accepted; the DB key part is superseded by [ADR 0034](0034-remove-app-level-encryption.md) (API tokens stay in the secure store)
- Date: 2026-10-01

## Context
- API tokens and the DB key must live in the platform secure store. Verified 2026-10, flutter_secure_storage 11.2.0:
  - **Android:** RSA-OAEP plus AES-GCM in the Android Keystore. The minimum is API 24. The deprecated
    EncryptedSharedPreferences option is removed.
  - **iOS/macOS:** Keychain. macOS needs the Keychain Sharing entitlement, which requires a provisioning profile, or the
    data-protection keychain must be disabled.
  - **Windows:** since v10 values are stored in an encrypted file instead of the Credential Manager. **Verified in
    `flutter_secure_storage_windows` 4.2.2 source:** the active implementation (`dartPluginClass`,
    `DpapiJsonFileMapStorage`) encrypts the file `flutter_secure_storage.dat` in the app-support directory with DPAPI
    (`CryptProtectData`/`CryptUnprotectData`, current-user scope).
- Android auto-backup can restore prefs whose keys no longer exist, which causes `InvalidKeyException`.

## Decision
- Use flutter_secure_storage behind a `SecretStore` port in the domain.
- Exclude its storage from Android auto-backup (`android:fullBackupContent`/`dataExtractionRules`).
- Windows needs no custom DPAPI wrapper. Re-check the Windows backend whenever the plugin's major version changes.
- iOS/macOS items use `KeychainAccessibility.first_unlock_this_device`: they are available after the first unlock (needed
  when the app resumes in the background) and are never migrated to another device or iCloud Keychain.

## Consequences
- Tokens never touch prefs, the DB, backups or logs.
- A reinstall or restore from a device backup loses the tokens. The user re-enters them, which the manual explains.
