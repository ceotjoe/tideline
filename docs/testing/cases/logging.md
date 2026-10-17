# Logging (LG)

### LG-01 Everyday entry
**P1 · all · Needs: demo account or Wavelog**
1. Type a callsign, frequency `14205`, mode, reports. Press **Log QSO** (Enter on a keyboard).
2. Log a second QSO with the same call a minute later on another band.

**Expected:** the DXCC hint and the worked-before hint appear while typing; the band is derived from the frequency; the
QSO appears in the list at once and the form is ready for the next one. Nothing waited for the network.

Result:

### LG-02 Frequency entry
**P1 · all · Needs: nothing**
Enter `14.205`, `14205`, `472`, `1840`, `136`, `7`, `50`, `144`, then `abc` and `99999`.

**Expected:** `14.205` and `14205` read as 14.205 MHz (20 m); `472` is 630 m; `1840` is 160 m; `136` is 2200 m; `7`,
`50` and `144` stay MHz (40 m, 6 m, 2 m). The reading is shown under the field. Invalid input is refused with a message
and does not become a QSO.

Result:

### LG-03 QSO date and time is UTC
**P1 · all · Needs: nothing**
1. Set the device time zone to one far from UTC (for example UTC+9, then UTC−8). Log a QSO with the time at "now".
2. Open **Change time**. Type `20261017`, check the cursor moved to the time, type `1734`, press Enter.
3. Open it again, change the time through the calendar and the clock instead.
4. Enter a month 13, a time 25:00 and a date far in the future.
5. Log across midnight UTC (set the time to 23:59, then 00:01 the next day).

**Expected:** all times are UTC and say so, whatever the device time zone. Typing over the selected text replaces it; the
cursor jumps to the time after the eighth digit; Enter sets it. Calendar and clock give the same stored value. Invalid
values are refused with a message and Cancel keeps the old value. The QSO date follows the UTC day. The ADIF export holds
`QSO_DATE` and `TIME_ON` in UTC.

Result:

### LG-04 Edit and delete a QSO
**P1 · all · Needs: nothing**
1. Edit the callsign, band, time and comment of a waiting QSO. Delete another. Undo where an undo is offered.
2. Edit a synced QSO (see DS-09).

**Expected:** edits are saved locally first and sync later; a deleted QSO leaves the list (soft delete) and a deletion
that was already synced is handled as the app explains. Nothing is shown as lost.

Result:

### LG-05 Rotation, resize and entered data
**P1 · iPad, Android tablet, desktop · Needs: nothing**
1. Type half a QSO (call, frequency, comment). Rotate the tablet in both directions; resize the desktop window from
   narrow to maximised; open split view; show and hide the keyboard.

**Expected:** every typed value is still there each time; nothing important sits behind the keyboard; the layout switches
by window size without a restart.

Result:

### LG-06 Callsign directory and notes
**P2 · all · Needs: a log with history**
1. Type a call you worked before. Use **Fill in**.
2. Write a note for the station. Go offline. Find the station in the **Callsigns** tab and search by part of the call and
   name.
3. Make a backup and an ADIF export.

**Expected:** name, place and locator appear and **Fill in** only fills empty fields. The note is there offline and
after a restart. The note is in the backup, and in no ADIF export, and nothing is sent to Wavelog.

Result:

### LG-07 Fast Log Entry
**P2 · all · Needs: nothing**
Paste:
```
20m cw
1734 DL1ABC 599 579
5 G4XYZ
1734 DL1ABC 599 579
```
Read the preview, fix a problem line, log all. Repeat with an obviously wrong line and with a pasted block that contains
a tab or zero-width character.

**Expected:** every line is shown as read; a problem line is named and left out; the repeated line is flagged as a
duplicate; a running activation takes the QSOs; contest sessions refuse the feature. All good lines are logged in one go,
or none. No hidden characters end up in a callsign.

Result:

### LG-08 Several Wavelog accounts
**P2 · all · Needs: two Wavelog accounts (a second one can be the demo account)**
1. Add a second account. Switch on the log screen. Rename it, give it a new token.
2. Try to switch during a contest session and during an activation.
3. Sync with both accounts holding waiting QSOs.

**Expected:** the entry form takes a station of the new account without an error; switching is refused in step 2 with a
reason; each account's QSOs go to its own server and the sync screen lists the waiting QSOs per account. Removing an
account removes all its local data and its token, never anything on the server.

Result:

### LG-09 Demo account
**P1 · all · Needs: nothing (airplane mode)**
1. Fresh install, airplane mode. Welcome screen → **Try the demo (no Wavelog needed)**.
2. Finish onboarding, log, sync, open a contest session and an activation, remove the account.

**Expected:** nothing asks for a network; the account list says nothing leaves the device; the demo works end to end and
the removal leaves no data behind. This is the path App Review uses.

Result:

### LG-10 Duplicate and worked-before hints
**P2 · all · Needs: a log with history**
Log a call already worked on the same band and mode within the last minute, then on another band, then a week later.

**Expected:** a same-minute duplicate is called out before logging; a different band or mode is a worked-before hint, not
an error. Hints work offline.

Result:
