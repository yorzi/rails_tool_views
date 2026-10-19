# 0.3.0 local candidate validation

Date: 2026-10-19. Base: 78d133346711a5115b4f4d3a0b4df080379bcf64.
Owner authorizes 0.3 development and tests; no push, tag, publication or provider call.
WORK-20261019-01..03. Published version stays 0.2.0.

## Delivered boundary

- Host-authorized close/abandon, first-termination deadline, read-only closed view, authorized old receipt/correlation replay and rejection of new actions.
- Additive migration/installer; Surface-first action/delivery/lifecycle locks; callbacks outside transactions.
- Durable delivery_uncertain on expired delivering takeover; conservative backfill of legacy delivering or multiple-attempt histories. No force resolution or exactly-once repair.
- Opt-in purge_closed: strict policy, exact scope, explicit cutoff/deadline, default dry run, bounded Surface batches, lock-time rechecks, per-Surface atomic receipt graph cleanup and payload scrubbing.
- Surface/Presentation tombstones preserve correlation guards. Host business records survive; opaque metadata/backups/logs and disk compaction remain host responsibilities.

## Local checks

| Environment/check | Result |
| --- | --- |
| Ruby 3.3.5 / Rails 8.1.4 / SQLite | 114 tests / 988 assertions; eager load PASS |
| Ruby 3.3.5 / Rails 7.2.3.2 / SQLite | 114 / 988; eager load PASS |
| Ruby 4.0.2 / Rails 8.1.4 / SQLite | 114 / 988; eager load PASS |
| PostgreSQL 17.11, own disposable DB | 116 / 1000; eager load PASS |
| Optional RubyLLM adapter | 7 / 45 PASS |
| Genuine v0.2 runtime → working runtime | Three core combinations PASS |
| Built artifact → fresh Rails host | Three core combinations PASS; generated Minitest 1 / 2 each |
| Empty GEM_HOME network resolve/install/full host | PASS; activated dependency audit PASS |
| Real headless Chrome, CSRF/native and Turbo | 5 / 40 PASS; mobile/no-JS and lifecycle screenshots |
| Executable guide code, core and adapter | PASS, including actual close/preview/apply snippets |
| Guide lint | 19 pages, zero errors; two expected unreleased/tag warnings |
| Stable0.2/next site build | PASS; 2,571 local links, zero broken; internal records excluded |
| Seven dependency locks | No known vulnerabilities at refreshed fa2295251efb3b0d1a300e5ce8ad700ff1f1b485 (1,266 advisories) |
| Candidate package gate | PASS; 35 reviewed runtime/top-level files |
| Formal release package gate | Correctly refuses released:false |

The tested package SHA-256 is `b82d0e09924d776e4f2e30de13c49cbed34299e9d80779f7ddb1072ea984fdcb`. The isolated runner copied this exact artifact before network resolution. This is local artifact identity, not a cross-job reproducible-build claim. No runtime dependency versions changed.

## Behavioral evidence

Lifecycle tests cover specific :close/:abandon policy, scope denial, deadline validation, indefinite retention, first decision, old receipts, conflicting keys, closed HTML and correlation. Two overlapping callbacks demonstrate why terminal status is insufficient; their durable uncertainty remains protected even after the old worker acknowledges. Callback assertions verify execution outside a DB transaction.

Retention tests cover default deny/strict true, zero-write preview, cutoff/deadline/batch scope, active/foreign/indefinite exclusions, protected unknown/pending/failed/delivering/uncertain rows, changed owner after candidate selection, and stale restored actions after purge. Injecting an update failure after child deletion rolls back the entire graph; retry succeeds and host Effect remains. Old actions and matching correlations return 410 without reallocation; deleted delivery returns 404, other scopes 404.

PostgreSQL adds actual competing cleanup workers and an action/close overlap. Only one cleaner purges; the other observes the tombstone under the lock. An action commits before waiting closure, preserving revision, state and historical receipt. These tests are conditional on PostgreSQL because SQLite has no SELECT FOR UPDATE, not mocked SQLite locking.

Upgrade smoke archives immutable v0.2.0, boots its real code in a separate process and writes five old graphs/business effects. The new process runs the documented railties migration-copy task and verifies unchanged snapshots/receipt/correlation, active legacy views, exact quarantine backfill, safe unused migration down/up, refusal after closure, payload cleanup and all five business effects preserved. CI's three core combinations and bin/check now run this script; remote execution remains NOT_RUN.

Chrome drives save → close → readonly → early preview → fixture clock advance → eligible preview → apply → refresh. Receipts disappear, the host action log remains. Reviewed screenshots show closed state and empty gallery with preserved business history. Existing Turbo, ViewComponent and mobile HTML correction scenarios remain covered.

## Failures found and corrected

- New lifecycle/retention tests failed before the missing implementation was added; snapshot privacy expectations were updated for documented lifecycle metadata.
- Rails 7.2 reads a SQLite boolean default written by Rails 8.1 as nil. Explicit model default false prevents a NOT NULL failure; rerun passes. Database constraints stay unchanged.
- Two initially overlapping local core/adapter runs interfered with their shared SQLite fixture. Discarded those results; reran suites sequentially. Package, browser and upgrade fixtures use disposable databases.
- First browser assertion used the wrong notice text; corrected to the actual View closed. A later Chrome inspector stale-document error occurred during page transition; lifecycle coverage now explicitly exercises the native no-JS full-page flow. The existing Turbo save/restore test still passes. This is not proof that every browser/driver race is resolved.
- The upgrade harness initially removed the Bundler-preloaded current version constant and compared /tmp paths without realpath; corrected fixture loading, then all three combinations pass.
- Isolated audit was initially invoked under the developer Bundler, which hides global bundler-audit. The documented standalone Ruby command succeeds outside Bundler.

## Reproduce and limits

Run sequentially for the shared dummy SQLite database:

```sh
bundle exec rake test zeitwerk:check
BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec rake test zeitwerk:check
# Activate Ruby 4.0.2 before using gemfiles/ruby4.gemfile.
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter
bundle exec ruby scripts/upgrade_smoke.rb
bundle exec ruby scripts/package_smoke.rb
ruby scripts/clean_install_smoke.rb --audit
bundle exec ruby scripts/docs_examples.rb
BUNDLE_GEMFILE=gemfiles/adapter.gemfile DOCS_ADAPTER=1 bundle exec ruby scripts/docs_examples.rb
bin/check-browser
docs/site/bin/build.sh
python3 scripts/check_docs_site.py
ruby scripts/verify_release.rb --candidate
```

For PostgreSQL use gemfiles/postgres.gemfile and a unique task-owned DATABASE_URL; drop it afterward. Core CI fetches all tags for the upgrade fixture. Temporary package/upgrade/isolated directories and browser DBs are removed by runners. Chrome/driver/Puma exited; no manually retained service. Existing PostgreSQL service is not task-owned and stays running.

Raw logs for this run are under `/tmp/rtv030-*.log` (ephemeral); screenshots remain ignored in the latest tmp/browser/20261019T* runner directory. CI retains screenshots seven days when executed. These local artifacts are not public deployments.

Remote CI, publication, MySQL, live providers, external adoption, independent security review, full assistive-technology/device audit and formal H2/C/R remain open. Unknown/overlapping delivery recovery remains 0.4 work; never clear uncertainty based on elapsed time. Lifecycle use requires stopping old web/workers and taking a complete backup before migration. No mixed old writers or silent downgrade.
