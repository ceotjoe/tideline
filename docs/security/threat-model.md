# Threat model (STRIDE)

_Version 3, 2026-10-02 (contest mode). Covers the foundation, the MVP and contest mode. Update this page whenever the attack surface changes,
for example new network flows, new input formats, peer sync or the WSJT-X listener._

## Assets
1. **Wavelog API tokens.** Can write to, and optionally delete from, the user's log.
2. **The QSO log.** The user's data. It includes locations of portable operation, and it is irreplaceable when not yet synced.
3. **Integrity of the log.** No lost, silently altered or duplicated QSOs.
4. **The DB encryption key and the backup passphrase.**
5. **Pinned certificate fingerprints.** They decide whom we send tokens to.

## Actors
- **A1, network attacker:** on public Wi-Fi or a hostile LAN.
- **A2, malicious or compromised server:** an attacker-controlled "Wavelog", or a compromised instance.
- **A3, malicious file:** an ADIF/Cabrillo/backup/reference pack received from someone.
- **A4, someone with physical access** to an unlocked or locked device.
- **A5, other apps** on the same device.
- **A6 (later), malicious peer device** on the LAN.

## STRIDE analysis

| # | Threat | STRIDE | Actor | Mitigation | Status |
|---|---|---|---|---|---|
| T1 | Token sent to an impostor server via a MITM | S, I | A1 | TLS with platform roots. Self-signed certificates only via an explicit TOFU pin after showing the SHA-256 fingerprint; the inspection connection sends no data. No "disable validation" option. HTTP only on private LANs after opt-in. | Implemented (ADR 0009) |
| T2 | Token leaked via logs, crash output, backups or prefs | I | A4, A5 | Token only in the secure store. Redaction in the logging layer. Backups exclude secrets. Android auto-backup excludes secure-storage files. | Designed (ADR 0006) |
| T3 | QSO log read from a stolen device or backup | I | A4 | DB encrypted (ADR 0005). The key is in the secure store. Optional UI app lock (biometric/PIN). Backups: Argon2id + XChaCha20-Poly1305, tokens never included; restore caps KDF parameters (crafted files cannot exhaust memory). ADIF exports are plain text by design and say so. | Implemented |
| T4 | Crafted ADIF causing a crash, memory blow-up or injection | D, T | A3 | Strict parser with 64 MiB file, 64 KiB field and 500,000 record limits; fuzz tests; parsing in a separate isolate; imports above 50 QSOs wait for a dry-run review before upload. | Implemented |
| T5 | Crafted API responses (huge, malformed, unexpected types) | D, T | A2 | Typed decoding with validation, 16 MiB response limit, 20 s timeouts; malformed responses become errors, never crashes. | Implemented |
| T6 | Duplicate or lost QSOs from retries after timeouts or crashes | T | — | Reconcile before retry (ADR 0008). Crash-safe states. Every transition is journaled. | Designed |
| T7 | Server silently changes or drops uploaded QSOs | T, R | A2 | The local copy is kept and never overwritten automatically from the server. The sync journal records the server id and response for each QSO. | Designed |
| T8 | Token with excessive privileges | E | A2 (compromised app) | Least-privilege scopes. Required scopes are explained, optional ones are opt-in. The app warns when a token has scopes it doesn't need. | Designed |
| T9 | Pinned certificate silently replaced | S | A1 | A pin mismatch blocks the connection and requires re-confirmation that shows both fingerprints. | Designed |
| T10 | Malicious reference pack (wrong data, oversized, parser exploit) | T, D | A1, A3 | Downloads only from built-in official URLs over TLS. Size limits. Strict parsers. Pack hash and source recorded. Packs never contain executable content. MASTER.SCP: see T19. | Planned (v0.3) |
| T11 | DoS on the server through aggressive sync | D | — | Single worker. Exponential backoff with jitter. `Retry-After` honoured. | Designed |
| T12 | Clock skew corrupting QSO times | T | — | Times are taken from the device's UTC clock. A warning is shown when the server's `Date` header differs by more than 2 minutes. The time is always editable before sync. | Planned (MVP) |
| T13 | Other apps reading exported files | I | A5 | Exports go only where the user saves them, through the system file pickers. A warning that ADIF exports are unencrypted. | Planned (MVP) |
| T14 | Repudiation: "I never logged/deleted that" | R | — | Append-only sync journal for each QSO. Soft deletes with tombstones. | Designed |
| T15 | Supply-chain compromise of a dependency | T, E | — | Minimal dependencies, lockfile, Dependabot, actions pinned to SHAs, SBOM per release, review of native-asset hooks. | In place (CI) / planned (SBOM) |
| T16 | (Later) Rogue peer injecting or exfiltrating QSOs | S, T, I | A6 | QR pairing with public-key exchange. Mutual authentication. AEAD channel. Peer data validated like an import. Revocable pairings. A threat-model update is required before implementation. | Later |
| T17 | (Later) Spoofed WSJT-X UDP packets | S, T | A1 | Bind to loopback by default. Packets are validated. QSOs land in the queue for review. | Later |
| T18 | Crafted user contest definition (huge, deeply nested, unknown keys, rules that never terminate) | D, T | A3 | Strict parser: 256 KiB limit (checked before the file is fully read), every list ≤ 64 elements, unknown keys rejected, typed errors. The rule language is declarative (no expressions, loops or code), so evaluation is linear in the number of rules. User definitions cannot replace bundled ones. Fuzz tests. | Implemented (ADR 0018) |
| T19 | Malicious MASTER.SCP download (MITM, redirect to plain HTTP, oversized or binary body) | T, D | A1, A3 | Downloads only when the user presses Download, from a URL shown and editable in settings. HTTPS only, also after redirects (≤ 3); no credentials in URLs; platform TLS validation, never disabled. 8 MiB cap enforced on `Content-Length` and while streaming; connect, idle and total timeouts. Strict line parser (`[A-Z0-9/]{3,15}`, ≤ 200,000 calls). The request carries no query and only a neutral `Tideline/<version>` User-Agent. Pack hash and source are recorded. | Implemented |
| T20 | Server data injected into the worked-before index (crafted ADIF in `GET /qso?format=adif`) | T, D | A2 | Parsed with the same strict, fuzz-tested ADIF parser and the 16 MiB response limit. At most 10 pages per run. The index is derived data: it only drives hints, never changes QSOs, and can be rebuilt from settings. | Implemented |
| T21 | Duplicate or orphaned contest sessions on Wavelog after lost answers | T | — | The session is marked `verifying` before `POST /contest`; a retry first looks for a server session with the same contest, station and start minute. Linking is idempotent. A session deleted on the server is never recreated automatically. Every step is journaled. | Implemented |
| T22 | Cabrillo export used for header injection (CR/LF in soapbox, name or address) | T | A3 | The writer replaces control characters and line separators with spaces and writes pure ASCII; tested with injection attempts. | Implemented |

## Residual risks
- **Compromised OS (jailbreak/root):** an attacker who controls the OS can read the secure store. This is out of scope,
  per MASVS L1.
- **Lost DB key:** if the key is lost (for example a keychain reset), unsynced QSOs are unrecoverable without a backup.
  Mitigated by backup prompts and by showing the unsynced count prominently.
- **Self-hosted servers on plain HTTP:** the user explicitly accepts this risk, limited to private LANs.

## Changes in version 2
- **New flows (MVP):** onboarding with certificate inspection (F2), ADIF import and export (F4), encrypted backup and
  restore (F4), and the optional app lock.
- **New residual risk:** while the app lock is shown, the database stays open so sync can continue. The lock protects
  the screen, not the data at rest; the data at rest is protected by the encrypted DB and the OS. Gating the key is
  planned for v1.0.

## Changes in version 3
- **New inputs (contest mode):** user contest definitions (T18), the MASTER.SCP download and file import (T19), and the
  server ADIF pull into the worked-before index (T20).
- **New flows:** Wavelog contest-session sync (`/contest`, needs `contest:write`; T21) and Cabrillo export (T22).
- **New residual risk:** the default MASTER.SCP URL points at a third-party site. Its operator sees the user's IP
  address when the user downloads the list. PRIVACY.md says so.
