# RailsToolViews documentation

The user-facing site lives in [site/](site/index.md). The existing `agent`, `human`, `adr`, `evidence`, `operations`, and `specs` folders remain internal project records and are not published by the site build.

## Build and preview

From the repository root:

```sh
BUNDLE_GEMFILE=docs/site/Gemfile bundle install
docs/bin/build.sh
python3 scripts/check_docs_site.py
docs/bin/serve.sh
```

Open http://127.0.0.1:4000/. Stop the preview with Ctrl-C. It binds only to loopback and builds the API reference before starting. Guide edits rebuild automatically; rerun the build after changing Ruby API comments or site configuration. No live-reload listener is started.

Generated output is in `docs/site/_site/`, including `/api/`, `llms.txt`, `llms-full.txt`, search data, and Markdown copies. Do not edit generated output. Run the tutorial checks with:

```sh
bundle exec ruby scripts/docs_examples.rb
BUNDLE_GEMFILE=gemfiles/adapter.gemfile DOCS_ADAPTER=1 bundle exec ruby scripts/docs_examples.rb
```

For the installed project-docs skill:

```sh
python3 /Users/andy/.codex/skills/project-docs/scripts/docs.py check --dir docs/site
python3 /Users/andy/.codex/skills/project-docs/scripts/docs.py impact --dir docs/site
```

The style checker applies to the site only, not historical Specs or agent records. Configuration values shared across releases live in `site/_config.yml`. Pages use Jekyll link tags. API comments live beside the public Ruby methods.

## GitHub Pages publication

The public guides are hosted at https://rails-tool-views.wangyaodi.com through GitHub Pages with the GitHub Actions source. `DOCS_PUBLISH=true` enables deployment in `.github/workflows/docs.yml`. Pull requests only build and validate. A successful `Release Gem` workflow triggers a new deployment even when the GitHub Release was created with the built-in token.

The Pages custom domain matches `site/_config.yml`, `site/CNAME` and `.rdoc_options`. Cloudflare has a DNS-only CNAME `rails-tool-views` pointing to `yorzi.github.io`. Configure the Pages domain before adding DNS, then enforce HTTPS once GitHub issues its certificate. A CNAME file alone does not configure a domain for an Actions-based Pages site.

The latest stable tag is built at `/`; `main` is built at `/next/`. Older majors are retained under `/vN/`. See [the release procedure](operations/02_RELEASE_CHECKLIST.md) for exact release and verification commands.
