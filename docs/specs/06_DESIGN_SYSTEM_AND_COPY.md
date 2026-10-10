# UX / design contract for an OSS Rails component runtime

This is a developer SDK, not a consumer UI brand. Do not impose a default product aesthetic on host Rails apps. Components inherit host styling; optional example CSS must be namespaced and removable.

## Surfaces
- SCR-01: Developer demo page (registered component, props, preview, present action, action log).
- SCR-02: Inline chat bubble containing one interactive component; host renders Surface, never tool JSON.
- SCR-03: Surface recovery/error state for denied access, stale revision, malformed component, missing renderer and agent unavailable.

## Interaction principles
- One visible choice with explicit label/legend; Submit/Continue button clarifies whether it updates locally, saves to server or requests AI follow-up.
- Accessible HTML form control before custom widget. Keyboard tab order natural. Visible focus, disabled and pending indicators; errors connected to fields using aria-describedby and announced via role=status/alert appropriately.
- States: initial, loading, empty options, ready, submitted, agent_pending, validation_error, forbidden, conflict/reload, provider_failure, incompatible_schema. No blank error swallowing.
- Narrow viewports: inline Surface width 100%, no mandatory horizontally scrolling cards, touch targets sized for common mobile devices.
- Developer-facing copy: precise, no anthropomorphism. Example: "Selection saved"; "This view changed. Refresh to continue"; "Your choice was saved, but the AI follow-up could not complete."

## Demo visual specification
Wireflow is maintained in 06A and assets/design; a low-fidelity ASCII/Mermaid flow is authoritative for sequence only. No canonical colors, logo or marketing screenshots; this is intentional because the host owns design. A functional narrow-width browser prototype is required before Gate H1, and system tests before release.

## No unsafe "magic"
UI output must only include registered components; no invisible controls or auto-submitted destructive user choices. Avoid assuming every component is safe to expose as agent-callable.