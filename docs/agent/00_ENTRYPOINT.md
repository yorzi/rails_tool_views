# AI Implementation Entrypoint

> **Authority:** operational agent instructions for this implementation repository.

## Read first

1. `../../SPEC_BASELINE.md`
2. `../human/00_SYSTEM_AT_A_GLANCE.md`
3. `../human/01_PROJECT_STATUS.md`
4. `01_IMPLEMENTATION_PLAN.md`
5. `02_CURRENT_WORK.md`
6. `05_SPEC_DELTA_PROTOCOL.md`
7. relevant ADRs / feature/runtime docs for the requested task

Before changing behavior, complete `03_PRE_FLIGHT_CHECKLIST.md`.

Before declaring a work unit complete, complete `04_POST_FLIGHT_CHECKLIST.md`.

## Prime directive

Implement the pinned product intent while preserving an honest record of current reality. Never remove ambiguity by silently changing either the baseline or the documentation of reality.

## Authority model

### Desired behavior

Use the pinned OddlyNiche baseline referenced by `SPEC_BASELINE.md`.

### Current behavior

Use observed behavior/tests, current code/schema/config and current living docs.

### Code-level technical decisions

Use ADRs under `../adr/` and current project constraints.

### Framework defaults

Use current framework/tool skills only where they do not conflict with baseline or established application constraints.

## Current executable scope

Only work items checked/declared active in `02_CURRENT_WORK.md` are in immediate scope unless a human explicitly broadens the task.

## Mandatory completion outputs

For a meaningful work unit report:

- implementation summary;
- requirement/issue mapping;
- tests/validation;
- migrations/data impact;
- security/privacy/accessibility impact;
- Spec alignment classification;
- Progress Ledger entry;
- human docs/diagrams updated or explicit `none — reason`;
- unresolved human decision/risk.

## Additional execution contracts

Read `07_DOCUMENTATION_MAINTENANCE.md` for per-commit linkage, document ownership and process cleanup. Use `06_ACCEPTANCE_MATRIX.md` for actual acceptance evidence and `../operations/` before release/operational work. At bootstrap, initialize these documents according to applicable lifecycle gates; a local-only product need not invent a deployment.
