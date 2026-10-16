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

Open http://127.0.0.1:4000/rails_tool_views/. Stop the preview with Ctrl-C. It binds only to loopback and builds the API reference before starting. Guide edits rebuild automatically; rerun the build after changing Ruby API comments or site configuration. No live-reload listener is started.

Generated output is in `docs/site/_site/`, including `/api/`, `llms.txt`, `llms-full.txt`, search data, and Markdown copies. Do not edit generated output. Run the tutorial checks with:

```sh
bundle exec ruby scripts/docs_examples.rb
BUNDLE_GEMFILE=gemfiles/adapter.gemfile DOCS_ADAPTER=1 bundle exec ruby scripts/docs_examples.rb
```

For the installed project-docs skill:

```sh
python3 /Users/andy/Workspace/AI/Skills/project-docs/scripts/docs.py check --dir docs/site
python3 /Users/andy/Workspace/AI/Skills/project-docs/scripts/docs.py impact --dir docs/site
```

The style checker applies to the site only, not historical Specs or agent records. Configuration values shared across releases live in `site/_config.yml`. Pages use Jekyll link tags. API comments live beside the public Ruby methods.

## Publication remains disabled

The repository remains private. `.github/workflows/docs.yml` builds and checks docs, but Pages configuration, artifact publication, and deployment require both a public repository and repository variable `DOCS_PUBLISH=true`. Neither is enabled by this task. When publication is explicitly requested, review the generated package, configure GitHub Pages with the GitHub Actions source, and enable that variable. A custom domain is optional.

There are no stable release tags yet. The current build is marked unreleased at the root. When a stable tag includes this site, the build supports the release at `/`, main at `/next/`, and older majors at `/vN/`. Multiversion publication has not been exercised against actual releases.
