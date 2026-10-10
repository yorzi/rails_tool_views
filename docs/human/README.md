# Human Comprehension Layer

This directory explains **what the application is now**, not merely what the original product Spec intended.

Recommended reading order:

1. `00_SYSTEM_AT_A_GLANCE.md`
2. `01_PROJECT_STATUS.md`
3. `02_FEATURE_MAP.md`
4. `03_SYSTEM_ARCHITECTURE.md`
5. `04_RUNTIME_FLOWS.md`
6. recent entries in `05_PROGRESS_LEDGER.md`
7. `06_HUMAN_CHANGELOG.md`
8. `07_GLOSSARY.md`

## Rules

- Prefer stable concepts and boundaries over class-by-class narration.
- Distinguish `IMPLEMENTED`, `PARTIAL`, `PLANNED`, `DEPRECATED`, `REMOVED`.
- Use diagrams when they reduce mental reconstruction cost.
- Explain current reality; link to Specs for original intent.
- Do not copy the whole AI contract into human prose.
- Internal refactors with no human mental-model impact do not require architecture/flow rewrites, but still receive a compact Progress Ledger entry.

## Evidence and operations

For verification details use [Acceptance Matrix](../agent/06_ACCEPTANCE_MATRIX.md); for running, releasing and recovering use [Operations](../operations/README.md). Daily review starts with the most recent WORK section; use its `Work-ID:` trailer to find the exact commit.
