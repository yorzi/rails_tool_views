# RailsToolViews

**Turn trusted Rails views into persistent, interactive tools.**

Register an existing Partial or ViewComponent, present it with validated data, and let users act through authorized Rails handlers. Each view keeps its state across refreshes. Your application owns authentication, tenant boundaries and business records.

The core runs without an AI provider. An optional RubyLLM adapter lets agents present registered components and continue after a user action. RailsToolViews does not generate executable UI code.

[Documentation](https://rails-tool-views.wangyaodi.com) · [RubyGems](https://rubygems.org/gems/rails_tool_views) · [API reference](https://rails-tool-views.wangyaodi.com/api/)

Version **0.1.0** is the first public release.

## Try the workbench

Requires Ruby 3.3+ and Bundler. From this checkout:

```sh
bundle install
bin/demo
```

Open **http://127.0.0.1:3100**. Stop with `Ctrl-C` when finished.

| Workflow | What to try |
| --- | --- |
| Component playground | Present a Partial, chat card or ViewComponent. Save a choice and refresh to restore it. |
| Customer intake | Submit an invalid email, correct it and create a customer with field-level feedback. |
| Support workspace | Find a ticket, inspect its account, review a draft reply and confirm the local outbox. |
| Content review | Edit, regenerate, accept a version and download its text export. |

Switch synthetic identities to explore two tenants and two roles. Fixtures run locally, with no provider calls or external messages. The identity switch is a testing aid, not production authentication. See the [demo walkthrough](docs/site/_getting_started/demo.md) for test scenarios and continuation failure/retry.

## Add it to a Rails application

Add the gem:

```ruby
# Gemfile
gem "rails_tool_views", "~> 0.1.0"
```

```sh
bundle install
bin/rails generate rails_tool_views:install
bin/rails db:migrate
```

Follow [Getting Started](docs/site/_getting_started/getting-started.md) to configure authenticated scope resolution and register a component. Once registered, present and render it:

```ruby
scope = RailsToolViews::Scope.new(actor: current_user.id.to_s, tenant: current_account.id.to_s)
surface = RailsToolViews.present(:choice_card, props: approved_props, scope: scope)
```

```erb
<%= rails_tool_views_surface(surface, scope: scope) %>
```

Component and action policies deny by default. The host must authorize domain records and allowed values independently of proposed props. External side effects require host idempotency or an outbox. Read [Security](SECURITY.md) before integration.

## Documentation

Read the [searchable guides](https://rails-tool-views.wangyaodi.com). Preview locally with `docs/bin/serve.sh`; setup and build instructions are in [docs/README.md](docs/README.md).

- [Getting Started](docs/site/_getting_started/getting-started.md): installation and a working first component.
- [Configuration](docs/site/_getting_started/configuration.md): host identity and engine settings.
- [Core guides](docs/site/_core_features): components, surfaces, actions and validation.
- [Advanced guides](docs/site/_advanced): optional RubyLLM, continuation and production boundaries.
- [API reference](docs/site/_reference/api-reference.md): generated Ruby API documentation.
- [Upgrading](docs/site/_reference/upgrading.md): moving an unpublished development host to the first public version.

The dummy host in [`test/dummy`](test/dummy) contains the complete runnable examples and is excluded from the gem runtime. OddlyDock is a planned reference host, not a dependency.

## Development

```sh
bundle exec rake test zeitwerk:check
bundle exec ruby scripts/package_smoke.rb
# Optional adapter tests:
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter
```

Tests use offline responses and block TCP connections. Supported dependency bounds are in [the gemspec](rails_tool_views.gemspec); tested combinations and limitations are recorded in [validation evidence](docs/evidence). MySQL and live-provider behavior remain unverified. See [the release checklist](docs/operations/02_RELEASE_CHECKLIST.md) for remaining release gates.

## Project status and attribution

Released under the [MIT license](LICENSE.txt).

RailsToolViews is an unofficial community project. Rails marks belong to David Heinemeier Hansson, with exclusive licensing to the Rails Foundation. Framework names identify compatibility; neither the owner nor the Foundation endorses or is affiliated with this project. See the [Rails trademark policy](https://rubyonrails.org/trademarks).
