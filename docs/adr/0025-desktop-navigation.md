# 0025. Desktop navigation on macOS, Windows and Linux

- Status: accepted
- Date: 2026-10-04

## Context
- On macOS and Windows the app looked like its phone version: a bottom bar in a narrow window, no menu bar, no way
  back but a touch-style back arrow. The maintainer asked for the navigation that desktop software usually has, not the
  mobile look (v0.4 step 6.4).
- [ADR 0010](0010-adaptive-size-classes.md) says layouts follow the window size, never the device. A menu bar and a
  sidebar are not a layout of the screens; they are the input environment (pointer, keyboard, windows), which the
  ADR allows to differ ("platform only affects input affordances such as hover and shortcuts").
- [ADR 0011](0011-command-registry.md): every user-facing command goes through the command registry.

## Decision
- **"Desktop" is the operating system** (`TargetPlatform` macOS, Windows, Linux), decided in one place
  (`isDesktopPlatform`). Touch platforms are unchanged. A tablet in a big window is still a tablet: no menu bar.
- **A sidebar, never a bottom bar.** Desktop windows always use the navigation rail, also at a phone-like width. The
  rail shows labels beside the icons (sidebar) from 1100 dp on desktop, 1440 dp elsewhere (tablets in landscape need
  the room). Screens still adapt to the width they are left, as before.
- **A menu bar from the registry.** Menus *Go* (log, callsigns, sync, settings, go back), *Operate* (sync now, contest mode, start
  an activation) and *Help* (keyboard shortcuts). Labels and the shortcut shown come from the registry, so menus,
  shortcuts, the overlay and the manual cannot disagree; an item whose command has no handler on the current screen is
  disabled.
  - macOS: the system menu bar (`PlatformMenuBar`) with the app menu (About, Settings ⌘,, Hide, Quit) and the
    standard Window menu.
  - Windows and Linux: a flat `MenuBar` strip at the top of the window. The shortcut is shown, not registered (the
    app's own shortcut map handles the key, so it never runs twice).
- **Go back.** A command `nav.back` with `Esc`, `Alt+←` and `Ctrl/⌘+[`. It takes you one level up the path
  (`/settings/account/x` → `/settings/account`) and exists only on such a page; on a tab's top level it is disabled and
  the key passes through. `Esc` is also "clear entry" on the log screen and "wipe" in contest mode, so a command can now
  be a **fallback** (`TidelineCommand.fallback`): it runs only when no other command on the same chord has a handler,
  and the conflict check does not count it.
- **Context menu.** A right click on a log row offers *Open QSO* and *Copy callsign*.
- **Keyboard and focus** were already complete (every command has a shortcut, focus is visible); nothing changes.

## Consequences
- With a narrow desktop window the content has the width minus an 80 dp rail. There is no minimum window size yet
  (it needs native code on each OS); the layouts already work down to a phone's width.
- The settings hub is still a list on wide windows. A two-pane settings view (list left, page right) is the next
  desktop refinement; it needs the pages as children of one route and is left for later.
- Commands that live inside a screen (log, contest) are not in the menu: their handlers belong to that screen. They
  stay on their keys and in the overlay.
- Not verified on real hardware: the macOS system menu and the Windows menu strip are covered by widget tests and
  goldens only.
