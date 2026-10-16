# Current work

WORK-20261016-01 — owner-requested RailsToolViews rename, related gem update, commit and push (2026-10-16).

- [x] Find original Specs; verify 59 copied files against pinned 0ea28b1; read naming supplement at c100a73.
- [x] Rename package/namespace/entrypoints/install command; preserve old APIs and persisted identifiers.
- [x] Core and optional adapter regression, independent packaged install, real pre-rename persisted-data compatibility, local version matrix.
- [x] Update baseline supplement/delta, ADR 005, acceptance, upgrade guide, operations, evidence and ledger.
- [x] Prepare verified changes and ledger for the authorized main commit.
- [ ] Push this commit to the now-created private `yorzi/rails_tool_views` and verify remote SHA. Owner supplied destination/visibility; origin is configured. Keep private until further development and explicit visibility change.

No RubyGems publication or OddlyDock implementation is included. Existing open audit findings and manual inspection remain in human/01_PROJECT_STATUS.md. Do not start adjacent work.
