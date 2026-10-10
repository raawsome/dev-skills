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
Routing: tickets carrying `Architect` / `Arena` / `Both` flags need multi-attempt orchestration — stop and hand to `/implement-spec`; criteria are canonical in `to-tickets` §4, the map in `ask-matt`.
<!-- CUSTOM-END -->

Commit your work to the current branch.
