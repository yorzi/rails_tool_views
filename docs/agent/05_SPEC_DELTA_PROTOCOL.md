# Spec Delta Protocol

Distinguish IMPLEMENTATION_BUG (repair code), INTENTIONAL_DELTA (record temporary implementation boundary), and PRODUCT_INTENT_CHANGE (owner revises intended product). Never edit the external baseline to hide a mismatch.

## DELTA-001 — local build from a REVIEW reference

Opened 2026-10-10; INTENTIONAL_DELTA; owner Andy Wang. The reference requires formal H2/C/R before independent public handoff. The current user explicitly authorized building v0 in this local workspace. Proceeded with reversible local implementation; no formal approval signature, public repository, license grant, push or publication was fabricated. Status: ACCEPTED_TEMPORARY for local development. Formal release/handoff needs separate owner action. Scope and security acceptance remain the pinned product contract.

Keyword registration, ViewComponent props kwargs and JSON/Turbo-only transport are reversible technical choices recorded in ADR 001. Conditional broadcasting acceptance is N/A because no channel is enabled. Remote CI, upstream runtime comparison and external trials stay open evidence gates rather than being relabeled PASS.

## DELTA-002 — owner-authorized V1 before manual inspection

2026-10-10; INTENTIONAL_DELTA; ACCEPTED_TEMPORARY for local development. Andy explicitly approved proceeding to V1 and will inspect after completion. Promote pinned P1 UC-02..05 and Demo B/C into local executable scope without fabricating external adoption, release viability or formal gate signatures. Ticket/customer/artifact data and services live in the reference host, not built-in gem business models. Customer sending is demonstrated by a local durable outbox only; no external contact.

## Audit 2026-10-13 — no new delta

WORK-20261013-01 repaired two IMPLEMENTATION_BUGs against the pinned contract: nested schemas that were not closed (SEC-10, FR-01-AC-02) and native forms for zero-argument actions (FR-05-AC-01). Redaction scope, failure reporting and overridable wording are reversible technical choices recorded in ADR 003; form helpers, ViewComponent context, host controller choice and PostgreSQL support are recorded in ADR 004 and stay inside FR-02/05/07/08 and NFR-03. Product intent, DELTA-001 and DELTA-002 are unchanged.

## DELTA-003 — owner-authorized RailsToolViews identity

2026-10-16; PRODUCT_INTENT_CHANGE; approved by the owner's explicit request in this chat. WORK-20261016-01 / ADR 005 adopts `rails_tool_views` / `RailsToolViews`, retaining legacy API and persisted identifiers. Supplemental source: OddlyNiche c100a73d80b92de2246901922caa2b7bd819d889 naming contract. No external Specs rewrite or fabricated H2 approval. Commit and push are authorized; owner subsequently specified `yorzi/rails_tool_views`, private, now created as origin. Gem publication and OddlyDock integration are not included.

## DELTA-004 — single public identity before release

2026-10-18; PRODUCT_INTENT_CHANGE; approved by the owner in this session ("Full single identity"). WORK-20261018-01 / ADR 006 removes the `ToolViews` compatibility layer that DELTA-003 retained and renames the `tool_views_*` persisted and wire identifiers to `rails_tool_views_*`. The naming supplement (OddlyNiche c100a73, supporting/07, TV-05) allowed either reading old records or an explicit migration; this delta takes the explicit-migration branch, documented in the Upgrading guide and exercised on OddlyDock's development database. Component keys, versions, digests, Surface IDs and replay semantics are unchanged. The pinned Specs are not edited from here; OddlyNiche records the matching decision separately.

## DELTA-005 — owner-authorized first publication

2026-10-18; INTENTIONAL_DELTA; accepted by the owner's explicit request to publish `0.1.0` with GitHub Pages and DNS. Andy separately confirms MIT, GitHub private vulnerability reporting, the public repository and `rails-tool-views.wangyaodi.com`. WORK-20261018-02 packages the existing implementation and removes historical publication blocks. No runtime/API/schema change and no external Specs edit. Formal H2/C/R, independent security review, live provider/MySQL qualification and external adoption remain open; release authorization is not evidence that these gates passed. Internal `0.2` and `0.3` versions were unpublished development candidates; public versioning begins at 0.1.0.
