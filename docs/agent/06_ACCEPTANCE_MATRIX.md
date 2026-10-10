# Acceptance matrix — v0 local evidence

Source: pinned 04_FEATURE_MVP_SPECS and SEC-01..18. LOCAL is not CI, PROVIDER, USER or BUSINESS proof. Read ../evidence/VALIDATION.md for exact commands and limits.

| AC | Evidence | Local result / boundary |
|---|---|---|
| FR-01-AC-01 | registry_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-01-AC-02 | registry_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-01-AC-03 | registry_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-02-AC-01 | rendering_test.rb; registry_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-02-AC-02 | rendering_test.rb; registry_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-03-AC-01 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-03-AC-02 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Real Chat acknowledgment and authorized HTML share an explicit reference; no model-text renderer. |
| FR-03-AC-03 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-03-AC-04 | adapter/ruby_llm_test.rb; privacy_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-04-AC-01 | runtime_test.rb; durability_test.rb; rendering_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-04-AC-02 | runtime_test.rb; durability_test.rb; rendering_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-04-AC-03 | runtime_test.rb; durability_test.rb; rendering_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-01 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-02 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-03 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-05-AC-04 | runtime_test.rb; controller_test.rb; durability_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-06-AC-01 | continuation_test.rb; adapter/ruby_llm_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-06-AC-02 | continuation_test.rb; adapter/ruby_llm_test.rb | LOCAL_PASS; Actual RubyLLM ask/new-user-turn API; pending tool calls reject. No live provider. |
| FR-06-AC-03 | continuation_test.rb; adapter/ruby_llm_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-07-AC-01 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-07-AC-02 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; Ready/loading/empty/invalid/denied/conflict/pending/failed/completed tested by browser or integration fixtures. |
| FR-07-AC-03 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; 360px Space/Tab/Enter, native labels/legend, error-describedby and focus observed; no full screen-reader audit. |
| FR-07-AC-04 | controller_test.rb; rendering_test.rb; manual browser evidence | LOCAL_PASS; JSON/Turbo parity and bounded targets pass; ActionCable N/A, disabled. |
| FR-08-AC-01 | scripts/package_smoke.rb; README; release checklist | LOCAL_PASS; Offline positive/negative behavior covered. |
| FR-08-AC-02 | scripts/package_smoke.rb; README; release checklist | LOCAL_PASS; Mocked real Chat loop passes; live-provider script documented but NOT_RUN. |
| FR-08-AC-03 | scripts/package_smoke.rb; README; release checklist | LOCAL_PARTIAL / RELEASE_OPEN; Contribution/security/release documentation exists; license/disclosure/release approval remain pending. |
| NFR-01-AC-01 | registry_test.rb; rendering_test.rb; controller_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| NFR-02-AC-01 | durability_test.rb; runtime_test.rb; controller_test.rb | LOCAL_PASS; Offline positive/negative behavior covered. |
| NFR-02-AC-02 | durability_test.rb; runtime_test.rb; controller_test.rb | LOCAL_PASS; Fresh process and concurrent workers pass. Channels N/A while absent. |
| NFR-03-AC-01 | local Ruby/Rails matrix; .github/workflows/ci.yml | LOCAL_PARTIAL / RELEASE_OPEN; Three exact local combinations pass; remote Linux CI is configured but NOT_RUN. |
| NFR-04-AC-01 | privacy_test.rb; offline network guard; package smoke | LOCAL_PASS; Offline positive/negative behavior covered. |
| NFR-05-AC-01 | privacy_test.rb; SECURITY.md; host projection/retention contract | LOCAL_PASS; No transcript/credentials/raw domain dump is persisted by core; accepted display fields require host projection. |
| NFR-06-AC-01 | manual browser evidence; rendering_test.rb | LOCAL_PASS; Desktop/360px no-overflow, restored choice and focus; assistive-technology audit still a release review. |

## Security coverage

| SEC | Executable evidence / applicability |
|---|---|
| SEC-01 | Registry unknown component/untrusted renderer/unknown props; no eval/constantize. |
| SEC-02 | Escaped script title in native Partial; ViewComponent safe render. |
| SEC-03 | Unknown action and missing policy reject before handler. |
| SEC-04 | Runtime/HTTP different actor or tenant returns unavailable with no props. |
| SEC-05 | Trusted host option allowlist rejects values even when model props offer them. |
| SEC-06 | Stale revision and independent concurrent workers produce conflict without overwrite. |
| SEC-07 | Action replay receipt, tool correlation and provider retry create once; concurrent same key effects once. |
| SEC-08 | Presentation keys isolate actor/tenant/adapter/context; chat scopes differ. |
| SEC-09 | Digest/missing component fails recoverably without deleting state. |
| SEC-10 | Size/depth/unknown-field/ref/schema tests; TCP blocked in tests. |
| SEC-11 | Provider callback failure, unchanged committed selection, explicit retry and active lease. |
| SEC-12 | Metadata-only notifications, filtered parameters, snapshot projection and retention deletion. |
| SEC-13 | HTTP business_rules/tenant/policy-like extra fields rejected; host policy recomputed. |
| SEC-14 | Forged source and action not declared on registered component reject. |
| SEC-15 | Actor/tenant HTTP read/write denial. ActionCable subscription/broadcast N/A; no channel shipped. |
| SEC-16 | Client target body rejects; replacement target is authorized Surface only; browser ignores older revision. |
| SEC-17 | Identical JSON/Turbo committed state and replay; format does not branch mutation. |
| SEC-18 | SQLite restored in new Ruby process; two separate concurrent workers; durable receipts. |

## Evidence gates outside local v0

Gate V remains PARTIAL: actual upstream loader/catalog and package probes ran, and ToolViews controls pass, but no complete DSPy/A2UI runtime security comparison, neutral-core upstream extraction or measured extension comparator exists. SP-06 schema byte sizes are local measurements, not live model reliability/token benchmarks. SP-07 maintainer contact and external developer trials were not authorized/performed. Gate H2/R remains OPEN. No acceptance row turns those limits into a PASS.
