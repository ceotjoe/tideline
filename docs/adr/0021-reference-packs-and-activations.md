# 0021. Reference packs and activation sessions

- Status: accepted
- Date: 2026-10-03

## Context
Verified on 2026-10-03 with `curl` (headers and the first lines only):

| Pack | Source | Format | Size |
|---|---|---|---|
| POTA | `https://pota.app/all_parks_ext.csv` | CSV, quoted. Columns `reference,name,active,entityId,locationDesc,latitude,longitude,grid` | 9.4 MB |
| SOTA | `https://www.sotadata.org.uk/summitslist.csv` redirects (302) to `https://storage.sota.org.uk/summitslist.csv` | A title line `SOTA Summits List (Date=dd/mm/yyyy)`, then CSV: `SummitCode,AssociationName,RegionName,SummitName,AltM,AltFt,GridRef1,GridRef2,Longitude,Latitude,Points,BonusPoints,ValidFrom,ValidTo,ActivationCount,ActivationDate,ActivationCall`. Dates `dd/mm/yyyy` | 25 MB |
| WWFF | `https://wwff.co/wwff-data/wwff_directory.csv` | CSV with 26 columns: `reference,status,name,program,dxcc,…,latitude,longitude,…,validFrom,validTo,…` Dates `yyyy-mm-dd`, `0000-00-00` means unset | 24.5 MB |

- `https://api.pota.app/program/parks` answers 403 without a browser, so it is not a source.
- The files are 3 to 25 MB, so the 8 MiB cap of MASTER.SCP (T19) does not fit. Parsing the whole body in memory is also
  too heavy on phones.
- Validity rules, from the programs' public descriptions: POTA needs 10 QSOs within one UTC day, SOTA 4 QSOs, WWFF 44 QSOs.
  These are defaults in `program_rules`, not hard-coded, because programs change them.
- Licensing is unchanged from ADR 0013: SOTA, POTA and WWFF terms for redistribution are unknown or restrictive, so
  nothing is bundled.

## Decision
- Download only on user request, from the URLs above shown beforehand and editable (as for MASTER.SCP). HTTPS only,
  also after redirects. Platform TLS validation, never disabled.
- Per-pack size caps: POTA 20 MB, SOTA 60 MB, WWFF 60 MB, enforced on `Content-Length` and while streaming.
- **Stream** the body to a temporary file while hashing it, then parse it chunk by chunk into a temporary table and swap
  it in one transaction. A failed download or parse never damages the installed pack. Parsing runs on the app isolate:
  it awaits between 64 KB chunks and takes about one second per 25 MB on a desktop, and the database work already runs on
  a background isolate. Revisit only if profiling on a phone shows dropped frames.
- Parsers are strict about the header row (an unknown header fails the pack), and tolerant only of extra trailing columns.
  Rows with an invalid reference are skipped and counted, and the count is shown.
- Activations are local sessions in the `activations` table. QSOs get `MY_*_REF` from the active session at write time,
  in the same transaction as the QSO. Ending a session never edits QSOs.
- Progress is computed from QSOs (per program rule and UTC day), so it survives edits and deletes.

## Consequences
- First use of each program needs a connection. The manual says so.
- `PackDownloader` (app/lib/src/services/pack_download.dart) follows the MASTER.SCP rules but streams to a file. The SCP
  downloader keeps its in-memory path (8 MiB) for now. Merging the two is a later cleanup, not needed for correctness.
- **Own references and Wavelog (verified 2026-10-03, see `wavelog-api.md`):** Wavelog ignores `MY_*_REF` and
  `MY_GRIDSQUARE` in an upload and copies them from the station location the QSO is uploaded to. Tideline keeps them on
  every QSO and exports them in ADIF, but only a location carrying the reference puts them on the server. The other
  station's reference (`POTA_REF`, `SOTA_REF`, `WWFF_REF`) syncs normally, so park to park works.
- **Decision (maintainer, 2026-10-03): option A.** Tideline compares the activation's reference with the references on the
  cached Wavelog locations, preselects a match and warns when none matches. It never changes the user's Wavelog
  configuration, so it needs no `station:write` scope. Updating or creating locations (options B and C) remains a possible
  opt-in feature with its own consent step.
- Open: whether the 4 QSO SOTA rule also needs the "same summit, once per UTC day" handling.

## Update 2026-10-05 (counting rules checked, step 7.4)
Checked against the programmes' texts: the WWFF Global Rules V5.10 (sections 4.6 and 4.7, read in the PDF) and the SOTA
General Rules as quoted in the SOTA Reflector and club summaries (the official rules page could not be fetched, so the
SOTA points are less certain and worth a second look by the maintainer).
- **WWFF:** 44 QSOs; the same call on another band, mode or date is a separate QSO; the QSOs of several visits add up.
  New window `sessionByDay`: all days of a session add up, a repeat counts once per UTC day.
- **SOTA:** 4 QSOs, each with a different station, on one UTC day (an activation does not span midnight UTC); points are
  once per summit and calendar year. New setting `repeat: call`, and the window is `utcDay`.
- **Not built:** adding up WWFF QSOs across sessions of the same reference, and SOTA's once-per-year points. Both need a
  per-reference history; the manual says so. This closes the open question about the SOTA window above.
- Rules stored before this change have no `repeat` and read as `callBandMode`. Nothing stores rules unless a user did.
