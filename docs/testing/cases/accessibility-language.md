# Accessibility and language (AL)

Target: WCAG 2.2 AA. Automated tests check contrast and guideline matchers; these cases are what only a person with the
real tool can judge.

### AL-01 VoiceOver (iPhone and iPad)
**P1 · iOS, iPadOS, macOS · Needs: VoiceOver**
Without looking: set up the demo account, log a QSO, correct it, sync, open the sync screen, change a setting.

**Expected:** every control has a sensible label and the focus order follows the reading order; callsigns are read letter
by letter in the field, the list and the contest list; after **Log QSO** "Logged" and the callsign are announced; the
tide gauge, sync states, banners and errors are spoken as text; dialogs (including the date and time dialog) can be read,
operated and closed.

Result:

### AL-02 TalkBack (Android)
**P1 · Android phone and tablet · Needs: TalkBack**
Same task as AL-01, plus explore by touch on a tablet in landscape.

**Expected:** the same as AL-01; nothing is skipped or read twice; Switch Access or a Bluetooth keyboard reaches every
control.

Result:

### AL-03 Narrator or NVDA (Windows) and VoiceOver on Mac
**P2 · macOS, Windows · Needs: the screen reader**
Same task as AL-01 on the computer, with the keyboard only.

**Expected:** the same as AL-01. Note which screen reader and version.

Result:

### AL-04 Contest and activation by screen reader
**P1 · iOS and Android · Needs: screen reader, a session**
Run a short contest session and a short activation without seeing the screen.

**Expected:** the exchange fields, the serial, dupe warnings, score, the activation progress and the end dialog are all
available as text and operable.

Result:

### AL-05 Keyboard only
**P1 · macOS, Windows, iPad with keyboard, Android tablet with keyboard · Needs: a hardware keyboard**
Put the mouse away. Do AL-01's task, then a contest QSO.

**Expected:** Tab and Shift+Tab reach every control in reading order with a visible focus; Enter logs, Esc clears or goes
back; **Ctrl/⌘+/** or F1 shows an overlay that matches the menu bar and the manual's table; dialogs trap focus and return
it; shortcuts work on a German keyboard layout; every dialog closes with Esc.

Result:

### AL-06 200 % text
**P1 · phone, tablet portrait, tablet landscape, small desktop window · Needs: nothing**
Set the OS text size to the largest and Tideline's text size to 200 %. Visit onboarding, log, sync, contest, activation,
callsigns, settings and every dialog, in both languages.

**Expected:** no cut-off, overlapping or unreachable text; entered data survives a rotation; touch targets stay at least
48 × 48 dp, larger in glove mode.

Result:

### AL-07 Themes, contrast, motion
**P2 · all · Needs: a bright place and a dark room**
Light, dark, sunlight (outdoors), night red (dark room), follow-the-system; Windows contrast themes; macOS Increase
contrast; **Reduce motion** on.

**Expected:** all text and controls readable; status is never colour alone (icon plus text); animations stop with reduce
motion; the tide gauge always has its text equivalent; the easy-to-read font works.

Result:

### AL-08 Language switch
**P1 · all · Needs: nothing**
Settings → Appearance and language: choose Deutsch while the system is English, and the other way round, then the system
default. Walk through onboarding, log, sync, contest, activation, callsigns and settings.

**Expected:** every string is in the chosen language and changes at once; nothing is half English; the choice is
independent of the system language and survives a restart.

Result:

### AL-09 German quality
**P1 · one platform, by a German speaker · Needs: nothing**
At the largest text size, read buttons, banners, dialogs, errors (token problem, duplicate, needs decision, rate limit,
update from Wavelog) and the gauge text.

**Expected:** German reads naturally and is not a literal translation; no word is cut off; times are marked UTC;
callsigns are still read letter by letter by the German voice. Wording problems are listed with the string key.

Result:

### AL-10 Right to left
**P3 · debug build · Needs: the pseudo-locale**
Run with the pseudo-locale (right to left).

**Expected:** the field order mirrors and nothing overlaps. This is a development check, not a release language.

Result:
