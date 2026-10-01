# Wavelog API notes

_Verified 2026-10-01 against the [API v2 docs](https://docs.wavelog.org/developer/api-v2/) and the Wavelog
source (`wavelog/wavelog@master`, latest release **3.2.3**, 2026-09-23)._

Each statement is marked:
- **✔ verified**, with its source;
- **? unknown**: not established, so do not rely on it.

Source paths are relative to the Wavelog repository. Re-verify this page when supporting a new Wavelog release.

## Versions

| Fact | Status |
|---|---|
| API v2 first shipped in **3.1.0** (released 2026-08-09) | ✔ docs + release notes |
| Logbook, Contest, Catalog resources and station `set_active` need **3.2.0+** | ✔ docs |
| Token table `api_token` (`token_hash` SHA-256, `scopes` comma list, `expires_at`, `status`) | ✔ `application/migrations/288_api_v2_tokens.php` |

**Tideline minimum:** 3.1.0. Contest-session features require 3.2.0 and are switched on by capability probing.

## URLs and authentication

- **Base URL** (✔ docs; `application/config/routes.php` routes `api/v2(/.+)` → `api_v2/route`):
  `https://<host>[/<path>]/index.php/api/v2/<resource>[/<id>]`.
  - The `index.php/` segment can be dropped only if the web server rewrites URLs.
  - Tideline probes `…/index.php/api/v2/status` first, then `…/api/v2/status`, and stores which variant works.
- **Path depth:** more than two segments after `v2` returns 404; a trailing slash is fine. ✔ `Api_v2.php::route`
- **Auth header:** `Authorization: Bearer wl2_…`, with `X-API-Key: wl2_…` as fallback. Tokens without the `wl2_` prefix
  (legacy v1 keys) get 401 `invalid_token`. Sessionless. ✔ `Api_v2.php::extract_key/authenticate`
- **Tokens** (✔ docs):
  - Created in the Wavelog UI: user menu → API → new v2 token.
  - The user sets a name, scopes, and an expiry of 30, 90 or 365 days, or never.
  - The token is shown once and can be revoked.

## Scopes

A scope is `<resource>:<verb>` (✔ `Api_v2_resource.php::required_scope`):
- GET needs `:read`.
- POST and PATCH need `:write`.
- DELETE needs `:delete`.

Available scopes (✔ `*_resource.php::scope_labels`):

| Resource | Scopes |
|---|---|
| qso | `qso:read`, `qso:write`, `qso:delete` |
| station | `station:read`, `station:write`, `station:delete` |
| logbook (3.2) | `logbook:read`, `logbook:write`, `logbook:delete` |
| radio | `radio:read`, `radio:write`, `radio:delete` |
| contest (3.2) | `contest:read`, `contest:write`, `contest:delete` |
| club | `club:read`, `club:write`, `club:delete` (only when club stations are enabled) |
| others | `statistic:read`, `confirmation:read`, `lookup:read` |
| token, catalog | no scope required |

### What Tideline asks for

| Scope | Required? | Why (shown in onboarding) |
|---|---|---|
| `qso:write` | required | Upload QSOs and correct fields of uploaded QSOs. |
| `qso:read` | required | Check whether a QSO is already on the server before re-sending it, so nothing is duplicated. Also builds the offline "worked before" index. |
| `station:read` | required | List your station locations, so each QSO goes to the right one. |
| `contest:read`, `contest:write` | optional | Create contest sessions in Wavelog and link contest QSOs to them (Wavelog 3.2+). |
| `qso:delete` | optional | Delete QSOs on the server that you deleted in Tideline, and "replace on server" for corrections the API can't patch. |
| `lookup:read` | optional | Online callsign lookups when connected. |

## Response format

- **Success:** `{ "data": …, "meta": { "timestamp", "resource", "method", … } }`. 201 responses include a `Location` header;
  DELETE returns 204. ✔ docs
- **Errors:** `{ "error": { "code", "message", "details" } }`. ✔ docs

| HTTP | `code` | Tideline handling |
|---|---|---|
| 400 | `validation_error`, `invalid_json` | QSO → `rejected` (unless `details.duplicate`; see below) |
| 401 | `unauthorized`, `invalid_token`, `token_expired` | Account → blocked; ask the user for a new token |
| 403 | `insufficient_scope`, `forbidden`, `insufficient_club_permission`, `club_access_revoked` | Scope problem → account notice; `forbidden` on a station → QSO `rejected` |
| 404 | `not_found` (also for items you may not see) | Resource missing / feature not available |
| 405 | `method_not_allowed` (with an `Allow` header) | Bug, so log it |
| 409 | `conflict` | QSO → `conflict` |
| 429 | `rate_limited` (`details.retry_after` + `Retry-After` header) | Back off exactly as told |
| 500 | `internal_error` | Treat as an uncertain outcome → `verifying` |

- **Request bodies:** JSON, scalar values only. The bulk `qsos` array is the exception. ✔ `Qso_resource::create`
- **PUT:** returns 405; only PATCH is supported. ✔ `Api_v2_resource::replace`
- **Pagination:** `page` and `per_page` (max 5000). `meta` returns `page, per_page, count, total, total_pages, has_more`.
  Only QSO and Confirmation lists are paginated. ✔ docs

## Health, version and capabilities

| Endpoint | Result | Status |
|---|---|---|
| `GET /api/v2/status` (public) | `{name: "Wavelog API", status: "ok"}`. **No version.** | ✔ `Api_v2.php::route` |
| `GET /api/v2/token` | whoami: `{id, name, owner, user_id, scopes[], expires_at}` | ✔ docs |
| `GET /api/v2/statistic?profile=system` | Includes the Wavelog version, but is **admin-only**. A non-admin gets 400. | ✔ docs |
| capabilities endpoint | none | ✔ (absent) |

**Tideline probe:**
1. `status` returns 200: v2 is present (3.1+).
2. `token`: read scopes and expiry.
3. `catalog?topic=contest` returns 200: 3.2+. A 404 means contest-session features are hidden.

## QSOs

### Create
- **Single:** `POST /qso` with a JSON object. ✔ `Qso_resource::create_from_json`
  - Required fields: `station_profile_id`, `call`, `band`, `mode`, `qso_date` (YYYY-MM-DD), `time_on`
    (HHMM, HHMMSS or HH:MM[:SS]).
  - Other ADIF fields are passed as lowercase keys; `freq` is in **Hz**.
  - Returns 201, a `Location` header, and the full QSO including the server `id`.
- **Bulk JSON:** `{station_profile_id, qsos: [...], dryrun?}`. ✔ `::create_bulk_json`
  - All rows go to one station.
  - Returns 201 `{parsed, imported, skipped, messages}`. **No per-row IDs.**
  - `dryrun: true` returns 200 `{dryrun: true, parsed}`.
  - A missing required field in any row rejects the whole request with 400 and `details.index`.
- **Bulk ADIF:** `{import_type: "adif", station_profile_id, adif: "…", dryrun?}`, with frequencies in MHz.
  Returns the same summary. ✔ `::create_from_adif`
- **Station is mandatory:** a missing or foreign `station_profile_id` gives 403 `forbidden`. There is no fallback to the active
  station. ✔ `::create`
- **No side effects:** creating a QSO triggers no live QRZ upload and no callbook lookup. ✔ docs
- **Fields kept on import** (✔ `Logbook_model::import`): the standard columns plus `contest_id`, `srx`, `stx`,
  `srx_string`, `stx_string`, `check`, `class`, `precedence`, `arrl_sect`, `darc_dok`, `sota_ref`, `pota_ref`, `wwff_ref`.
- **Fields dropped:** unknown keys, including `APP_*` fields. ✔ explicit field mapping
- **Batch size:** no limit in the API code. ✔ PHP and web-server body limits may apply. ? unknown

### Server duplicate rule
A duplicate is the same `call` + `time_on` **to the minute** + `band` + `mode` + `station_id`.
✔ `Logbook_model::import` (`skipDuplicate` block)

- A single POST that is a duplicate returns **400 `validation_error`** with `details.duplicate[…]`. It is **not** a 409.
- In a bulk upload, duplicates are counted in `skipped`, and a bulk request that only contains duplicates still returns 201.

### Idempotency
**There is no client-side QSO identifier.** QSOs have no UUID column, and unknown fields are dropped. ✔

Tideline therefore relies on:
- single POSTs (to get the server id back);
- a reconcile query on the duplicate tuple before any retry.

See [ADR 0008](../adr/0008-sync-idempotency-without-server-uuid.md).

### Read
`GET /qso` (✔ `Qso_resource::index`):
- **Filters:** `callsign`, `qso_since`, `qso_until` (date, inclusive), `station_id`, `since_id`, `page`, `per_page` (≤ 5000).
- **JSON** is ordered newest first.
- **`format=adif`** is ordered by ascending `id` and returns `{exported, lastfetchedid, adif}`; pass `lastfetchedid` back as `since_id`.
- **No `updated_since`:** edits and deletes made in the Wavelog UI are not visible incrementally. Detect drift with
  `meta.total` and a periodic full rebuild.
- **JSON rows do not include** `station_callsign`, `dxcc` or QSL status. Use ADIF format for the full field set.

### Update
`PATCH /qso/{id}` (✔ `Qso_resource::editable_fields/read_only_fields`):
- **Editable:** `call, band, band_rx, rst_sent, rst_rcvd, gridsquare, name, comment, notes, qth, prop_mode, sat_name,
  sat_mode, sota_ref, pota_ref, wwff_ref, iota, sig, sig_info, darc_dok, state, cnty, cqz, ituz, qsl_via, srx, stx,
  srx_string, stx_string`.
- **Read-only:** `id, station_id, qso_date, mode, submode, freq, freq_rx`.
  Corrections to time, mode, frequency or station must be made in Wavelog, or by delete + re-create (needs `qso:delete`).

### Delete
`DELETE /qso/{id}` returns 204 and needs `qso:delete`. ✔ docs

## Station locations
- `GET /station` returns `{id, uuid, name, callsign, gridsquare, city, dxcc, country, cq, itu, state, cnty, iota, sota,
  wwff, pota, sig, sig_info, power, active}`. `id` is the `station_profile_id`.
  ✔ `Station_resource::format_station`
- If the user enabled "only show locations linked to the active logbook", the list is filtered. ✔
- Not paginated. ✔

## Contests (3.2.0+)
- **Contest list:**
  - Contests form one global list per instance and are **activated by an admin**; users cannot activate them.
    ✔ `Contest_admin.php` (`authorize(99)`)
  - QSOs store the contest's **ADIF name** in `COL_CONTEST_ID`.
  - `GET /catalog?topic=contest` returns active contests as `{id, contest: <adifname>, name}`. Numeric ids are
    instance-local, so always use the ADIF name. ✔ `Catalog_resource.php::contest_topic`
- **Sessions:** `/contest` has full CRUD (✔ `libraries/api_v2/Contest_resource.php`):
  - `GET /contest` accepts `?station_id=` and `?since_id=`.
  - `GET /contest/{id}` includes `qso_ids`.
  - `POST /contest` takes `contest` (ADIF name) or `contest_id`, plus `time_start`, `time_end` (`YYYY-MM-DD HH:MM[:SS]`), and
    `station_id`. Optional: `comment`, `settings`, `qso_ids`. The contest must be active.
  - `PATCH /contest/{id}` accepts `link_qso_ids` and `unlink_qso_ids` (and keeps `COL_CONTEST_ID` in step).
  - `DELETE /contest/{id}` keeps the QSOs unless `?delete_qsos=true` is passed (which also needs `qso:delete`).
- **Session settings JSON** (✔ `Contesting_model::session_settings_defaults`):
  - `exchangefields`: a subset of `serial`, `gridsquare`, `exchange`.
  - `copyexchangeto`: `dok`, `locator`, `qth`, `name`, `age`, `state` or `power`.
  - `serial_per_band`, `serial_scope` (`station` or `operator`), `callbook_lookup`, `custom_name`.
- **Exchange columns:** `stx`/`srx` hold serials (integers); `stx_string`/`srx_string` hold the exchange; `gridsquare` holds a
  received grid. ✔
- **Linking:** QSOs posted via the API are **not** linked to a session automatically. Tideline links them with
  `PATCH /contest/{id}` and `link_qso_ids`. ✔
- **Serials:** Wavelog keeps serial counters in a server cache, not in the session. **Tideline owns serial numbering
  locally.** ✔ `Contesting::serial_*`
- **Cabrillo:** Wavelog's export is web UI only, with no API, so Tideline generates Cabrillo itself. ✔
- **Older servers:** on 3.1.x, or for contests the admin has not activated, Tideline still uploads `contest_id` and the
  exchange fields, and keeps the session only locally. This is explained in the manual.

## Lookups and reference data
- `GET /lookup?callsign=…` (`lookup:read`, `detail=basic|full`) returns DXCC data and worked/confirmed status. ✔
- `GET /lookup?grid=…` checks one grid; `?grid=all` lists every worked grid. ✔
- `GET /catalog?topic=dxcc|subdivisions` returns the entity list. **There is no prefix/exception table**, so Tideline needs its own
  offline DXCC data. ✔
- No API offers SOTA, POTA or WWFF reference lists. ✔
- Wavelog itself downloads DXCC data from Club Log (key required), and SCP, SOTA, WWFF and POTA lists from their official
  URLs. ✔ `Update_model`

## Rate limits
- Off by default; an admin can enable them. ✔ docs
- Limits use a sliding window per token per resource (the docs' example: `api_v2_qso` 120/60 s, default 60/60 s).
  Failed authentication is limited per IP.
- When limited, the server returns 429 with `Retry-After`. Tideline honours it exactly.

## Legacy API (`application/controllers/Api.php`)
- **Methods:** `auth`, `check_auth`, `create_station`, `station_info`, `qso`, `get_contacts_adif`, `logbook_check_callsign`,
  `logbook_check_grid`, `logbook_get_worked_grids`, `radio`, `statistics`, `private_lookup`, `lookup`, `qralatlng`,
  `version`, `get_wp_stats`, `list_clubmembers`. ✔
- **Auth:** the key goes in the JSON body or URL. ✔
- **Only in legacy:** a version endpoint for non-admins, and radio `cat_url`. Tideline needs neither, so **Tideline uses API v2
  only** ([ADR 0007](../adr/0007-wavelog-api-v2-only.md)).

## Open / unknown
- **Body-size limits for bulk uploads:** ? unknown. These depend on the server's PHP and web-server configuration.
- **Storing a client id in `notes`/`comment`:** ? untested. It would also pollute user-visible fields, so it is **not used**.
- **Behaviour across Wavelog upgrades:** re-verify this page for every Wavelog minor release, and record fixtures in `packages/wavelog_mock`.
