---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
metadata:
  upstream: "mattpocock/skills@49dd158d1076134a641b33efb035946536778336 skills/engineering/implement (compared 2026-10-14; fork point unknown)"
---

Implement the work described by the user in the spec or tickets.

<!-- CUSTOM-BEGIN: ticket-title, reason: ticket title grounds the run and ambiguous refs need asking; retirement: delete markers if upstream adds ticket intake -->
If the user passes a ticket reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.
<!-- CUSTOM-END -->

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, call the Skill tool with "dev-code-review" to review the work. <!-- CUSTOM-BEGIN: review-base, reason: dev-code-review stalls asking for a fixed point; retirement: delete markers if upstream passes one -->Pass the merge-base with the default branch (`git merge-base origin/<default-branch> HEAD`, or the local default branch when there is no remote) as its fixed point.<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: flag-routing, reason: bare implement silently single-shots flagged tickets + user-invoked skills cannot Skill-invoke user-invoked skills per writing-for-agents SKILL-MECHANICS:10,22, so flagged work goes to a Task subagent following SKILL.md as reference (intentional waiver of router-hint-only rule); retirement: delete markers if upstream routes flags -->
Re-check flags against `to-tickets` §4 (cite, do not redefine); `Architect:/Arena:/Both: yes`, missing/malformed/contradicting lines, or any doubt routes to a Task subagent following `implement-spec/SKILL.md` as reference (never via the Skill tool).
Trivial 1-line fix proceeds only per §4(2)–(3) (normalizable or routine-missing-irrelevant-line), appended to `## corrections` in `.scratch/<spec>/flag-corrections.md` and cited in the commit message.
<!-- CUSTOM-END -->

Commit your work to the current branch.
