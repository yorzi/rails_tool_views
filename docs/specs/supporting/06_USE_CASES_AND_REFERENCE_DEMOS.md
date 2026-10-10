# ToolViews — Ten use cases, reference applications and adoption tests

**Stage:** Product-intent research / REVIEW; not a commitment to implement ten applications or ten components. **Date:** 2026-10-10. **Source:** owner discussion, architecture and pinned upstream review. **Evidence:** hypotheses only; no user interviews, usage data or adoption measurements.

## Product-level selection rule

A strong ToolViews use case already has **trusted Rails view(s), server-side domain policies and Rails services**, but lacks standardized AI-tool discovery, persistent UI Surface, authorized actions and optional agent return. The opportunity is integration/runtime glue removal—not unrestricted UI generation, a workflow orchestrator, or a replacement for ViewComponent, Turbo, RubyLLM, or application authorization.

Every reference app must enforce: (a) explicit, scoped component/action registry; (b) model/browser args are untrusted; (c) application-owned resource resolution and authorization; (d) Surface UI state, authoritative business state and agent transcript stay separate; (e) same committed transition regardless of JSON/Turbo/Cable response format; (f) retries, version conflicts, restart recovery and accessible loading/error states.

### Priority and scope (ranked hypotheses)

| ID | Use case | Candidate UI components | AI role | Priority / horizon | Why it matters |
|---|---|---|---|---|---|
| UC-01 | Human-in-the-loop AI workflow | ChoiceCard, ApprovalCard | Request decision and continue | **P0** / S1 Choice; S3 return | Smallest full agent→UI→human→action roundtrip |
| UC-02 | AI-assisted data entry | PrefilledForm, CustomerForm | Extract/propose fields | P1 / V1 | Reuses existing validated Rails forms |
| UC-03 | Rails Admin Copilot | RecordCard, ActionPanel, ListCard | Context/query and recommend | P1 / V1 | Reuses existing domain services and auth |
| UC-04 | AI-generated results review | ResultPreview, ReviewCard | Draft/revise on feedback | P1 / V1 | Interactive review/accept/regenerate |
| UC-05 | Customer support agent | TicketCard, ReplyReview | Research/draft/triage | P1 / V1 | Demonstrates real domain action permissions |
| UC-06 | Interactive AI research | SourceCard, ComparisonCard | Gather/summarize/follow up | P2 / V2 | Structured sources and exploration |
| UC-07 | AI shopping assistant | ProductCard, ProductPicker | Recommend/compare | P2 / V2 | Catalog state with deterministic cart action |
| UC-08 | Data analysis copilot | MetricCard, ChartCard, FilterPanel | Query/interpret | P2 / V2 | Existing analytics widgets become tool-capable |
| UC-09 | Multi-step application forms | StepForm, ConfirmationCard | Assist incomplete stages | P2 / V1+ | State reuse across multi-step UX |
| UC-10 | Deterministic Rails widgets (no AI) | StatefulWidget, ActionCard | None | **P0** / S1 | Proves true framework independence |

Priority is a **qualitative hypothesis**, not a numerical market score. P0 = core technical proof, P1 = first real application differentiation, P2 = later exploration. V1/V2 are **not** V0 acceptance requirements.

## Individual use-case contracts

### UC-01 — Human-in-the-loop workflow (S1/S3)
- **Actor & trigger:** Rails application user; an agent or controller needs a choice/approval before proceeding.
- **Flow:** bounded `present_ui(choice_card)` or direct Rails present → persisted Surface → user selects an allowed option → authorized `select_option` Rails handler → server commits revision → optional structured `AgentInteraction` resumes the host agent.
- **State:** component key/digest, allowed option identifiers, selected key, revision, opaque app context link. Actual business mutation stays in Rails services.
- **Risks:** fake option, cross-tenant Surface, forged approval, duplicate click, misleading pending/agent-failed UI. High-impact approvals require host-specific policy and explicit user confirmation.
- **Proof:** S1 passes without any provider; S3 agent continuation preserves tool-call correlation and does not misrepresent tool acknowledgment as user consent. FR-01..07 / SEC-01..18 as applicable.

### UC-02 — AI-assisted data entry (V1)
- **Actor & trigger:** Account operator describes a new customer/project/ticket in natural language.
- **Flow:** AI proposes fields → allowlisted PrefilledForm → user edits/corrects → validated `submit_form` calls existing Rails service → record created once; errors re-render form.
- **State:** draft/surface state separate from persisted Customer/Project/Ticket; never let AI assign protected identifiers or privileged attributes.
- **Risks/proof:** mass assignment, forbidden record association, duplicate create, private field leakage. Fresh-app demo must reject unauthorized values, keep validation errors and prove service executes once.

### UC-03 — Rails Admin Copilot (V1)
- **Actor & trigger:** Authenticated staff asks to locate or inspect a subset of records.
- **Flow:** existing scoped Rails query tool selects IDs → Record/ListCard render through authorized server-side resolver → operator clicks view/filter or `prepare_followup` → Rails service performs permitted action or agent prepares draft.
- **State:** store only permitted identifiers and display-safe projections, not ActiveRecord object dumps.
- **Risks/proof:** data enumeration, tenant crossing, stale objects, privileged action spoofing. Query tool and ActionDispatcher **each** authorize independently; staff roles produce different allowed components/actions.

### UC-04 — Generated result review (V1)
- **Actor & trigger:** Content/creative operator requests campaign, product copy or report variants.
- **Flow:** agent creates candidate artifacts → ResultPreview/ReviewCard displays versions → `edit` or `accept` deterministic Rails actions; `regenerate` explicitly emits AgentInteraction; `export` uses host service.
- **State:** artifact revisions in host data store; Surface only holds current selection/edit UI references.
- **Risks/proof:** stale approval, regeneration after accepted revision, leaking private prompts, failed export retries. Show accept/edit/regenerate boundaries with no implicit model business writes.

### UC-05 — Customer support assistant (V1; official business demo)
- **Actor & trigger:** Support staff opens ticket and asks agent for recommended next step.
- **Flow:** authorized TicketCard displays scoped record → operator selects `view_account`, `draft_reply` or `assign_ticket` → deterministic Rails actions for access/assignment, optional LLM draft for reply → explicit operator review before sending.
- **State:** ticket status and assignee remain in host domain database; Surface stores view/review state.
- **Risks/proof:** customer data exposure, wrong-account ticket, sending without explicit confirmation, role escalation, duplicate assignment. One demo with two roles and two tenants must reject forged source/action.

### UC-06 — Interactive AI research (V2)
- **Actor & trigger:** Analyst asks for a comparison of sources and conclusions.
- **Flow:** agent gathers **attributed** sources → SourceCard/ComparisonCard → user filters, selects evidence and requests deeper follow-up → scoped agent interaction.
- **State:** host stores actual report/source provenance; Surface keeps filters/selection only.
- **Risks/proof:** fabricated citations, private source access, prompt injection within source text. Citation data must be verified by host; no claim of cross-protocol portability in V0.

### UC-07 — Shopping assistant for a Rails commerce app (V2)
- **Actor & trigger:** Customer requests shortlist of goods.
- **Flow:** agent requests catalog query → ProductCard/Picker displays host-resolved products → user compares/selects → allowlisted `add_to_cart` Rails service; checkout/payment remains outside ToolViews.
- **State:** cart/inventory/pricing is business authority; not model-supplied props.
- **Risks/proof:** spoofed price/availability/product ID, double add, cross-account cart. Recheck current price, inventory and policy at Action time. Not a Shopify plugin promise.

### UC-08 — Data analysis copilot (V2)
- **Actor & trigger:** Authorized analyst asks for a time-series metric comparison.
- **Flow:** bounded scoped query → pre-existing MetricCard/ChartCard → FilterPanel changes time range or metric → deterministic re-query/render; optional agent interprets only the approved aggregate.
- **State:** host owns query/results and source permissions; Surface holds filter settings and query reference.
- **Risks/proof:** query-injection, unauthorized dimensions, leakage of row-level/private data, resource-heavy queries. Strict server-approved dimensions and query cost budgets.

### UC-09 — Multi-step application forms (V1+)
- **Actor & trigger:** User starts a multi-stage onboarding/request; optional agent helps fill gaps.
- **Flow:** StepForm/ConfirmationCard → validated next/back/save → persisted draft → explicit final submission via domain service; agent may propose values but cannot bypass mandatory steps.
- **State:** host-owned draft and completion state; Surface captures current step/revision/validation feedback.
- **Risks/proof:** skipped mandatory consent, stale step, unsafe resubmission, resumed sessions under a different account. Multi-component orchestration is out of V0 scope.

### UC-10 — AI-free Rails component runtime (S1)
- **Actor & trigger:** Existing Rails Controller renders a registered StatefulWidget/ActionCard.
- **Flow:** Rails code presents component → Surface persists → user clicks authorized action → Turbo refreshes UI → full reload reconstructs state; optional adapters **never load**.
- **State:** ActiveRecord-backed Surface with revision and idempotency, scoped to actor/tenant.
- **Risks/proof:** hidden mandatory RubyLLM dependency, in-memory-only store, stale Turbo target, action replay. CI without RubyLLM and without network + restart/worker case.

## Official reference demos and gates

| Demo | Stage | Minimum meaningful demonstration | Not included |
|---|---|---|---|
| **A — Interactive Choice Card** (UC-01 + UC-10) | S1 offline, S2 tool, S3 optional continuation | existing Partial/ViewComponent, direct present, authorization, persisted state, one deterministic choice, Turbo refresh, reload/replay/conflict, then optional RubyLLM tool roundtrip | General approval engine, trees, multi-step builder |
| **B — Support Ticket Assistant** (UC-03 + UC-05) | V1 after release viability | real record resolver, staff role/tenant policy, TicketCard, trusted assignment, AI draft subject to human review, cross-tenant denial | Autonomous customer contact or privileged writes |
| **C — Generated Result Review** (UC-04) | V1 | existing ResultPreview, accept/edit as deterministic services, regenerate as explicit agent continuation, revisions and failure recovery | Full creative production or rendering engine |

Demo C can use a Creative Studio-like **fixture**; Demo A can be tested in a RubyLLM Workbench-like sample. Named existing applications are **candidate validation contexts**, not automatic dependencies or commitments to modify those repositories.

## Evidence-driven evaluation

Each adoption trial records: `UC-ID`, developer profile, existing component/service baseline, Rails/Ruby versions, task and permissions, estimated steps vs actual steps, integration LOC/maintenance burden, successful actions, safety failures, elapsed time and observed usefulness. Compare the same workflow both **with** and **without** ToolViews; count reduced custom glue, **not** just faster screenshots.

**Continue/expand:** UC-01+UC-10 pass S1/S3 and external developers demonstrate lower integration cost; at least one V1 demo (prefer UC-05 or UC-04) shows business value beyond rendering a card. **Pivot:** if only validation/catalog remains novel, contribute upstream to GenerativeUI or focus on a narrow adapter. **Kill/avoid expansion:** if no repeatable integration benefit or authorization/state safety cannot be proven.

## Requirements and scope guardrails

Existing FR-01..08, NFR-01..06, SEC-01..18 and SP-01..12 remain canonical. The UC scenarios are **use-case evidence and future reference contracts**, not new V0 FRs. Add an FR or change a canonical V0 gate only through a documented product-intent change. Implementations must live in a separate OSS repo after explicit human handoff.
