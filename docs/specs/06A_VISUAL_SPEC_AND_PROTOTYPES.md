# Visual and prototype applicability

**Classification:** Open-source developer integration with one end-user demo. Product visual identity is NOT_APPLICABLE for V0 because the gem reuses host components; functional interaction visuals are INCLUDED.

## Required design evidence
- VIS-01: [data/control flow](assets/design/flow.mmd) — reference-only architecture, not exact UI geometry.
- SCR-01: inline chat select-card and selection submission; low-fidelity concept below, no high-fidelity concept required before this code-first feasibility spike.
- SCR-02: same component in ordinary Rails page; same props/action behavior.
- SCR-03: visible invalid/stale/denied/agent unavailable fallbacks.

~~~text
┌ Chat message ─────────────────────────────┐
│ AI: Please select an option.             │
│ ┌── trusted Rails SelectCard ──────────┐ │
│ │ Choose a workflow                   │ │
│ │ ( ) Compare options                 │ │
│ │ ( ) Continue analysis               │ │
│ │ [Continue]                           │ │
│ └──────────────────────────────────────┘ │
│ Submitted ✓ / AI follow-up pending…      │
└───────────────────────────────────────────┘
~~~

## Visual authority
Flow diagram and ASCII wireframe are EXPLORATION/REFERENCE; neither overrides feature/security contracts. Before Gate H1 capture human-reviewed lightweight UI state board for mobile/desktop and a working interactive prototype or document a signed rationale for its absence. No actual visual prototype exists in this Specs-stage commit.

## Verification
Tab/Enter/Space keyboard operation, error focus/announcements, 360px width, reload restored values, no model call on deterministic interaction. The app repo maintains screenshots and browser test reality after Gate I.