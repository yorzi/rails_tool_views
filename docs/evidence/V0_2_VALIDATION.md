# 0.2.0 local candidate validation

2026-10-18, macOS arm64. Base `c90fd8d`; implementation units WORK-20261018-06..09. Andy authorizes the bounded 0.2 development and incremental local commits. Public release stays 0.1.0. No 0.2 push, tag, hosted deployment or upload occurred.

## Acceptance

| Requirement | Observed result |
| --- | --- |
| Author a trusted Partial | `rails_tool_views:component review_card` generates registration/Partial/Minitest. Closed bounded schemas, no AI exposure, component/action policies both deny. Public presentation and dispatch reject; authorizing presentation alone cannot authorize the action. |
| Preserve host files | Flat key up to 64 characters; all outputs preflighted. Invalid names, existing output including --force, and escaping symlinks reject without partial writes. Two definitions survive repeated shared registry reloads. |
| Full HTML correction | Complete Engine document with title/lang/viewport/CSRF/main; 403/404/409/422 preserved. Authorized fields and safe reload path render; cross-identity pages expose no props/form. Successful correction avoids GET on a POST-only action route. |
| Existing contracts | Embedded helper remains a fragment; JSON/Turbo, scope/policy/transaction/replay/CSRF behavior retain regression coverage. No data/schema migration or added runtime dependency. |
| Real installed host | Actual frozen gem installs into a temporary Rails app. Migration/helper/escaping/JSON action/Turbo replay/stale HTML/scoped denial/native redirect/validation/generated correction/restore/eager load pass. Actual generated Minitest: 1 run / 2 assertions. |
| Browser | Real Chrome, CSRF enabled, loopback Puma, disposable SQLite. Partial and ViewComponent save/refresh, mobile validation, and genuinely JS-disabled HTML error/correction/refresh pass. |

## Checks

Database suites ran sequentially for the shared SQLite file. Browser and packaged hosts use separate disposable databases. PostgreSQL uses its own temporary database, dropped afterward.

| Check | Result |
| --- | --- |
| Ruby 3.3.5 / Rails 8.1.4 core + eager load | 97 tests / 837 assertions; zero failures/errors/skips |
| Ruby 3.3.5 / Rails 7.2.3.2 core + eager load | 97 / 837; zero failures/errors/skips |
| Ruby 4.0.2 / Rails 8.1.4 core + eager load | 97 / 837; zero failures/errors/skips |
| PostgreSQL 17.11 / Ruby 3.3.5 / Rails 8.1.4 | 97 / 837; zero failures/errors/skips; eager load passes |
| Optional RubyLLM 2.1.0 adapter | 7 / 45 passes; no live provider |
| Core and adapter documentation examples | PASS |
| Frozen installed artifact under all three Ruby/Rails bundles | Full host assertions and generated Minitest 1 / 2 PASS |
| `ruby scripts/clean_install_smoke.rb --audit` | Empty GEM_HOME, network-resolved dependencies, outside Bundler; same full installed-host assertions and Minitest pass; activated-dependency audit PASS |
| `bin/check-browser` | 4 / 28 passes; screenshots inspected |
| Seven unique lockfiles | No advisory findings after refresh; root Gemfile was checked twice, so the raw audit log has eight PASS lines |
| `verify_release.rb --candidate` | PASS, 31 packaged files; version/docs/changelog/license/MFA/exclusions align |
| `verify_release.rb` without flag | Expected refusal: `Docs are not marked released` |
| project-docs lint | 16 guides, zero errors; two expected warnings because main is 0.2.0 unreleased while latest release tag is v0.1.0 |
| Versioned docs build + link checker | v0.1.0 stable and working tree next; 2,210 local links, zero broken; internal content excluded |

Artifact: `pkg/rails_tool_views-0.2.0.gem` (ignored local build).

SHA-256: `e3c784de6f8527db6091b86b059945de2a0be112b9a2237fcf240904c4069a30`.

The isolated runner copies the package before network resolution and prints the same hash. This records the tested artifact, not a cross-job reproducible-build claim. Runtime files are app/config/db/lib plus the reviewed top-level license/readme/changelog/security files; browser libraries, internal records, databases and credentials are excluded. The generator's test template is intentionally packaged; generated application tests are not runtime application code.

Advisory snapshot: `fa2295251efb3b0d1a300e5ce8ad700ff1f1b485`, 1,266 advisories. Audited locks: root, adapter, browser, postgres, rails72, ruby4, docs/site. No runtime dependency version change; browser dependencies live only in their development bundle.

## Reproduce

```sh
bin/check
BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec rake test zeitwerk:check
# Ruby 4 uses the separately installed runtime and gemfiles/ruby4.gemfile.
# PostgreSQL uses a new disposable database and gemfiles/postgres.gemfile.
bin/check-browser
BUNDLE_GEMFILE=gemfiles/adapter.gemfile DOCS_ADAPTER=1 bundle exec ruby scripts/docs_examples.rb
ruby scripts/clean_install_smoke.rb --audit
bundle exec ruby scripts/verify_release.rb --candidate
docs/site/bin/build.sh
python3 scripts/check_docs_site.py
```

For package checks across the version bundles, install the same frozen file with `Gem::Installer` into a temporary directory, then invoke `scripts/support/packaged_host.rb <installed-lib> <temporary-host>` with `RAILS_TOOL_VIEWS_PACKAGE_BUNDLE=1`. `package_smoke.rb` performs the normal build/install route. The isolated command additionally resolves all runtime dependencies plus SQLite from RubyGems; it must not borrow the developer bundle.

## Browser review and cleanup

Automation artifacts: `tmp/browser/20261018T121156-58923/`, including `no-js-invalid-mobile` and `no-js-corrected-mobile`. Chrome CDP device emulation sets a real 390px viewport; resizing a desktop Chrome window alone initially left its minimum width at 500px, so that earlier screenshot was not accepted as 390px evidence.

Manual IAB review on temporary demo PID 51497, `127.0.0.1:3198`: open the direct Surface page, submit invalid email with Enter, inspect retained name/error, correct email, Tab to the button, Enter to submit, confirm readable Surface URL and revision 2, reload and confirm saved record. Screenshot: `tmp/browser/manual-020-corrected.png`. The page loads no Turbo script, and the separate automated driver disables page JavaScript explicitly. These were synthetic fixtures, without external messages or provider calls.

The browser tab and demo stopped; temporary SQLite directory removed. Chrome/driver/Puma processes ended; temporary PostgreSQL databases dropped. The pre-existing PostgreSQL service remains running. Browser Ruby network guards permit loopback only, including Selenium's port probe; this is not a browser firewall. Screenshots stay in ignored tmp; CI is configured to retain fixture PNGs seven days. CI was not run remotely for this candidate.

Failure-artifact probe: temporarily change the no-JS title assertion to an impossible expected value, run all four scenarios, observe exactly one intentional failure, then restore the source and rerun 4/28 green. `with_browser` captures the selected driver before restoring the default session; the failure PNG in `tmp/browser/20261018T121145-58925/` matches the accepted run’s invalid-page PNG (SHA-256 `0aecabe215a14b9728246f41973f41248d2e87a380b8fa7cc8a5af3cfba13986`). This prevents unrelated blank default-tab artifacts. No intentional failure remains in committed tests.

## Boundaries and next action

No MySQL, live provider, external developer trial, independent security review, full screen-reader/physical-device audit or formal H2/C/R closure is claimed. Internal historical V1 is not public 1.0. Automated sample/temporary-host checks are engineering acceptance, not external adoption.

Review and authorize a candidate push, inspect exact remote CI, then prepare dated release history/changelog and `released: true` before a separately authorized 0.2 tag/upload. Do not move v0.1.0 or start 0.3 automatically. The release workflow never passes `--candidate`, so local readiness does not bypass its release gate.
