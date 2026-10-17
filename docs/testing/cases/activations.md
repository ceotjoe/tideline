# Activations (AC)

SOTA, POTA and WWFF reference lists are downloaded by the user (9 to 25 MB each). Counting rules (ADR 0021 and its
update): POTA 10 QSOs per UTC day, SOTA 4 QSOs with different stations on one UTC day, WWFF 44 QSOs and the same
station counts again on another UTC day. SOTA and WWFF count over the whole activation.

### AC-01 Download, cancel, remove a list
**P1 · all · Needs: Wi-Fi**
1. Settings → Reference data: download POTA. Watch the progress bar and its text.
2. Start a second download and cancel it halfway.
3. Remove a list.

**Expected:** progress bar and text agree; a cancelled download leaves the installed list untouched; removing works and
frees the space; only the official source is contacted; the metadata (source, date, size) is shown.

Result:

### AC-02 Start offline
**P1 · all · Needs: an installed list**
Network off. Start an activation: search by name and by reference, use "near me" with a grid square, pick a park.

**Expected:** everything works offline; the grid square and the note about the Wavelog location are shown.

Result:

### AC-03 POTA counting
**P1 · all · Needs: nothing**
Log 10 QSOs on one UTC day, one of them repeating call, band and mode. Delete a QSO. Log across midnight UTC.

**Expected:** the banner counts 9 until one more distinct QSO is logged, then shows a valid activation; the repeat is not
counted; deleting changes the number at once; after midnight UTC the count starts again for the new day. The banner has a
text equivalent (no colour alone).

Result:

### AC-04 SOTA and WWFF counting
**P2 · all · Needs: nothing**
SOTA: 4 QSOs with different stations, then the same station on another band. WWFF: the same station on two UTC days.

**Expected:** SOTA counts 4 distinct stations and ignores the repeat on another band; WWFF counts the same station again
on the second UTC day and adds the days up. The numbers match the award rules.

Result:

### AC-05 Park to park and summit to summit
**P2 · all · Needs: real Wavelog for the check**
Log a QSO with the other station's reference and sync.

**Expected:** the other reference is on Wavelog (`POTA_REF`, `SOTA_REF`, `WWFF_REF`). Your own reference is in the local
ADIF as `MY_POTA_REF` etc. The app says that Wavelog takes your own reference from the station location.

Result:

### AC-06 End and export
**P1 · all · Needs: nothing**
End the activation, quit and reopen, export the activation as ADIF and the whole log.

**Expected:** the activation is shown as ended and no longer takes QSOs; the ADIF has the `MY_*_REF` fields; ending is confirmed
by a dialog that VoiceOver and the keyboard can use; **Ctrl/⌘+Shift+E** ends it on desktop.

Result:

### AC-07 Outdoors, field mode, battery
**P2 · phone and tablet · Needs: a real outing of at least 60 minutes**
Field mode on, sunlight theme, glove mode, screen on. Log at least 10 QSOs outdoors.

**Expected:** the screen stays readable in sun; buttons are usable with gloves; the screen stays on only while the log is
open; battery use over the hour is reported (note the percentage); switching Field mode off restores the previous
theme and button size.

Result:
