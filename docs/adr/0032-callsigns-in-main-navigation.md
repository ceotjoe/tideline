# 0032. The callsign directory as a main destination

- Status: accepted
- Date: 2026-10-06

## Context
[ADR 0026](0026-callsign-directory-and-notes.md) put the directory page under Settings → Reference data → *Browse
callsigns and notes*. It is something an operator looks at while logging (who is this station, what did I note), not a
setting, and three taps deep it was hard to find. The maintainer asked for its own entry in the main menu.

## Decision
- **A fourth top-level destination, second after Log**: Log, Callsigns, Sync, Settings. Settings stays last. It is a
  branch of the `StatefulShellRoute` at `/callsigns`, so its search and scroll state survive switching tabs, and it
  appears in the bottom bar, the rail, the desktop menu bar (*Go*) and the shortcut overlay.
- **Command `nav.callsigns`** (id never renamed, [ADR 0011](0011-command-registry.md)) with `⌘2` / `Ctrl+2`. Sync moves
  from `⌘2` to `⌘3`. Shortcuts the user has overridden keep their binding; only the defaults change.
- **The old route `/settings/callsigns` is removed**, and so is the *Browse* tile. Nothing outside the app links to the
  route. The Reference data section stays as information: what the directory holds and how many stations it has.
- **The compact rail grows with large text.** At 200 % text "Callsigns" is wider than the other labels, so the rail
  becomes wider and leaves the log's entry form less room. The form's *Clear* and *Log* buttons now share the width they
  have instead of keeping a fixed width, so nothing overflows.

## Consequences
- Four destinations in the phone bottom bar. Labels and touch targets are covered by the shell tests, including 200 %
  text, German and the pseudo-locale.
- Muscle memory for `⌘2` = Sync breaks once; the manual's shortcut table is generated from the registry and is current.
- No new data, network access or permission. The threat model and `PRIVACY.md` are unchanged.
