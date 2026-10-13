# V1 acceptance — local implementation evidence

Authority: owner-approved local promotion of pinned UC-02..05 / Demo B/C, recorded in DELTA-002. These V1-* labels are **implementation-local acceptance identifiers**, not new FR/AC IDs or amendments to the external baseline. V0 acceptance remains in [06](06_ACCEPTANCE_MATRIX.md); exact results/limits are in [V1 validation](../evidence/V1_VALIDATION.md).

| Local ID / source | Required behavior | Executed evidence / result |
|---|---|---|
| V1-FORM-01 / UC-02 | Proposed fields editable; approved invalid values and field errors retained without committing | v1_test, v1_controller_test; JSON/HTML/Turbo 422, browser keyboard correction; LOCAL_PASS |
| V1-FORM-02 / UC-02 | Protected tenant/role attributes denied; trusted tenant; service creates once | v1_test; durable same-key replay, repeat submission denial, v1_durability_test concurrent processes; LOCAL_PASS |
| V1-FORM-03 / UC-02 | Domain write and Surface/receipt roll back together; duplicate email remains local feedback | v1_test post-write rejection and uniqueness; LOCAL_PASS |
| V1-QUERY-01 / UC-03 | Query independently checks current staff/tenant; bounded safe projection and escaped search | v1_test, adapter/v1_test; capped ID/subject/status, no email/body; LOCAL_PASS |
| V1-QUERY-02 / UC-03 | Resolver/presentation/dispatch independently authorize; revoked staff and wrong-account association deny | v1_test, v1_controller_test; real SDK scoped query/presentation fixture; LOCAL_PASS |
| V1-SUPPORT-01 / Demo B | Two roles/two tenants yield different components/actions | v1_test, v1_controller_test; browser identity switch/denied foreign ticket; LOCAL_PASS |
| V1-SUPPORT-02 / UC-05 | Account view and assignment use trusted association/member/domain version; forged source/action reject | v1_test, controller tests; assignment replay/stale version and foreign member denial; LOCAL_PASS. Account view over the real form returned 400 until WORK-20261013-01; now covered by controller_test and the HTTP pass |
| V1-SUPPORT-03 / UC-05 | Draft only after explicit continuation; review required; lead and confirmation required for local outbox | v1_test, v1_controller_test; browser draft/edit/approve/confirm, one local outbox; LOCAL_PASS, no external send |
| V1-REVIEW-01 / Demo C | Human edit makes immutable host version, separate from Surface revision | v1_test; preserved old body and cross-Surface stale edit rejection; LOCAL_PASS |
| V1-REVIEW-02 / UC-04 | Accept current version; accepted edit/regeneration deny; start separate new draft | v1_test, v1_controller_test; browser accepted lock; LOCAL_PASS |
| V1-REVIEW-03 / UC-04 | Regeneration is explicit; failed continuation preserves changes and permits retry | v1_test; browser actual failure fixture → stop/restart → restore → retry; LOCAL_PASS |
| V1-REVIEW-04 / UC-04 | Delayed regeneration cannot overwrite newer edit/accepted result | v1_test current domain version and accepted checks; LOCAL_PASS |
| V1-EXPORT-01 / UC-04 | Export only accepted exact version; failed export rolls back and same-key retry succeeds | v1_test; no artifact/version mutation or duplicated export; LOCAL_PASS |
| V1-EXPORT-02 / UC-04 | Download reauthorizes tenant/role and serves exact accepted content | v1_controller_test; browser file download/content checked; LOCAL_PASS |
| V1-RECOVERY-01 / UC-02/04 | New process restores authoritative business state and Surface receipts | v1_durability_test separate Ruby boot; LOCAL_PASS |
| V1-RECOVERY-02 / UC-04/05 | Committed callback write with uncertain acknowledgment replays once | v1_test durable host receipt; forged payload/delivery correlation rejects; LOCAL_PASS, no remote exactly-once claim |
| V1-PRIVACY-01 / SEC-02/12 | Escaped artifact body; actual SQL/request/notification redaction | privacy_test, v1_privacy_test; Engine-scoped request and SQL redaction, host body filters and metadata-only events; LOCAL_PASS within tested fields |
| V1-UI-01 / FR-07 / NFR-06 | Native labels/keyboard, error association/focus, saving/failed/completed, mobile | browser and HTTP fixtures; 360px measured no overflow, screenshots; LOCAL_PASS, no full accessibility audit |
| V1-HOST-01 / FR-08 | Packaged Engine uses host scope method and helper; validation/restore/eager load work | fresh installed-gem host probes; LOCAL_PASS |
| V1-COMPAT-01 / NFR-03 | Entire core/V1 suite and eager load pass exact local combinations | Ruby 3.3.5 Rails 7.2.3/8.1.4, Ruby 4.0.2 Rails 8.1.4; LOCAL_PASS, remote CI NOT_RUN |

Fixtures exercise real Rails services/transactions and real optional RubyLLM Tool APIs with mocked provider responses. They do not demonstrate language extraction quality, live model drafts, external delivery, production authentication, adoption or business benefit. Formal Gate V/H2/R and [release checklist](../operations/02_RELEASE_CHECKLIST.md) remain open. Andy's manual inspection is pending, as requested.
