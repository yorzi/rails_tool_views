# Current work

WORK-20261016-01 — owner-requested RailsToolViews rename, related gem update, commit and push (2026-10-16).

- [x] Find original Specs; verify 59 copied files against pinned 0ea28b1; read naming supplement at c100a73.
- [x] Rename package/namespace/entrypoints/install command; preserve old APIs and persisted identifiers.
- [x] Core and optional adapter regression, independent packaged install, real pre-rename persisted-data compatibility, local version matrix.
- [x] Update baseline supplement/delta, ADR 005, acceptance, upgrade guide, operations, evidence and ledger.
- [x] Commit implementation on main: 7e73e4e, with WORK-20261016-01 ledger trailer.
- [x] Push implementation to private `yorzi/rails_tool_views`; remote main verified at 7e73e4ec0e13f4a570754ead6ac4b2628074eccb and visibility PRIVATE. WORK-20261016-02 records this delivery evidence. Keep private until the remaining development is completed.
- [x] Previous remote CI for 7e73e4e and 873643d completed successfully, verified on 2026-10-16.

No RubyGems publication or OddlyDock implementation is included. Existing open audit findings and manual inspection remain in human/01_PROJECT_STATUS.md. Do not start adjacent work.

## WORK-20261016-03 — documentation site (submission authorized)

- [x] Create Jekyll/vitepress-theme site in docs/site with four collections, 14 pages plus homepage.
- [x] Add generated RDoc/Markdown API and comments, llms files, search, version-aware builds, and publication-disabled workflow.
- [x] Run tutorial examples from source pages, optional adapter example, full regression, style/build/link checks and browser preview.
- [x] Preserve original Specs/internal records and stop task-owned preview server.
- [x] Owner requested submitting the changes and renaming the local checkout to `rails_tool_views`. Commit/push authorized; documentation deployment remains disabled.
- [ ] Human review of guide content remains distinct from submission authorization.

See docs/README.md and evidence/DOCS_VALIDATION.md for commands and boundaries.

## WORK-20261016-04 — README and demo showcase

- [x] Replace duplicated README reference material with focused guide links.
- [x] Improve demo navigation, responsive layout and workflow guidance.
- [x] Verify tests, docs and browser workflows; record evidence and stop preview.
