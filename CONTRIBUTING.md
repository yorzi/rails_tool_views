# Contributing

Keep the core independent of RubyLLM. Host applications own their business services and permissions. Start coding work with [AGENTS.md](AGENTS.md) and the [agent entrypoint](docs/agent/00_ENTRYPOINT.md).

## Develop

```sh
bundle install
bin/check
```

The adapter checks and `bin/demo` run on `gemfiles/adapter.gemfile`, which adds RubyLLM. `bin/demo` installs it; for `bin/check`, run `BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle install` once. Code that needs RubyLLM stays out of the core: the demo keeps it in `test/dummy/lib/demo_llm.rb` and loads it only when the bundle has RubyLLM.

For browser changes, install `BUNDLE_GEMFILE=gemfiles/browser.gemfile bundle install` and run `bin/check --browser`. Chrome is required; Selenium manages its driver. Fixture screenshots are written under `tmp/browser/`. Follow [the agent verification loop](docs/operations/03_AGENT_VALIDATION.md) for browser review and isolated installation.

Run database-backed suites sequentially because they share the dummy test database. Reproduce behavior through the public API, cover successful and rejected requests, and run the relevant [compatibility and package checks](docs/operations/02_RELEASE_CHECKLIST.md). Offline fixtures do not prove live-provider behavior.

Each authored commit includes a Progress Ledger section and a matching `Work-ID:` trailer, as described in [the maintenance contract](docs/agent/07_DOCUMENTATION_MAINTENANCE.md). Use `main` unless the owner requests a branch. Pushes and releases require owner authorization; never contact other maintainers on the owner's behalf without it.

## Write documentation

README introduces the project and links to the guides. Write tutorials, options and API behavior in `docs/site/`; do not duplicate them in the README. See [documentation ownership and build commands](docs/README.md).

Update the relevant guide in the same commit as a public API change. Record breaking changes in Upgrading and release changes in CHANGELOG. Maintain proposed work in [ROADMAP.md](ROADMAP.md), not as implemented features in the guides.

## Report a problem

Include Ruby, Rails and adapter versions, reproduction steps, and an anonymized example. Never include API keys, customer data or raw production payloads. Use [private vulnerability reporting](SECURITY.md) for security issues.

Contributions use the project's [MIT license](LICENSE.txt).

`bundle exec ruby scripts/upgrade_smoke.rb` exercises the immutable `v0.2.0` runtime and the working runtime in separate processes against a disposable database. Fetch tags first. It verifies the standard existing-host migration task, saved payloads and receipts, correlation, uncertainty backfill, rollback refusal and business preservation. It runs in each core CI combination and `bin/check`. Run suites sharing `test/dummy/storage/test.sqlite3` sequentially.
