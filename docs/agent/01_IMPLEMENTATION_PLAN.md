# v0 implementation map

Purpose: reuse a trusted host Partial/ViewComponent as a persistent interactive tool. Actors and tenants are host-resolved opaque references; permissions deny by default. No account model or AI provider is required.

1. Inspect pinned upstream implementations; choose a bounded independent registry or a safe reuse path through an ADR. Use JSONSchemer rather than a copied compiler.
2. Registry: immutable key/version/digest, strict closed schemas, explicit render target and policies; capped catalogs. FR-01/02.
3. ActiveRecord runtime: Surface, Presentation (correlation), ActionExecution (replay receipt), AgentInteraction (post-commit continuation). FR-04/05.
4. One transaction for validated/authorized actions; durable idempotency and revision checks; JSON and Turbo only negotiate output after commit. FR-05/07 and SEC-01..18.
5. Optional RubyLLM Tool subclass with explicit host scope/catalog/context, real ToolCall correlation and browser references separate from acknowledgment. FR-03.
6. Explicit structured agent interaction delivered by an opt-in host adapter; no transcript writes from core. FR-06.
7. Engine controller, helper, migration installer and ChoiceCard dummy app. Native labeled controls, mobile layout, empty/error/conflict/loading/continuation states; browser keyboard and restored state verification. FR-07/08.
8. Core-only and adapter tests, fresh packaged install, local Ruby/Rails matrix, CI configuration, human docs and progress ledger. Record live/provider/PostgreSQL/external/release gaps honestly.

No ActionCable in v0: JSON and Turbo are the supported transports. Introducing broadcasting requires separate scoped subscription tests. Host domain state stays outside Surface. External side effects require host idempotency/outbox.
