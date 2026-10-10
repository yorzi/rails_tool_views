# Spec Delta Protocol

Distinguish IMPLEMENTATION_BUG (repair code), INTENTIONAL_DELTA (record temporary implementation boundary), and PRODUCT_INTENT_CHANGE (owner revises intended product). Never edit the external baseline to hide a mismatch.

## DELTA-001 — local build from a REVIEW reference

Opened 2026-10-10; INTENTIONAL_DELTA; owner Andy Wang. The reference requires formal H2/C/R before independent public handoff. The current user explicitly authorized building v0 in this local workspace. Proceeded with reversible local implementation; no formal approval signature, public repository, license grant, push or publication was fabricated. Status: ACCEPTED_TEMPORARY for local development. Formal release/handoff needs separate owner action. Scope and security acceptance remain the pinned product contract.

Keyword registration, ViewComponent props kwargs and JSON/Turbo-only transport are reversible technical choices recorded in ADR 001. Conditional broadcasting acceptance is N/A because no channel is enabled. Remote CI, upstream runtime comparison and external trials stay open evidence gates rather than being relabeled PASS.
