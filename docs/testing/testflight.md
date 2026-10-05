# TestFlight: what to test

For the maintainer and any tester of a TestFlight build (ADR 0022). Work through the sections that fit your device;
none of them needs to be done in one sitting. Tick what works and write down what does not.

**Build under test:** Tideline 0.4.0, build ____ · **Device:** ____ · **iOS/iPadOS:** ____ · **Wavelog:** ____ ·
**Language:** EN / DE

## 0. Before you start
- [ ] You have a Wavelog (3.1 or newer; 3.2 for contest sessions) and an API token. See the manual chapter
  "Creating a Wavelog API token".
- [ ] Use a **test station location** or a test logbook if you do not want test QSOs in your real log. Deleting QSOs
  on Wavelog needs `qso:delete`.
- [ ] Turn on VoiceOver (Settings → Accessibility → VoiceOver) for sections 2 to 4 if you test it.

## 1. First setup and sync
- [ ] Onboarding: address check, token check with the list of permissions, station choice, **Start logging**.
- [ ] A self-signed server: the fingerprint dialog appears, and trusting it works. A changed certificate is refused.
- [ ] Log 3 QSOs with the network **off**. They show as waiting and nothing blocks the screen.
- [ ] Network on: **Sync now** uploads them. Each QSO shows its state as icon **and** text. The tide gauge text agrees.
- [ ] Open a synced QSO, correct the name or comment, sync: the change reaches Wavelog.
- [ ] Change the **time or mode** of a synced QSO: Tideline offers the "needs decision" choices and explains why.
- [ ] Log a duplicate (same call, band, mode, minute): the explanation is clear.
- [ ] Revoke the token in Wavelog, sync: "Token problem" is explained, nothing is lost, a new token fixes it.
- [ ] Quit and reopen the app during a sync: no QSO is duplicated or lost.
- [ ] Settings → Export log as ADIF; open the file in another app. Create an encrypted backup and restore it on a
  second device or after reinstalling.
- [ ] Optional app lock with Face ID / Touch ID, and the passcode fallback.

## 2. Everyday logging (phone, tablet)
- [ ] Callsign entry with the keyboard up: DXCC hint, worked-before hint, band from the frequency
  (`14205`, `14.205`, `472`, `1840`).
- [ ] Times are UTC. Change the time manually and back to "now".
- [ ] **iPad**: rotate in both directions, use split view and Stage Manager, with and without the on-screen keyboard.
  Typed input must survive. Nothing important is hidden behind the keyboard.
- [ ] **iPhone**: portrait only, as intended.
- [ ] Hardware keyboard on iPad: Enter logs, Esc clears, ⌘/ shows the shortcuts.
- [ ] Themes: light, dark, **sunlight** outdoors, **night red** in the dark; glove mode; easy-to-read font.
- [ ] Largest text size (Settings → Accessibility → Display & Text Size → Larger Text, up to 200 %): no cut-off or
  overlapping text anywhere.

## 3. VoiceOver (and later TalkBack)
- [ ] Every control has a sensible label; focus order follows the reading order; focus is visible with a keyboard.
- [ ] The callsign is read **letter by letter**, in the field, the log list and the contest list.
- [ ] After **Log QSO**, "Logged" and the callsign are announced.
- [ ] The tide gauge, sync states, banners and errors are spoken as text. Nothing depends on colour.
- [ ] Dialogs (end activation, remove list, certificate) can be read and closed with VoiceOver.
- [ ] Contest screen (section 4) and activation screens (section 5) can be used without seeing the screen.

## 4. Contest mode
- [ ] Start a session: contest, station, **My exchange**, Cabrillo categories. A contest of your choice from the bundled
  list.
- [ ] Download MASTER.SCP (Settings → Super check partial), then type a call: suggestions and the dupe hint appear.
- [ ] Run for 30 minutes or more with real or simulated contacts: Enter, Space and Tab move through the exchange; the
  next serial number is shown; the score, multipliers and rates look plausible (they are an estimate).
- [ ] Edit and delete a QSO without leaving contest mode. The sent serial stays fixed. A deleted serial is not reused.
- [ ] Rotate the iPad and use the keyboard: the entry stays usable and nothing is lost.
- [ ] Export Cabrillo (running and ended session): the warnings list is understandable; open the file and check the
  header, the QSO lines and the category lines against the contest's rules.
- [ ] Wavelog 3.2+: the session appears on Wavelog after the first QSO upload, and its QSOs are linked.
- [ ] Quit the app mid-contest and reopen: the session and its entry are as you left them.

## 5. Activations (SOTA, POTA, WWFF)
- [ ] Settings → Reference lists: download **POTA** (about 9 MB) with Wi-Fi. Progress bar and text agree. **Cancel** a
  second download halfway: the first list stays installed.
- [ ] Optionally download SOTA (about 25 MB) and WWFF (about 24 MB), and remove one again.
- [ ] Start an activation: search by name, pick a park, check the grid square and the note about the Wavelog location.
- [ ] With the network off: the whole activation, including the search, still works.
- [ ] The banner counts correctly: 10 QSOs on one UTC day make a POTA activation valid; repeating call, band and mode
  is not counted. Delete a QSO and watch the number change.
- [ ] Park to park: enter the other station's park; after sync it is on Wavelog as `POTA_REF`.
- [ ] Wavelog only stores **your** park if the station location carries it (the app says so). Check one QSO on Wavelog.
- [ ] End the activation; reopen the app; the log and the ADIF export contain `MY_POTA_REF` (or SOTA/WWFF).

## 5b. New in 0.4
- [ ] **Accounts:** add a second Wavelog account (Settings → Wavelog accounts), switch with the menu on the log screen,
  rename it, give it a new token. Switching is refused during a contest session or an activation. Sync covers both.
- [ ] **Callsign directory:** type a call you worked before: name, place and locator appear, **Fill in** fills empty
  fields. Write a note for a station and see it again later, also offline. Browse and search it in Settings →
  Reference data.
- [ ] **Free up space:** Settings → account → *Remove synced QSOs*. Check the count, **Check with Wavelog**, **Export,
  then remove**. Only synced QSOs go; nothing is deleted on Wavelog; an ADIF re-import skips them.
- [ ] **Fast Log Entry** (lightning bolt in the log): paste a few lines like `20m cw` / `1734 DL1ABC 599 579` / `5 G4XYZ`.
  Read the preview, fix a problem line, log. Duplicates are marked.
- [ ] **Field mode** (Settings → Field mode): the switch changes theme, button size and keeps the screen on while the log
  is open; switching it off restores yours. Note the battery over a longer session.
- [ ] **Keyboard (phone):** a *Hide keyboard* bar sits above the keyboard and the navigation is reachable; number pads
  appear for reports and frequency.
- [ ] **Mac or Windows:** sidebar, menu bar, **Esc** or Alt+← goes back, right click on a log row.

## 6. Things that must not happen
- [ ] No network request without a user action, other than talking to your Wavelog.
- [ ] The token never appears in screens, exports, backups or in what you attach to a report.
- [ ] No QSO is lost, duplicated or silently changed on the device.
- [ ] The app does not crash. If it does, note what you did just before.

## Known limitations of this build
- iPhone is portrait only. iOS does not allow reliable background sync: open the app to sync.
- Reference lists need a connection once (9 to 25 MB each).
- "Near me" in the activation setup uses your grid square, not GPS.
- The counting rules of the activation programs are fixed defaults (POTA 10 per UTC day, SOTA 4, WWFF 44; SOTA and WWFF
  count over the whole activation). Check your award's rules if exact counting matters.
- Wavelog ignores your own park or summit in an upload and uses the one of the station location.
- No tests on TalkBack, Android or desktop in this build.

## How to report
Use TestFlight's **Send Beta Feedback** (screenshot, device and build are attached) or open an issue at
<https://github.com/ceotjoe/tideline/issues>. Please include:
1. What you did, step by step, and what you expected.
2. What happened, with a screenshot if you can.
3. Build number, device, iOS version, language, text size, VoiceOver on or off.
4. Whether the network was on, and whether a Wavelog was involved (never include a token or a server address you want
   to keep private; blur it in screenshots).

Tideline has no telemetry. The only data you share is what you choose to send.

---

# Beta description for App Store Connect

For **TestFlight → Test Information**. Internal testers do not need it, external testers do. The limit is 4,000
characters per language. Keep English as the primary text and add the German one as a localisation.

## English

Tideline is the offline logger for Wavelog, for radio amateurs. It works fully offline and syncs your QSOs to your own
Wavelog server when a connection is there. There is no account with us, no tracking and no analytics.

What you can try in this build:
• Log QSOs offline and see for every QSO what sync is doing: waiting, uploaded, checked, rejected, with a plain
  explanation.
• Contest mode for the big contests: fast keyboard entry, serial numbers that never repeat, dupe checks, super check
  partial, score and rates, Cabrillo export.
• SOTA, POTA and WWFF activations: reference lists you download yourself, search by name or distance, progress toward a
  valid activation, park-to-park and summit-to-summit.
• Made to be accessible: VoiceOver, large text up to 200 %, themes for sunlight and for the night, glove mode, full
  keyboard use on iPad.

You need a Wavelog server (version 3.1 or newer) and an API token. Your QSOs and token stay on your device and go only
to your own server. See "What to test" for the steps and the known limitations.

Please tell us what is unclear, slow or wrong. Use "Send Beta Feedback" in TestFlight or open an issue at
https://github.com/ceotjoe/tideline/issues.

## Deutsch

Tideline ist der Offline-Logger für Wavelog, für Funkamateure. Er funktioniert komplett offline und überträgt Deine QSOs
zu Deinem eigenen Wavelog-Server, sobald eine Verbindung besteht. Es gibt kein Konto bei uns, kein Tracking und keine
Analyse.

Das kannst Du in diesem Build ausprobieren:
• QSOs offline loggen und bei jedem QSO sehen, was die Synchronisierung macht: wartend, hochgeladen, geprüft,
  abgelehnt, jeweils mit einer klaren Erklärung.
• Contest-Modus für die großen Contests: schnelle Eingabe per Tastatur, Seriennummern, die sich nie wiederholen,
  Dupe-Prüfung, Super Check Partial, Punkte und Raten, Cabrillo-Export.
• SOTA-, POTA- und WWFF-Aktivierungen: Referenzlisten, die Du selbst herunterlädst, Suche nach Name oder Entfernung,
  Fortschritt zur gültigen Aktivierung, Park zu Park und Gipfel zu Gipfel.
• Barrierefrei gedacht: VoiceOver, große Schrift bis 200 %, Themen für Sonnenlicht und für die Nacht, Handschuh-Modus,
  volle Tastaturbedienung auf dem iPad.

Du brauchst einen Wavelog-Server (ab Version 3.1) und ein API-Token. Deine QSOs und Dein Token bleiben auf Deinem Gerät
und gehen nur an Deinen eigenen Server. Die Schritte und die bekannten Einschränkungen stehen unter „Was zu testen ist“.

Sag uns bitte, was unklar, langsam oder falsch ist. Nutze „Beta-Feedback senden“ in TestFlight oder öffne ein Issue unter
https://github.com/ceotjoe/tideline/issues.

---

# What to Test (per build)

Paste into **TestFlight → build → Test Details → What to Test** (4,000 characters). Replace the first line for each
build.

## English

Build 4 (0.4.0): several accounts, callsign directory, free up space, Fast Log Entry, field mode.
Please try: 0) The new features: a second account, the callsign hint and notes, Fast Log Entry (lightning bolt), Settings → Field mode, Settings → account → Remove synced QSOs. Then the rest: 1) First setup with your Wavelog and a token. 2) Log QSOs offline, then sync. 3) A short contest session and
a Cabrillo export. 4) Download a POTA list and run an activation. 5) VoiceOver on the log screen, the contest screen and
the activation screen. 6) iPad rotation and the on-screen keyboard.
The full checklist is in the repository: docs/testing/testflight.md.
Known: iPhone is portrait only; no background sync on iOS; reference lists need a one-time download of 9 to 25 MB.

## Deutsch

Build 4 (0.4.0): mehrere Konten, Rufzeichen-Verzeichnis, Speicher freigeben, Fast Log Entry, Feldmodus.
Bitte ausprobieren: 0) Die Neuerungen: ein zweites Konto, Rufzeichen-Hinweis und Notizen, Fast Log Entry (Blitz-Symbol), Einstellungen → Feldmodus, Einstellungen → Konto → Synchronisierte QSOs entfernen. Danach das Übrige: 1) Ersteinrichtung mit Deinem Wavelog und einem Token. 2) QSOs offline loggen, dann synchronisieren.
3) Eine kurze Contest-Sitzung und ein Cabrillo-Export. 4) Eine POTA-Liste laden und eine Aktivierung durchführen.
5) VoiceOver auf Log-, Contest- und Aktivierungsbildschirm. 6) iPad-Drehung und Bildschirmtastatur.
Die vollständige Checkliste liegt im Repository: docs/testing/testflight.md.
Bekannt: iPhone nur im Hochformat; keine Hintergrund-Synchronisierung unter iOS; Referenzlisten brauchen einmalig einen
Download von 9 bis 25 MB.
