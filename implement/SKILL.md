---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "code-review" to review the work.

<!-- CUSTOM-BEGIN: flag-routing, reason: bare implement silently single-shots flagged tickets; retirement: delete markers if upstream routes flags -->
To override a stale flag, provide override evidence (settled-interface SHA or ADR, approach count, touched LOC and file count). Re-check the flags against `to-tickets` §4 first; when the flag no longer applies, proceed locally and log the correction to `flag-corrections.md`, referenced from the commit message. When the ticket is contested, security-sensitive, hard-to-reverse, marked `Both: yes`, or evidence is absent, stop and hand to `/implement-spec`. Tie goes to handoff. Criteria canonical in `to-tickets` §4; routing map canonical in `implement-spec` §4 (`ask-matt` cites them only).
<!-- CUSTOM-END -->

Commit your work to the current branch.
