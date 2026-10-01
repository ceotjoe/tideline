# 0003. State management: Riverpod 3

- Status: accepted
- Date: 2026-10-01

## Context
- We need providers that expose drift streams, are easy to override in tests, and support many independent screens.
- Verified 2026-10: flutter_riverpod 3.4.3 and riverpod_generator 4.0.9 are actively maintained.
- Riverpod 3's offline persistence and Mutations APIs are explicitly marked *experimental*.

## Decision
- Use Riverpod 3 with code generation for notifiers.
- **Do not use** the experimental offline-persistence or mutation APIs. Persistence is drift's job.
- Alternatives considered:
  - bloc: more boilerplate for stream exposure.
  - signals: a smaller ecosystem for testing overrides.

## Consequences
- The DB is the source of truth, and providers stay thin.
- Revisit this decision when the experimental APIs become stable.
