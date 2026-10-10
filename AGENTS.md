# Agent Operating Contract

All coding agents working in this repository MUST start at [`docs/agent/00_ENTRYPOINT.md`](docs/agent/00_ENTRYPOINT.md).

## Prime directives

1. Preserve the product intent recorded in [`SPEC_BASELINE.md`](SPEC_BASELINE.md).
2. Treat this repository's code/tests/schema and living docs as the source of **current implementation reality**.
3. Never hide a mismatch between baseline intent and current reality. Use the Spec Delta Protocol.
4. Before a meaningful change, complete the pre-flight checklist.
5. Before declaring a work unit complete, complete the post-flight checklist.
6. Every authored commit requires a Progress Ledger entry.
7. Update human architecture/flow docs when the human mental model changes, not for cosmetic churn.
8. Product-level intent changes require human approval; do not “fix” the OddlyNiche baseline from this repository.

## Current work

The only authoritative short-horizon task list is [`docs/agent/02_CURRENT_WORK.md`](docs/agent/02_CURRENT_WORK.md). Do not start speculative adjacent work merely because it appears easy.

## Commit and lifecycle discipline

Follow `docs/agent/07_DOCUMENTATION_MAINTENANCE.md`: every authored commit includes its own human-readable Progress Ledger section and matching `Work-ID:` trailer. Record checks honestly, including not-run reasons. Maintain `docs/agent/06_ACCEPTANCE_MATRIX.md` and relevant `docs/operations/` procedures at their lifecycle gates. Existing human authorization remains valid; do not ask again merely to fill a template field.

Specs are external read-only references during application work. Never edit through a local symlink. Verify its checkout against the pinned baseline before relying on it; if different, read the pinned revision.
