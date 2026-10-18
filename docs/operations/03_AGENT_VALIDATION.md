# Agent development and verification

Use `test/dummy` as the maintained demo and test host. Do not create another permanent application just to start a feature. Temporary package hosts test the installed artifact; they are not external adoption evidence.

## Repeat for each feature

1. Read Current Work. Reproduce the affected behavior with a focused failing test.
2. Implement the smallest public contract and update its user guide.
3. Run focused checks, then `bin/check`. Database suites run sequentially.
4. For UI changes, run the browser suite below and inspect its screenshots. Use the agent's browser tools for actual keyboard/mobile/layout review when screenshots or automated assertions leave a question open. Convert reproducible regressions into tests.
5. Record exact results and limits in the ledger. Commit one finished unit with its Work-ID. Stop every task-owned server/driver before completion.

## Browser suite

```sh
BUNDLE_GEMFILE=gemfiles/browser.gemfile bundle install
bin/check-browser
# Or run the core/adapter/package/docs checks before browser tests:
bin/check --browser
```

Chrome must be installed. Selenium manages its driver; `CHROME_BIN` can name an explicit local Chrome executable. `bin/check-browser` creates a temporary SQLite database and prints the screenshot folder under `tmp/browser/`. Tests use real form tokens and the demo's server-resolved fixture identity. They cover Partial/ViewComponent persistence and customer validation, including JavaScript-disabled correction on a 390px device emulation; new UI features add their own scenarios.

The Rails server, driver connections and driver port probe use loopback. Core/adapter tests still forbid TCP; browser tests permit loopback only in Ruby test clients. This guard is not a browser-level network firewall or provider isolation proof. The demo uses local assets and deterministic callbacks, with no provider call or customer contact. No production data belongs in artifacts.

For a scenario that selects another driver, use `with_browser(:rails_tool_views_no_js)` so failure screenshots are taken before restoring the default session. The test runner closes browser sessions and driver processes; the Rails server ends with the test child process. Screenshots are retained locally in ignored `tmp/`; CI uploads fixture screenshots for seven days. Inspect a failed run before retrying. Do not report a screenshot as an assertion or an offline test as live-provider evidence.

## Verify the installed artifact

```sh
bundle exec ruby scripts/package_smoke.rb
ruby scripts/clean_install_smoke.rb --audit
```

Build the gem first (the package smoke does this). Install `bundler-audit` outside the application bundle and refresh its advisory database before `--audit`. The first command uses the developer bundle; the second installs dependencies and SQLite into an empty GEM_HOME and runs the same generated-host fixture outside Bundler. Both assert the loaded entrypoint belongs to the installed gem. The host checks installer/migration, escaped rendering, action helpers, HTTP actions, complete HTML pages, generated rejection/correction, durable restore and eager load. It runs the actual generated Minitest scaffold too. The isolated runner copies the input gem and prints its SHA-256 before network resolution, so another build cannot replace the artifact being tested. Temporary directories are removed on exit.

For install/generator/dependency changes, run both. For public API changes, also run the advertised Rails/Ruby bundles and optional adapter checks in the release checklist. Provider calls and future gem uploads still require their own authorization.
