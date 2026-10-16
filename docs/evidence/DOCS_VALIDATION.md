# Documentation validation, 2026-10-16

WORK-20261016-03. Local documentation based on 873643d; owner subsequently authorized submission and a local folder rename. No site deployment or repository visibility change.

- Site: Jekyll 4.4.1, jekyll-vitepress-theme 1.10.1, RDoc 8.1.0. Dependencies locked in docs/site/Gemfile.lock, with x86_64-linux included.
- Scope: 14 content pages in four collections plus homepage; generated HTML/Markdown API; llms.txt and llms-full.txt; local search; light/dark appearance; release-aware build scripts.
- `docs.py check --dir docs/site`: 14 pages, 0 errors, 0 warnings. Historical/internal docs are outside the checker and site, not rewritten to satisfy guide lint.
- `docs/bin/build.sh`: PASS. No stable release exists, so the working tree is built at /rails_tool_views/. Real stable/next/archive publication has not been exercised.
- `python3 scripts/check_docs_site.py`: 1,031 local links checked, 0 broken; internal specs/agent/human/evidence/operations/adr folders absent from output. An initial RDoc link generated from the old comment arguments[...] was fixed in its source comment and regenerated.
- `bundle exec ruby scripts/docs_examples.rb`: PASS using a task-owned temporary SQLite database. Executes marked page examples for registration, lifecycle, dispatch/replay and error text, plus the actual tutorial ERB form.
- `BUNDLE_GEMFILE=gemfiles/adapter.gemfile DOCS_ADAPTER=1 bundle exec ruby scripts/docs_examples.rb`: PASS for the same examples and optional RubyLLM catalog. No provider request.
- `bundle exec rake test zeitwerk:check`: 83 tests, 665 assertions, zero failures/errors, eager load PASS (seed 59764). Ruby changes are comments and RDoc annotations only.
- Workflow YAML parsing and git diff whitespace checks: PASS. GitHub Actions itself was not run for this draft.
- Browser: homepage and guide layout at the available narrow viewport, search for idempotency with relevant results, search-result navigation, mobile menu, light/dark toggle, API reference and generated module page verified. A full wide/mobile device matrix and full accessibility audit were not run.
- Preview: initial sandbox loopback bind failed with EPERM; approved retry served only 127.0.0.1:4000. PID 53838 was stopped, the temporary browser tab closed, and no listener remained on port 4000. Live reload was omitted to avoid an additional listener.
- Private boundary: Pages setup/upload/deploy require DOCS_PUBLISH=true and a public repository. Both are left unchanged; no public URL is claimed. Existing Specs remain untouched. No schema/data migration, runtime behavior change, or new runtime dependency.

Reproduce from docs/README.md. Source examples, build scripts, and CI checks are included; generated output stays ignored. The screenshot was saved as a local review artifact, not published.

Submission follow-up: prior remote CI at 7e73e4e and 873643d is confirmed successful. The new documentation commit requires its own CI result. Target checkout folder: `/Users/andy/Workspace/OpenSource/rails_tool_views`; no compatibility symlink is planned.
