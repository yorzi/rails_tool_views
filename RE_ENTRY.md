# Re-entry

Current milestone: 1.0.0 is published (2026-10-26) under the owner exception in DELTA-008. A post-1.0 audit on branch `claude/laughing-pasteur-p18ora` adds unreleased fixes, an agent-chat demo and the "After 1.0" plan in [ROADMAP.md](ROADMAP.md). Nothing after 1.0.0 is tagged or published. Read README.md, SPEC_BASELINE.md, docs/human/01_PROJECT_STATUS.md and docs/agent/02_CURRENT_WORK.md first.

Run `bin/check` for the core, eager load, adapter, package, upgrade and docs-example checks; it needs `BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle install` once. `bin/check --browser` adds the Selenium suite. `bin/demo` installs the adapter bundle and serves the offline demo on 127.0.0.1:3100; stop it with Ctrl-C. Start at `/` (component playground), `/agent` (RubyLLM agent chat), `/v1/customer`, `/v1/support` and `/v1/review`.

Next owner action: review the audit commits and the roadmap's "Decisions for the owner", then decide whether to release them as 1.0.1. Live-provider runs, external setup trials and an independent security review still need separate authorization.
