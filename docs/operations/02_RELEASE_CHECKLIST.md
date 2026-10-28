# Gem and documentation release

The owner authorized the first public `rails_tool_views` release as **0.1.0** on 2026-10-18, including commit/push/tag, GitHub Pages and DNS. The owner selected MIT and GitHub private vulnerability reporting. This replaces the historical no-publication scope; it does not invent H2/C/R, independent security review, external adoption or live-provider results. See DELTA-005 and [release evidence](../evidence/RELEASE_0_1_0.md).

0.1.0 publication, checksum comparison and stable/next HTTPS deployment are complete. The release tag is `v0.1.0` at `f2d4303`; see the evidence above before changing a release.

Andy explicitly authorizes the 0.2.0 candidate push, remote CI and publication on 2026-10-18. Work proceeds without repeating that approval; 0.2.0 delivery is complete; [actual evidence](../evidence/RELEASE_0_2_0.md) records the exact commit, runs and checksum. The v0.1.0 tag remains immutable.

Andy explicitly authorizes 1.0.0 push, exact remote CI, `v1.0.0`, OIDC publication and docs on 2026-10-26, choosing 1.0.0 over rc1 with ROADMAP conditions 5 and 6's independent review and formal disposition waived (DELTA-008). The 1.0 tag makes 0.4.0 the archived 0.x site at `/v0/`. Delivery is verified; [actual evidence](../evidence/RELEASE_1_0_0.md) records the tag, runs, checksums and hosted checks.

On 2026-10-28 Andy requests the review of the post-1.0 audit and the 1.0.1 preparation. The candidate (version, lockfiles, `released: true`, changelog, release history, What's New and Upgrading) and its local checks are prepared on `claude/laughing-pasteur-p18ora`. Pushing to `main`, exact remote CI, `v1.0.1` and publication still need Andy's explicit go-ahead. 1.0.1 adds no migration or runtime dependency; it raises the adapter's RubyLLM floor to 2.0.

Andy explicitly authorizes 0.3.0 push, remote verification, publication and documentation commits on 2026-10-19. 0.3 delivery is verified; [actual evidence](../evidence/RELEASE_0_3_0.md) records the immutable tag, remote runs, published checksums and hosted checks. Prior tags remain immutable.

## One-time setup

- Public repository: `yorzi/rails_tool_views`; keep private vulnerability reporting enabled.
- GitHub environment: `release`. RubyGems Trusted Publisher: owner `yorzi`, repository `rails_tool_views`, workflow `release.yml`, environment `release`. No long-lived RubyGems API key is stored in GitHub.
- GitHub Pages source: GitHub Actions; repository variable `DOCS_PUBLISH=true`.
- Domain: `rails-tool-views.wangyaodi.com`, claimed in Pages before creating the Cloudflare DNS-only CNAME `rails-tool-views → yorzi.github.io`. Keep HTTPS enforced after certificate issuance.
- Keep gem version, docs version, changelog heading and tag identical. MIT is in `LICENSE.txt`; gem metadata requires MFA.

This follows ruby_llm-browser's successful OIDC release workflow. Optional experimental attestations are disabled to avoid pre-Bundler default-zlib activation. OIDC remains enabled.

## Prepare and verify

1. Update `lib/rails_tool_views/version.rb`, path entries in all lockfiles, `docs/site/_config.yml` (`released: true`), `CHANGELOG.md`, release history and What's New. Public behavior changes also update their guide and Upgrading.
2. Run tests **sequentially** because local bundles share the dummy test database:

```sh
bundle exec rake test zeitwerk:check
bundle exec ruby scripts/package_smoke.rb
bundle exec ruby scripts/upgrade_smoke.rb
bundle exec ruby scripts/docs_examples.rb
BUNDLE_GEMFILE=gemfiles/rails72.gemfile bundle exec rake test zeitwerk:check
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter
BUNDLE_GEMFILE=gemfiles/adapter.gemfile DOCS_ADAPTER=1 bundle exec ruby scripts/docs_examples.rb
BUNDLE_GEMFILE=gemfiles/ruby_llm20.gemfile bundle exec rake test:adapter
bundle exec rake build
bundle exec ruby scripts/verify_release.rb
ruby scripts/clean_install_smoke.rb --audit
docs/site/bin/build.sh
python3 scripts/check_docs_site.py
```

`package_smoke.rb` installs the artifact into a fresh Rails host and checks migration, rendering, HTTP actions, validation, restore and eager loading using the development dependency bundle. Refresh the advisory database first with `bundle-audit check --update` (install `bundler-audit` outside the app bundle if needed). `clean_install_smoke.rb --audit` separately resolves dependencies from RubyGems in an empty GEM_HOME and loads the artifact and installer outside the source bundle; it runs the same installed-host migration, rendering and HTTP workflow, then audits the activated gems including Ruby defaults and SQLite. Both temporary install directories are removed on exit.

3. Inspect the package manifest, dependency licenses, advisory results, generated site and disclosure URL. Internal records, databases and credentials must not enter either artifact. Review the evidence gaps below as gaps, not PASS.
4. Add a Progress Ledger section with honest checks and `Work-ID`, run staged linkage, commit and push the release candidate to `main`. Verify that candidate's remote CI and Docs checks before tagging.

For local unreleased candidates, use `bundle exec ruby scripts/verify_release.rb --candidate`. It validates the same package metadata and exclusions while allowing `released: false`. The release workflow never supplies this flag; a normal release check must still refuse an unreleased docs configuration. For a future release, change the changelog date, release history and `released` flag, obtain owner authorization and run the exact candidate through remote CI.

## Publish

For this release, after the exact candidate passes remote CI:

```sh
git tag -a v1.0.1 -m "Release RailsToolViews 1.0.1"
git push origin v1.0.1
```

The `Release Gem` workflow runs the full reusable compatibility CI (Ruby 3.3 and 4.0, Rails 7.2 and 8.1, optional RubyLLM and PostgreSQL), metadata/package checks, independent dependency resolution, dependency advisories and versioned documentation builds. Only then can the `release` environment publish through OIDC and create the GitHub Release with the gem and SHA256SUMS.

Do not move or reuse a tag after a successful RubyGems upload. If checks fail before publication, fix on main and inspect the exact failed step before deciding how to retry. Published versions are immutable; use a new version for code fixes.

## Release candidates

Use RubyGems prerelease versions such as `1.0.0.rc1` with the matching tag `v1.0.0.rc1`. The `Release Gem` workflow asks RubyGems' own `Gem::Version#prerelease?` and creates such a GitHub Release with `--prerelease --latest=false`, so it never replaces the latest stable release. A stable version keeps GitHub's automatic Latest selection.

`docs/site/bin/build.sh` builds stable docs only from `vX.Y.Z` tags, so a candidate tag never replaces the stable site; candidate readers use `/next/`. On 2026-10-21 a scratch clone with a local `v1.0.0.rc1` tag built `v0.4.0` at `/` and the working tree at `/next/`. `gem install rails_tool_views` ignores prereleases unless `--pre` or an exact version is given.

Each candidate still needs owner authorization, exact remote CI and the evidence in ROADMAP's 1.0 conditions. After publication, confirm the GitHub Release shows the Pre-release badge and that the Latest release and stable docs still name the previous stable version.

## Verify the outcome

- RubyGems API and gem page report the intended version and source/docs/MFA metadata. Download the published gem and compare SHA-256 with the GitHub Release asset and SHA256SUMS.
- Release verification and publication jobs both succeed for the tagged commit. Preserve the exact run URL.
- Post-release Docs workflow succeeds; stable home/Getting Started name the new release, `/next/` uses the Git branch install command, API/search/llms files work, and HTTPS is enforced. Check canonical URLs and internal-record exclusion.
- Record outcome in evidence, acceptance, project status and a separate ledger-linked delivery commit. Stop every task-created server.

## Evidence limits retained after 1.0.0

Formal H2/C/R and independent security review remain open. MySQL has arithmetic/index-width coverage but no real migration run. Live-provider behavior, upstream runtime comparison, external setup trials and measured adoption value remain unverified. PostgreSQL evidence must identify the exact local or remote candidate; past green runs do not cover a later commit. These limits do not silently become release approval; the owner's explicit release instruction and the 1.0.0 exception (DELTA-008) are recorded separately.

## Rollback

Revert documentation source and rerun Docs for a site correction; use Pages deployment history to inspect the prior deployment. Do not delete DNS while Pages still claims the live domain. If retiring the site, remove DNS first and then detach the Pages domain to avoid a dangling custom-domain record. RubyGems publication cannot be undone by a Git revert; issue a corrected version and consider yanking only for a concrete broken or unsafe package with owner authorization.

0.3 includes a lifecycle migration. Stop old web/workers and back up before upgrading; do not mix old writers or downgrade after closure. Use the public Upgrading and Surface Lifecycle guides for protected deliveries, host policy and retained tombstones.

## Authorized 0.4 publication

2026-10-20: owner explicitly requests remote CI, release acceptance, related docs and publication. WORK-20261020-05..06 execute the existing flow without repeating permission. Runtime local evidence is V0_4_VALIDATION; [publication evidence](../evidence/RELEASE_0_4_0.md) records the observed successful exact-tag delivery, checksums and stable0.4/next acceptance. 0.4 adds no migration or runtime dependency over0.3. Drain old web and delivery workers before switching, deliver after host commit, preserve host durable deduplication and conservative uncertainty. Older hosts follow the0.3 migration instructions first.
