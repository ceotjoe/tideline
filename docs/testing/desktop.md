# Mac and Windows: what to test

For testers of the desktop builds. The general rules, the reporting form and the exit criteria are in
[README.md](README.md). Features are explained in [testflight.md](testflight.md); this page lists what is different on a
computer. Linux is scaffolded but unofficial: reports are welcome, but they do not block a release.

**Build under test:** Tideline 0.6.0 · **Computer:** ____ · **OS:** ____ · **Wavelog:** ____ · **Language:** EN / DE ·
**Screen reader:** VoiceOver (Mac) / Narrator or NVDA (Windows) / none

## 0. Before you start
- **Mac:** the Mac App Store build through TestFlight, or a build from source (`flutter run -d macos`).
- **Windows:** download from the GitHub release, either the **portable zip** (unzip and run `tideline.exe`) or the **MSIX**
  (double-click to install). Check the checksum against `SHA256SUMS.txt`.
- [ ] A Wavelog 3.1 or newer and an API token, or the demo account.
- [ ] A test station location.

## 1. Install and first run
- [ ] **Mac:** the app opens without a Gatekeeper warning. The system asks about the local network only if you connect to
  a server in your home network, and the text explains why.
- [ ] **Windows MSIX:** installs without errors and shows the publisher you expect. Windows SmartScreen may warn about an
  unknown publisher; note what it says and whether the signature is shown.
- [ ] **Windows portable zip:** runs from a folder and from a USB drive without an installer. A second launch does not
  corrupt the data.
- [ ] Uninstall removes the app. Your log stays in your user folder. Note whether you can tell where it is.
- [ ] Update from an earlier build: the log is there. **From 0.5.x:** the log is empty, a one-time notice says why, and
  the old file is still on disk and not deleted.
- [ ] Windows only: the app works with a high-DPI display (125 %, 150 %, 200 % scaling) and with two monitors of
  different scaling; moving the window between them keeps the layout.

## 2. Setup and sync
- [ ] Onboarding with a real Wavelog; a self-signed server shows the fingerprint dialog.
- [ ] Log QSOs with Wi-Fi off, then on: **Sync now** uploads them. The state is icon and text.
- [ ] Close the window or quit during a sync, reopen: no QSO is lost or duplicated.
- [ ] Put the computer to sleep during a sync and wake it: Tideline checks reachability and continues.
- [ ] Behind a corporate proxy or VPN (if you have one): a clear message, not a hang.

## 3. Window and navigation
- [ ] The **sidebar** shows Log, Callsigns, Sync, Settings in every window size, with names from a wide window on.
- [ ] **Menu bar:** Mac uses the system menu bar; Windows shows a strip in the window. Go, Operate and Help each show
  their shortcuts, and an entry that makes no sense on the current page is greyed out.
- [ ] **Go back** works with **Esc**, **Alt+←** (**⌥←** on Mac) and **Ctrl+[** (**⌘[**). On the log screen **Esc**
  still clears the entry.
- [ ] **Right click** a QSO: *Open QSO* and *Copy callsign*.
- [ ] **Resize:** drag the window from very narrow to maximised, and back. Typed input is never lost; the layout
  switches between phone-like and tablet-like without a restart.
- [ ] **Full screen** (Mac) and **maximise or snap** (Windows) keep the layout correct.
- [ ] **Mac:** the red, yellow and green buttons behave; **⌘Q** quits cleanly; **⌘W** closes the window as expected;
  Mission Control and Stage Manager do not break the window.
- [ ] **Windows:** closing the window ends the app; no process remains in Task Manager.

## 4. Keyboard only
Put the mouse away.
- [ ] Tab and Shift+Tab move through every control, in reading order, with a **visible focus** everywhere.
- [ ] **Enter** logs a QSO, **Esc** clears, **Ctrl/⌘+N** starts a new one, **Ctrl/⌘+E** edits the last one.
- [ ] **Ctrl/⌘+/** or **F1** shows every shortcut. The overlay matches the menu bar and the manual's table.
- [ ] **Ctrl/⌘+1, 2, 3** go to Log, Callsigns, Sync; **Ctrl/⌘+,** opens settings.
- [ ] **Ctrl/⌘+Shift+C** opens contest mode, **+A** starts an activation, **+E** ends it, **+F** opens Fast Log Entry,
  **+S** syncs.
- [ ] Contest mode: Enter, Space and Tab move through the exchange; Page Up and Page Down change band; **Ctrl/⌘+L**
  goes to the callsign.
- [ ] Dialogs trap focus and return it to where you were when closed. Every dialog closes with Esc.
- [ ] On a non-US keyboard layout (German, for example), the shortcuts still work and the overlay shows the right keys.

## 5. Screen readers
- [ ] **VoiceOver on Mac** (**⌘F5**): controls have labels, callsigns are read **letter by letter**, "Logged" and the
  callsign are announced after Log QSO, the tide gauge and sync states are spoken as text.
- [ ] **Narrator or NVDA on Windows:** the same checks. Note which one you used.
- [ ] Contest and activation screens can be used without seeing the screen.

## 6. Files, copy and paste, printing
- [ ] ADIF export and import through the system file dialogs; Cabrillo export. Open the exports in another program.
- [ ] Paste a callsign or a block of lines into Fast Log Entry from another application: no hidden characters.
- [ ] Backup and restore: make a backup on the computer, restore on another (or after removing the app data). The backup
  is not encrypted and says so.
- [ ] Drag a file onto the window (Mac and Windows): nothing unexpected happens. Note it if it does.

## 7. Themes, text, display
- [ ] Light, dark, sunlight and night red. **Follow the system** switches when the OS changes mode.
- [ ] **High contrast:** Windows contrast themes; macOS **Increase contrast** and **Reduce motion**. The app stays usable
  and animations stop with reduce-motion on.
- [ ] 200 % text scaling in the app and the OS text size at the largest: no cut-off text.
- [ ] A small window (about 800 × 600) and a large one (4K or ultrawide): nothing floats off or stretches oddly.

## 8. Features that must also work here
Work through these in testflight.md and tick them again for desktop.
- [ ] Contest mode (section 4) with a hardware keyboard, which is the main use on a computer.
- [ ] Activations (section 5): download a POTA list, search offline, run an activation.
- [ ] New in 0.4 (section 5b) and New in 0.5 and 0.6 (section 5c): accounts, callsign directory, free up space, Fast Log
  Entry, Field mode (the screen-on and battery parts do not apply to a computer), demo account.

## 9. Things that must not happen
- [ ] No network request without a user action, other than talking to your Wavelog.
- [ ] The token never shows on screen, in exports, backups or logs.
- [ ] No QSO is lost, duplicated or silently changed.
- [ ] The app does not crash or hang. Windows: Event Viewer shows no application error for Tideline. Mac: no crash
  report in Console.

## Known limitations of this build
- Desktop has no background sync; open the app to sync. There is no tray icon.
- Reference lists need a connection once (9 to 25 MB each).
- Windows builds are only as trusted as the certificate they are signed with; a new publisher can trigger SmartScreen.
- Linux is experimental and not tested at all by the project.
