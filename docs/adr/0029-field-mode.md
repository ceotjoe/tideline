# 0029. Field mode: one switch, battery saver, keep the screen on

- Status: accepted
- Date: 2026-10-05

## Context
- v0.4 proposal C (field modes). Sunlight and night themes, glove mode and reduced motion exist; there was no single
  setting for operating outdoors and no way to keep the screen on while logging.
- The maintainer accepted the recommendation on 2026-10-05: a switch plus separate options, a battery saver, keep the
  screen on with one small plugin, **no GPS button**.

## Decision
- **Four settings, one derived switch.** Theme `sunlight`, density `glove`, `ui.batterySaver` and `ui.keepScreenOn` are
  the stored values. *Field mode* is derived (all four on), so changing one by hand turns the switch off by itself and
  there is no second source of truth. Switching on stores `ui.fieldModeRestore` (`theme|density`) so switching off puts
  the earlier theme and density back, also after a restart; a theme or density that already was the field one is
  replaced by the defaults. A damaged restore value is ignored.
- **Battery saver = less periodic work, nothing else.** The tide wave does not animate (level and text stay), the entry
  form clock fires once a minute just after the minute changes (it shows minutes) instead of every second, the contest
  rates tick every 30 s instead of 5 s. The app has no sync backoff and no background work to lengthen (sync runs on
  foreground, connectivity and request), so sync behaviour is unchanged; the "longer backoff" candidate was dropped
  because there is nothing to change. I have not measured battery on a device and the manual does not claim a number.
- **Keep the screen on** with `wakelock_plus` (^1.8.1), behind `ScreenWake`, which counts the screens that ask (log,
  Fast Log Entry and contest can be open together) and releases on the last one. Only these three screens ask, and only
  when the setting is on; it releases when they leave the tree. A platform without the feature is ignored. Tests use a
  recording fake.
- **No GPS/location button.** It would add a location permission and change PRIVACY.md and the store forms; typing a
  locator is quick. Later, if wanted.
- **The keyboard bar** of ADR 0020 already uses the density's touch target, so glove mode makes it larger.

## Consequences
- New dependency `wakelock_plus` and, through it, `package_info_plus` (reads the app's own version; no network;
  the Android plugin manifest declares no permission, checked in the package source). The
  lockfile pins both. Threat model: version 5 note, no new data or network.
- Existing goldens of the settings hub changed (a new entry).
- Open: battery effect not measured; screen-on on Android/Windows/Linux not tried on real devices.
