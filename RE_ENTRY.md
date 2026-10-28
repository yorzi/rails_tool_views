# Re-entry

Current milestone: 1.0.0 is published (2026-10-26) under the owner exception in DELTA-008. The 1.0.1 candidate on branch `claude/laughing-pasteur-p18ora` carries the reviewed post-1.0 audit (RubyLLM 2.0 floor, agent-chat demo, chat and importmap guides) with its version, changelog and docs metadata and local release checks. It is not pushed to `main`, tagged or published. Read README.md, SPEC_BASELINE.md, docs/human/01_PROJECT_STATUS.md and docs/agent/02_CURRENT_WORK.md first.

Run `bin/check` for the core, eager load, adapter, package, upgrade and docs-example checks; it needs `BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle install` once. `bin/check --browser` adds the Selenium suite. `bin/demo` installs the adapter bundle and serves the offline demo on 127.0.0.1:3100; stop it with Ctrl-C. Start at `/` (component playground), `/agent` (RubyLLM agent chat), `/v1/customer`, `/v1/support` and `/v1/review`.

Next owner action: decide whether to publish 1.0.1. If yes, fast-forward `main` to the branch, push, check the exact main CI and Docs runs, then tag `v1.0.1` as docs/operations/02_RELEASE_CHECKLIST.md shows. Separately decide the roadmap's "Decisions for the owner". Live-provider runs, external setup trials and an independent security review still need separate authorization.
