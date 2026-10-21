# 1.0.0.rc1 readiness — local candidate

2026-10-21. Owner-requested audit and RC preparation (WORK-20261021-01..07). Local commits only: nothing is pushed, tagged or published, and no provider, contact or adoption trial took place. LOCAL results are not remote CI, provider, user or business evidence.

## Verdict

The code, package, docs and release tooling are ready to become `1.0.0.rc1`. The ROADMAP requires every 1.0 condition to be evidenced before rc1. Conditions 1, 3 (local) and 4 are met; conditions 2, 5 and 6 are not. Publishing rc1 therefore needs either that evidence or an explicit owner exception recorded in SPEC_BASELINE, plus separate authorization for push, exact remote CI, tag and OIDC publication.

## Audit fixes

Every fix landed with a test that failed first.

| Work-ID | Defect | Fix |
| --- | --- | --- |
| 01 | Stimulus controller focused the status of every saved Surface on page load, against the feedback guide | Focus only after a rendered Turbo replacement or on an error |
| 02 | Invalid schema `pattern`, malformed action definitions and non-array `expose_to` raised raw Ruby errors | `INVALID_SCHEMA`, `INVALID_ACTION`, `INVALID_COMPONENT` |
| 03 | Invalid-UTF-8 identifiers raised `ArgumentError`; String subclasses survived normalization; request digests re-applied payload limits to their envelope; the correlation race path skipped `presentation.rejected`; discovery policies got a mutable `Access` | Stable codes and UTF-8 identifiers, plain Strings, limit-free digests of bounded values (digest bytes pinned and unchanged), wrapped rejection event, frozen `Access` |
| 04 | Engine page inline style had no CSP nonce | `tag.style nonce: content_security_policy_nonce` |
| 05 | An rc tag would have become GitHub's Latest release | `Gem::Version#prerelease?` selects `--prerelease --latest=false` |

Reviewed and kept, because each is documented intent: delivery uncertainty has no force clear; protected rows can fill a purge batch; a worker without an adapter marks pending work `skipped`; the mount must be named `:rails_tool_views`. They are owner decisions below.

## 1.0 conditions

| # | Condition | Status | Evidence / gap |
| --- | --- | --- | --- |
| 1 | Declared public contract | MET, owner review pending | `docs/site/_reference/public-contract.md`: Ruby API, codes and statuses, helpers, HTTP fields, DOM/Stimulus, events, delivery keys, persisted data, internal and experimental parts |
| 2 | Complete host workflows | PARTIAL | Installed-gem host (Partial, JSON/Turbo/HTML, replay, conflict, denial, validation, restore, delivery retry, lifecycle/purge, generated scaffold) PASS locally and in an empty GEM_HOME. ViewComponent runs only in the dummy host. Two lifecycle semantics are open decisions (D1, D2) |
| 3 | Supported matrix and upgrades | LOCAL_PASS, remote NOT_RUN | Below. Data saved by real 0.1.0, 0.2.0, 0.3.0 and 0.4.0 runtimes upgrades with replay, correlation, quarantine, rollback, purge and business records intact. MySQL is excluded from the supported matrix |
| 4 | Bounded adapter claims | MET | No provider call was authorized, so the RubyLLM adapter is labeled experimental, as the ROADMAP prescribes; the core is provider-free |
| 5 | External usability evidence | NOT_STARTED | Three external setup trials, the measured bespoke-Rails comparison and a non-dummy host in recurring use for at least two weeks all need the owner and contact authorization |
| 6 | Review and distribution | PARTIAL | Advisories clean (below); MIT and private reporting unchanged. This audit is AI-assisted, not an independent security review. Formal baseline gates need the owner's disposition. Candidate remote CI, registry checksums and hosted HTTPS are NOT_RUN |

## Local matrix on the candidate

Runtime and package as committed in WORK-20261021-07 (version `1.0.0.rc1`, docs `released: false`).

| Check | Result |
| --- | --- |
| Ruby 3.3.5 / Rails 8.1.4 / SQLite | 134 / 1162, eager load PASS |
| Ruby 3.3.5 / Rails 7.2 / SQLite | 134 / 1162, eager load PASS |
| Ruby 4.0.2 / Rails 8.1.4 / SQLite | 134 / 1162, eager load PASS |
| PostgreSQL 17.11, unique temporary database | 137 / 1178, eager load PASS; database dropped |
| RubyLLM 2.1.0 adapter and adapter docs examples | 7 / 45 PASS |
| Chrome, Turbo and JavaScript disabled | 9 / 81 PASS, screenshots under ignored `tmp/browser/` |
| Installed-gem host, generated scaffold | PASS |
| Upgrade from real 0.1.0, 0.2.0, 0.3.0, 0.4.0 runtimes | PASS |
| Empty GEM_HOME install, full host, activated-dependency audit | PASS at advisory commit 5fd86bbd |
| `bundle-audit` on all seven lockfiles | No vulnerabilities found |
| Candidate package gate | 35 files, metadata aligned; SHA-256 9bba50bd3a38136ef351fecfc1ba0a1526aa42e257278b53918a6c738b802ed8 (local build, not a release checksum) |
| Formal release gate | Correctly refuses: "Docs are not marked released" |
| Docs build and checks | stable 0.4 at `/`, candidate at `/next/`, 3254 local links, internal records excluded; 24 guides, 0 errors, 2 expected pre-tag warnings |
| rc tag docs rule | Scratch clone with local `v1.0.0.rc1` built stable 0.4.0; no tag in this repository |

The first Ruby 4 attempt failed in the harness (`rvm use 4.0.2` is not a valid name); rerun with `rvm ruby-4.0.2 do` and confirmed `RUBY_VERSION` 4.0.2. During WORK-01 the JavaScript-disabled lifecycle browser test hit a Selenium stale-node error 3 of 12 times under machine load; page JavaScript provably does not run under that driver, and 12 interleaved runs of old and new code all passed. It is a pre-existing timing flake, not fixed here.

## Owner decisions before rc1

- **D1 Purge batches.** Protected rows sort first and can fill every batch, so newer eligible views are never reached. An additive cursor can come in a 1.x minor; decide whether 1.0 ships without it.
- **D2 Uncertain delivery.** A Surface with `delivery_uncertain` can never close or be purged, and there is no supported reconciliation API. Decide whether 1.0 needs an authorized resolution path.
- **D3 Missing adapter.** `deliver` without an adapter marks pending work `skipped` permanently, so a worker started without adapter configuration silently drops follow-up. Decide whether to keep this documented behavior.
- **D4 Conditions 2, 5, 6.** Supply the evidence, or record an explicit exception for rc1.
- **D5 Publication.** Push, exact remote CI, `v1.0.0.rc1` tag and OIDC publication each need separate authorization.

## Cleanup

All task-created browsers, drivers, Puma servers and the temporary PostgreSQL database stopped or were removed and verified absent. The pre-existing PostgreSQL service was left running. Scratch clones and sites were deleted.
