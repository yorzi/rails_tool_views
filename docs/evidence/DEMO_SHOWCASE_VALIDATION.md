# Demo showcase validation

WORK-20261016-04, 2026-10-16. Local Ruby 3.3.5 / Rails 8.1.4.

- Full regression: 83 tests, 665 assertions, zero failures/errors/skips; eager load PASS.
- Documentation: 15 guides, zero style errors/warnings; site build PASS; 1,075 generated local links, zero broken; internal records excluded.
- Browser at 127.0.0.1:3197, separate temporary SQLite database: real ChoiceCard selection and refresh persistence; action log reload; invalid email feedback then successful customer creation; ticket draft, human edit/review and confirmed local queue; artifact edit, acceptance lock and export link; switch to South Agent shows South records and hides customer-intake navigation.
- Desktop visual inspection: shared sidebar, active navigation, page-specific headings, context switcher, empty canvas, ticket inbox/detail and form states. Responsive breakpoints implemented; physical mobile device/full accessibility audit not run. Existing labels, focus/status regions and keyboard controls preserved; skip link added.
- No core runtime/schema/dependency or authorization changes; no provider calls or external customer contact. Existing local application on port 3100 left untouched. Demo used alternate loopback port 3197.
- Documentation now points to the guides instead of duplicating API reference material. No published docs URL is claimed.

Cleanup and delivery are recorded in the post-flight and Progress Ledger.
