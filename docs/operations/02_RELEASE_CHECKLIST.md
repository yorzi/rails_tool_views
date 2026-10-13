# Release gate — OPEN / NOT AUTHORIZED

Candidate: local 0.2.0.pre.v1 on main, 2026-10-11. No public repository or RubyGem publication was performed. Local build authorization does not approve release. Andy's manual inspection follows V1 completion and remains pending.

- [x] Offline core and optional adapter implementation/tests; negative/security coverage.
- [x] Packaged install in fresh Rails host and namespaced migration.
- [x] Local supported-version checks and mobile/keyboard/recovery evidence.
- [x] Contribution/security/install/failure/retention documentation.
- [x] Owner-authorized local UC-02..05 / Demo B/C, validation feedback and host version/recovery examples.
- [ ] Human API/security/spec review and formal H2/C/R/adoption records.
- [ ] Name/namespace and license/dependency attribution clearance.
- [ ] Verified private security disclosure channel and maintenance policy.
- [ ] Remote Linux CI execution against the exact candidate commit.
- [ ] PostgreSQL concurrency verification before broader database support. Local PostgreSQL 17.11 passed the suite, separate-process concurrency and the demo on 2026-10-13; the CI job is configured and NOT_RUN, so this stays open.
- [ ] Configured real-provider presentation/continuation smoke.
- [ ] Complete upstream extraction/runtime comparison SP-09..12; no inferred exploit claims.
- [ ] At least three external setup trials and measured bespoke integration comparator.
- [ ] Explicit owner approval for push/public repository/release.

No gate is auto-approved by green local tests. Do not add CI publication credentials or a release workflow until authorized.
