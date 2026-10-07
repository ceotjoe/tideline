# Android: what to test

For testers of the Android build (phone and tablet), delivered through the Google Play internal or closed test, or by
`adb install` from a release build (`docs/release.md`, "A signed build for your own device"). The general rules, the
reporting form and the exit criteria are in [README.md](README.md). The iOS checklist in [testflight.md](testflight.md)
explains each feature in more detail; this page lists what is different or only testable on Android.

**Build under test:** Tideline 0.6.0, build ____ · **Device:** ____ · **Android:** ____ · **Wavelog:** ____ ·
**Language:** EN / DE · **Screen reader:** TalkBack on / off

## 0. Before you start
- [ ] Android 7.0 (API 24) or newer. Note the manufacturer, since battery and keyboard behaviour differ.
- [ ] You joined the test through the opt-in link, and the Play Store shows Tideline. Closed-test testers: stay opted in
  for the full 14 days, because Google counts it.
- [ ] A Wavelog 3.1 or newer and an API token, or use the demo account.
- [ ] A test station location, so test QSOs stay out of your real log.

## 1. Install, update, first run
- [ ] Fresh install from Play: the app starts, the Welcome screen is shown in your system language.
- [ ] Android's permission list for the app shows only network access (and biometric for the lock). No location,
  contacts, storage or notification permission is asked.
- [ ] Update from an earlier Tideline build (if you have one): the log is there afterwards. **From 0.5.x:** the log is
  empty and a one-time notice says why; QSOs you had synced are on Wavelog. Nothing is deleted from the old file.
- [ ] Uninstall and reinstall: the app starts clean and does not offer a restore from a Google backup (Tideline asks
  Android not to back up its data).

## 2. Setup and sync
- [ ] Onboarding with a real Wavelog: address check, token check, station choice, **Start logging**.
- [ ] A self-signed server: the fingerprint dialog appears and trusting it works.
- [ ] Plain HTTP to a server in your home network: the warned opt-in appears; a public address over HTTP is refused.
- [ ] Log 3 QSOs in airplane mode. They wait. Turn the network on: they sync (foreground only). **Sync now** works.
- [ ] Switch between Wi-Fi and mobile data during a sync; kill the app from the recent apps list during a sync and open
  it again: no QSO is lost or duplicated.
- [ ] **Doze and background:** put the app in the background for an hour with the screen off. Tideline does not claim to
  sync in the background; on return it syncs when you open it. Note the battery drain, which should be near zero.
- [ ] Revoke the token in Wavelog, sync: "Token problem" is explained, nothing is lost, a new token fixes it.

## 3. TalkBack
- [ ] Turn on TalkBack (Settings → Accessibility → TalkBack). Every control has a sensible label; swipe order follows
  the reading order.
- [ ] The callsign is read **letter by letter** in the field, the log list and the contest list.
- [ ] After **Log QSO**, "Logged" and the callsign are announced.
- [ ] The tide gauge, sync states, banners and errors are spoken as text.
- [ ] Dialogs (end activation, remove list, certificate) can be read and closed.
- [ ] The contest screen and the activation screens can be used without seeing the screen.
- [ ] Explore by touch on a tablet in landscape: nothing is skipped, nothing is read twice.
- [ ] Switch Access or a keyboard connected over Bluetooth can reach every control.

## 4. Android behaviour
- [ ] **Back button and back gesture** (gesture navigation and three-button navigation): on a settings page it goes up
  one level; on the log screen it does not close the app with an entry in progress and lose the entry; at the top it
  leaves the app as usual. Predictive back animation looks right (Android 14+).
- [ ] **Keyboard:** a *Hide keyboard* bar sits above the keyboard, the navigation is reachable, number pads appear for
  reports and frequency. Try Gboard and the manufacturer keyboard (for example Samsung Keyboard). Autocorrect must not
  change a callsign.
- [ ] **Rotation and resize:** rotate in both directions; use split screen, a freeform window, and fold or unfold on a
  foldable. Typed input survives and nothing important hides behind the keyboard.
- [ ] **Edge-to-edge:** the status bar and navigation bar do not cover content on Android 15 and 16; there is no blank band
  above the page titles on phones with a notch or punch hole.
- [ ] **Hardware keyboard on a tablet or Chromebook:** Enter logs, Esc clears, **Ctrl+/** shows shortcuts, Tab moves
  with a visible focus.
- [ ] **Themes:** light, dark, sunlight outdoors, night red; follow the system dark mode. Glove mode; easy-to-read font.
- [ ] **Font and display size:** Settings → Display → Font size and Display size at the largest values, plus Tideline's
  text size to 200 %: no cut-off or overlapping text.
- [ ] **Biometric app lock:** switch it on in Security and backup; fingerprint or face unlocks; the device PIN fallback
  works; leaving the app and coming back asks again.
- [ ] **Files:** export ADIF and Cabrillo through the Android file picker to Downloads and to a cloud provider; import
  an ADIF file from the file picker. Create a backup, restore it on a second device or after reinstalling. The backup is
  not encrypted and says so.
- [ ] **Copy callsign** and paste a callsign: no hidden characters or spaces end up in the field.
- [ ] **Screen on:** Field mode keeps the screen on only while the log, Fast Log Entry or the contest screen is open,
  and releases it when you leave. Note the battery over a longer session.

## 5. Features that must also work here
Work through these in testflight.md. Tick them again for Android; each has been tested mainly on iOS.
- [ ] Everyday logging (section 2): DXCC hint, worked-before hint, band from the frequency, UTC time.
- [ ] Contest mode (section 4): a session of 30 minutes or more, Cabrillo export, rotation mid-contest.
- [ ] Activations (section 5): download a POTA list on Wi-Fi, cancel a download, run an activation offline.
- [ ] New in 0.4 (section 5b): accounts, callsign directory, free up space, Fast Log Entry, Field mode.
- [ ] The demo account: **Try the demo (no Wavelog needed)** works with no network at all.

## 6. Things that must not happen
- [ ] No network request without a user action, other than talking to your Wavelog.
- [ ] The token never appears on screen, in exports, backups, `adb logcat`, or what you attach to a report.
- [ ] No QSO is lost, duplicated or silently changed on the device.
- [ ] The app does not crash or freeze (ANR). Play Console's Android vitals show no crash for your session.
- [ ] Tideline's data does not show up in Google's backup (Settings → System → Backup).

## Known limitations of this build
- Android has no background sync in this version; open the app to sync.
- Reference lists need a connection once (9 to 25 MB each).
- Not tested on every manufacturer. Please name yours in a report.
- Tablets and foldables are supported through window size classes; large landscape layouts are checked with screenshots
  only on a few sizes.
