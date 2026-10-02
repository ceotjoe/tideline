# 0018. Contest mode: definitions as data, local serials, Wavelog sessions

- Status: accepted
- Date: 2026-10-02

## Context
- Contest rules differ in exchange, dupe rule, points and multipliers, and they change from year to year. Hard-coding
  them would mean an app release for every rule change, and it would rule out user-supplied contests.
- Wavelog 3.2 has contest sessions (`/contest` CRUD), but it keeps serial counters in a server cache, not in the
  session. Contest QSOs are not linked to a session automatically. It has no Cabrillo API. ✔ See
  [wavelog-api.md](../architecture/wavelog-api.md#contests-320).
- Contest operation must be fully offline, fast, and never lose or repeat a serial number.

## Decision
- **Definitions are JSON data** following the schema in
  [contest-definitions.md](../architecture/contest-definitions.md). They are parsed strictly in `tideline_domain`
  (unknown keys rejected, size limits enforced). The bundled set ships as app assets; user files can be imported.
- **Rules are a small declarative language:** ordered point rules (first match wins), predicates over my and their
  station, and multiplier sources with a scope. Nothing is executable, so definitions cannot run code.
- **Contest QSOs are ordinary QSOs.** Exchanges are stored in their ADIF fields (`STX`/`SRX`, `SRX_STRING`, `CQZ`,
  `STATE`, `DARC_DOK`, …), and `CONTEST_ID` is set from the definition's `adif` name. They sync through the normal QSO
  pipeline (ADR 0008).
- **Serials are local.** Each one is allocated in the same database transaction that inserts the QSO, from
  `serial_allocations` (`max + 1`, never reused, kept with `qso_id = null` after a delete). The form shows the next
  serial as a preview, but the number is only taken on save. In Phase 3 the only strategy is `single`; `prefix` and
  `range` (multi-operator) stay in the schema for later.
- **Wavelog sessions are an optional extra (3.2+):** after a session's QSOs have been uploaded, the sync engine creates
  the session (`POST /contest`) and links the QSOs (`PATCH /contest/{id}` with `link_qso_ids`). Creation is made
  idempotent by a reconcile step (`GET /contest?station_id=` and match on contest + start time) before any retry, as
  for QSOs. Older servers or inactive contests keep the session local only; the QSOs still carry `CONTEST_ID`.
- **Cabrillo 3.0** is generated locally by `tideline_adif`, from the definition's exchange order.
- **The score is an estimate,** labelled as such.
- **MASTER.SCP** is never bundled (its licence is unclear). The user downloads it on request from a URL they can see
  and edit, which is recorded in `PRIVACY.md`. It is stored in `scp_calls`.

## Consequences
- New contests and rule changes need no app release. User definitions are untrusted input, and the strict parser
  and threat model cover them.
- The rule language cannot express every contest. Contests that need more fall back to the generic definitions
  (serial or free exchange, no scoring) until the language grows. A schema version guards each extension.
- Serial allocation is atomic with the QSO insert, so a crash cannot produce a QSO without a serial or a repeated
  serial.
- Session sync adds a second idempotent step to the sync engine, with its own journal events.
