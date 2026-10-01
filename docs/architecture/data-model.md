# Data model

The local database uses drift on SQLite3MultipleCiphers (encrypted at rest; see
[ADR 0005](../adr/0005-encrypted-database-sqlite3mc.md)).

**Field names follow ADIF 3.1.x**, so import and export are lossless. Every ADIF field without a dedicated column is kept
in `adif_extra` (a JSON object of `FIELD_NAME → string value`).

## Conventions (from day one, for device-to-device sync)

| Convention | Rule |
|---|---|
| Primary keys | UUID v4 strings for every user-data row. Integers only for append-only local tables (journal). |
| Time | Stored as **UTC epoch milliseconds** (`int`). Never local time. ADIF `QSO_DATE`/`TIME_ON` are derived on export. |
| Change tracking | `hlc_modified` (hybrid logical clock string: `<millis>-<counter>-<deviceId>`), `origin_device_id`, `rev` (int, +1 per local change). |
| Deletion | Soft delete via `deleted_at`. Tombstones are pruned only after every paired device and the server have them. |
| Ownership | Every log row carries `account_id`, so accounts never mix. |

## Tables

### accounts
| Column | Notes |
|---|---|
| `id` (uuid) | |
| `label` | User-chosen, e.g. "Personal", "Club station DL0XYZ" |
| `base_url` | As entered; normalised without a trailing slash |
| `uses_index_php` | bool, set by the probe |
| `cert_pin_sha256` | nullable; TOFU pin of the leaf certificate |
| `allow_http_lan` | bool; only for private addresses |
| `server_caps` | JSON: `{apiV2: true, v32: bool, probedAt}` |
| `scopes` | JSON array as reported by `/token` |
| `token_expires_at` | nullable UTC millis |

**The token itself is never in the database.** It lives in the secure store under the key `account.<id>.token`.

### station_profiles
`id` (uuid), `account_id`, `remote_id` (Wavelog `station_profile_id`), `name`, `callsign`, `gridsquare`, `dxcc`,
`cqz`, `ituz`, `sota_ref`, `pota_ref`, `wwff_ref`, `iota`, `sig`, `sig_info`, `active`, `fetched_at`.
A cache of `GET /station`. It is refreshed on each sync and remains usable offline.

### qsos
| Group | Columns |
|---|---|
| Identity | `id` (uuid), `account_id`, `station_profile_id` (nullable while drafting) |
| Core ADIF | `call`, `time_on` (UTC ms), `time_off`, `band`, `band_rx`, `mode`, `submode`, `freq_hz`, `freq_rx_hz`, `rst_sent`, `rst_rcvd` |
| Contacted station | `name`, `qth`, `gridsquare`, `dxcc`, `cqz`, `ituz`, `state`, `cnty`, `country`, `cont`, `darc_dok`, `iota` |
| Programs | `sota_ref`, `pota_ref`, `wwff_ref`, `sig`, `sig_info`, `my_sota_ref`, `my_pota_ref`, `my_wwff_ref`, `my_sig`, `my_sig_info` |
| Own station | `station_callsign`, `operator`, `my_gridsquare`, `tx_pwr` |
| Contest | `contest_id`, `srx`, `stx`, `srx_string`, `stx_string`, `check`, `class`, `precedence`, `arrl_sect` |
| Other | `prop_mode`, `sat_name`, `sat_mode`, `comment`, `notes`, `qsl_via`, `adif_extra` (JSON) |
| Provenance | `contest_session_id`, `activation_id`, `source` (`manual`/`fle`/`import`/`peer`/`wsjtx`) |
| Sync metadata | `origin_device_id`, `hlc_created`, `hlc_modified`, `rev`, `deleted_at` |

Frequencies are stored as integer **Hz**. ADIF uses MHz and Wavelog's JSON API uses Hz, so the conversion happens only at
the edges.

### qso_sync
One row per QSO and account: `qso_id`, `account_id`, `state`, `operation` (`create`/`patch`/`delete`/`replace`),
`remote_qso_id`, `attempts`, `next_attempt_at`, `last_error_code`, `last_error_key` (localisation key),
`server_message` (raw, redacted), `synced_rev`, `synced_hash`.
States are described in [sync-state-machine.md](sync-state-machine.md).

### sync_journal
Append-only: `id` (int), `account_id`, `qso_id` (nullable), `at` (UTC ms), `event`, `detail` (JSON, redacted).
User-visible ("Sync history"). Pruned by age or count, never by state.

### Contests
| Table | Columns |
|---|---|
| `contest_definitions` | `id`, `name`, `cabrillo_name`, `wavelog_adif_name`, `version`, `definition` (JSON: exchange fields, dupe rule, multipliers, scoring), `builtin` |
| `contest_sessions` | `id` (uuid), `definition_id`, `account_id`, `station_profile_id`, `started_at`, `ended_at`, `settings` (JSON), `remote_session_id`, `serial_strategy` (`single`/`prefix`/`range`), `serial_range_start`, `serial_range_end` |
| `serial_allocations` | `session_id`, `serial` (unique within session), `qso_id` (nullable once deleted), `allocated_at` |

Serials are **monotonic and never reused**. A deleted QSO keeps its allocation row with `qso_id = null`.

### Activations
| Table | Columns |
|---|---|
| `activations` | `id` (uuid), `account_id`, `program` (`SOTA`/`POTA`/`WWFF`/`IOTA`/…), `reference`, `my_gridsquare`, `station_profile_id`, `started_at`, `ended_at` |
| `program_rules` | `program`, `version`, `rules` (JSON: validity threshold, per-band/mode rules) |

### Reference data
| Table | Columns |
|---|---|
| `reference_packs` | `id`, `kind` (`dxcc`/`sota`/`pota`/`wwff`/`iota`/`scp`), `version`, `source_url`, `sha256`, `fetched_at`, `region_filter`, `licence_note` |
| `dxcc_entities` | `dxcc`, `name`, `prefix`, `cqz`, `ituz`, `cont`, `lat`, `lon`, `deleted` |
| `dxcc_prefixes` | `prefix_or_call`, `exact` (bool), `dxcc`, `cqz_override`, `ituz_override` |
| `refs` | `program`, `ref`, `name`, `region`, `lat`, `lon`, `valid_from`, `valid_to` |
| `scp_calls` | `call` |

### worked_before
`account_id`, `call`, `band`, `mode`, `dxcc`, `gridsquare`, `first_time`, `source` (`server`/`local`).
Derived from the server pull (`GET /qso?format=adif&since_id=`) plus local QSOs. Rebuildable at any time.

### Devices (device-to-device sync, later milestone; tables exist from v1)
- `devices`: `id`, `name`, `public_key`, `paired_at`, `revoked_at`.
- `peer_cursors`: `device_id`, `last_hlc`.

### Settings
- `settings`: key/value. Holds UI preferences such as theme, locale, glove mode and text spacing.
- `shortcut_bindings`: `command_id`, `binding`, `platform`. Only user overrides; defaults live in code.

## Migrations

- Every schema change bumps the drift `schemaVersion`. The schema is dumped with `drift_dev schema dump` into
  `packages/tideline_data/drift_schemas/`.
- Migration tests are generated from those dumps, and every version-to-version step is tested with data.
