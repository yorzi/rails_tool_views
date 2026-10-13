# ToolViews

Trusted Rails components as persistent, interactive presentation tools. **Local v1 implementation complete; unpublished.** The core works without RubyLLM, API keys or a provider. ToolViews does not generate executable UI code.

## Try the offline demo

Ruby 3.3+ and Bundler:

```sh
bundle config set --local path vendor/bundle
bundle install
bin/demo
# Open http://127.0.0.1:3100; Ctrl-C stops the loopback-only server.
```

Present a ChoiceCard, choose a workflow, save, then refresh. “Present in chat” embeds the same component and forwards the selection to a deterministic host callback; it does not call an AI provider. The demo also renders a trusted ViewComponent and an empty-options state. Its actor is a session identifier for local demonstration, not a production authentication system. Refresh the action log to load new committed actions.

V1 adds three host-owned reference workflows:

| URL | Try this | Boundary |
|---|---|---|
| `/v1/customer` | Correct proposed name/email, submit invalid input, fix it, then create once | Only leads; tenant and privileged attributes come from the host |
| `/v1/support` | Search/open a ticket, view its account, assign a member, request and edit a draft, approve and confirm the local queue | Two tenants/two roles; outbox only, no customer contact |
| `/v1/review` | Save a human edit, explicitly request regeneration, accept the current version, prepare/download text | Immutable host versions; accepted content is locked |

Switch the four synthetic identities to inspect role/tenant restrictions. This switch is an offline fixture, **not authentication suitable for production**. Proposed fields, draft replies and regenerated copy are deterministic fixtures; no live AI success is claimed. “Start another customer draft” and “Start a new result draft” create fresh reviewable work without overwriting completed records. The nine demo domain tables/services are in `test/dummy`, excluded from the gem runtime.

To inspect continuation failure/retry, stop the normal server and run `TOOLVIEWS_DEMO_AGENT_FAILURE=1 bin/demo`. Request a draft or regeneration; saved state remains visible. Stop it, restart `bin/demo`, reload and choose “Retry AI follow-up”. Always stop the loopback server with Ctrl-C when finished.

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

Engine controllers inherit the host's `ApplicationController`, preserving its authentication methods, filters and view helpers. When authentication lives on a subclass, name it with `config.parent_controller = "AuthenticatedController"`; it must descend from `ActionController::Base`. Review inherited filters for the mounted routes and resolve identity from authenticated server state; request arguments must never choose actor/tenant.

## Register an existing Partial

Registration uses explicit keyword arguments. No reflection or model-selected constants are involved. The props schema and every nested object must be closed (`additionalProperties: false`). Every nested value must also say what it accepts: declare `type`, `enum` or `const`, or be an `anyOf`/`oneOf`/`allOf` of branches that do, and give every array an `items` schema. An untyped or empty subschema is rejected at registration because it would accept any JSON. Supported JSON Schema keywords are listed in `ToolViews::Schema::KEYWORDS`; remote/local `$ref` resolution is disabled. Limits default to 32 KiB, 16 nesting levels, 20 catalog components and 60 committed actions per Surface per minute.

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

The component's own template posts the action. `tool_views_action_form` yields a Rails form builder whose fields are named `arguments[...]`, keeps ids unique when several Surfaces share a page, and fills in the action name, current revision, a fresh idempotency key and the source component:

```erb
<%# app/views/choices/_card.html.erb %>
<h2><%= props.fetch("title") %></h2>
<%= tool_views_action_form(surface, :select_option) do |form| %>
  <% props.fetch("options").each do |option| %>
    <%= form.radio_button :key, option.fetch("key"), checked: state["selected"] == option["key"] %>
    <%= form.label :key, option.fetch("label"), value: option.fetch("key") %>
  <% end %>
  <%= form.submit "Save" %>
<% end %>
```

`tool_views_action_button(surface, :accept, "Accept", arguments: { version: 3 })` renders a one-button form for an action whose arguments are fixed. `tool_views_action_fields(surface, :accept)` returns only the routing fields for a form you build yourself. A mistyped action name fails when the template renders, with the name in the error.

Partial locals are `props`, `state`, `surface` and `error`. A trusted ViewComponent registration uses `component: MyComponent` and receives validated props as keyword arguments. A component whose initializer also names `surface:`, `state:` or `error:` receives those as well, so it can be interactive; `include ToolViews::SurfacesHelper` in it to use the form helpers ([example](test/dummy/app/components/demo_choice_component.rb)). A component that names none of them is called exactly as before. Registration rejects a props schema that declares a property with a context name the component accepts. Both renderers inherit host escaping/style; avoid `raw`/`html_safe` on untrusted props. A string at `state["message"]` is announced in the Surface's polite status region; without one the Engine says “View ready.” or, after a committed action, “Changes saved.”

A renderer that raises is replaced by a visible `RENDER_FAILED` message with saved state intact. The exception goes to `Rails.error` (handled, source `tool_views`) and the Rails log, and a metadata-only `surface.render_failed.tool_views` event fires. A `ToolViews::Error` raised by the renderer itself, such as a host permission check, is shown as that error and is not reported as a failure.

For domain validation, a handler may raise:

```ruby
raise ToolViews::ValidationError.new(
  fields: { email: "must be a valid email address" },
  values: access.arguments.slice("name", "email"))
```

A handler can also reject with a host-defined code. Supply the wording directly or translate `tool_views.errors.<downcased code>`; built-in codes translate the same way:

```ruby
raise ToolViews::Error.new("OUT_OF_STOCK", status: 422, message: "Only two left.")
# or config/locales/*.yml -> en.tool_views.errors.out_of_stock
```

Engine-owned wording (status, revision line, AI follow-up states, saving/failed announcements) lives in `ToolViews::SurfacesHelper::TEXT`; override any key under `tool_views.surface.<key>`.

JSON receives `VALIDATION_FAILED`, `fields` and `values` with HTTP 422. Authorized HTML/Turbo re-render the trusted component with this `error`; the component maps fields to labeled controls and escapes retained values. The rejected request commits neither domain writes nor a new Surface revision/receipt. Return only approved, schema-validated form values, never private records or exception dumps. The [customer component](test/dummy/app/views/v1/_customer_form.html.erb) and [host workflows](test/dummy/app/services/demo_v1/workflows.rb) demonstrate this contract.

## Present, render and restore without AI

```ruby
scope = ToolViews::Scope.new(actor: current_user.id.to_s, tenant: current_account.id.to_s)
surface = ToolViews.present(:choice_card, props: approved_props, scope: scope, context: "project:123")
# ERB:
# <%= tool_views_surface(surface, scope: scope) %>
restored = ToolViews.restore(surface.id, scope: scope)
```

Surfaces use UUIDs and persist contract digest, props, UI state, revision and optional opaque context reference. A changed schema/renderer/action signature or version fails visibly; old state is preserved for host migration. Bump `version` when changing renderer/handler semantics not represented by the schema. Business records and agent transcripts are separate authorities.

Core notifications contain metadata only. Log redaction is scoped to the Engine instead of being added to the host's global filter list. Request logs for the mounted routes keep routing metadata (`action_name`, `base_revision`, `idempotency_key`, `source_component`, `target`, ids) and mask every other field, including action arguments, CSRF tokens and unknown injected fields. The four Engine models redact props, state, continuation payloads and receipts in `#inspect` and in SQL bind logs. Host parameters and columns that happen to be called `state`, `result` or `arguments` are untouched. On Rails 8.1, Rails itself also registers model-scoped keys for these attributes, so a parameter nested as `surface[state]` is masked while `state` and `order[state]` are not. The Engine reads only the request body; Rails logs a URL's query string before routing, so never put data there. Hosts must still project safe display fields and review their own application logs, retention and provider disclosure. The reference host additionally filters email/body/feedback; these domain filters are not an exhaustive production privacy policy.

POST `/tool_views/surfaces/:id/actions` with a session-resolved identity and CSRF token:

```json
{"action":"select_option","arguments":{"key":"compare"},"base_revision":1,"idempotency_key":"request-uuid"}
```

HTML forms may use `action_name` to avoid Rails' route parameter name, and may omit `arguments` for an action that takes none. Unknown fields, client policy text, forged source, non-Surface targets, unauthorized values and stale revisions reject. The only tolerated extras are `commit` and `button`, which Rails' own submit helpers post; their values are never read. JSON and Turbo share one committed transition. A matching replay returns the original receipt; reuse for different arguments rejects. JSON includes `current_revision` when newer state exists. Turbo always renders the current snapshot and only addresses that Surface's DOM ID. Without Turbo, a committed HTML post redirects back to the same-host page that embeds the Surface, which then shows the saved state; a missing or foreign `Referer` falls back to the Engine's own Surface page. No ActionCable transport is shipped.

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

An action can return `Transition.new(state: ..., agent: true)`. `ToolViews.deliver` invokes an optional host adapter **after** action commit. No adapter means the selection succeeds and continuation is skipped. Failure preserves selection and provides explicit retry; the adapter's exception is reported to `Rails.error` and the Rails log with a metadata-only `agent_failed.tool_views` event, while the interaction stores only `AGENT_UNAVAILABLE`; forwarding claims a durable lease (`config.delivery_lease`, 300 seconds by default) and uses a stable delivery key. An expired lease may retry, so the host delivery backend must deduplicate that key across crashes. Exactly-once remote delivery is not promised.

`ToolViews::Adapters::RubyLLM::Continuation` takes `chat_resolver:` (authorized durable chat lookup) and `delivery:` (host durable deduplication around the supplied block). It uses `Chat#ask` for a new user turn; RubyLLM rejects pending tool calls. Core never fabricates tool messages. For slow work, set `auto_deliver = false`, keep `agent_adapter` configured, enqueue `ToolViews.deliver` from a host Active Job, and use the saved interaction ID. HTTP reports 202/pending while the action remains committed. The gem does not run a queue or poll your provider.

The V1 host callback puts its business write and `DemoAgentReceipt` in one transaction keyed by `delivery_key`. A retry after a committed domain write but uncertain core acknowledgment does not create another version/reply. It rechecks current permissions and the domain version before applying an unseen request. This local receipt does not establish exactly-once delivery to an external provider. [TicketsQueryTool](examples/tickets_query_tool.rb) demonstrates a separate scoped RubyLLM query tool returning bounded display-safe references; query and presentation/action policies each authorize independently.

## Verification and compatibility

```sh
bundle exec rake test
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/adapter.gemfile bundle exec rake test:adapter
bundle exec ruby scripts/package_smoke.rb
```

Tests block TCP connections; optional Chat tests use real RubyLLM 2.1 APIs with offline provider responses. Local matrix: Ruby 3.3.5 / Rails 7.2.3 and 8.1.4; Ruby 4.0.2 / Rails 8.1.4. ViewComponent 4.15.0, Turbo Rails 2.0.23, JSONSchemer 2.5.0 and SQLite 2.9.6 were exercised. Other combinations are unverified. CI is configured, not yet executed remotely.

PostgreSQL 17 passed the full suite and the demo locally, including the separate-process concurrency tests and SQL bind redaction:

```sh
BUNDLE_GEMFILE=gemfiles/postgres.gemfile bundle install
DATABASE_URL=postgres://USER@127.0.0.1:5432/toolviews_test BUNDLE_GEMFILE=gemfiles/postgres.gemfile bundle exec rake test
```

A deadlock, serialization failure or lock timeout rolls the whole action back and is returned as `CONFLICT`; retry with the same idempotency key. MySQL is unverified. ActionCable is not implemented.

A separately opt-in billable smoke is in `examples/provider_smoke.rb`; prepare the development DB first and load `OPENAI_API_KEY` from a secret manager or protected env file. Never put credentials in command arguments or inline exports. Run it only with explicit intent using `TOOLVIEWS_LIVE_SMOKE=1`; no live-provider success is claimed here.

See [v0 acceptance](docs/agent/06_ACCEPTANCE_MATRIX.md), [v1 acceptance](docs/agent/08_V1_ACCEPTANCE.md), [v1 validation evidence](docs/evidence/V1_VALIDATION.md), [operations](docs/operations/01_RUNBOOK.md), [security](SECURITY.md) and [release checklist](docs/operations/02_RELEASE_CHECKLIST.md). Name/license clearance, formal human review and external setup trials remain open. See `LICENSE_PENDING.md`; no publication is authorized.
