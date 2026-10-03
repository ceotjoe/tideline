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
- **Room for the keyboard.** While the keyboard is up in landscape the app bar is hidden (the tide gauge stays). The
  strip is capped at the body height minus 96 dp; if it still does not fit (Split View, very large text) it scrolls and
  the list keeps a minimum height. Keyboard state comes from the view's insets, because the scaffolds above consume
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
- The contest screen has the same keyboard problem and is a follow-up.
