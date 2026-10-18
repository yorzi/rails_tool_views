# Single identity validation — 2026-10-18

Work ID: WORK-20261018-01; base `33b1dca`; candidate `0.3.0.pre.v3`. Owner decision in the 2026-10-18 session: keep `rails_tool_views` and remove every legacy `ToolViews` identifier before the first release (ADR 006, DELTA-004).

## Environment

macOS arm64. Ruby 3.3.5 + Rails 8.1.4 and Rails 7.2.3 (SQLite); Ruby 4.0.2 (`gemfiles/ruby4.gemfile`, SQLite); RubyLLM 2.1.0 for the adapter suite. OddlyDock (Ruby 4.0.2, Rails 8.1.4, SQLite) loaded this working tree through its Bundler local override.

## Results

| Check | Result |
|---|---|
| `bundle exec rake test zeitwerk:check` (Ruby 3.3.5, Rails 8.1.4) | 89 runs / 723 assertions, 0 failures; eager load PASS |
| `BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec rake test` | 89 runs, 0 failures (88 before the Stimulus test was added) |
| `BUNDLE_GEMFILE=gemfiles/ruby4.gemfile bundle exec rake test zeitwerk:check` (Ruby 4.0.2) | 89 runs / 723 assertions, 0 failures; eager load PASS |
| `BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter` | 7 runs / 45 assertions, 0 failures |
| `scripts/package_smoke.rb` | PACKAGED_INSTALL_PASS with `rails_tool_views:install`, `CreateRailsToolViews` and `rails_tool_views_*` tables |
| `scripts/docs_examples.rb` (core and `DOCS_ADAPTER=1`) | DOCS_EXAMPLES_PASS |
| `docs/bin/build.sh`, `scripts/check_docs_site.py`, project-docs check | build PASS; 1,042 local links, 0 broken; 15 guide pages, 0 errors/warnings |
| `bin/demo` on 127.0.0.1:3111 | `/` 200, `rails_tool_views_controller-*.js` 200; server stopped, port free |
| PostgreSQL | NOT RUN: no local server in this session. CI job unchanged apart from database names. |
| MySQL | NOT RUN (unchanged from earlier evidence). |

## Defect found during the rename and fixed

The first mechanical pass renamed `tool-views` only where no hyphen preceded it, so the Surface partial and the Stimulus controller kept `data-tool-views-*-value` / `-target` attributes while the controller was registered as `rails-tool-views`. Stimulus therefore never bound values or targets, and focus did not move after an action. The gem suite did not catch it because the old rendering assertion checked the old attribute. OddlyDock's browser test `ChatWidgetTest` failed deterministically (focus stayed on `body`). Fix: the attributes now use `data-rails-tool-views-*`. New `RenderingTest#test_Surface_markup_and_the_Stimulus_controller_use_the_same_identifier` asserts the identifier, every value/target attribute prefix and the attribute the controller reads; with the partial reverted it fails ("missing revision value"), with the fix it passes. OddlyDock system tests then passed 8/8.

## Upgrade path exercised on a real 0.2 host

OddlyDock's development database (backed up first) received synthetic old-name rows: one Surface at revision 2, one action receipt, one agent interaction, one placement and one continuation keyed `toolviews:interaction:999`. Its migration `RenameToolViewsToRailsToolViews` (the Upgrading guide's steps plus a delivery-key rewrite) then:

- renamed the three custom indexes and the four tables; Rails renamed default-named indexes;
- kept the Surface row, state and revision, and the receipt/interaction join;
- moved the placement foreign key to `rails_tool_views_surfaces`;
- rewrote the delivery key to `rails_tool_views:interaction:999`.

`db:rollback:primary` restored every old table, index, foreign key and key; migrating again succeeded. The database was then restored from the backup and migrated cleanly, so no synthetic rows remain. OddlyDock afterwards passed 518 tests, 8 system tests, zeitwerk, RuboCop and Brakeman.

## Boundaries

No release, push or publication. The pinned Specs under `docs/specs/` are unchanged. Earlier evidence files describe 0.2 behavior and are kept as history.
