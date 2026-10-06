# 0034. Remove app-level encryption

- Status: accepted
- Date: 2026-10-06
- Supersedes: [0005](0005-encrypted-database-sqlite3mc.md); amends [0006](0006-secrets-secure-storage.md) and
  [0022](0022-testflight-first-distribution.md)

## Context
- Tideline shipped two pieces of its own encryption: the database (SQLite3MultipleCiphers, ChaCha20, ADR 0005) and the
  passphrase backups (Argon2id + XChaCha20-Poly1305, `cryptography` package).
- Because of them the app counts as using non-exempt encryption (ADR 0022 update 2026-10-05). That means export-compliance
  answers in App Store Connect (mass-market self-classification, France) and a matching story for the other stores.
- For a logbook app run by one maintainer that overhead is out of proportion. What is left without our own encryption is
  exempt: HTTPS and certificate pinning use the OS TLS stack, tokens use the OS secure store, biometrics use `local_auth`,
  and SHA-256 is only hashing.
- The app is still in TestFlight (0.5.0); no store release has happened.

## Decision
- **Database:** plain SQLite (`sqlite3` build hook, `source: sqlite3`). No key, no cipher, no `cryptography` package.
- **Backups:** one plain, unencrypted backup file. The UI says clearly that it is unencrypted, like an ADIF export.
  Encrypted backups of earlier versions can not be restored any more.
- **Secure store:** keeps the API tokens and the device id. The stored database key is deleted at startup, except when an
  old database was just set aside: then the key stays so that someone technical can still open that file.
- **Clean break for existing installs (no bridge build).** A database that a plain SQLite can not read (it was encrypted by
  0.5.x) is renamed aside, never deleted, and the app starts empty and tells the user. Unsynced QSOs of such an install are
  not migrated; testers sync before updating.
- **At-rest protection** comes from the OS (iOS/Android data protection with the device lock, optional app lock in the UI).
  The database and backups are excluded from iCloud/iTunes backup and from Android auto-backup and device transfer.
- `ITSAppUsesNonExemptEncryption` is `false` in the iOS and macOS `Info.plist`.
- CI guard (planned, done in the last phase of this change): fail if `cryptography`, SQLite3MultipleCiphers or SQLCipher appear in the lockfile or hooks, or if the plist key
  is `true`.
- Future features must not reintroduce our own encryption (for example LAN pairing should rely on OS TLS or wait).

## Consequences
- No export-compliance questions; simpler store forms.
- A lost or reset keychain no longer orphans the database, so the key-missing restore flow goes away.
- A stolen unlocked device, a rooted device or a file-level copy exposes the log. That is a weaker position than before and
  is recorded in the threat model (T3, T25). The log holds callsigns and QSO data that are public by nature in amateur radio,
  but notes and own locations are personal.
- 0.5.x data is not carried over (see above).
- This is the maintainer's classification, not a legal opinion.
