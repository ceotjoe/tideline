# Contest mode (CT)

Contest rules are data (`docs/architecture/contest-definitions.md`). Test with a contest you know, and check the numbers
against its published rules. Scores, multipliers and rates in Tideline are an estimate and say so.

### CT-01 Session setup
**P1 · all · Needs: nothing**
Start a session: contest from the bundled list, station, **My exchange**, Cabrillo categories.

**Expected:** only valid combinations are accepted; the missing field is named; the session shows its contest, band and
mode, and the entry form fits the contest's exchange.

Result:

### CT-02 Thirty minutes of contacts
**P1 · iPad or tablet with keyboard, and one desktop OS · Needs: a contest with serials**
Log 100 QSOs over at least 30 minutes (real, or a script/keyboard run) with Enter, Space and Tab moving through the
exchange.

**Expected:** the next serial number is always shown; points, multipliers and rates look plausible and match a hand
count of the first 20 QSOs; dupes are called out before logging; the entry never loses focus unexpectedly; no slowdown.

Result:

### CT-03 Serial numbers never repeat
**P1 · all · Needs: nothing**
1. Log serials 1 to 5. Delete QSO 5. Log the next.
2. Edit QSO 3 without leaving contest mode.
3. Quit the app, reopen, log the next.
4. Restore a backup made at serial 3 on a second device and log there, then compare the serials of both devices.

**Expected:** the sent serial of an existing QSO never changes; a deleted serial is not reused (the next is 6, then 7); a
restart continues the count; on a restored device note whether a serial is handed out twice and report it (allocations are per device).

Result:

### CT-04 Dupes
**P1 · all · Needs: nothing**
Log a call, then the same call on the same band (and, in a contest where it counts, the same mode). Then on another
band.

**Expected:** the second is flagged before logging and counted as 0 points or as the contest rule says; the other band is
a normal QSO. Behaviour is identical with the on-screen keyboard and a hardware keyboard.

Result:

### CT-05 Super check partial
**P2 · all · Needs: MASTER.SCP download (Wi-Fi)**
Download MASTER.SCP (Settings → Super check partial). Type a partial call.

**Expected:** suggestions appear while typing, work offline afterwards, and do not change a typed call by themselves.
The download shows progress and can be cancelled without damaging the old list.

Result:

### CT-06 Cabrillo export
**P1 · all · Needs: a finished session of at least 50 QSOs**
Export Cabrillo from a running and from an ended session. Open the file; check header, `QSO:` lines and category lines
against the contest's rules. Upload to the contest's log checker if it has one.

**Expected:** the warnings list is understandable and names the QSO; the file has the version header, contest name,
callsign, categories and one `QSO:` line per QSO in time order in UTC with the right column layout; the contest's own
checker accepts it.

Result:

### CT-07 Contest session on Wavelog 3.2
**P1 · all · Needs: real Wavelog 3.2 with `contest:read` and `contest:write`**
Log three QSOs in a session and sync.

**Expected:** the session exists on Wavelog after the first upload and the QSOs are linked to it. On Wavelog 3.1 the
session works locally and the app says Wavelog contest sessions need 3.2; nothing fails.

Result:

### CT-08 Resume and rotation
**P1 · all · Needs: nothing**
Mid-contest: rotate the tablet, quit the app, reboot the device, reopen.

**Expected:** the session and the entry are as left, including a half-typed call; rates continue; no QSO is lost or
duplicated.

Result:
