# 0020. Entry strip for the log screen in landscape

- Status: accepted
- Date: 2026-10-03

## Context
- On a tablet in landscape the on-screen keyboard takes about 400 dp of the 820–1024 dp window height. The form (a
  360–400 dp column of eleven fields) showed only the callsign and band/mode above it; the rest had to be scrolled.
- Logging is fast keyboard work. Scrolling between fields while a station is waiting is not acceptable.
- The three-column layout (form, log, callsign context) also left the log list narrow (ADR 0010, 2026-10-02 note).

## Decision
- **Strip layout.** When the window is wider than tall and the screen body is at least 900 dp wide, the entry form is
  three rows across the full width and the log list fills the width below:
  1. callsign, band, mode, frequency, RST sent, RST received;
  2. name, locator, comment, station;
  3. UTC time, frequency reading, DXCC and worked-before hints; Clear and Log.
  Reading order is focus order.
- **Same state, two arrangements.** `QsoEntryForm` takes a `QsoEntryLayout` (`stacked` or `strip`); both build from the
  same field widgets, controllers and `GlobalKey`, so rotation keeps typed input and focus.
- **The text equivalent stays.** The frequency reading ("14.205 MHz · 20 m") moves out of the narrow frequency column
  into the third row (`FrequencyReadout`); it is still shown for every layout.
- **Room for the keyboard.** While the keyboard is up in landscape the app bar and the contest banner are hidden (the tide gauge stays), and the
  list gives up its minimum height. The iPad Pro 11" landscape keyboard is about 426 pt tall, which leaves ~330 pt. The
  strip is capped at the body height minus 96 dp; if it still does not fit (Split View, very large text) its rows scroll,
  Clear and Log stay pinned, and the list keeps a minimum height. Keyboard state comes from the view's insets, because the scaffolds above consume
  `MediaQuery.viewInsets`.
- **No third pane.** The context panel is removed: the DXCC and worked-before hints are the one-line hints in row 3.
  QSO details open in a bottom sheet on every non-compact window, so the form never moves; phones still use a page.
- **Phones stay in portrait.** iPhone lists only portrait in `Info.plist`. `PhoneOrientationLock` locks to portrait on
  iOS and Android when the physical display's shortest side is under 600 dp. It looks at the display, not the window,
  so a tablet in a narrow window still rotates. This is an orientation policy, not a layout branch; layouts remain
  driven by window size.

## Consequences
- All fields, Clear and Log fit above a 400 dp keyboard at 1180×820, 1210×834 and 1366×1024, and at 1.3× text (test).
- The callsign details beyond the hints (WAE entity, DXCC number, list of earlier QSOs) are no longer on the log screen.
  The worked-before status is still shown; the full history is in the log list.
- Portrait tablets and narrow windows keep the form-plus-list layout; with the keyboard up they still scroll.
- **Portrait uses a grid** (added 2026-10-03). `QsoEntryLayout.grid` arranges the fields in rows of up to three
  (callsign, band, mode / frequency, RST, RST / name, locator, comment / station, time), the hints beneath, and Clear
  and Log pinned under a scrolling area. It is used whenever the strip is not: portrait and landscape windows narrower
  than 900 dp. The old form-beside-list layout is gone. At 820×1180 to 1024×1366 with a 360 dp keyboard and up to 1.5×
  text, every field and both buttons are visible (test). The contest screen needed no change in portrait; a test
  documents it.
- **Contest mode uses the same strip** (added 2026-10-03). `ContestEntryPanel` takes the same `QsoEntryLayout`. Row 1:
  callsign, the received exchange elements (their number depends on the contest), band, mode, frequency. Row 2: the
  live hints and the sent exchange. Pinned below: the frequency reading and the buttons, so Log never sits inside a
  scrollable. The recent QSOs and the score panel share the space under the strip. Keyboard detection is the shared
  `KeyboardAware` mixin.
- **Tests check real visibility.** Keyboard-fit tests require each control to be hit-testable (inside the visible part of
  any scroll view) with a 430 dp keyboard and the contest banner present; a first version that only compared
  positions let clipped rows pass. At text scales of 1.1 and above the hints scroll below the fields instead of sitting
  beside the buttons, because the time row and two hint lines grow tall.
- **Buttons stay pinned in the fallback** (added 2026-10-03). In the strip, the grid and the contest strip alike, the
  rows and hints scroll when the keyboard leaves too little height, while Clear and Log stay below them and never sit
  inside a scrollable (test, down to a 520 dp keyboard and at 2× text).
