# 0035. Refresh a QSO that was changed in Wavelog

- Status: accepted
- Date: 2026-10-16
- Amends: [0027](0027-evict-synced-qsos.md)

## Context
- Issue #1: a QSO was synced, then its time was changed in Wavelog. *Remove from this device* refused it, while a full
  delete worked.
- Cause: ADR 0027 only removes a QSO when Wavelog confirms it with the same duplicate key (call, minute, band, mode,
  station). After the change the key differs, so the QSO is "not confirmed" and stays. Local and server copy have
  diverged, and removing the local one would silently lose the only record of what was logged here.
- ADR 0027 states that Wavelog cannot be read back into the log. That is only partly true: `GET /qso?format=adif` returns
  the full field set (docs/architecture/wavelog-api.md). Verified in the Wavelog source
  (`Qso_resource`, `Logbook_model`): `since_id` means `COL_PRIMARY_KEY > since_id`, ascending by id.

## Decision
- **A synced QSO can be refreshed from Wavelog by hand** ("Update from Wavelog" in the QSO details, and as the action of
  the snackbar when removing finds a changed QSO). The user confirms first.
- **One read-only request:** `GET /qso?format=adif&since_id=<remoteId - 1>&per_page=1`. The QSO is only taken over when
  `lastfetchedid` equals the Wavelog id; otherwise it is gone on the server and nothing changes. No dupe-key search is
  needed because we go by id.
- **The server version replaces the local one** (all ADIF fields, parsed strictly by `tideline_adif`; unknown fields go
  to `adif_extra`). The row keeps its UUID, origin and creation HLC; the modification HLC and `rev` advance, so the
  change is an ordinary edit for later device-to-device sync. The sync row stays `synced` with the same Wavelog id. Nothing
  is uploaded.
- **Guarded in the transaction:** applied only if the QSO is still `synced`, has a Wavelog id, is not deleted, is in no
  contest session or activation, and its `rev` is the one read before the request. A local edit in between wins.
- **Excluded for now:** contest and activation QSOs (serials, exchange and Cabrillo depend on them).
- A journal entry `refreshedFromServer` records it.
- ADR 0027 is unchanged otherwise: bulk "free up space" still leaves changed QSOs in place and counts them.

## Consequences
- After a refresh the dupe keys match again and *Remove from this device* works.
- The user decides; there is no automatic detection of server-side changes during sync (Wavelog has no `updated_since`).
  Detecting drift automatically is possible later.
- The refresh is one request per QSO and needs a connection and `qso:read`.
- Fields that only Wavelog knows (DXCC, zones, QSL status) now appear in the local copy; they are read-only server
  fields for later syncs, as before.
- No new network destination and no new data leaves the device; the threat model is unchanged.
