# Local V1 validation — 2026-10-10–11

Work ID: WORK-20261010-02; base `57edc3e`; candidate `0.2.0.pre.v1`. This records local implementation verification, not Andy's manual approval, remote CI, live provider, external-user or business evidence. V0's original record remains in [VALIDATION.md](VALIDATION.md).

## Scope and environment

Pinned `yorzi/oddlyniche/toolviews` commit: `0ea28b1a76990b8c1e6a0bbd236119fd5bc5d1cc`; source pack unchanged. Andy explicitly authorized completing V1 before manual inspection (DELTA-002). Local scope: UC-02..05 and Demo B/C, generic field feedback and host integration. No UC-06..09 or external sending.

macOS arm64; Ruby 3.3.5/4.0.2; Rails 7.2.3/8.1.4; SQLite 2.9.6, ViewComponent 4.15.0, Turbo Rails 2.0.23, JSONSchemer 2.5.0. Version locks are in Gemfile.lock and gemfiles/. Nine demo-only domain/receipt tables are additive; core still installs four namespaced tables.

## Executed final checks

| Command / exact combination | Actual result |
|---|---|
| `bin/check` — Ruby 3.3.5 / Rails 8.1.4 | Core/V1: 60 tests, 468 assertions; eager load passed. Adapter: 6 tests, 44 assertions. Installed-gem fresh-host smoke passed |
| `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec rake test zeitwerk:check` — Ruby 3.3.5 / Rails 7.2.3 | 60 tests, 468 assertions; eager load passed |
| Ruby 4.0.2 / Rails 8.1.4 isolated bundle; exact command below | 60 tests, 468 assertions; eager load passed |
| `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec ruby scripts/package_smoke.rb` | Installed-gem fresh Rails 7.2 host passed |
| Ruby 4 package probe, explicit matching interpreter | Installed-gem fresh Rails 8.1 host passed |
| JS/checker syntax, ledger linkage, authored whitespace, unchanged specs | Checked while finalizing this work's local commit |

All test counts above have zero failures/errors/skips. Core excludes RubyLLM; optional adapter uses real RubyLLM 2.1.0 Tool/Chat APIs with offline responses. TCP is blocked in test workers; no live provider result is implied. DB suites ran sequentially because they share the dummy test DB.

```sh
GEM_HOME=/Users/andy/.rvm/gems/ruby-4.0.2 \
GEM_PATH=/Users/andy/.rvm/gems/ruby-4.0.2:/Users/andy/.rvm/gems/ruby-4.0.2@global \
BUNDLE_PATH=/Users/andy/Workspace/OpenSource/tool_views/vendor/ruby4 \
BUNDLE_GEMFILE=gemfiles/ruby4.gemfile \
/Users/andy/.rvm/rubies/ruby-4.0.2/bin/ruby \
/Users/andy/.rvm/gems/ruby-4.0.2/gems/bundler-4.0.9/exe/bundle exec rake test zeitwerk:check
```

For the Ruby 4 package probe, use the same environment/interpreter/Bundler prefix and replace `rake test zeitwerk:check` with `/Users/andy/.rvm/rubies/ruby-4.0.2/bin/ruby scripts/package_smoke.rb`. An initial `bundle exec ruby` picked the shell's Ruby 3.3 through PATH and failed to locate Ruby 4's isolated gems; using the explicit matching interpreter passed. Rails 7.2 emits an upstream ostruct packaging warning; tests and package probe pass.

Installed probes build the actual .gem, install into a temporary gem directory, and boot a new host rather than requiring source runtime files. They verify installer/migration, host authentication method/helper, escaped Partial, scoped HTTP action, bounded validation feedback with unchanged rejected revision, durable restore and eager load. Temporary host directories are removed at probe completion. Domain demo files are excluded from runtime packaging.

## Behavior and recovery

24 added core-suite tests exercise form input/validation/protected fields, business transaction rollback/create-once, scoped query/presentation/actions and changed associations, two roles/two tenants, trusted assignment/stale version, explicit reply drafting/review/confirmation, immutable artifacts, accept/edit/regenerate separation, stale cross-Surface writes, export failure/replay and authorized download. Existing V0 tests remain green.

Independent Ruby workers verify concurrent same-key customer submissions create one customer and one receipt, and a new boot restores regenerated/accepted/exported content plus host delivery receipt. A test resets the core acknowledgment after a committed host callback to prove durable business receipt reuse without another version. This is a simulated uncertain acknowledgment, not a real remote-provider crash test.

Actual Rails SQL capture verifies private artifact body redaction; notifications exclude it. Parameter filters include approved form values and authenticity_token. The final browser action log also showed authenticity_token as `[FILTERED]`. Host email/body/feedback filters are sample-specific, not exhaustive production privacy coverage. Rendered artifact script text is escaped. Engine requests now inherit host auth/helper behavior; a fresh installed host verifies this beyond the dummy app.

## Browser observations

Puma bound only `127.0.0.1:3100`. Browser interactions used the real local HTTP forms/Turbo responses:

- Customer: typed invalid email and corrected name; server 422 kept both values, field error/aria association and focused error. Corrected input created one customer and focused saved status.
- Support: assigned North Agent, explicitly drafted, edited and approved the reply, checked confirmation with Space/Tab/Return, and queued exactly one local outbox. No customer was contacted.
- Identity: South Agent saw only its tenant ticket and lacked lead-only creation/assignment/queue controls. Requesting a known North ticket returned a generic denied response without its data.
- Results at 360×800: saved a human edit as domain version 2, enabled the explicit offline failure fixture, requested regeneration, observed saving/failed status and preserved content. After real stop/restart without the failure flag, reloaded the same failed interaction and retried it: version 3, continuation completed, Surface revision remained 3. Accepted version 3 (Surface 4), prepared export (Surface 5), clicked the real download and checked its text matched the accepted content.
- Body/document scroll width was 345px at viewport 360px: no horizontal overflow. Native controls, labels and status/error focus were exercised; no full screen-reader/WCAG audit was performed.

Screenshots: [invalid form](v1-form-error.jpg), [reviewed local support queue](v1-support-complete.jpg), [agent role](v1-agent-role.jpg), [failed regeneration, 360px](v1-regeneration-failed.jpg), [accepted/exported result, 360px](v1-result-mobile.jpg), [final result after viewport reset](v1-result-complete.jpg). They contain synthetic fixture data. Screenshots supplement tests and are not a claim that every negative case was manually inspected.

## Remaining gates and cleanup

Human inspection is pending by request. License/name/disclosure review, remote Linux CI, PostgreSQL concurrency, live-provider extraction/presentation/continuation, external setup trials, measured integration benefit and complete upstream runtime comparison remain open. Source REVIEW and formal Gate V/H2/R statuses are unchanged. No push, publication, provider charge or external communication occurred.

Task-owned Puma PIDs 74625, 74917, 75052 and 75131 were explicitly stopped. The final `lsof -nP -iTCP:3100 -sTCP:LISTEN` found no listener. Temporary browser tab closed and mobile override reset. Test/probe workers exited; no task-owned server/watcher/queue/tunnel remains running.

The local commit carries `Work-ID: WORK-20261010-02` and its one Progress Ledger section. Staged/committed linkage uses scripts/check-progress-ledger.mjs; source snapshots retain original formatting and authored files receive whitespace checks.
