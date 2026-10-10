# ToolViews

Trusted Rails components as persistent, interactive presentation tools. **Local v0 implementation; unpublished.** The core works without RubyLLM, API keys or a provider. ToolViews does not generate executable UI code.

## Try the offline demo

Ruby 3.3+ and Bundler:

```sh
bundle config set --local path vendor/bundle
bundle install
bin/demo
# Open http://127.0.0.1:3100; Ctrl-C stops the loopback-only server.
```

Present a ChoiceCard, choose a workflow, save, then refresh. “Present in chat” embeds the same component and forwards the selection to a deterministic host callback; it does not call an AI provider. The demo also renders a trusted ViewComponent and an empty-options state. Its actor is a session identifier for local demonstration, not a production authentication system. Refresh the action log to load new committed actions.

## Install into a host Rails application

The gem is not published. Build it with `bundle exec ruby scripts/package_smoke.rb`, or use a local path during development:

```ruby
# Gemfile
 gem "toolviews", path: "/path/to/tool_views", require: "tool_views"
# Optional renderer only; omit when using Partials:
 gem "view_component", "~> 4.0"
```

```sh
bundle install
bin/rails generate tool_views:install
bin/rails db:migrate
```

The installer adds four namespaced tables, a fail-closed initializer and a named Engine mount. The host owns the database, authentication, tenant resolution, policies, existing components and business services. The mount can use a different path; keep `as: :tool_views`.

## Register an existing Partial

Registration uses explicit keyword arguments. No reflection or model-selected constants are involved. The props schema and every nested object must be closed (`additionalProperties: false`). Supported JSON Schema keywords are listed in `ToolViews::Schema::KEYWORDS`; remote/local `$ref` resolution is disabled. Limits default to 32 KiB, 16 nesting levels, 20 catalog components and 60 committed actions per Surface per minute.

```ruby
ToolViews.configure do |config|
  config.scope_resolver = ->(controller) {
    user = controller.current_user
    account = controller.current_account
    user && account && ToolViews::Scope.new(actor: user.id.to_s, tenant: account.id.to_s)
  }
end

Rails.application.config.to_prepare do
  # Keep registry definitions reload-safe in development.
  ToolViews.reset_registry!
  # Register the host components here.
end
```

Use `ToolViews.reset_registry!` inside `to_prepare`, then register the components. Configuration remains intact. A complete ChoiceCard registration is in [the dummy initializer](test/dummy/config/initializers/tool_views.rb), and its existing ERB component is in [choices/card](test/dummy/app/views/choices/_card.html.erb). The essential action shape is:

```ruby
ToolViews.register :choice_card,
  description: "Choose an allowed workflow", version: "1",
  schema: ChoicePropsSchema, partial: "choices/card",
  policy: ->(access) { HostPolicy.can_present_or_read?(access) },
  expose_to: [:agent],
  actions: {
    select_option: {
      schema: ChoiceParametersSchema,
      policy: ->(access) { HostPolicy.can_select?(access) },
      handler: ->(access) {
        ChoiceSelection.call(actor: access.actor, tenant: access.tenant,
          key: access.arguments.fetch("key"))
        ToolViews::Transition.new(state: { selected: access.arguments.fetch("key") })
      }
    }
  }
```

`Access` contains `actor`, `tenant`, `operation`, `props`, `surface`, `action`, `arguments` and `context_ref`. Component policy receives `:discover`, `:present` or `:read`; action policy receives `:action`. Missing policies deny. Recompute permission from trusted host data, including authorized domain records and allowed option keys. **Membership in model-proposed props is not permission.** For database atomicity, handlers must use the same database/transaction as Surface. External side effects need host idempotency or an outbox.

Partial locals are `props`, `state`, `surface` and `error`. A trusted ViewComponent registration uses `component: MyComponent` and receives validated props as keyword arguments (`MyComponent.new(**props.symbolize_keys)`). Wrap an existing component explicitly when it needs additional Surface state. Both renderers inherit host escaping/style; avoid `raw`/`html_safe` on untrusted props.

## Present, render and restore without AI

```ruby
scope = ToolViews::Scope.new(actor: current_user.id.to_s, tenant: current_account.id.to_s)
surface = ToolViews.present(:choice_card, props: approved_props, scope: scope, context: "project:123")
# ERB:
# <%= tool_views_surface(surface, scope: scope) %>
restored = ToolViews.restore(surface.id, scope: scope)
```

Surfaces use UUIDs and persist contract digest, props, UI state, revision and optional opaque context reference. A changed schema/renderer/action signature or version fails visibly; old state is preserved for host migration. Bump `version` when changing renderer/handler semantics not represented by the schema. Business records and agent transcripts are separate authorities.

Core notifications contain metadata only. The Engine filters props, state, continuation payloads, receipts and action arguments from Rails parameter/SQL bind logs. Hosts must still project safe display fields and review their own application logs, retention and provider disclosure.

POST `/tool_views/surfaces/:id/actions` with a session-resolved identity and CSRF token:

```json
{"action":"select_option","arguments":{"key":"compare"},"base_revision":1,"idempotency_key":"request-uuid"}
```

HTML forms may use `action_name` to avoid Rails' route parameter name. Unknown fields, client policy text, forged source, non-Surface targets, unauthorized values and stale revisions reject. JSON and Turbo share one committed transition. A matching replay returns the original receipt; reuse for different arguments rejects. JSON includes `current_revision` when newer state exists. Turbo always renders the current snapshot and only addresses that Surface's DOM ID. No ActionCable transport is shipped.

Register the optional Stimulus factory from `tool_views_controller.js` in your own application. The dummy layout shows a no-node example; Rails importmap/Vite hosts can import the same factory and register `tool-views`. Turbo supplies disabled/loading submit behavior; the controller announces results, restores focus and ignores older incoming revisions.

## Optional RubyLLM presentation and continuation

Keep RubyLLM in the host Gemfile. Core never loads it:

```ruby
require "tool_views/adapters/ruby_llm"
presenter = ToolViews::Adapters::RubyLLM::PresentUI.new(
  keys: [:choice_card], scope: scope, context: "chat:456")
chat.with_tools(presenter).ask("Help me choose a workflow")
# RubyLLM supplies the real ToolCall ID. ToolViews deduplicates per actor,
# tenant, adapter and context; the model gets status/surface_id/revision.
# Host UI separately restores and renders presenter.references.
```

The bounded schema exposes an enum of approved components and a union of their props schemas; the server validates the exact selected component again. Reference collection is request-local convenience; durable presentation links are in `ToolViews::Presentation`, scoped to actor/tenant/context. Never render arbitrary model text as a component or monkeypatch chat internals.

An action can return `Transition.new(state: ..., agent: true)`. `ToolViews.deliver` invokes an optional host adapter **after** action commit. No adapter means the selection succeeds and continuation is skipped. Failure preserves selection and provides explicit retry; forwarding claims a durable lease and uses a stable delivery key. An expired lease may retry, so the host delivery backend must deduplicate that key across crashes. Exactly-once remote delivery is not promised.

`ToolViews::Adapters::RubyLLM::Continuation` takes `chat_resolver:` (authorized durable chat lookup) and `delivery:` (host durable deduplication around the supplied block). It uses `Chat#ask` for a new user turn; RubyLLM rejects pending tool calls. Core never fabricates tool messages. For slow work, set `auto_deliver = false`, keep `agent_adapter` configured, enqueue `ToolViews.deliver` from a host Active Job, and use the saved interaction ID. HTTP reports 202/pending while the action remains committed. The gem does not run a queue or poll your provider.

## Verification and compatibility

```sh
bundle exec rake test
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter
bundle exec ruby scripts/package_smoke.rb
```

Tests block TCP connections; optional Chat tests use real RubyLLM 2.1 APIs with offline provider responses. Local matrix: Ruby 3.3.5 / Rails 7.2.3 and 8.1.4; Ruby 4.0.2 / Rails 8.1.4. ViewComponent 4.15.0, Turbo Rails 2.0.23, JSONSchemer 2.5.0 and SQLite 2.9.6 were exercised. Other combinations are unverified. CI is configured, not yet executed remotely. PostgreSQL and ActionCable are unverified/unimplemented respectively.

A separately opt-in billable smoke is in `examples/provider_smoke.rb`; prepare the development DB first and load `OPENAI_API_KEY` from a secret manager or protected env file. Never put credentials in command arguments or inline exports. Run it only with explicit intent using `TOOLVIEWS_LIVE_SMOKE=1`; no live-provider success is claimed here.

See [acceptance](docs/agent/06_ACCEPTANCE_MATRIX.md), [validation evidence](docs/evidence/VALIDATION.md), [operations](docs/operations/01_RUNBOOK.md), [security](SECURITY.md) and [release checklist](docs/operations/02_RELEASE_CHECKLIST.md). Name/license clearance, formal human review and external setup trials remain open. See `LICENSE_PENDING.md`; no publication is authorized.
