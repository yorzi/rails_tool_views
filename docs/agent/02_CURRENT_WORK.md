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

## WORK-20261017-01 — fixes from the OddlyDock integration

Owner authorized fixing gem issues found while integrating OddlyDock in dev mode (2026-10-17).

- [x] No-Turbo HTML action redirect works under any mount name; regression checked in the packaged fresh-host smoke (fails before the fix with 500).
- [x] Surface accessible name translatable per render under `tool_views.components.<key>`; rendering test added.
- [x] Guides: renderers and parent-controller filters call host routes through `main_app`; translation scopes updated.

Delivery: pushed to private `yorzi/rails_tool_views` main so OddlyDock's lock can pin the fix (owner's dev-mode instruction); the remote SHA is the evidence. No gem release.

## WORK-20261017-02 — review and audit fixes

Andy asked in this session for a review and audit of the whole project and for real problems to be fixed (2026-10-17). Base `a1a9b26`.

- [x] Reproduce the MySQL/InnoDB index-length failure and fix it by bounding identifier columns to 150 bytes; add an index-width regression test.
- [x] Stop a non-binary database collation from resolving another actor, tenant, correlation or idempotency key; confirm every identity lookup byte for byte.
- [x] Cap stored identifiers in `Data.identifier` while keeping the 255-byte cap for descriptions and versions.
- [x] Docs: production and upgrading notes, CHANGELOG, whats-new; refresh the stale findings in human/01_PROJECT_STATUS.md.
- [x] Verify on SQLite and PostgreSQL 17.11, adapter suite, packaged install, docs examples, docs site build and style checks.

Delivery: committed on main; not pushed. Full evidence and boundaries in [AUDIT_V2_VALIDATION.md](../evidence/AUDIT_V2_VALIDATION.md). MySQL itself stays NOT_RUN. One recommendation (a distinct `action.replayed` event) is left for an owner decision because it changes the notification catalog.

## WORK-20261018-01 — single public identity

Andy kept the gem name and chose "Full single identity" in this session (2026-10-18). Base `33b1dca`.

- [x] Remove the `ToolViews` constant, legacy entrypoints, `tool_views:install`, `tool_views_*` helpers and the `:tool_views` route-proxy fallback.
- [x] Rename tables/indexes, I18n, notifications, `Rails.error` source, DOM/CSS/Stimulus identifiers and delivery keys to the `rails_tool_views` prefix; version 0.3.0.pre.v3.
- [x] Rewrite identity tests; add the Stimulus identifier regression test after a real browser failure in OddlyDock.
- [x] Upgrading guide with the host migration; ADR 006, DELTA-004, CHANGELOG, status and evidence.
- [x] Verify Rails 8.1/7.2, Ruby 4.0.2, adapter, packaged install, docs and the upgrade on OddlyDock's development database.

Delivery: committed on main; not pushed. OddlyDock's matching change pins this commit through its local override, so push this repository before OddlyDock's CI resolves the lock.

## WORK-20261018-02 — first public release

Owner requests `0.1.0`, hosted gem guides on GitHub Pages, DNS configuration and the ruby_llm-browser release pattern. This explicitly authorizes the required commit/push/tag/publication; the repository is already public.

- [x] Read release constraints and reference workflow; verify pinned Specs and local baseline.
- [x] Align version, release docs, license, gem metadata and security disclosure.
- [x] Validate core/adapter/matrix, packaged host, clean dependency installation, docs and package boundaries.
- [x] Configure Pages/domain/DNS and RubyGems Trusted Publisher.
- [x] Commit with ledger, push, verify exact-candidate remote checks, then tag/release.
- [x] Verify RubyGems artifact, GitHub Release assets, stable/next docs and HTTPS; record outcome. No preview service started.

Delivery: 0.1.0 is published under `v0.1.0` at `f2d4303`. Release run 39117821018 and post-release Pages run 39118079958 succeeded. Registry/release gem checksums agree; stable/next, search, API, llms and enforced HTTPS verified. WORK-20261018-03 fixes the initial candidate's missing checksum; WORK-20261018-04 records actual delivery. See `../evidence/RELEASE_0_1_0.md`. No speculative adjacent work is active.
