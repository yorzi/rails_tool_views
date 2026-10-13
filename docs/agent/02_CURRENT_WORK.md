# Current work

Completed: owner-requested review and audit of local v1 with resulting hardening. Work ID: WORK-20261013-01; base commit 3635c54. Andy asked on 2026-10-13 to review and audit the gem, judge its value and make improvements where a better design exists; that request is the scope authorization. Committed locally on main at Andy's request the same day; not pushed.

- [x] Read entrypoint, baseline, plan, deltas, ADR 001/002, acceptance and the pinned contracts; read all gem and reference-host code.
- [x] Reproduce suspected defects with executable probes before changing code.
- [x] Schema walk: reject untyped, empty, open or item-less nested schemas (SEC-10, FR-01-AC-02).
- [x] Scope log redaction to the Engine; stop altering host `filter_parameters` (SEC-12).
- [x] Report renderer and adapter failures instead of swallowing them.
- [x] Host-worded error codes, translatable Engine copy, no demo state key or demo codes in core.
- [x] Zero-argument native form posts, found by driving the real demo over HTTP.
- [x] Order-dependent suite: an existing CSRF test left forgery protection on when it ran first; present at 3635c54.
- [x] Second request, "continue with your best thoughts": action form helpers, Rails submit names, ViewComponent context, `parent_controller` and `delivery_lease`, non-Turbo redirect back, database rollback as CONFLICT.
- [x] PostgreSQL 17.11: full suite, seeds, eager load and the demo over HTTP on a throwaway loopback instance; gemfile and CI job added.
- [x] Regression tests with a revert check per fix; three-combination matrix, adapter suite, packaged install, HTTP and browser pass.
- [x] ADR 003 and 004, README, SECURITY, CHANGELOG, acceptance rows, human docs and ledger section.

Not done, recorded as open findings in ../human/01_PROJECT_STATUS.md: receipt retention, MySQL and its index length, the non-Turbo error page, stale status message, duplicated migration file, a component generator. No push, publication, UC-06..09, live provider or external contact.

Previous unit: WORK-20261010-02, local v1, complete. Andy's manual inspection of v1 is still pending and now includes this unit.

Next: Andy inspects the v1 workflows and ADR 003/004 at his own pace. The most useful new evidence would be one outside Rails developer following the README and timing it. Do not start release work, a push or the open findings without a new request.
