---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

<!-- CUSTOM-BEGIN: flag-routing, reason: bare implement silently single-shots flagged tickets; retirement: delete markers if upstream routes flags -->
To override a stale flag, provide override evidence (settled-interface SHA or ADR, approach count, touched LOC and file count). Re-check the flags against `to-tickets` §4 first; when the flag no longer applies, proceed locally and log the correction to `flag-corrections.md`, referenced from the commit message. When the ticket is contested, security-sensitive, hard-to-reverse, marked `Both: yes`, or evidence is absent, stop and hand to `/implement-spec`. Tie goes to handoff. Criteria are canonical in `to-tickets` §4, the map in `ask-matt`.
<!-- CUSTOM-END -->

Commit your work to the current branch.
