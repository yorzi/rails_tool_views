# Current work

WORK-20261016-01 — owner-requested RailsToolViews rename, related gem update, commit and push (2026-10-16).

- [x] Find original Specs; verify 59 copied files against pinned 0ea28b1; read naming supplement at c100a73.
- [x] Rename package/namespace/entrypoints/install command; preserve old APIs and persisted identifiers.
- [x] Core and optional adapter regression, independent packaged install, real pre-rename persisted-data compatibility, local version matrix.
- [x] Update baseline supplement/delta, ADR 005, acceptance, upgrade guide, operations, evidence and ledger.
- [x] Commit implementation on main: 7e73e4e, with WORK-20261016-01 ledger trailer.
- [x] Push implementation to private `yorzi/rails_tool_views`; remote main verified at 7e73e4ec0e13f4a570754ead6ac4b2628074eccb and visibility PRIVATE. WORK-20261016-02 records this delivery evidence. Keep private until the remaining development is completed.
- [ ] Remote CI: triggered, queued when checked; no remote PASS claimed.

No RubyGems publication or OddlyDock implementation is included. Existing open audit findings and manual inspection remain in human/01_PROJECT_STATUS.md. Do not start adjacent work.
