---
layout: default
title: "Generating a Component"
nav_order: 5
description: "Generate a Partial with closed schemas and configure host authorization before using it."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Generate the registration, Partial and test scaffold.
* Load several components during Rails reloads.
* Replace denied policies with host authorization.

## Generate the Files

After [installing the engine]({% link _getting_started/getting-started.md %}), run:

```sh
bin/rails generate rails_tool_views:component review_card
```

Use a flat snake_case name of at most 64 characters, starting with a letter. The generator creates:

```text
config/rails_tool_views/components/review_card.rb
app/views/rails_tool_views/components/_review_card.html.erb
test/rails_tool_views/components/review_card_test.rb
```

The command refuses existing destinations, including with `--force`, and paths that follow a symlink outside your application. Resolve a conflict before running it again. It does not rewrite your initializer.

## Load the Registrations

Add this to your existing `config/initializers/rails_tool_views.rb`. Keep all registrations in one shared reload block:

```ruby
Rails.application.config.to_prepare do
  RailsToolViews.reset_registry!
  Dir[Rails.root.join("config/rails_tool_views/components/*.rb")].sort.each do |file|
    load file
  end
  # Register other trusted components here too.
end
```

Do not reset the registry inside individual files. A later file would remove earlier components. Configure your [scope resolver]({% link _advanced/production.md %}) separately so requests use the authenticated actor and tenant.

## Authorize the Component

Both generated policies return `false`. Presentation fails with `NOT_ALLOWED` until you replace the component policy. Actions remain denied until you replace their policy too. Use trusted host records to authorize `access.actor`, `access.tenant` and allowed argument values. The generated component is not exposed to an AI adapter.

The scaffold accepts a bounded `title` prop and a bounded `value` argument. Both schemas reject extra fields. The handler changes UI state only. Replace its action and policies to match your domain; the [actions guide]({% link _core_features/actions.md %}) explains transactions and authorization.

Once your policies allow the current scope:

```ruby
surface = RailsToolViews.present(:review_card,
  props: { title: "Review the draft" }, scope: scope)
```

Render it with `rails_tool_views_surface(surface, scope: scope)`. The Partial uses Rails escaping and the action form helper to supply the revision, replay key and source component.

## Run the Generated Test

```sh
bin/rails test test/rails_tool_views/components/review_card_test.rb
```

The test checks the initial denied presentation through the public API. It expects the shared registration block to load your definition in the test environment. If your test helper resets the registry, run the shared reload hook afterward. When you authorize the component, replace the denial test with allowed and denied actor/tenant cases, invalid arguments, and saved-state checks. Keep the generated test out of the runtime package.

For a ViewComponent, use the [registration guide]({% link _core_features/components.md %}); this generator creates a Partial only.
