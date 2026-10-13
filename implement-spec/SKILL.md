---
name: implement-spec
description: "Builds a whole spec at once from tickets on one integration branch."
disable-model-invocation: true
---

You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

The goal is the entire spec implemented on a single **integration branch**, with every ticket resolved the way the issue tracker closes work.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Cite by path instead of duplicating pointed-to material.

**Implementer subagents** should be run in the background where possible for maximum concurrency.

## Steps

1. Read the spec and tickets to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. <!-- CUSTOM-BEGIN: swarm-routing, reason: upstream has no multi-slice exploration routing; retirement: delete markers if upstream adds swarm routing -->For multi-slice exploration, run the exploration as a **swarm** instead of a single subagent. Single by default; swarm iff ≥3 independent slices/subsystems OR a coverage matrix with ≥2 axes, with a declared shape plus N per swarm Phase A plus a one-line reason in the exploration notes.<!-- CUSTOM-END --> Briefs stay pointer-based (spec path, ticket IDs, SHAs, grounding dir); cite by path.

<!-- CUSTOM-BEGIN: fanout-depth, reason: nested fan-out multiplies agents; see research §fanout-depth; retirement: delete markers if upstream adopts a depth rule -->
Protocol per research §fanout-depth; payload: run implementer serially in-ticket. Briefs state 'depth: top|child'.
<!-- CUSTOM-END -->

3. Create the integration branch named `integration/<spec-slug>` <!-- CUSTOM-BEGIN: integration-branch, reason: upstream has no $INTEGRATION convention; retirement: delete markers if upstream adds an integration-branch convention -->(`$INTEGRATION`). Pass `$INTEGRATION` in every implementer and merger brief. Prune `$INTEGRATION` (local plus remote) when the spec resolves.<!-- CUSTOM-END --> If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets.

4. Use **implementer subagents** to implement each ticket, each in its own worktree on its own branch. <!-- CUSTOM-BEGIN: flag-routing, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->Before routing, check all four flag lines (`Architect:`, `Arena:`, `Interrogate:`, `Both:`); re-check per `to-tickets` §4 — contradictions (1) / normalization (2) / gaps (3) — in one cheap pass (cite §4); `Status:` marks + skips per the §4 `blocked-by-gap` lifecycle here. Route each ticket once per frontier state (re-route on promotion/vacate/re-entry):
   - `Architect: yes` goes through **architect** (sketch first, then a single implementer fills in the sketch) before any code is written.
   - `Arena: yes` (which implies `Architect: no` per `to-tickets` §4) goes through **arena** instead of a single implementer.
   - `Both: active <ticket#>` takes the Both path (architect sketch scaffold first, then code-arena on bodies, then verify), queued tickets wait, other claimants route as `Arena: yes` per `to-tickets` §4, the sketch keeps architect Phase C checkpoint rules (per architect Phase C). Both code-arena size per §4 arbitration log / arena Phase A (cite, do not restate).
   - routine tickets: single attempt. `Interrogate: yes` has no step-4 effect; it routes in step 7 via the `code-review` opt-in gate. Done iff every frontier ticket is either skipped-blocked or routed-once, in a logged table.<!-- CUSTOM-END --> <!-- CUSTOM-BEGIN: both-pick, reason: first-wins is order-dependent; retirement: delete markers if upstream adopts a selection rubric -->Both collision: arbitrate per `to-tickets` §4; apply once per frontier pass after the step-6 frontier check (wave-1: arbitrate the initial frontier in step 4 before routing, no S6 prerequisite).<!-- CUSTOM-END --> Each implementer subagent:
   - <!-- CUSTOM-BEGIN: drift-check, reason: upstream has no pre-start drift check; retirement: delete markers if upstream adds drift handling -->checks drift before starting: `git rev-list --left-right --count $INTEGRATION...HEAD` for magnitude and `git merge-tree $(git merge-base HEAD $INTEGRATION) HEAD $INTEGRATION` for conflict prediction; the correct commands above replace `rebase --dry-run`, which git lacks; if diverged or conflicted, rebase onto `$INTEGRATION` before calling `tdd`;<!-- CUSTOM-END -->
   - calls the Skill tool with `tdd` to build the ticket;
   - merges `$INTEGRATION` into its own branch before reporting done

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**. <!-- CUSTOM-BEGIN: merger-gate, reason: over-broad grep bounces green merges + WARN/advisory must-clear; retirement: delete markers if upstream narrows the grep or adds a must-clear list -->Merger gate is typecheck (must run on every merge and block landing on red) plus ticket-scoped tests (red) plus grep. DENY regex is scoped to src/** here: deny `\.skip\(|\bdescribe\.skip\b|\bit\.skip\b|\btest\.skip\b|\bxdescribe\b|\bxit\b|\bTODO\(tdd\)|\bFIXME\(tdd\)|@ts-nocheck` plus the scaffolder markers (`ARCHITECT-NOTE`, `ARENA-NOTE`, `DO-NOT-SUBMIT`). WARN (lands, must clear by step 7) is `as` + whitespace + `any` with word boundaries plus `eslint-disable`-style suppressions: each WARN entry clears iff deleted or step 7 lists its ticket ID + reason; any unlisted entry fails step 7. full suite runs advisory and async per merge and never blocks landing — only ticket-scoped reds gate landing (no retry counter); collect advisory reds and WARN entries into the step-7 must-clear list.<!-- CUSTOM-END --> <!-- CUSTOM-BEGIN: gap-handling, reason: one red ticket must not block the frontier; retirement: delete markers if upstream adds gap handling -->On ticket-scoped red (log 1), return the log to the implementer for one repair pass and re-gate (log 2); on second red, retry once and re-gate (log 3); on third red write `.scratch/<spec>/gaps/<ticket>.md` with gate logs 1–3 plus SHAs plus the old-to-new edge map (edge syntax per `to-tickets`), land nothing, reparent only tickets whose 'Blocked by' edges name the gap ticket, and continue the frontier around it. Frontier reporting per step 6 (cite, do not restate).<!-- CUSTOM-END -->

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. <!-- CUSTOM-BEGIN: gap-recheck, reason: upstream has no blocked-ticket recheck; retirement: delete markers if upstream adds gap handling -->If step 4 skipped any `blocked-by-gap` ticket, each frontier pass re-checks per the `to-tickets` §4 lifecycle; fixed tickets re-enter as ready, cleared automatically on fix. After 3 consecutive frontier passes with the 'blocked-by-gap' set unchanged, report the blocked ticket IDs plus gap paths to the user, naming requester + clearer so none starves, and continue the unblocked frontier (no new fan-out onto blocked tickets until fixed).<!-- CUSTOM-END -->

7. Once all tickets are complete, call the Skill tool with `code-review` on the integration branch — <!-- CUSTOM-BEGIN: interrogate-gate, reason: upstream has no Interrogate routing; retirement: delete markers if upstream adds review gates -->its opt-in Interrogate gate covers `Interrogate: yes` tickets and contested designs (flag criteria: `to-tickets` §4).<!-- CUSTOM-END --> Interrogate gate per code-review §5 autonomous rule (log suggested interrogation with reason and continue, never block). <!-- CUSTOM-BEGIN: must-clear-fix, reason: upstream has no WARN/advisory must-clear list; retirement: delete markers if upstream adds a must-clear list -->Fix all review issues plus every must-clear entry in a single implementer subagent; done iff must-clear list empty and review issues closed.<!-- CUSTOM-END -->

8. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes work, and report the integration branch. <!-- CUSTOM-BEGIN: pr-corrections, reason: upstream has no corrections-count-plus-pr-body rule; retirement: delete markers if upstream adds it -->Corrections per the `to-tickets` §4 iff rule; cite its path + count in the report and carry a one-line count + link in the PR body. When a PR exists or is created (step 3 draft or step 8 mark-ready), call the Skill tool with `pr` to shape the body.<!-- CUSTOM-END -->

9. Clean up all **implementer subagent** worktrees <!-- CUSTOM-BEGIN: worktree-cleanup, reason: upstream has no worktree cleanup details; retirement: delete markers if upstream adds cleanup -->(list, `remove --force`, prune, log paths, non-blocking).<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: scratch-gc, reason: upstream has no scratch retention rule; retirement: delete markers if upstream adds retention -->
On spec close, GC per `setup-matt-pocock-skills/issue-tracker-local.md` §scratch GC convention.
<!-- CUSTOM-END -->
