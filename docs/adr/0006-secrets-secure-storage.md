# 0006. Secrets: flutter_secure_storage

- Status: accepted (Windows backend pending verification)
- Date: 2026-10-01

## Context
- API tokens and the DB key must live in the platform secure store. Verified 2026-10, flutter_secure_storage 11.2.0:
  - **Android:** RSA-OAEP plus AES-GCM in the Android Keystore. The minimum is API 24. The deprecated
    EncryptedSharedPreferences option is removed.
  - **iOS/macOS:** Keychain. macOS needs the Keychain Sharing entitlement, which requires a provisioning profile, or the
    data-protection keychain must be disabled.
  - **Windows:** since v10 values are stored as encrypted files rather than in the Credential Manager. Whether those files
    are protected by DPAPI was **not verified**.
- Android auto-backup can restore prefs whose keys no longer exist, which causes `InvalidKeyException`.

## Decision
- Use flutter_secure_storage behind a `SecretStore` port in the domain.
- Exclude its storage from Android auto-backup (`android:fullBackupContent`/`dataExtractionRules`).
- **Before the first release**, read the plugin's Windows source. If it does not use DPAPI (`CryptProtectData`, user scope),
  implement the Windows `SecretStore` with DPAPI via FFI instead.

## Consequences
- Tokens never touch prefs, the DB, backups or logs.
- A reinstall or restore from a device backup loses the tokens. The user re-enters them, which the manual explains.
