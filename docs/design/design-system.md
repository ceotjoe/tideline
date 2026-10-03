# Design system: "Low Tide"

Tideline's visual language is calm and coastal. It uses soft sand and seafoam, generous whitespace and rounded shapes,
and a wave horizon that shows how much is waiting to sync. The direction was chosen in
[ADR 0014](../adr/0014-design-direction-low-tide.md).

**Rule:** widgets never use raw colours, sizes or durations. Everything comes from tokens in `app/lib/src/design/`, read
through `context.colors` and `context.metrics`.

## Colour

Raw palette: `tokens/palette.dart`. Semantic tokens: `tokens/color_tokens.dart` (`TidelineColors`).

| Token | Light | Dark | Sunlight | Night red | Use |
|---|---|---|---|---|---|
| `background` | `#F6F1E7` sand | `#0F1E22` deep sea | `#FFFFFF` | `#000000` | Page |
| `surface` | `#FFFCF6` | `#16292E` | `#FFFFFF` | `#0D0000` | Cards, panes |
| `surfaceVariant` | `#E3F0EC` seafoam tint | `#1E383D` | `#F0F0F0` | `#140000` | Selection, inputs |
| `text` | `#12343B` | `#E8F1EF` | `#000000` | `#FF4433` | Primary text |
| `textSecondary` | `#3E5C61` | `#A9C2C0` | `#1F1F1F` | `#F0301F` | Metadata |
| `primary` / `onPrimary` | `#1F6F68` / white | `#7FD1C3` / `#08302B` | `#003D37` / white | `#FF4433` / black | Actions |
| `outline` | `#6F8A8B` | `#6F8A8B` | black | `#CC2214` | Borders (≥ 3:1) |
| `focus` | `#1A4F8B` | `#8CC4FF` | `#0000B8` | `#FF6655` | Focus ring (≥ 3:1) |
| `tideWater` / `tideLine` | `#9FD3C7` / `#1F6F68` | `#1E383D` / `#7FD1C3` | `#D0E8E2` / black | `#140000` / `#CC2214` | Tide gauge |
| Status: synced, pending, conflict, rejected | green, blue, amber, coral pairs | lighter pairs on dark fills | dark text on white | one red, so they differ by icon and text | Sync chips |

**Contrast is tested, not eyeballed.** `test/design/contrast_test.dart` checks every pair returned by
`TidelineColors.contrastPairs` in every theme:
- text: ≥ 4.5:1;
- UI components: ≥ 3:1;
- sunlight text: ≥ 7:1.

Add any new pair there.

**Status colours.** Status is never shown by colour alone: it always has an icon and text. Night red uses a single hue,
so it is distinguishable only by icon and text, which is intended.

## Type scale (`TidelineType`)

| Style | Size / line height | Use |
|---|---|---|
| display | 34 / 40, w600 | Big numbers (rates, counts) |
| title | 22 / 28, w600 | Screen titles |
| heading | 18 / 24, w600 | Sections |
| body | 16 / 24 | Text |
| label | 14 / 20, w600 | Buttons, chips |
| caption | 13 / 18 | Metadata |
| callsign | 20 / 26, w700, tabular, slashed zero | Callsigns (0 vs O never ambiguous) |

- All sizes scale with the OS text size and are tested at 200%.
- "Extra text spacing" applies the WCAG 1.4.12 maxima: letter 0.12 em, word 0.16 em, line height 1.5×.

## Spacing, density and touch targets (`TidelineMetrics`)

- **Spacing scale:** xs 4, sm 8, md 16, lg 24, xl 40 (dp), multiplied by the density factor.

| Density | Spacing factor | Minimum touch target |
|---|---|---|
| comfortable (default) | 1.0 | 48 dp |
| dense (contest mode) | 0.75 | 48 dp |
| glove | 1.25 | 64 dp |

- **Radii:** sm 8 (chips, inputs), md 14 (buttons), lg 22 (cards, sheets). Rounded shapes are part of the Low Tide identity.

## Motion

- **Durations:** short 150 ms, medium 250 ms, tide 1200 ms.
- **Reduce motion:** always go through `TidelineMetrics.motion(context, duration)`, which returns zero when the user has
  asked for reduced motion.
- **The tide wave** moves only while QSOs are waiting, and never with reduced motion.

## Signature component: the tide gauge

`app/lib/src/widgets/tide_gauge.dart`

- A wave horizon across the top of the content. Its level rises logarithmically with the number of unsynced QSOs, so both
  3 and 300 are visible.
- With nothing pending it is "low tide": a thin line at the bottom.
- The count is **always shown as text** ("12 QSOs waiting to sync"). It is a live region for screen readers, and the
  painting is excluded from semantics.

## Layout

The layout follows window size classes ([ADR 0010](../adr/0010-adaptive-size-classes.md)):

| Size class | Width | Navigation | Log screen |
|---|---|---|---|
| compact | < 600 | Bottom bar, within thumb reach | One column |
| medium | 600–839 | Navigation rail | Form and log side by side |
| expanded | 840–1199 | Navigation rail | Landscape: entry strip over the log; portrait: form and log |
| large | ≥ 1200 | Rail (labels from 1440) | Landscape: entry strip over the log |

In landscape the entry form is a three-row strip across the full width, so every field stays visible above the
on-screen keyboard ([ADR 0020](../adr/0020-landscape-entry-strip.md)). Phones stay in portrait.

## Themes

Four themes are derived from the same tokens:
- **light** and **dark** (following the system by default);
- **sunlight** (maximum contrast), which is also used when the OS "increase contrast" setting is on;
- **night red** (one red hue on black). For best night vision, also lower the screen brightness.

## App icon (planned for Phase 2)

**Requirement:** the icon must be built for Apple's Liquid Glass (iOS/iPadOS 26 and macOS 26 and later), not just
look acceptable there.

- **Layered source, not a flat image.** The artwork is kept as separate vector layers (background, then one to three
  foreground groups) and assembled with Apple's Icon Composer into an `.icon` file. The system renders the glass
  material, highlights, shadows and depth from those layers.
- **No baked-in effects.** No gradients that imitate light, no drop shadows, no highlights and no texture in the
  artwork itself. The system adds them, and baked-in versions conflict with them.
- **Bold, simple foreground.** One clear motif (the Low Tide wave horizon) with solid shapes and thick strokes. Thin
  lines and fine detail disappear under the glass.
- **Every appearance must work:**
  - default (light);
  - dark;
  - clear, which is translucent;
  - tinted, which is monochrome in the user's colour.

  Each foreground layer must therefore read well as a flat silhouette.
- **One shape for all Apple platforms.** On macOS 26 the system applies the same rounded-square mask as on iOS. No
  custom silhouettes: legacy macOS icons get placed inside a grey tile.
- **Older systems:** the app supports iOS 16 and macOS 12, so a flattened fallback for older OS versions must come from
  the same source. Verify how Xcode generates this when the icon is built.
- **Other platforms reuse the layers.** The same layers become the Android adaptive icon (foreground + background) and
  the monochrome themed icon, and are flattened for Windows (MSIX tiles, `.ico`) and Linux.
