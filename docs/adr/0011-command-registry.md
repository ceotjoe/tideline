# 0011. Central command registry for actions and shortcuts

- Status: accepted
- Date: 2026-10-01

## Context
- Contest mode and desktop/tablet use need configurable, discoverable keyboard shortcuts.
- Flutter has no iPadOS system shortcut overlay, and `PlatformMenuBar` is macOS-only (verified 2026-10).

## Decision
- Every user command is declared once in a `CommandRegistry`. Each entry has:
  - a stable id;
  - an ARB label key;
  - a scope (global, logging, contest, …);
  - default bindings, which may differ per platform family (Apple uses Meta, others use Control).
- User overrides are stored in `shortcut_bindings` and resolved at runtime.
- The registry generates:
  - the `Shortcuts`/`Actions` maps;
  - the in-app shortcut overlay (opened with `?` or `Ctrl/⌘ + /`);
  - on macOS, the `PlatformMenuBar` entries;
  - the manual's shortcut table, via a tool script.

## Consequences
- One source of truth, so contest mode only adds commands and needs no new infrastructure.
- Conflicting bindings are detected when loading.
