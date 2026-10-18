# ADR 007 — Component scaffolds and Engine HTML pages

2026-10-18; accepted implementation design for owner-authorized 0.2. FR-01/02/07/08, no product-intent change.

The component generator creates three files: registration under config, a Partial, and a Minitest scaffold. It uses the existing DSL with closed bounded schemas and two denied policies, without agent exposure or domain writes. A shared host to_prepare block resets once and loads every definition; the generator does not patch existing initializers or create callbacks that erase another component. Preflight every output and refuse conflicts or symlink escape before writing.

Direct Engine HTML and rejected HTML requests need complete documents. Use an Engine-owned layout instead of inheriting an embedding host layout that may require unavailable instance variables/assets. Rails view lookup allows a host override. Embedded rendering and Turbo remain fragments, JSON remains structured. Reauthorize before rendering correction fields; unavailable identity renders only the error page. Keep original status codes and link only to the restored Surface.

A corrected POST may have another POST-only Engine URL as its Referer. Redirect to the Surface in this case, otherwise preserve the existing same-origin redirect-back behavior. This avoids a GET /actions 404 without trusting caller-supplied return URLs.

No schema changes or runtime dependencies. Real Chrome with JS disabled tests the HTML path; isolated installed-gem host tests the generator and runnable scaffold. These are local integration evidence, not external adoption or full assistive-technology review.
