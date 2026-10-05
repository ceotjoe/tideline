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
| T10 | Malicious reference list (SOTA, POTA, WWFF: wrong data, oversized, parser exploit) | T, D | A1, A3 | Downloads only when the user presses Download, from a URL shown and editable in settings (defaults are the official files). HTTPS only, also after redirects (≤ 3); no credentials, query or fragment in URLs; platform TLS validation, never disabled. Per-list size caps (POTA 20 MB, SOTA 60 MB, WWFF 60 MB) enforced on `Content-Length` and while streaming; the body goes to a temporary file that is deleted afterwards. Strict streaming CSV parser: a wrong header rejects the file, bad rows are skipped and counted, field length, column count and row count are capped (400,000 rows). The new list replaces the old one in a single transaction only after the whole file parsed, so a failed or cancelled download never damages the installed list. The request carries only a neutral `Tideline/<version>` User-Agent. Hash, source and fetch date are recorded. Lists are display data: they never change QSOs. MASTER.SCP: see T19. | Implemented (ADR 0021) |
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
| T23 | Activation data sent to Wavelog is not what the user expects (own park or grid silently replaced by the station location's values) | T | A2 | Own references and grid are kept on every QSO and in ADIF exports. Wavelog ignores them in an upload and uses its station location (verified 2026-10-03, `wavelog-api.md`), so the setup screen shows whether the chosen location carries the reference and warns when none does. Tideline never edits Wavelog station locations (ADR 0021, option A). | Implemented |
| T24 | Unencrypted copy of a reference list in SQLite's temporary storage while a list is installed | I | A5 | The list is public data (reference, name, region, position). It is collected in a SQLite temporary table, which lives in memory or in SQLite's temp file and is dropped when the install ends, also on failure. No QSO, callsign or other personal data is ever written there. | Accepted |
| T25 | Personal data of third parties (names and places of the stations you worked, your own notes about them) leaks from the device or a backup | I | A4, A5 | The directory and the notes live in the encrypted database (T3); notes travel only in encrypted backups; neither is part of any ADIF or Cabrillo export or sent to Wavelog (it has no notes API, `wavelog-api.md`). Text from untrusted ADIF (server pull, restored backup) is cleaned (control characters removed, length limited), the directory is capped at 500,000 stations per account for server pulls, and notes are limited to 2,000 characters. | Implemented (ADR 0026) |
| T26 | A QSO is removed from the device although Wavelog does not have it (data loss), or Wavelog data is deleted by mistake | T, D | A2 | Removal is a purge of the local copy, never a delete: nothing is sent to the server and no delete scope is used. Only QSOs that are synced, unchanged since and outside contests and activations are eligible, and Wavelog must confirm each by id and duplicate key through a read-only listing before removal; if the listing cannot be read completely (offline, revoked token, too large) nothing is removed. The conditions are re-checked inside the removal transaction. An ADIF export of exactly the removed QSOs is offered first and removal is cancelled if saving fails. The record that stays holds ids and a SHA-256 of the duplicate key, no callsign. | Implemented (ADR 0027) |
| T27 | Crafted or huge Fast Log Entry text (pasted from elsewhere): crash, slow parsing, injected fields, QSOs logged wrongly | D, T | A3 | The parser is total (never throws), reads at most 5,000 lines of 500 characters and values of 256, uses only linear patterns, and is fuzzed (token soup, random characters, mutations, hostile sizes). A line with a problem is left out whole and cannot change what later lines inherit. Control characters are removed from values; fields that are core, that have their own word, or that Tideline sets (`my_*`, station, operator) are refused. Nothing is stored until the user confirms, all QSOs in one all-or-none transaction. | Implemented (ADR 0028) |

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

## Changes in version 4
- **New inputs (activations):** the SOTA, POTA and WWFF reference lists (T10), downloaded only on request.
- **New flows:** the own references of an activation travel with the QSO to Wavelog, which replaces them with the
  values of the station location (T23). No new Wavelog scope is requested.
- **New residual data:** reference lists in the local database (encrypted at rest) and a short-lived temporary table
  during installation (T24).
- **Not changed:** the set of hosts the app talks to grows only by the three official list sources, each contacted only
  when the user presses Download. PRIVACY.md lists them.

## Changes in version 5 (field mode, step 6.8)
- **New dependency:** `wakelock_plus` (and `package_info_plus`), only to keep the display on while the log is open and the
  user has asked for it. No network access, no new data, no new permission (the plugin's Android manifest declares none, checked in
  the package source). Pinned by the lockfile (ADR 0029).

## Changes in version 5 (Fast Log Entry, step 6.7)
- **New input:** typed or pasted shorthand text (T27), read by a pure parser with limits and a preview before anything is
  stored. No new network access, scope or stored data beyond QSOs with source `fle`.

## Changes in version 5 (removing synced QSOs, step 6.6)
- **New flow:** one read-only `GET /qso` listing by date range (the existing `qso:read` scope; no new scope) to confirm
  that Wavelog has the QSOs before their local copies are removed (T26). No delete is ever sent.
- **New stored data:** `evicted_qsos` (ids and a hash of the duplicate key). No new host.

## Changes in version 5 (callsign directory and notes, step 6.5)
- **New inputs:** the same server ADIF pull as the worked-before index (T20), now also read for name, place, locator,
  country, state and zones (T25); notes typed by the user; the `callsignNotes` list of a restored backup.
- **New stored data:** the directory (derived, per account) and the notes (local only). No new host, scope or request.

## Changes in version 5 (multiple accounts, step 6.3)
- **No new inputs and no new hosts.** Several Wavelog servers can be connected, each through the same onboarding checks
  (T1, T5, T8, T9). Each token has its own secure-store key (`account.<id>.token`).
- **Account removal is a purge of this device** and now deletes everything of the account: QSOs and their sync state,
  contest sessions with links and serials, activations, the worked-before index, cached stations, the account's
  settings and the token. Nothing is deleted on a server. It used to fail on the foreign keys when contest data existed,
  which left the account (and its token) in place.
- **New residual risk:** with several accounts a QSO can be logged to the wrong one. Mitigations: the active account is
  named on the log screen and in the settings, switching is refused while a contest session or an activation runs, and a
  newly added account is never made active automatically.
