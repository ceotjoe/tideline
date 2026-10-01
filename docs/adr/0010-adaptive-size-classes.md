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

## Consequences
- Foldables, resizable windows and desktop work automatically.
- Golden tests cover compact (phone), medium (tablet portrait) and expanded (tablet landscape).
