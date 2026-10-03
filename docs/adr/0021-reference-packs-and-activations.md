# 0021. Reference packs and activation sessions

- Status: proposed
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
- **Stream** the body to a temporary file, hash it, parse line by line in an isolate, write to a staging table and swap it
  in one transaction. A failed download or parse never damages the installed pack.
- Parsers are strict about the header row (an unknown header fails the pack), and tolerant only of extra trailing columns.
  Rows with an invalid reference are skipped and counted, and the count is shown.
- Activations are local sessions in the `activations` table. QSOs get `MY_*_REF` from the active session at write time,
  in the same transaction as the QSO. Ending a session never edits QSOs.
- Progress is computed from QSOs (per program rule and UTC day), so it survives edits and deletes.

## Consequences
- First use of each program needs a connection. The manual says so.
- A shared download service replaces the SCP-specific one; the SCP behaviour and tests must stay identical.
- Open: whether the 4 QSO SOTA rule also needs the "same summit, once per UTC day" handling, and which Wavelog field
  carries a second reference for P2P (to be verified against the API docs in step 4.6, not assumed).
