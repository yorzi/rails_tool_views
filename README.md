# RailsToolViews

Turn trusted Rails Partials and ViewComponents into persistent, interactive tools. Your Rails application owns authentication, permissions and business data. RubyLLM integration is optional.

[Documentation](https://rails-tool-views.wangyaodi.com) · [Getting started](https://rails-tool-views.wangyaodi.com/getting-started/) · [API](https://rails-tool-views.wangyaodi.com/api/) · [Roadmap](ROADMAP.md)

## Install

Requires Ruby 3.3 or later and a patched Rails release.

```sh
bundle add rails_tool_views
bin/rails generate rails_tool_views:install
bin/rails db:migrate
```

Continue with [Getting Started](https://rails-tool-views.wangyaodi.com/getting-started/) to configure authenticated scope and register your first component. Component and action policies deny access until you configure them.

## Try the demo

From this checkout:

```sh
bundle install
bin/demo
```

Open http://127.0.0.1:3100 and stop with Ctrl-C. The demo covers choices, customer forms, support and content review using offline fixtures. See the [walkthrough](https://rails-tool-views.wangyaodi.com/demo/).

## Contribute

Read [Contributing](CONTRIBUTING.md) for development and documentation commands. Report vulnerabilities through the [private security channel](SECURITY.md).

Released under the [MIT license](LICENSE.txt). RailsToolViews is an unofficial community project, without affiliation or endorsement. Rails marks belong to David Heinemeier Hansson and are exclusively licensed to the Rails Foundation; see the [trademark policy](https://rubyonrails.org/trademarks).
