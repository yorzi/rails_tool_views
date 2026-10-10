# ADR 002 — host workflows, validation feedback and independent business versions

Date: 2026-10-11. Status: implemented locally. Work: WORK-20261010-02; UC-02..05 / Demo B/C; DELTA-002.

The owner authorized V1 before manual inspection. The pinned contracts require existing host services and independent query/action authorization, rather than a built-in customer or support product. A form must retain approved invalid input; multiple Surfaces may refer to the same business record; a post-commit continuation may succeed before its core acknowledgment is saved.

Keep customer/ticket/artifact models, policies, query tools, exports and local outbox in the reference host. The gem still installs four tables. Register three trusted Partials with closed schemas and explicit policies. Persist identifiers and UI references in Surface; resolve business records and their associations under current role/tenant permissions on every operation. Native HTML form domain IDs/versions are bounded numeric strings; core revision retains its existing integer contract.

Add bounded `ValidationError(fields:, values:)` as generic feedback. On rejection, roll back domain writes, Surface update and receipt. JSON returns 422; authorized HTML/Turbo render the current trusted component with approved retained input. Error values are not written into Surface. Fields/messages are bounded and renderer escaping remains mandatory; the host chooses the returned safe values.

Inherit the host's `ApplicationController` to preserve authentication methods/filters/helpers on mounted requests. V1 HTTP rendering exposed their loss under direct `ActionController::Base` inheritance. Installed-gem tests now prove a host scope method and helper work. This requires an HTML-capable host and review of inherited filters; the synthetic demo identity switch is not production authentication.

Lock and compare business versions independently of Surface revision. Customer submission prevents second creation; ticket/reply versions protect assignment and reviewed content; immutable artifact versions prevent stale acceptance or delayed regeneration overwriting human edits. Acceptance locks a version and export binds to it. New drafts are separate records. Hidden buttons improve usability, while server policies remain authoritative.

The offline Agent callback validates persisted correlation, current policy and domain version. It commits business output with `DemoAgentReceipt` keyed by the stable delivery key; retries after uncertain acknowledgment do not duplicate output. Regeneration/drafting cannot accept or queue automatically. Reply delivery is a local durable outbox with explicit review and confirmation; no external sender is configured. Real-provider/remote side-effect deduplication remains a host contract.

Alternatives were to put business services in core, copy domain records into props, reuse Surface revision as business version, or hold the action transaction open during model work. Each would couple the gem to a domain or obscure authority/recovery boundaries. The selected separation adds host code, and no measured integration-cost advantage is claimed.

Parameter/SQL filtering includes approved form values and CSRF tokens; the example host additionally filters its email/body/feedback attributes. Rails 7.2/8.1 sharing the local SQLite test schema exposed a boolean default introspection mismatch, resolved by an explicit `DemoStaff` attribute default. Existing inactive records are not reactivated by seeding.

Reconsider these choices after manual API/security review, real host integration, provider crash/retry trials, PostgreSQL concurrency and measured external setup effort. This ADR grants no license, publication or formal source gate approval.
