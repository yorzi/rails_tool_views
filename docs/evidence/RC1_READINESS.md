# 1.0.0.rc1 readiness — local candidate

2026-10-21. Owner-requested audit and RC preparation (WORK-20261021-01..07), then the owner-approved lifecycle decisions D1..D3 (WORK-20261021-08..12, ADR 010, DELTA-007). Local commits only: nothing is pushed, tagged or published, and no provider, contact or adoption trial took place. LOCAL results are not remote CI, provider, user or business evidence.

## Verdict

The code, package, docs and release tooling are ready to become `1.0.0.rc1`, and the three lifecycle gaps found in the audit are closed. The ROADMAP requires every 1.0 condition to be evidenced before rc1. Conditions 1, 2 (local engineering), 3 (local) and 4 are met; conditions 5 and 6 are not, and condition 2's separate host is an engineering host, not an external adopter. Publishing rc1 therefore needs either that evidence or an explicit owner exception recorded in SPEC_BASELINE, plus separate authorization for push, exact remote CI, tag and OIDC publication.

## Audit fixes

Every fix landed with a test that failed first.

| Work-ID | Defect | Fix |
| --- | --- | --- |
| 01 | Stimulus controller focused the status of every saved Surface on page load, against the feedback guide | Focus only after a rendered Turbo replacement or on an error |
| 02 | Invalid schema `pattern`, malformed action definitions and non-array `expose_to` raised raw Ruby errors | `INVALID_SCHEMA`, `INVALID_ACTION`, `INVALID_COMPONENT` |
| 03 | Invalid-UTF-8 identifiers raised `ArgumentError`; String subclasses survived normalization; request digests re-applied payload limits to their envelope; the correlation race path skipped `presentation.rejected`; discovery policies got a mutable `Access` | Stable codes and UTF-8 identifiers, plain Strings, limit-free digests of bounded values (digest bytes pinned and unchanged), wrapped rejection event, frozen `Access` |
| 04 | Engine page inline style had no CSP nonce | `tag.style nonce: content_security_policy_nonce` |
| 05 | An rc tag would have become GitHub's Latest release | `Gem::Version#prerelease?` selects `--prerelease --latest=false` |
| 09 (D3) | `deliver` without an adapter marked committed follow-up `skipped` forever | `AGENT_NOT_CONFIGURED` (503); the interaction is unchanged |
| 10 (D1) | Protected oldest views filled every `purge_closed` batch | Keyset cursor: `after:` and `next_after`, narrowing only |
| 11 (D2) | `delivery_uncertain` could never be resolved, so the view could never close or be cleaned up | Host-attested `reconcile_delivery`, default-deny `reconciliation_policy`, lease guard, fence kept, `agent_reconciled` |

The mount must still be named `:rails_tool_views`; that is documented intent and stays. Uncertainty still never clears on age or status: only an attestation does, and a fresh lease is never overridden.

## 1.0 conditions

| # | Condition | Status | Evidence / gap |
| --- | --- | --- | --- |
| 1 | Declared public contract | MET, owner review pending | `docs/site/_reference/public-contract.md`: Ruby API, codes and statuses, helpers, HTTP fields, DOM/Stimulus, events, delivery keys, persisted data, internal and experimental parts |
| 2 | Complete host workflows | MET locally (engineering host) | Installed-gem host exercises Partial and ViewComponent renderers, JSON/Turbo/HTML, replay, conflict, denial, validation, restore, delivery retry, missing adapter, takeover reconciliation, close and paged cleanup, and the generated scaffold. The empty-GEM_HOME install has no ViewComponent and runs the Partial path. Lifecycle and retention semantics are settled by ADR 010. An external adopter's host is condition 5 |
| 3 | Supported matrix and upgrades | LOCAL_PASS, remote NOT_RUN | Below. Data saved by real 0.1.0, 0.2.0, 0.3.0 and 0.4.0 runtimes upgrades with replay, correlation, quarantine, rollback, purge and business records intact, and its protected histories reconcile and clean up. MySQL is excluded from the supported matrix |
| 4 | Bounded adapter claims | MET | No provider call was authorized, so the RubyLLM adapter is labeled experimental, as the ROADMAP prescribes; the core is provider-free |
| 5 | External usability evidence | NOT_STARTED | Three external setup trials, the measured bespoke-Rails comparison and a non-dummy host in recurring use for at least two weeks all need the owner and contact authorization |
| 6 | Review and distribution | PARTIAL | Advisories clean (below); MIT and private reporting unchanged. This audit is AI-assisted, not an independent security review. Formal baseline gates need the owner's disposition. Candidate remote CI, registry checksums and hosted HTTPS are NOT_RUN |

## Local matrix on the candidate

Final runtime as committed in WORK-20261021-12 (version `1.0.0.rc1`, docs `released: false`). The first matrix for WORK-07 had the same shape at 134 tests; this one includes D1..D3.

| Check | Result |
| --- | --- |
| Ruby 3.3.5 / Rails 8.1.4 / SQLite | 144 / 1254, eager load PASS |
| Ruby 3.3.5 / Rails 7.2 / SQLite | 144 / 1254, eager load PASS |
| Ruby 4.0.2 / Rails 8.1.4 / SQLite | 144 / 1254, eager load PASS |
| PostgreSQL 17.11, unique temporary database | 148 / 1274, eager load PASS, including a real reconcile-versus-reclaim race; database dropped |
| RubyLLM 2.1.0 adapter and adapter docs examples | 7 / 45 PASS |
| Chrome, Turbo and JavaScript disabled | 9 / 81 PASS, screenshots under ignored `tmp/browser/` |
| Installed-gem host, both renderers, generated scaffold | PASS |
| Upgrade from real 0.1.0, 0.2.0, 0.3.0, 0.4.0 runtimes | PASS; 2, 2, 1 and 1 protected histories reconciled and cleaned up |
| Empty GEM_HOME install, full host (Partial), activated-dependency audit | PASS at advisory commit 5fd86bbd |
| `bundle-audit` on all seven lockfiles | No vulnerabilities found (WORK-07; no dependency changed since) |
| Candidate package gate | 35 files, metadata aligned; local build SHA-256 461b03a9595eac9cb11d969d56a21aa3ffb072612044a0482af81509dba4b2b3, not a release checksum |
| Formal release gate | Correctly refuses: "Docs are not marked released" |
| Docs build and checks | stable 0.4 at `/`, candidate at `/next/`, 3261 local links, anchors present, internal records excluded; 24 guides, 0 errors, 2 expected pre-tag warnings |
| rc tag docs rule | Scratch clone with local `v1.0.0.rc1` built stable 0.4.0; no tag in this repository |

Mutation checks: removing the lease guard, the policy call, the idempotent no-op or the uncertainty clear each fails the reconciliation tests; removing reconciliation's row locks fails the PostgreSQL race test. The lifecycle guide's reconciliation job was executed verbatim with stand-in host models.

The first Ruby 4 attempt in WORK-07 failed in the harness (`rvm use 4.0.2` is not a valid name); later runs use `rvm ruby-4.0.2 do` and confirm `RUBY_VERSION` 4.0.2. During WORK-01 the JavaScript-disabled lifecycle browser test hit a Selenium stale-node error 3 of 12 times under machine load; page JavaScript provably does not run under that driver, and 12 interleaved runs of old and new code all passed. It is a pre-existing timing flake, not fixed here.

## Resolved decisions

D1 (purge batches), D2 (uncertain delivery) and D3 (missing adapter) are resolved by the owner's instruction of 2026-10-21; see ADR 010 for the design and alternatives, DELTA-007 for the contract supplement and the Upgrading guide for host steps.

## Owner decisions before rc1

**Decided 2026-10-26.** The owner chose to publish 1.0.0 directly, skipping rc1, with conditions 5 and 6's independent review and formal disposition waived as an explicit exception (SPEC_BASELINE, DELTA-008). D4 is an exception, not evidence; D5 is authorized for 1.0.0. The decisions as originally posed:


- **D4 Conditions 5 and 6.** Supply external setup trials, the bespoke comparison and two weeks of non-dummy use, an independent security review and the formal-gate disposition, or record an explicit exception for rc1.
- **D5 Publication.** Push, exact remote CI, `v1.0.0.rc1` tag and OIDC publication each need separate authorization.

## Cleanup

All task-created browsers, drivers, Puma servers and the temporary PostgreSQL database stopped or were removed and verified absent. The pre-existing PostgreSQL service was left running. Scratch clones and sites were deleted.
