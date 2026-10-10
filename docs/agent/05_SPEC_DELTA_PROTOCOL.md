# Spec Delta Protocol

Distinguish IMPLEMENTATION_BUG (repair code), INTENTIONAL_DELTA (record temporary implementation boundary), and PRODUCT_INTENT_CHANGE (owner revises intended product). Never edit the external baseline to hide a mismatch.

## DELTA-001 — local build from a REVIEW reference

Opened 2026-10-10; INTENTIONAL_DELTA; owner Andy Wang. The reference requires formal H2/C/R before independent public handoff. The current user explicitly authorized building v0 in this local workspace. Proceeded with reversible local implementation; no formal approval signature, public repository, license grant, push or publication was fabricated. Status: ACCEPTED_TEMPORARY for local development. Formal release/handoff needs separate owner action. Scope and security acceptance remain the pinned product contract.

Keyword registration, ViewComponent props kwargs and JSON/Turbo-only transport are reversible technical choices recorded in ADR 001. Conditional broadcasting acceptance is N/A because no channel is enabled. Remote CI, upstream runtime comparison and external trials stay open evidence gates rather than being relabeled PASS.

## DELTA-002 — owner-authorized V1 before manual inspection

2026-10-10; INTENTIONAL_DELTA; ACCEPTED_TEMPORARY for local development. Andy explicitly approved proceeding to V1 and will inspect after completion. Promote pinned P1 UC-02..05 and Demo B/C into local executable scope without fabricating external adoption, release viability or formal gate signatures. Ticket/customer/artifact data and services live in the reference host, not built-in gem business models. Customer sending is demonstrated by a local durable outbox only; no external contact.
