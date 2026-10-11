---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

<!-- CUSTOM-BEGIN: ticket-title, reason: ticket title grounds the run and ambiguous refs need asking; retirement: delete markers if upstream adds ticket intake -->
If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.
<!-- CUSTOM-END -->

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "code-review" to review the work.

<!-- CUSTOM-BEGIN: flag-routing, reason: bare implement silently single-shots flagged tickets; retirement: delete markers if upstream routes flags -->
Re-check flags against `to-tickets` §4 (cite, do not redefine); `Architect:/Arena:/Both:/Interrogate: yes`, missing/malformed/contradicting lines, or any doubt routes via the Skill tool "implement-spec".
Trivial 1-line fix proceeds only per §4(2)–(3) (normalizable or routine-missing-irrelevant-line), appended to `## corrections` in `.scratch/<spec>/flag-corrections.md` and cited in the commit message.
<!-- CUSTOM-END -->

Commit your work to the current branch.
