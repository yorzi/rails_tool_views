# 0.4.0 local candidate validation

Date: 2026-10-20. Base: `3ed5e39e694043972173d87c9ef981015a053152`.
Runtime candidate: `6d90216`, following WORK-20261020-01..03. WORK-04 records acceptance and documentation only. Owner authorizes development/local commits and explicitly chooses DELTA-006. No push, tag, provider call or publication. Published version remains 0.3.0.

## Delivered boundary

- Fence success/failure acknowledgments using existing monotonic interaction attempts. A stale callback cannot overwrite the newer claim or emit a false terminal outcome. Claims retain Surface-first locking; adapters run outside transactions.
- Refuse delivery inside an outer host transaction with DELIVERY_IN_TRANSACTION before any adapter effect. Host owns after-commit scheduling, pending recovery/outbox, trusted identity and durable delivery-key deduplication.
- Actual host Active Job checks pending delivery after separate boot, failed explicit retry, revoked identity and process exit(73) after domain effect/receipt commit. Expired takeover preserves the same key and one committed effect. Uncertainty remains protected, including after terminal acknowledgment; no force-resolution/cleanup API.
- Keep action.executed and add replayed:boolean. Database rollback/lock conflict now emits the existing action.conflict code-only notification. Handled-error ordinary log lines omit raw message/stack; original exception stays in host-controlled Rails.error.
- Optional Transition.notice is bounded to500bytes, plain/escaped even for SafeBuffer. Surface state/snapshot excludes notice; action receipts retain exact responses. JSON/Turbo display response notice; HTML uses exact Surface/actor/tenant flash once via the helper. Existing persistent state.message stays compatible.
- No new migration, runtime dependency, queue, dashboard or frontend state machine. Drain old web/worker callbacks before switching runtimes.

## Final local checks

| Check | Result |
| --- | --- |
| Ruby3.3.5 / Rails8.1.4 / SQLite |129 tests /1129 assertions, eager load PASS |
| Ruby3.3.5 / Rails7.2.3.2 / SQLite |129 /1129, eager load PASS |
| Ruby4.0.2 / Rails8.1.4 / SQLite |129 /1129, eager load PASS |
| PostgreSQL17.11, unique temporary DB |132 /1145, eager load PASS |
| Optional RubyLLM SDK adapter |7 /45 PASS; no provider request |
| Actual built gem → disposable Rails host |All three combinations PASS; generated Minitest1 /2 each |
| Immutable0.2 and0.3 → working runtime |All three combinations PASS; old receipt/correlation/data,0.3 closed/purged guards, migration/rollback/business preservation |
| Empty GEM_HOME network-resolved installation |PASS; actual host/installer/HTTP/recovery/notice/lifecycle/generated test; activated dependency audit PASS |
| Real Chrome E2E |8 /77 PASS; Turbo and JS-disabled notice→refresh; keyboard/focus/loading/mobile/failed retry; CSRF and lifecycle regressions |
| Executable guides, core and adapter |PASS, including actual notice construction, dispatch/replay, close/preview/apply |
|22-guide lint |Zero errors; two expected unreleased0.4/latest-tag0.3 warnings |
| Stable0.3 and next build |PASS;2897 local links, zero broken; internal records excluded |
| Seven lockfile audits |No known vulnerabilities at refreshed fa2295251efb3b0d1a300e5ce8ad700ff1f1b485,1266 advisories |
| Candidate package gate |PASS,35 reviewed runtime/top-level files |
| Formal release gate |Correctly refuses released:false |

Final isolated-install artifact SHA256: `58fd80ccd37505015fada90c10b561e24167e30b391ada153eaef60a162ce86a`. The isolated runner copied this exact artifact before resolving network dependencies; source package hash stayed equal afterward. No cross-job binary reproducibility or remote publication is claimed. Tests/docs beyond the packaged file set remain in this repository.

## Failure-first checks and corrections

1. Four recovery regressions first reproduced old success/failure overwriting a newer attempt, late failure undoing completion and delivery running before outer commit. Attempt fencing and transaction refusal make them pass.
2. A secret sentinel first appeared in the ordinary handled-error log. The narrowed log passes while Rails.error retains the original exception behind host privacy controls.
3. Six feedback tests first failed against the old API. They now cover deterministic receipt, metadata-only replay flag, no snapshot notice, invalid-feedback rollback, escaping, JSON/Turbo, one-request HTML and scope isolation. Existing legacy-message browser tests also pass.
4. Existing database rollback tests initially returned CONFLICT with zero notification. All three rollback classes now emit the expected code-only event.
5. PostgreSQL concurrency test first read stale query cache in the parent thread. Its final read now uses uncached, without changing runtime for a test artifact; full132/1145 passes. Two competing fresh claims invoke one callback. Other delivery overlap and cleaner/action-close races remain covered.
6. The first browser launch hit sandbox loopback bind EPERM. Authorized execution outside that restriction ran real Chrome successfully. RDoc's Transition is a constant anchor, not a class page; the link checker found the initial wrong URL and the corrected build has zero broken links. Docs impact heuristically flags private raise_action_conflict!, which is explicitly private/:nodoc:, not a new public API.

## Inspection and evidence locators

Run `bin/check --browser`, the additional Ruby/Rails gemfiles, and the PostgreSQL job for repeatable checks. Upgrade scripts archive immutable tags and use separate processes and disposable databases. `scripts/clean_install_smoke.rb --audit` runs outside Bundler against the built gem.

Fixture-only screenshots live in ignored `tmp/browser/20261020T021329-89464/` (mobile loading/failure/recovery) and `tmp/browser/20261020T022249-98468/` (both notice transports). Loading, failure, recovered and notice captures were visually checked. Raw transient logs are `/tmp/rtv040-*.log`; they are not durable acceptance artifacts or included in the gem/site. This record retains the useful outcome and reproduction paths.

All task-created browser/driver/Puma processes ended; temporary package/install/upgrade directories clean themselves; uniquely named PostgreSQL test databases were dropped and verified absent. The pre-existing PostgreSQL service remains untouched. No preview server/watch/tunnel was left running.

## Evidence limits and next step

LOCAL_ONLY, COMMITTED_LOCAL, UNPUSHED, UNPUBLISHED, OWNER_REVIEW_PENDING. Remote CI and hosted0.4 docs are NOT_RUN. Public stable0.3 stays unchanged. After owner review and explicit push/release authorization, check exact remote CI, set released metadata, tag and use the existing OIDC flow. Do not repurpose this local record as delivery proof.

No exactly-once remote claim, automatic uncertainty clearance or complete erasure. Host must own outbox/deduplication, original exception privacy and reconciliation/quiescence. Provider/MySQL qualification, external setup trials/comparison/adoption, independent security/full accessibility review and formal H2/C/R gates remain open for1.0. No external contact or provider credentials/budget were used. All59 pinned Specs stay unchanged.
