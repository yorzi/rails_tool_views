# Audit validation v2 — 2026-10-17

Work ID: WORK-20261017-02; base `a1a9b26`; candidate `0.2.0.pre.v2`. Andy asked for a review and audit of the whole project and for real problems to be fixed. Everything below was reproduced, changed and re-verified in the working tree. This is local evidence, not Andy's approval, remote CI, MySQL, live-provider or browser evidence. Earlier records: [VALIDATION.md](VALIDATION.md), [V1_VALIDATION.md](V1_VALIDATION.md), [AUDIT_VALIDATION.md](AUDIT_VALIDATION.md), [RENAME_VALIDATION.md](RENAME_VALIDATION.md), [DOCS_VALIDATION.md](DOCS_VALIDATION.md).

## Environment

macOS arm64; Ruby 3.3.5; Rails 8.1.4; SQLite and a local PostgreSQL 17.11 (`DATABASE_URL=postgres://andy@127.0.0.1:5432/toolviews_probe`, `gemfiles/postgres.gemfile`); RubyLLM 2.1.0 (adapter suite only). No dependency or lockfile change. No new table or column; the bundled migration keeps four tables.

## Defects fixed

| # | Defect at base | After |
|---|---|---|
| 1 | The installer migration created the five-column presentation index on unbounded `varchar(255)` columns. Under utf8mb4 MySQL/InnoDB measures the key as 5 x 255 x 4 = 5100 bytes against a 3072-byte limit, so `CREATE TABLE tool_views_presentations` fails on MySQL | Identifier columns are bounded with `limit: 150`; the widest index is 5 x 150 x 4 = 3000 bytes. A test computes every index's worst-case width and asserts it is at most 3072 |
| 2 | Actor, tenant, context, adapter, call and idempotency references were only capped at 255 bytes, and every identity lookup used plain equality. On a database collation that is not binary (MySQL's default utf8mb4 collation, a PostgreSQL ICU/libc locale), a value that only compares equal could resolve another scope's Surface, another correlation's presentation, another action receipt, or another idempotency key | `RailsToolViews::Data.identifier` caps stored, indexed identifiers at 150 bytes (`reference` keeps 255 for descriptions and versions). After each lookup the runtime confirms a byte-exact match: `restore` requires the actor, tenant and id to match, `correlated_presentation` and the adapter receipt raise `IDEMPOTENCY_CONFLICT` / `INVALID_CORRELATION` on a near match, and `dispatch` requires the exact idempotency key before replay |

## Findings already fixed by an existing test

`docs/human/01_PROJECT_STATUS.md` listed "the migration file exists in `db/migrate` and the installer template, with no test that they agree". `test/identity_test.rb` already asserts the two files are byte-identical, so that finding was stale. The template was updated to match the migration in this change; the assertion keeps them coupled.

## Revert (mutation) checks

Each fix was reverted on its own and the related tests were run; the tree was restored afterwards.

| Reverted | Tests that then failed |
|---|---|
| `restore` byte-exact guard | `RuntimeTest#test_a_surface_only_a_non-binary_collation_could_match_is_refused` |
| `correlated_presentation` guard | `RuntimeTest#test_a_correlation_only_a_non-binary_collation_could_match_is_a_conflict_not_a_replay` |
| idempotency byte-exact check | `RuntimeTest#test_an_idempotency_key_only_a_non-binary_collation_could_match_is_a_conflict` |
| adapter receipt guard | `RubyLLMAdapterTest#test_a_receipt_only_a_non-binary_collation_could_match_is_refused` |
| migration `limit: 150` values | `IdentityTest#test_every_index_key_stays_within_the_MySQL_utf8mb4_byte_limit` (5100 bytes) |

The collation tests hand the runtime a row that simulates a non-binary collation match and assert the guards reject it; a byte-exact match still resolves. The `registry_test` assertions fail if the 150-byte cap is widened, and confirm multi-byte values are measured in bytes (`"é" * 75` passes, `"é" * 76` is rejected).

## Probed and not recorded as defects

- A top-level JSON `null`, array or string request body returns a bounded `400`, not a `500`.
- A NUL (`\u0000`) inside props round-trips on a PostgreSQL `json` column.
- `form_tag` / `form_with` against an action do not emit extra `utf8` or `_method` fields that would be rejected.
- Generated artifacts stay gitignored; the working tree held no stray build output.

## Final checks

| Command / combination | Result |
|---|---|
| `bundle exec rake test zeitwerk:check` — Ruby 3.3.5 / Rails 8.1.4 / SQLite | 88 tests, 702 assertions, 0 failures; eager load passed |
| `DATABASE_URL=.../toolviews_probe BUNDLE_GEMFILE=gemfiles/postgres.gemfile bundle exec rake test` — PostgreSQL 17.11 | 88 tests, 702 assertions, 0 failures |
| `BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter` — RubyLLM 2.1.0 | 7 tests, 45 assertions, 0 failures |
| `bundle exec ruby scripts/package_smoke.rb` | PACKAGED_INSTALL_PASS |
| `bundle exec ruby scripts/docs_examples.rb` | DOCS_EXAMPLES_PASS |
| `docs/bin/build.sh`, `python3 scripts/check_docs_site.py` | build passed; 1,075 local links, 0 broken; internal records excluded |
| `docs.py check --dir docs/site` | 15 guide pages, 0 errors, 0 warnings |

The fresh PostgreSQL run needed the probe schema dropped first (`DROP SCHEMA public CASCADE`) because the bundled migration was already applied on that database. That is expected: an existing host keeps its installed columns and the runtime bound is enforced in code, so no data migration is required. A new host, or MySQL where the old migration cannot apply, gets the bounded columns.

## Boundaries

MySQL was not installed or migrated; defect 1 is proven by column introspection and arithmetic, not by a real MySQL `CREATE TABLE`. No live model provider, remote CI, browser or assistive-technology run was repeated. The audit covers the gem's own code, tests, migration, installer and documentation; it is not a third-party security review.

## Open recommendation (needs owner decision)

A replayed action currently emits `action.executed`, the same event as a first execution, so telemetry cannot tell a replay from a new mutation. Emitting a distinct `action.replayed` would change the notification catalog the pinned specification lists (`action.executed/rejected/conflict`), so it was left unchanged here. It needs an owner decision before it is implemented.
