# 0008. Sync idempotency without a server-side client id

- Status: accepted
- Date: 2026-10-01

## Context
- The brief asked for a stable client UUID per QSO for duplicate-free retries. What we verified about Wavelog:
  - It cannot store a client id: there is no UUID column, and `APP_*` fields are dropped.
  - Its duplicate rule is call + `time_on` to the minute + band + mode + station.
  - A single POST of a duplicate returns 400 with `details.duplicate`.
  - Bulk create returns counts only, with no per-row ids.
  - A server id is needed later, for PATCH, DELETE and linking contest sessions.

## Decision
- Every QSO has a local UUID, plus a `remote_qso_id` once synced.
- **Uploads are single POSTs**, one QSO per request, so each response maps to exactly one QSO.
- **Any uncertain outcome** goes to `verifying`: a timeout, a 5xx, an app kill mid-request, or a 400 duplicate.
  A reconcile query (`GET /qso` filtered by callsign, date and station, matched on the duplicate tuple) runs before any
  retry.
- Local same-minute twins with identical tuples are surfaced as conflicts.
- The dry-run preview uses the server's bulk `dryrun` parse, but never bulk-imports.

## Consequences
- **Pros:** no duplicates and no lost QSOs, even across crashes.
- **Cons:**
  - Large backlogs take one request per QSO. At the documented example limit (120/min), that is 500 QSOs in about 4–5
    minutes, which is acceptable.
  - Requires the `qso:read` scope.
