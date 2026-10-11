---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

<!-- CUSTOM-BEGIN: ticket-title, reason: ticket title grounds the run and ambiguous refs need asking; retirement: delete markers if upstream adds ticket intake -->
If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: tdd-invocation, reason: Skill-tool invocation replaces bare /tdd per upstream #878; retirement: delete markers if upstream adopts Skill-tool wording -->
Call the Skill tool with "tdd" where possible, at pre-agreed seams.
<!-- CUSTOM-END -->

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

<!-- CUSTOM-BEGIN: review-invocation, reason: Skill-tool invocation replaces bare /code-review per upstream #878; retirement: delete markers if upstream adopts Skill-tool wording -->
Once done, call the Skill tool with "code-review" to review the work.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: flag-routing, reason: bare implement silently single-shots flagged tickets; retirement: delete markers if upstream routes flags -->
Re-check the flags against `to-tickets` §4 first. When the flag no longer applies, proceed locally and log override evidence (settled-interface SHA or ADR, approach count, touched LOC and file count) to `.scratch/<spec>/flag-corrections.md`, referenced from the commit message.
Trivial-fix escape: a one-line diff with that evidence logged may proceed locally.
Otherwise stop and hand to `/implement-spec`: contested, security-sensitive, hard-to-reverse, or `Both: yes` tickets, or evidence absent. On doubt, hand to the Skill tool "handoff".
<!-- CUSTOM-END -->

Commit your work to the current branch.
