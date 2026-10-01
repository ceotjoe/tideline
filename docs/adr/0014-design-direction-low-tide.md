# 0014. Design direction: "Low Tide"

- Status: accepted
- Date: 2026-10-01

## Context
Three directions were proposed in Phase 0:
- **A, "Tide Chart":** nautical chart style.
- **B, "Harbour Signal":** bold, maximum contrast.
- **C, "Low Tide":** soft and minimal.

The maintainer chose **C**.

## Decision
- **Low Tide:** soft seafoam and sand tones, generous whitespace, rounded shapes, and a **wave horizon** tide gauge
  across the top that drops as the sync queue empties. The gauge is always paired with a count and text.
- **Contest mode** uses a *dense* density token set from the same palette. That density is needed for contest operating,
  and it addresses the known weakness of this direction.
- **Sunlight and night-red themes** are derived from the same tokens. Contrast is enforced by tests, so the soft look
  never drops below WCAG AA.

## Consequences
- Soft tints are used for surfaces and decoration only. Text and icons always use token pairs that pass contrast tests.
