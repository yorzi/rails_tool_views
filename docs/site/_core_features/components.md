---
layout: default
title: "Registering Components"
nav_order: 1
description: "Turn a trusted Partial or ViewComponent into a validated presentation capability."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Define closed schemas and explicit component keys.
* Reuse a Partial or ViewComponent.
* Change contracts without reinterpreting saved state.

## Define the Contract

Start with the complete [ChoiceCard registration]({% link _getting_started/getting-started.md %}#register-a-choicecard). Supply `description:`, `schema:`, and exactly one of `partial:` or `component:`. Supply a component policy and a policy for every action; missing policies deny.

Keys use lowercase letters, digits, and underscores, start with a letter, and contain at most 64 characters. Register each key once per registry. Use `version:` to distinguish semantic changes.

Every object schema is closed with `additionalProperties: false`. Every array declares `items`. Nested values must declare a type, enum, const, or constrained schema combination. `$ref` and unsupported keywords are rejected. Unknown props are rejected rather than silently discarded.

## Reuse a Renderer

A Partial receives `props`, `state`, `surface`, and `error` locals. A ViewComponent receives validated props as keyword arguments. It can opt into runtime context by explicitly naming `surface:`, `state:`, or `error:` in its initializer. Include `RailsToolViews::SurfacesHelper` to use the action helpers.

The props schema cannot declare a property that conflicts with an opted-in context keyword. Use Rails escaping for user-provided values; do not use `raw` or `html_safe` to render them.

## Check Policy at Each Operation

A component policy receives an `Access` with operation `:discover`, `:present`, or `:read`. Discovery has empty props and no context reference, so a policy must handle that case. The action policy receives `:action`, validated arguments, and the Surface.

`Access` exposes `actor`, `tenant`, `operation`, `props`, `surface`, `action`, `arguments`, and `context_ref`. Resolve business records through actor/tenant-scoped host queries. Model-selected identifiers and offered options never replace that check.

## Change a Contract

The digest covers key, version, schema, renderer identity, and action schemas. Changing these makes existing Surfaces incompatible. Bump `version` when renderer or handler semantics change without changing these structural fields. Restore rejects a mismatched contract and leaves saved state intact; you provide an explicit migration or recreate the Surface.

## Next Steps

* [Actions and Forms]({% link _core_features/actions.md %}) adds handlers.
* [RubyLLM Integration]({% link _advanced/ruby-llm.md %}) exposes an explicit catalog.
