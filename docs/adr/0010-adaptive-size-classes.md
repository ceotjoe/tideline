# 0010. Adaptive layouts by window size class

- Status: accepted
- Date: 2026-10-01

## Context
- Flutter has no official window-size-class API, and `flutter_adaptive_scaffold` is discontinued (verified 2026-10).
- iPadOS 26 ignores `UIRequiresFullScreen`, so apps must handle any window size: Split View, Slide Over and Stage Manager.

## Decision
- A small in-house `SizeClass`, using Material 3 breakpoints on the current window width from `MediaQuery.sizeOf`:

  | Class | Width (dp) |
  |---|---|
  | compact | < 600 |
  | medium | 600–839 |
  | expanded | 840–1199 |
  | large | ≥ 1200 |

- Layouts never branch on the device type or platform. Platform only affects input affordances such as hover and
  shortcuts.
- Form state lives outside widgets (notifiers), so a layout change never loses input.
- **Panes follow the available width, not only the class.** Within a screen, the number of columns comes from the
  width its body really has (after the navigation rail), with a minimum width per pane. The navigation rail shows its
  labels beside the icons only from 1440 dp. (Added 2026-10-02: at 1210 dp, an iPad Pro 11" in landscape, the `large`
  class with a wide rail and fixed columns left the log list ~130 dp, and the log body failed to lay out.)
- **Landscape logging uses a full-width entry strip** instead of columns, so the fields fit above the keyboard
  ([ADR 0020](0020-landscape-entry-strip.md)). (Added 2026-10-03.)

## Consequences
- Foldables, resizable windows and desktop work automatically.
- Golden tests cover compact (phone), medium (tablet portrait) and expanded (tablet landscape), plus 1210 × 834 (just
  past the `large` breakpoint). A layout test renders the log screen at widths from 840 to 1600 dp.
