---
layout: default
title: "Demo Workbench"
nav_order: 4
description: "Explore persistent components and host-owned workflows with offline fixtures."
---

# {{ page.title }}

{{ page.description }}
{: .fs-6 .fw-300 }

After reading this guide, you will know:

* Run and stop the local reference application.
* Exercise successful actions, validation and role boundaries.
* Inspect continuation failure without contacting a provider.

## Start the workbench

From the repository root, run:

```sh
bundle install
bin/demo
```

Open `http://127.0.0.1:3100`. The server binds to loopback. Use `Ctrl-C` to stop it when finished. The default local SQLite database preserves completed work across restarts. If the port is occupied, run `PORT=3197 bin/demo` and open `http://127.0.0.1:3197`.

The application uses deterministic fixtures. It does not send customer messages or call an AI provider. Synthetic identity switching is a testing aid, not production authentication.

## Present a component

In **Component playground**, choose **Present ChoiceCard**, select an option, and save it. Refresh to verify that the view retains the selection. **Refresh action log** reloads committed selections; the log is a page-load snapshot, not a live event feed.

**Present in chat** uses the same trusted component with a deterministic host callback. **Render ViewComponent** exercises the optional renderer. **Show empty state** checks a component without options. Each presentation adds a saved view to the current browser session's workspace.

## Validate a customer

Open **Customer intake** as a lead. Enter an invalid email and submit. The form retains your values and shows field feedback. Correct the email and create the customer. Refresh to inspect the saved result. Use **Start another customer draft** for a fresh form; completed records remain intact.

## Review a support reply

Open **Support workspace**, search for a ticket, and select it from the tenant inbox. View the authorized account and assign a team member as a lead. Request a reply draft, edit its text, then approve it. As a lead, select the confirmation checkbox and queue the reviewed reply locally.

The final state represents a local outbox record, not external delivery. Switching identities opens the support workspace. An agent cannot assign tickets or confirm the queue. Switching tenants changes the visible records; permission checks also run when a saved action is submitted.

## Review and export content

Open **Content review**. Save a human edit, supply feedback and request regeneration. Inspect **Recent version history** to see the separate host versions. As a lead, accept the current version and prepare its text export. The download contains the accepted version.

Acceptance locks that draft. **Start a new result draft** creates separate work without overwriting the accepted content.

## Exercise failure and retry

Stop the normal server, then run:

```sh
TOOLVIEWS_DEMO_AGENT_FAILURE=1 bin/demo
```

Request a reply draft or regeneration. The action remains saved while follow-up fails. Stop the server, restart with `bin/demo`, reload and choose **Retry AI follow-up**. This verifies the local callback path, not a live provider.

For the underlying contract, read [Continuation]({% link _advanced/continuation.md %}).
