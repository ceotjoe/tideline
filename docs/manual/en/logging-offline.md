# Logging offline

Every QSO is saved on your device the moment you log it, with or without a connection. Syncing happens separately and
never makes you wait.

## Logging a QSO

1. **Callsign.** Type it in. Letters become upper case automatically. On iPad you can also write with the Apple Pencil.
   - As you type, Tideline shows the **DXCC entity, continent and CQ/ITU zones**. This works offline, using the
     built-in country data.
   - It also shows whether you **worked the station before**: a new call, a new band, a new mode, a new combination of
     band and mode, or already worked (with the date of the first contact). This comes from the worked-before index,
     which holds your log and, after a sync, the QSOs on your Wavelog server. If it looks wrong (for example after you
     deleted QSOs in Wavelog), use **Settings → Worked-before index → Rebuild worked-before index**.
2. **Band, mode and frequency.**
   - Choose the band and mode, or just type a frequency, and the band is chosen for you. Under the field, Tideline
     shows how it read your entry, for example "14.205 MHz · 20 m".
   - With a decimal point (or comma) the number is MHz: `14.205`, `144.300`, `2320.2`.
   - A whole number is read as whatever lands in an amateur band: `7`, `50` and `144` are MHz, while `14205`, `1840`,
     `472` (630 m) and `136` (2190 m) are kHz. Numbers of 1800 and more are always kHz, so for microwave bands type a
     decimal point.
   - Band, mode, frequency and station stay set for the next QSO.
3. **Reports.** Leave them empty for the usual default: 59 for phone, 599 for CW, −10 for FT8/FT4.
4. **Time.** The time is always **UTC** and runs live. Choose **Change time** to log an earlier contact, and **Use current
   time** to go back.
5. **Log.** Choose **Log QSO**, or press **Enter** on a keyboard. The form is ready for the next QSO immediately.

## Keyboard

| Key | Action |
|---|---|
| Enter | Log the QSO |
| Esc | Clear the entry |
| Ctrl/⌘ + N | Back to the callsign field |
| Ctrl/⌘ + E | Open the last QSO |
| Ctrl/⌘ + / or F1 | Show all shortcuts |

See [Keyboard shortcuts](keyboard-shortcuts.md) for the full list.

## Tablets and desktop

- **Landscape:** the fields form three rows across the whole width, with your log underneath. With the on-screen
  keyboard open, all fields and the **Clear entry** and **Log QSO** buttons stay visible without scrolling. The top bar
  hides while the keyboard is open; it returns when you close the keyboard. Tab and Shift+Tab move through the fields
  row by row.
- **Portrait:** the fields form rows of up to three across the width, with Clear entry and Log QSO pinned beneath them
  and your log below. With the on-screen keyboard open, every field and both buttons stay visible without scrolling.
- **QSO details:** choose a QSO in the log to see its details in a sheet over the log; what you are typing stays where
  it is. Swipe the sheet down to close it.
- **Phones** stay in portrait.
- **Resizing:** rotating or resizing the window (Split View, Stage Manager) never loses what you typed.
