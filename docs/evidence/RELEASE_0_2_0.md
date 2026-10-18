# 0.2.0 release evidence

2026-10-18. Andy explicitly authorizes pushing the local candidate, checking remote CI, then publishing 0.2.0. Preparation WORK-20261018-10, actual delivery WORK-11. The 0.1.0 tag stays immutable.

## Local preparation

Implementation base aefc53d contains the four accepted development commits. Full local evidence is in [V0_2_VALIDATION](V0_2_VALIDATION.md): three Ruby/Rails combinations and PostgreSQL 97/837, adapter 7/45, Chrome 4/28, isolated installed host, seven unique dependency locks and activated-gem audits. These are local results, not candidate remote CI.

Release-only edits date CHANGELOG and history, set released true, archive What's New 0.1 at its existing URL, expose What's New 0.2, and replace Upgrading with the 0.1→0.2 instructions. Older identity migration instructions remain at immutable v0.1.0. No runtime/schema/dependency change.

New package/full host/actual generated Minitest 1/2, official release metadata gate (31 files) and documentation examples pass. Docs impact's ApplicationController removal warning is a false positive: core still defaults to ::ApplicationController, documented in Configuration. Docs lint: 17 guides, zero errors, one expected pre-tag version warning. Stable v0.1.0 + working next build: 2,301 local links, zero broken; internal records excluded.

Local preparation package SHA-256: `2c395bd4d41cfe3bd01c5e2654b1d25e7f84c5b512a2899ac875ba40460faef2`. Publication rebuilds separately; verify actual registry/Release assets instead of assuming binary identity across jobs.

Repository is PUBLIC, private vulnerability reporting enabled, release environment exists, Pages domain/HTTPS enforced. Existing scoped OIDC publisher remains in use; no security permission or DNS change is needed.

## Remote verification and delivery

Pending exact candidate push/CI, annotated tag, OIDC upload and hosted checks. Do not infer publication from the local version or dated source files. WORK-11 replaces this pending section with observed outcomes and run URLs.

## Limits and cleanup

No live provider or external customer contact, MySQL qualification, independent security review, external setup/adoption trials or formal H2/C/R closure. No temporary local service started for release preparation; previous development services were cleaned up. Runtime code remains frozen unless actual remote feedback requires a repair.
