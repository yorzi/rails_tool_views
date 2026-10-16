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

## Docs

The documentation site lives in `docs/site/`: Jekyll with the jekyll-vitepress-theme, in four collections (`_getting_started`, `_core_features`, `_advanced`, `_reference`). Preview it with `docs/site/bin/serve.sh` and build it with `docs/site/bin/build.sh`.

- A public API change is not done until its docs page changes in the same commit. Record anything that breaks existing code in `docs/site/_reference/upgrading.md`.
- Write in the Rails guides voice: second person, present tense, short sentences, code first, and the problem before the mechanics. No em dashes, no hype, no "simply".
- Every guide opens with its title, its description, and "After reading this guide, you will know". Explain a concept before summarizing it in a table.
- Start with the shortest working example, then options, then integration and backend-specific notes. Document a shared API once.
- Give each standalone feature a discoverable guide, and feature new ones on the release's What's New page.
- Front-matter `description` is one sentence and feeds llms.txt and link previews. Never use `&`, `<`, or `>` in it.
- Cross-link with `{% link _collection/page.md %}`, never hard-coded URLs. Keep values that change between releases in `_config.yml` and read them as `site.*` variables.
- Never edit generated pages; regenerate them.
- Public methods and classes get doc comments; mark internal code as internal.
