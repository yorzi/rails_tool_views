# Audit validation — 2026-10-13

Work ID: WORK-20261013-01; base `3635c54`; candidate still `0.2.0.pre.v1`. Everything below was verified in the working tree, which Andy then asked to have committed locally on main under this Work ID. This records an owner-requested review and audit with local verification. It is not Andy's approval, remote CI, live-provider, PostgreSQL, external-user or business evidence. Earlier records: [VALIDATION.md](VALIDATION.md), [V1_VALIDATION.md](V1_VALIDATION.md).

## Environment

macOS arm64; Ruby 3.3.5 and 4.0.2; Rails 7.2.3 and 8.1.4; SQLite and PostgreSQL 17.11 (pg 1.7.0), ViewComponent 4.15.0, Turbo Rails 2.0.23, JSONSchemer 2.5.0, RubyLLM 2.1.0 (adapter suite only). Existing lockfiles unchanged; `gemfiles/postgres.gemfile` and its lock are new. No migration; the gem still installs four tables.

## Defects reproduced at `3635c54` before any change

Each was observed by running code against the reference host, not inferred from reading.

| # | Observation at base | After |
|---|---|---|
| 1 | `Schema.new` accepted a closed object whose property was `{properties: {...}}`, `{}`, `{type: "array"}`, or hid `{"$ref": "#"}`; `validate!` then accepted `{meta: {role: "admin", anything: {...}}}` | `INVALID_SCHEMA` at registration for ten open shapes; closed unions, nullable objects and `anyOf: [{required: [...]}]` still register |
| 2 | With the Engine loaded, `config.filter_parameters` and `ActiveRecord::Base.filter_attributes` contained `props state payload result arguments values`. A host model with `state`/`result` columns inspected and logged as `[FILTERED]`; host params `address[state]`, `statement_id`, `search_results`, `real_estate` were masked | Host list no longer contains them; host column and parameter sentinels are visible; Engine requests, SQL binds and `#inspect` remain redacted |
| 3 | A missing partial rendered "cannot be rendered" with no log line, no `Rails.error` report, and a `surface.rendered` event. A raising adapter set `failed` with no report or event | One `Rails.error` report, one log line, `surface.render_failed` / `agent_failed` with class only; `surface.rendered` only on success |
| 4 | `ToolViews::Error.new("OUT_OF_STOCK")` could only say "The request was rejected (OUT_OF_STOCK)."; core held three reference-host codes; Engine chrome was fixed English and announced any `selected` state key | `message:`, `tool_views.errors.*`, `tool_views.surface.*`; reference-host wording in its own locale file; status reads `state["message"]` only |
| 5 | Posting the demo's real "View authorized account" form returned 400 `INVALID_ARGUMENTS`: an action with no arguments posts no `arguments` field. Earlier tests only called `ToolViews.dispatch` directly | Missing field is `{}`; explicit `null` and missing required arguments still reject |
| 6 | The suite was order-dependent. In an untouched export of `3635c54`, `test/v1_controller_test.rb` failed 5 of 7 tests for seeds 2, 3, 4, 6 and 12 of 1–14 when that file ran alone, and the full suite failed for 1 of the first 12 seeds: when `host identity mutation retains CSRF protection` ran first it set the application's forgery config before `ActionController::Base` loaded, leaving protection on for the rest of the process | That test now toggles only its own controller and restores the prior value; the same seeds pass |

Defect 6 means the green results recorded for WORK-20261010-01/02 depended on test order. It surfaced here as 14 failures on the first final Ruby 4.0.2 run and was traced to a seed before any rerun was accepted.

## Revert checks

For each fix the changed files were restored to `3635c54` one group at a time and the related test file was run; the working tree was restored afterwards and the full suite re-run.

| Reverted | Tests that then failed |
|---|---|
| lib/tool_views/core.rb | nested value positions; host-worded codes |
| lib/tool_views/engine.rb | host columns stay visible; host request parameters stay visible |
| surfaces_controller.rb | Engine request log masking |
| four models | `#inspect` redaction; SQL bind redaction |
| lib/tool_views/runtime.rb | adapter failure reported |
| surfaces_helper.rb and `_surface.html.erb` | renderer failure reported; rendered-once and renderer rejection; status copy and translations |

The zero-argument form test was written first and failed with 400 before the controller change.

## Adoption changes and PostgreSQL (same work unit, second request)

Probes before the change: a form built with Rails' `form.submit` or `form.button` returned 400 `UNKNOWN_FIELD`; inside a ViewComponent `main_app` and the mounted route proxy were unavailable except through `helpers`; a committed HTML post without Turbo redirected to a response starting with `<section` and containing no `<html>`.

| Change | Broken on purpose to check its test |
|---|---|
| `commit` / `button` accepted and ignored | Removing them from the tolerated list fails the submit-names test |
| Redirect back, same host only | Restoring the fixed redirect fails; `allow_other_host: true` fails on the foreign `Referer` case |
| `config.delivery_lease` | Restoring `5.minutes.ago` fails the lease test |
| ViewComponent context | Passing no context errors the interactive component test |
| `config.parent_controller` | Restoring `< ::ApplicationController` fails the separate-process test |
| Ids unique per Surface | Dropping `namespace:` fails the duplicate-id assertion across two Surfaces |
| Rollback returned as `CONFLICT` | Removing the rescue fails for `Deadlocked`, `SerializationFailure` and `LockWaitTimeout` |

PostgreSQL ran as a task-owned server from the installed Homebrew 17.11 binaries, with a data directory in the session scratch directory, listening on `127.0.0.1:54329` only. The suite needed no code change to pass on it. The demo's PostgreSQL-backed development log showed 24 Engine JSON binds as `[FILTERED]` and none unfiltered. The rollback mapping was added by reading the error classes PostgreSQL can raise and is tested by a handler that raises them; no real deadlock was provoked.

## Final checks on the final tree

| Command / combination | Result |
|---|---|
| `bin/check` — Ruby 3.3.5 / Rails 8.1.4 / SQLite | Core and reference host: 78 tests, 646 assertions; eager load passed. Adapter: 6 tests, 44 assertions. Installed-gem fresh-host smoke passed, now including the action form helper |
| `bundle exec rake test TESTOPTS="--seed=N"` for N = 1..12, same combination | 12 of 12 passed (24 of 24 at the 70-test stage) |
| `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec rake test zeitwerk:check` — Ruby 3.3.5 / Rails 7.2.3 / SQLite | 78 tests, 646 assertions; eager load passed; seeds 2, 6, 12, 19 passed; installed-gem smoke passed |
| Ruby 4.0.2 / Rails 8.1.4 / SQLite, isolated bundle, invocation as in V1_VALIDATION.md | 78 tests, 646 assertions; eager load passed; seeds 2, 6, 12, 19, 46695 passed; installed-gem smoke passed |
| `DATABASE_URL=postgres://toolviews@127.0.0.1:54329/toolviews_test BUNDLE_GEMFILE=gemfiles/postgres.gemfile bundle exec rake test zeitwerk:check` — Ruby 3.3.5 / Rails 8.1.4 / PostgreSQL 17.11 | 78 tests, 646 assertions; eager load passed; seeds 2, 6, 12, 19, 31 passed |
| `node --input-type=module --check < app/assets/javascripts/tool_views_controller.js` | Parsed |

All counts have zero failures, errors and skips. Suites ran sequentially because they share the dummy test database. Tests block TCP.

## Real application pass

`bin/demo` bound only `127.0.0.1:3100`. A script drove it over HTTP with a cookie jar and real CSRF tokens; 18 of 18 checks passed after fix 5 (17 of 18 before it, which is how defect 5 was found). After the adoption changes the script had 22 checks and passed 22 of 22 on SQLite and on PostgreSQL:

- ChoiceCard: present, "View ready.", Turbo action 200 replacing only its own Surface, handler message "Selection saved: compare.", state restored on reload, stale revision 409.
- Customer form: invalid email 422 with field error and retained value, corrected input creates once, second submission 409 with the reference host's own wording, injected `business_rules` rejected, missing CSRF token 403.
- Support: ticket card renders, account view 200 with the host message, another tenant's read of that Surface 404.
- Review page renders a Surface.
- Added later: the demo's ViewComponent card renders an action form with Rails' `form.submit`, commits with the `commit` field present, and a post without Turbo returns 303 to the embedding page, which then shows the saved choice.

The development log from that run contained zero occurrences of the invalid email, the injected policy text, or presentation props; the host parameter sentinel sent to `/demo/present` appeared once; Engine `state` binds appeared as `[FILTERED]`.

Browser (Chrome, real Stimulus and Turbo): the controller connected and showed the server-supplied "Saving changes…" and failure text with `aria-busy` set and cleared; a real selection replaced the Surface, announced "Selection saved: continue.", showed revision 2 and moved focus to the status element. The console read returned no messages, but capture began after the interactions, so it is not evidence about page load. No new screenshots were taken; no 360px pass and no screen-reader audit in this unit.

## Not verified

MySQL, including whether its adapter accepts the redacting bind value. PostgreSQL versions other than 17.11, and PostgreSQL in remote CI. A real deadlock. Remote CI. Live provider. `Rails.event` structured subscribers on 8.1 beyond the bind's `as_json`. On Rails 8.1 the host filter list gains Rails' own model-scoped keys (`surface.state`, `action_execution.result`, …); a probe showed `state` and `order[state]` stay visible and only `surface[state]` is masked. The query string of a request URL is logged by Rails before routing and is not covered by the Engine filter; the Engine reads only the request body.

## Cleanup

Task-owned demo servers (PIDs 30957, 31226, 41689 and 41772) were stopped; `lsof -nP -iTCP:3100 -sTCP:LISTEN` found no listener. The task-owned PostgreSQL server (PID 41143) was stopped with `pg_ctl stop`, its data directory deleted, and port 54329 has no listener. The browser tab was closed. Probe scripts and the HEAD export live in the session scratch directory, outside the repository. One local commit on main at Andy's request; the repository has no remote and nothing was pushed. No publication, provider call or external contact.
