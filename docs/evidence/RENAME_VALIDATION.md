# RailsToolViews rename verification — 2026-10-16

WORK-20261016-01; base 26825cb; candidate rails_tool_views 0.2.0.pre.v2. Local verification only.

- Source audit: all 59 `docs/specs` files exactly match OddlyNiche 0ea28b1a76990b8c1e6a0bbd236119fd5bc5d1cc. Current external checkout c100a73d80b92de2246901922caa2b7bd819d889 was clean; supplemental supporting/07 naming contract read. No external Specs edit.
- Baseline Ruby 3.3.5 / Rails 8.1.4: 78 tests, 646 assertions, no failures/errors; eager load PASS.
- Candidate Ruby 3.3.5 / Rails 8.1.4: `bundle exec rake test zeitwerk:check` — 83 tests, 665 assertions, no failures/errors; eager load PASS (seed 8838).
- Candidate Ruby 3.3.5 / Rails 7.2.3: same command with `BUNDLE_GEMFILE=gemfiles/rails72.gemfile` — 83 tests, 665 assertions, no failures/errors; eager load PASS (seed 17605). Upstream ostruct packaging warning remains.
- Candidate Ruby 4.0.2 / Rails 8.1.4: same explicit Ruby/Bundler/vendor/ruby4 environment documented in V1_VALIDATION — 83 tests, 665 assertions, no failures/errors; eager load PASS (seed 60697).
- Optional RubyLLM 2.1.0: `BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter` — 6 tests, 44 assertions, no failures/errors (seed 23187). Offline fixtures only.
- `bundle exec ruby scripts/package_smoke.rb` — PASS: built and installed rails_tool_views 0.2.0.pre.v2 into a temporary host; canonical generator creates original table schema; new mount/helper, escaped rendering, HTTP action, validation feedback, durable restoration and eager load work without RubyLLM or OddlyDock.
- `bundle exec ruby scripts/rename_smoke.rb` — PASS: exports actual base 26825cb, migrates/writes an isolated SQLite database using its old runtime, then reads via current runtime in a new process. Snapshot/digest/ID/revision stable; action and presentation replay stable; one host effect; delivery and DOM keys stable; foreign actor and changed digest rejected. Temporary checkout/database removed by block cleanup.
- Original migration and installer template are byte-identical and protected by a test. No schema/data migration. Runtime dependency constraints and external dependency versions unchanged; lockfiles update package identity/version.
- RubyGems exact-name API checks returned 404 for both names; no namespace reservation inferred. GitHub did not resolve yorzi/rails_tool_views. The owner then explicitly requested creating yorzi/rails_tool_views private; repository creation succeeded and origin was configured. Push verification follows the commit.

Not run: PostgreSQL revalidation, remote CI, browser visual/accessibility audit, live provider, OddlyDock integration, near-name/legal clearance, external installation trials. These are not implied by local regression. No task-owned server, watcher, tunnel or other long-lived service was started.

## Delivery evidence — WORK-20261016-02

Implementation commit 7e73e4ec0e13f4a570754ead6ac4b2628074eccb pushed to origin/main. `git ls-remote` matched it; `gh repo view` reported PRIVATE for yorzi/rails_tool_views. CI run https://github.com/yorzi/rails_tool_views/actions/runs/38905836844 was queued when inspected; no remote PASS claim. Commit-to-ledger range check passed. This documentation-only follow-up records observed delivery, without changing tested code. No long-lived task process remains.
