---
layout: default
title: "Getting Started"
nav_order: 1
description: "Install the prerelease and build an interactive ChoiceCard without an AI provider."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Install the engine into a Rails host.
* Register a trusted view and persist its state.
* Resolve identity before accepting browser actions.

## Install the Engine

Use Ruby {{ site.requirements.ruby }} and Rails {{ site.requirements.rails }} with a database. This documentation describes unreleased version {{ site.version }}. The repository is private, so GitHub installation requires access; no RubyGems release exists yet.

```sh
{% if site.docs_unreleased %}bundle add rails_tool_views --git https://github.com/yorzi/rails_tool_views --branch main{% else %}bundle add rails_tool_views --version {{ site.version }}{% endif %}
bin/rails generate rails_tool_views:install
bin/rails db:migrate
```

For a local checkout, use `gem "rails_tool_views", path: "/path/to/rails_tool_views"` in the host Gemfile instead. Install `view_component` separately only if you use that renderer. RubyLLM is optional.

The installer creates four tables, a fail-closed initializer, and a mount named `:rails_tool_views`. Keep that name if you change the URL path. An existing ToolViews host follows [Upgrading]({% link _reference/upgrading.md %}) instead of running the installer again.

## Register a ChoiceCard

Put the registration below inside `Rails.application.config.to_prepare do ... end` in the host initializer. Call `RailsToolViews.reset_registry!` at the start of that block so development reloads can register the components again.

```ruby
# docs-example: registration
RailsToolViews.register :choice_card,
  description: "Choose the next step", version: "1",
  partial: "choices/card", expose_to: [:agent],
  schema: {
    type: "object", additionalProperties: false,
    required: ["title"], properties: { title: { type: "string" } }
  },
  policy: ->(access) { access.actor == "alice" && access.tenant == "demo" },
  actions: {
    select_option: {
      schema: {
        type: "object", additionalProperties: false,
        required: ["key"], properties: { key: { type: "string", enum: ["compare", "continue"] } }
      },
      policy: ->(access) { access.actor == "alice" && access.tenant == "demo" },
      handler: ->(access) {
        RailsToolViews::Transition.new(state: { selected: access.arguments.fetch("key") })
      }
    }
  }
```

The fixed `alice`/`demo` identities are an isolated tutorial fixture. Replace both policies with host authorization before using real accounts. Options are defined by trusted application code, not by model-proposed props.

## Add the Existing View

Save this Partial as `app/views/choices/_card.html.erb`:

```erb
<h2><%= props.fetch("title") %></h2>
<p>Selected: <%= state["selected"] || "None" %></p>
<%= rails_tool_views_action_form(surface, :select_option) do |form| %>
  <%= form.select :key, [["Compare", "compare"], ["Continue", "continue"]] %>
  <%= form.submit "Save" %>
<% end %>
```

The form helper includes revision, action, component, and replay fields. The host still provides Rails CSRF protection. For enhanced Turbo updates, keep Turbo enabled and register the shipped `tool_views_controller.js` asset with Stimulus as `tool-views`; ordinary forms also work without it. Follow the asset setup in the reference host's `app/views/layouts/application.html.erb` when using Propshaft.

## Present and Restore

In a Rails console, after the host has loaded the registration:

```ruby
# docs-example: lifecycle
scope = RailsToolViews::Scope.new(actor: "alice", tenant: "demo")
surface = RailsToolViews.present(:choice_card, props: { title: "Next step" }, scope: scope)
restored = RailsToolViews.restore(surface.id, scope: scope)
restored.revision
# => 1
```

Pass the Surface and authorized scope to your page and render it with `<%= rails_tool_views_surface(surface, scope: scope) %>`. For a reload, restore the stored Surface ID rather than presenting a new one.

Before a browser can post, configure `scope_resolver` to return the authenticated host's identity. See [Configuration]({% link _getting_started/configuration.md %}). The tutorial scope passed in the console does not authenticate a browser.

## Next Steps

* [How It Works]({% link _getting_started/overview.md %}) explains the state boundary.
* [Actions and Forms]({% link _core_features/actions.md %}) adds safe business actions.
