# ADR 005 — RailsToolViews identity with persistent compatibility

2026-10-16; WORK-20261016-01. Owner explicitly requested the rename, related gem updates, commit and push. This is approval of the implementation identity, not a RubyGems release or formal Specs H2 approval.

## Source and scope

Original product baseline: OddlyNiche `toolviews/` at `0ea28b1a76990b8c1e6a0bbd236119fd5bc5d1cc`, retained in `docs/specs/`. The clean source checkout now points at `c100a73d80b92de2246901922caa2b7bd819d889`; its `supporting/07_RAILS_NAME_AND_ODDLYDOCK_CONTRACT.md` is the supplemental naming/upgrade contract. External Specs and the original snapshot are read-only. The source's PROPOSED label is historical source state; the owner's current instruction authorizes this implementation.

## Decision

Package `rails_tool_views`, canonical Ruby module `RailsToolViews`, entrypoint `rails_tool_views`, installer `rails_tool_views:install`, prerelease `0.2.0.pre.v2`. This is a package identity update, with existing runtime dependency constraints retained. Core remains independent of RubyLLM and OddlyDock.

`ToolViews` aliases the same module. Historical requires, helpers and mount aliases remain supported. New hosts get a `/rails_tool_views` mount named `:rails_tool_views`; old mounted paths remain host-owned. The installer supports both command names but must not be rerun on existing hosts. No promise to publish a separate legacy `toolviews` package is made.

Preserve four `tool_views_*` tables, original migration class/file names, DOM/Stimulus identifiers, translation keys, notification names, continuation delivery keys and all serialized contract fields. Renaming these mechanically would break existing rows, retries, clients or host translations. Host component class/partial names remain part of contract identity; changing them still requires explicit host migration. No coercion or bypass of authorization/digest guards.

## Verification and boundaries

`test/identity_test.rb`: both APIs share registry/configuration, core-only load, generator discovery, helper aliases and identical migration templates. `scripts/rename_smoke.rb`: actual pre-rename commit `26825cb` writes SQLite records, then a separate current process restores exact snapshots, replays action and presentation without repeating domain writes, preserves delivery/DOM identity, rejects foreign actors and changed digests. `scripts/package_smoke.rb`: built gem installed into an isolated host, new generator, real HTTP action/restore, canonical helper and eager load without RubyLLM/OddlyDock. The full suite retains legacy mounted routes, providing both mount-name paths.

RubyGems exact-name API checks for `rails_tool_views` and `toolviews` returned HTTP 404 on 2026-10-16. This is an observation, not a reservation or legal clearance. GitHub lookup did not resolve `yorzi/rails_tool_views`; the owner subsequently selected that repository with private visibility, and it was created as origin. Near-name/legal review remains open. Rails trademark policy was read at https://rubyonrails.org/trademarks; README identifies the project as unofficial.

TV-01/04/05 have independent local evidence. OddlyDock TV-02/03 integration, live provider, remote CI and public gem release remain separate gates. No new database migration, host domain dependency, authentication rule or provider call is introduced.
