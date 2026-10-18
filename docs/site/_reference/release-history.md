---
layout: default
title: "Release History"
nav_order: 9
description: "Distinguish the current development candidate from published releases."
guide: false
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

No public release has been published. Version {{ site.version }} is the current prerelease candidate on `main`. The repository remains private while development continues.

The current candidate keeps one RailsToolViews identity and removes the legacy ToolViews aliases that earlier unpublished candidates carried. Earlier local implementation milestones are not release tags.

When a stable tag includes this documentation site, the build publishes that tag at the root and default-branch docs at `/next/`; older major versions can remain under `/vN/`. Until then the local build shows the unreleased working tree at the root.

See [What Is New]({% link _getting_started/whats-new.md %}) and [Upgrading]({% link _reference/upgrading.md %}).
