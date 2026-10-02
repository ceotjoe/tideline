# Accessibility guidelines

Tideline targets **WCAG 2.2 AA** as a minimum. Accessibility is part of the Definition of Done, not a polish step.

## Checklist for every screen

- [ ] **Text and labels:** every interactive element has a meaningful label. Icon-only buttons have a `tooltip`, which is
      also their semantics label.
- [ ] **Touch targets:** at least 48 × 48 dp (64 in glove mode). Use the theme's buttons; don't shrink them.
- [ ] **Colour:** never the only cue. Status uses an icon plus text.
- [ ] **Contrast:** colours come only from tokens. New pairs are added to `contrastPairs`, and the test enforces them.
- [ ] **Text size:** works at 200% text scale with no clipping or overflow. Covered by a test per screen.
- [ ] **Headings:** section titles are marked `Semantics(header: true)`.
- [ ] **Live updates:** dynamic status (sync count, dupe warnings, "QSO logged") is announced, via a live region or
      `SemanticsService.sendAnnouncement`.
- [ ] **Keyboard:** everything reachable with Tab, focus is visible (theme focus ring), and commands have shortcuts in
      the command registry.
- [ ] **Motion:** respects reduce motion (`TidelineMetrics.motion`). No information is conveyed only by animation.
- [ ] **RTL:** the layout mirrors correctly. Use `EdgeInsetsDirectional` and `AlignmentDirectional`.
- [ ] **Tests:** the widget test runs `meetsGuideline` for `androidTapTargetGuideline`, `iOSTapTargetGuideline`,
      `labeledTapTargetGuideline` and `textContrastGuideline`.

## Callsigns and screen readers

- Callsigns must be read letter by letter, for example "D O 1 H O Z", not as a word. Use `CallsignText`
  (`app/lib/src/widgets/callsign_text.dart`) wherever a callsign is shown.
- iOS and macOS: `SpellOutStringAttribute` in an `AttributedString` semantics label.
- Other platforms: a label with the characters separated by spaces. A widget test checks it.
- **Still to verify by hand:** VoiceOver and TalkBack on real devices (simulators don't speak).

## Plain language

- Errors say what happened, what it means for the user's QSOs, and what to do next.
- Ham terms the community expects (QSO, RST, grid, DXCC) are fine. Other jargon is not.

## Platform notes

- **iPad Scribble (Apple Pencil):** enabled (the default `stylusHandwritingEnabled: true`) on every text field.
  - The callsign field upper-cases input itself, so the known first-letter capitalisation issue (#104315) has no effect.
  - **Not yet verified:** the iOS Simulator cannot simulate Pencil handwriting, so Scribble needs a check on a real iPad
    with an Apple Pencil. Results go here.
- **iPadOS keyboard shortcut overlay (hold ⌘):** not supported by Flutter. Tideline's own overlay (Ctrl/⌘ + / or F1) lists
  every shortcut.
