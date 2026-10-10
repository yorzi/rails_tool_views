# Local v0 validation — 2026-10-10

Work ID: WORK-20261010-01. This records local implementation evidence, not formal release, remote CI, live-provider, external-user or business verification.

## Baseline and environment

- Source: yorzi/oddlyniche/toolviews, pinned `0ea28b1a76990b8c1e6a0bbd236119fd5bc5d1cc`. `diff -qr docs/specs /private/tmp/toolviews-specs-20261010/toolviews` exited 0; the reference pack is unchanged.
- Host: macOS arm64, zsh. SQLite 2.9.6; ViewComponent 4.15.0; Turbo Rails 2.0.23; JSONSchemer 2.5.0. Version-specific locks live in Gemfile.lock and gemfiles/.
- Scope: UC-01/10, S1/S2/S3, local gem packaging and docs. Source REVIEW status remains unchanged. Formal Gate V is PARTIAL; H2/R remain OPEN.

## Executed checks

| Command / scope | Actual result |
|---|---|
| `bundle exec rake test zeitwerk:check` — Ruby 3.3.5 / Rails 8.1.4 | 36 tests, 238 assertions; zero failures/errors/skips; official Rails eager-load check passed |
| `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec rake test zeitwerk:check` — Ruby 3.3.5 / Rails 7.2.3 | 36 tests, 238 assertions; zero failures/errors/skips; eager load passed |
| Ruby 4.0.2 / Rails 8.1.4, isolated bundle; command below | 36 tests, 238 assertions; zero failures/errors/skips; eager load passed |
| `BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter` — Ruby 3.3.5 / Rails 8.1.4 / RubyLLM 2.1.0 | 5 tests, 34 assertions; zero failures/errors/skips |
| `bundle exec ruby scripts/package_smoke.rb` | Built actual .gem, installed into temporary gem directory, booted fresh Rails host; generator/migration, escaped Partial, scoped HTTP action, durable restore and eager load passed |
| `node --check app/assets/javascripts/tool_views_controller.js` and checker script | Both passed |

The final main/adapter/package commands are grouped in `bin/check`. Optional adapter dependencies must be installed separately first. Do not run database suites concurrently: they share the dummy test database.

Exact Ruby 4 command used:

```sh
GEM_HOME=/Users/andy/.rvm/gems/ruby-4.0.2 \
GEM_PATH=/Users/andy/.rvm/gems/ruby-4.0.2:/Users/andy/.rvm/gems/ruby-4.0.2@global \
BUNDLE_PATH=/Users/andy/Workspace/OpenSource/tool_views/vendor/ruby4 \
BUNDLE_GEMFILE=gemfiles/ruby4.gemfile \
/Users/andy/.rvm/rubies/ruby-4.0.2/bin/ruby \
/Users/andy/.rvm/gems/ruby-4.0.2/gems/bundler-4.0.9/exe/bundle exec rake test zeitwerk:check
```

Core tests exclude RubyLLM from their Gemfile and prove its require fails even though the optional SDK is installed elsewhere. Test/worker TCP entry points reject network connections. Adapter fixtures execute real RubyLLM Chat/Tool behavior with offline provider responses; they do not establish real provider schema acceptance or model reliability.

Separate worker processes verify persistence across boot, concurrent same-key replay creates one business effect, competing revisions do not overwrite, and receipts survive restart. SQL log capture verifies props/state/continuation payloads are filtered. Host business logging and external side effects remain host responsibilities.

## Browser evidence

Puma ran only on `127.0.0.1:3100`. Native Space/Tab/Return selected and saved options; Turbo focus moved to status. Refresh and an actual Puma stop/restart retained checked values and revisions. Two tabs sharing a demo session produced a stale-revision 409: current selection remained intact, the alert was shown, focus moved to it, and the fieldset referenced the error through aria-describedby.

- [Desktop choice, saved revision 2](desktop-choice.jpg): wider in-app browser layout, native radio choice and action log.
- [360px chat selection](mobile-chat.jpg): checked choice, saved revision and deterministic continuation completed.
- [360px two-tab conflict](mobile-conflict.jpg): current revision 3 and recoverable error.
- [Final default viewport](default-viewport-complete.jpg): both saved choices, ViewComponent, empty state and committed action history after refresh. The browser's default panel was narrow after resetting the explicit mobile override; this image is not a second wide-desktop test.

At the explicit 360px viewport, body width was 345px with no horizontal overflow. Empty state had no selection controls; ViewComponent rendered through the trusted class. Browser console had no JS warnings/errors before the deliberate HTTP 409. Pending/failed/invalid/denied states were verified by integration/render fixtures, not all manually captured. No complete screen-reader or WCAG conformance audit was performed.

## Feasibility probes and boundaries

Executed under the adapter bundle:

```sh
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec ruby scripts/upstream_probe.rb \
  /private/tmp/toolviews-generative-ui /private/tmp/toolviews-a2ui-rails
```

| Upstream | Pinned result |
|---|---|
| GenerativeUI `994410c95042b9c8da660fbf425cee99fb3e2066` | Actual loader/catalog/schema control passed. Blocking RubyLLM require caused expected eager-load failure. Built gem: 24 files, 3 app/ files; mandatory activesupport/ruby_llm/schematist/json_schemer |
| A2UI Rails `d409b71670febabc46d64694461ec1adddd5996f` | Actual built gem: 85 files, zero app/ files; mandatory dspy/sorbet-runtime. Full DSPy runtime/security probes NOT_RUN |

SP-01/03/04/05 have local ToolViews controls. SP-02/09/10 have bounded loader/package observations, not an upstream neutral-core extraction. SP-11/12 full runtime/extraction/comparator checks remain incomplete. ADR 001 explains Candidate C without claiming upstream exploits or lower measured maintenance cost. No upstream maintainer was contacted and no upstream code was copied.

SP-06: JSON byte measurements for the bounded PresentUI parameters schema, using 1/5/20 explicitly registered components with the same ChoiceCard props schema: **487 / 531 / 706 bytes**. Identical schemas are deduplicated in the union. These figures exclude descriptions/provider wrappers, do not represent 20 distinct schemas, and are not token/call/cost/reliability measurements or an individual-tool comparison. Live benchmark NOT_RUN.

## Remaining external gates

Remote Linux CI is configured, NOT_RUN. PostgreSQL concurrency, live provider presentation/continuation, three external setup trials, measured bespoke/upstream integration cost, independent security/accessibility review, verified disclosure channel, license/name clearance and formal release approval remain open. The package is unpublished and no repository push occurred.

## Cleanup and commit evidence

Task-owned Puma PIDs 67653 and 72059 were stopped explicitly. Final Puma session exited 0; `lsof -nP -iTCP:3100 -sTCP:LISTEN` returned no listener. Temporary tabs closed and explicit viewport override reset. No task-owned server, watcher, worker queue or tunnel remains running.

The local implementation commit uses `Work-ID: WORK-20261010-01`. Staged and committed Progress Ledger linkage are checked with the included script. Source snapshots retain their original formatting; authored runtime/living documentation receive the whitespace check.
