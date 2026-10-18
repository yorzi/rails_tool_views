# Documentation

Read the [published guides](https://rails-tool-views.wangyaodi.com) to use the gem. Their editable Markdown source is in [site/](site/). The site also exports Markdown and `llms.txt` for text-based readers.

## Keep each document focused

| Location | Responsibility |
| --- | --- |
| Root README | Purpose, installation, demo and navigation |
| `docs/site/` | User tutorials, configuration, integrations, API and upgrade guides |
| CONTRIBUTING / SECURITY / CHANGELOG | Contribution workflow, disclosure policy and release changes |
| [ROADMAP.md](../ROADMAP.md) | Proposed version sequence and 1.0 exit conditions |
| `human/` and `agent/` | Current implementation, immediate work, decisions and commit ledger |
| `operations/` and `evidence/` | Run/release procedures and bounded validation results |
| `specs/` | Read-only pinned product-intent references |

Link to the canonical document instead of repeating its contents. Completed work belongs in the ledger and evidence; current work stays short. Internal records are excluded from the public site. The roadmap is a proposal, not an API reference.

## Build and check

From the repository root:

```sh
BUNDLE_GEMFILE=docs/site/Gemfile bundle install
docs/bin/build.sh
python3 scripts/check_docs_site.py
bundle exec ruby scripts/docs_examples.rb
```

For an optional local preview, run `docs/bin/serve.sh`, open http://127.0.0.1:4000 and stop with Ctrl-C. It binds to loopback. Generated output lives in `site/_site/`; regenerate it rather than editing it.

The stable site follows the latest release tag; `/next/` follows `main`. See the [release procedure](operations/02_RELEASE_CHECKLIST.md) for Pages, domain configuration and publication checks. Guide writing and commit rules are in [AGENTS.md](../AGENTS.md).
