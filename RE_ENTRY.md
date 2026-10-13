# Re-entry

Current milestone: local v1 complete, unpublished, awaiting Andy's manual inspection. An owner-requested audit (WORK-20261013-01, ADR 003/004, docs/evidence/AUDIT_VALIDATION.md) hardened it on 2026-10-13 and was committed locally on main at Andy's request. No remote is configured and nothing is pushed. Read README.md, SPEC_BASELINE.md and docs/human/01_PROJECT_STATUS.md. The exact source reference is copied under docs/specs; it remains REVIEW and was not self-approved. V1 local scope was explicitly authorized after v0 (DELTA-002).

Run `bin/check` for core/eager-load, optional adapter and packaged-host checks. `bin/demo` starts the offline demo on 127.0.0.1:3100 and is stopped with Ctrl-C. Begin at `/v1/customer`, `/v1/support` and `/v1/review`; `/` retains the v0 ChoiceCard. See docs/evidence/V1_VALIDATION.md and docs/agent/08_V1_ACCEPTANCE.md for exact evidence. All task-owned preview servers are stopped.

Next owner action: inspect the API and three workflows, including invalid form input, tenant/role changes and accepted-result locking. Then decide license/name, formal handoff and whether to publish. Remote CI, PostgreSQL, real-provider smoke and external setup trials are release work, not completed evidence. Do not expand to UC-06..09 without new authorization.
