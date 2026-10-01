# 0005. Encrypted database: drift + SQLite3MultipleCiphers

- Status: accepted
- Date: 2026-10-01

## Context
- The brief suggested drift with SQLCipher. What we verified in 2026-10:
  - `sqlcipher_flutter_libs` is end-of-life ("no longer does anything") with sqlite3 3.x.
  - drift 2.32+ uses sqlite3 3.x, which picks its native library through build hooks (`hooks: user_defines: sqlite3:
    source:`). The options are `sqlite3`, `sqlite3mc`, `sqlcipher` and `system`.
  - The drift encryption docs now recommend `source: sqlite3mc` (SQLite3MultipleCiphers) with `PRAGMA key`, on all
    native platforms including Windows and macOS.
  - The `sqlcipher` source links OpenSSL on Windows, Linux and Android, and may lag behind upstream SQLite.

## Decision
- drift on `sqlite3` with `source: sqlite3mc`.
- The 256-bit random key is generated on first launch and stored in the secure store (ADR 0006).
- After opening, the app checks that `PRAGMA cipher` returns a row and refuses to run unencrypted.

## Consequences
- No OpenSSL dependency, and the same engine on all platforms.
- Tideline selects the cipher explicitly (`PRAGMA cipher = 'chacha20'`, i.e. ChaCha20-Poly1305) instead of relying on
  the library default. SQLite3MultipleCiphers is MIT-licensed (verified on GitHub), which is compatible.
- If the key is lost (for example the OS keychain is wiped), the local DB cannot be decrypted. Encrypted backups
  with a user passphrase mitigate this.
