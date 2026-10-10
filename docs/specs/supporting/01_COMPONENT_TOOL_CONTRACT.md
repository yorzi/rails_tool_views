# Component → Tool contract (proposed API, not implemented)

## Developer contract
~~~ruby
# Proposed shape; adapt during Phase 0 only through an ADR.
ToolViews.register :choice_card do
  description "Ask user to select one allowed option"
  partial "choices/card"
  property :title, type: :string, required: true
  property :options, type: :array, items: { type: :object, properties: {
    key: { type: :string }, label: { type: :string }
  } }
  action :select_option, handler: ChoiceSelection, parameters: SelectOptionSchema
  expose_to :agent
end

# Deterministic Rails use works without an AI SDK
surface = ToolViews.present(:choice_card, props: {title: "Choose", options: [...]},
  actor: current_user, context: @project)
# render surface using a helper on a normal Rails page
~~~

## Registry metadata
id:string; version/fingerprint; description; props_schema; renderer_target; allowed_actions; exposure_policy. Registry only stores application-defined code references, not instances. This schema is authored explicitly; model-provided props are never used to select Ruby constants, routes or template names.

## Public presentation protocol V0
~~~json
{"component":"choice_card","props":{"title":"Choose","options":[{"key":"a","label":"A"}]}}
~~~
The trusted adapter adds actor, context and correlation key from server state; model is forbidden from asserting owner/tenant. Result on success:
~~~json
{"status":"presented","surface_id":"server-id","revision":1}
~~~
Failure returns {status:"rejected",code:"INVALID_PROPS"|"NOT_ALLOWED"|...} with safe, non-sensitive detail.

## UI reference / display
The model receives an acknowledgment, but the browser receives a server-side Surface reference. Host explicitly embeds renderer in chat or page. No global monkeypatch of chat message partials; provide an opt-in helper/integration hook. Tool-call correlation must be scoped to conversation and adapter, use unique persistence key and be safe under retry.

## Schema engineering
Prefer strict object schema, required rules and closed properties; cap nesting and payload size. Tool descriptor generation is a separate Adapter API from registry rendering. The default single present_ui tool exposes an explicitly selected subset; do not leak all application components to every agent.

## Trade-off
One tool per component gives simple schemas but large tool sets. One bounded generic present_ui gives composability potential but may produce a large union schema. V0 tests both with 1, 5, 20 components and measures prompt/token overhead + model reliability before locking the API.

## Compatibility
RubyLLM adapter chooses supported tool-call callbacks/Tool class; core gem never requires ruby_llm. generative_ui bridge is assessed via upstream public API and license, not forked by default. Importing generative_ui catalogs and component tree composition is **future**, not a V0 promise.
Use-case binding: [UC-01/10](06_USE_CASES_AND_REFERENCE_DEMOS.md) prove a single allowlisted ChoiceCard and an AI-free Rails widget. The Registry must remain reusable by UC-02/03/04/05 later without silently exposing every host component to an agent.
