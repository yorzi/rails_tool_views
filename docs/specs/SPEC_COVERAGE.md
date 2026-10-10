# Specs coverage v3.1
All 19 concerns are evaluated in project-manifest.json. Core concerns 02/04/05/06/08/09/11/12/13/14/15/17/18/19 are INCLUDED, as are 01/03/10/16. 07 traffic SEO is NOT_APPLICABLE: this is an OSS Gem, not an SEO content site, though documentation discoverability remains in 10/16. Recheck if an independent docs website launches.

## Trigger review
| Trigger | Applicability and contract | Open gate |
|---|---|---|
| Accounts/multi-tenant | Host identity, cross-tenant protection; 03/04/09 | S1 security test |
| Billing | N/A no SaaS charges; 15 | If billing added |
| AI/external model | Optional but central; 03/04/05/supporting/03 | Phase 0/S2 |
| Content/copyright | OSS license dependencies; 13/14 | Release license audit |
| Jobs/webhooks | Optional agent return, duplicate/retry; 05/09 | S3 |
| Plugin/platform | Rails/Hotwire/gem compatibility; 05/09/17 | Phase 0 |
| Minor/regulated | Not directly in generic library, host responsible; 13 | Host-specific |
| SEO/multilingual | No consumer landing system; 07 | Docs site launch |
| Persistent data | Surface state/migrations; 05/09/18 | S1/S4 |
| Local first | No provider/network for deterministic path; 04/05/09 | S1 |

Outstanding: tech spike, licenses, compatibility matrix, browser visual evidence and external developer validation.
## Use-case trace
UC-01..10 hypotheses and demo stages are documented in [supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md](supporting/06_USE_CASES_AND_REFERENCE_DEMOS.md) and cross-mapped to 02/04/08/11 and REQUIREMENTS_TRACEABILITY. The ten scenarios do **not** create ten additional v3.1 concerns or imply ten V0 features.
