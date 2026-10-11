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

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. For multi-slice exploration (several subsystems, coverage matrices), run the exploration as a **swarm** instead of a single subagent. Single by default; swarm for multi-slice with a declared shape plus N plus a one-line reason in the exploration notes. Briefs stay pointer-based (spec path, ticket IDs, SHAs, grounding dir); cite by path.

<!-- CUSTOM-BEGIN: fanout-depth, reason: ticket-times-angle-times-hypothesis explodes; retirement: delete markers if upstream adopts a depth rule -->
Protocol per research §fanout-depth; payload: run implementer serially in-ticket. Briefs state 'depth: top|child'.
<!-- CUSTOM-END -->

3. Create the integration branch named `integration/<spec-slug>` (`$INTEGRATION`). Pass `$INTEGRATION` in every implementer and merger brief. Prune `$INTEGRATION` (local plus remote) when the spec resolves. If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets.

4. Use **implementer subagents** to implement each ticket, each in its own worktree on its own branch. <!-- CUSTOM-BEGIN: flag-routing-check, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->Before routing, check all four flag lines (`Architect:`, `Arena:`, `Interrogate:`, `Both:`); for tickets with `yes` on any line, with any line missing or malformed, or where flags contradict, re-check against `to-tickets` §4 autonomous (1)/(2)/(3) in one cheap pass (cite — well-formed per (1), normalizable per (2), otherwise (3)); a ticket meeting §4(3) only with `Status:` not already `blocked-by-gap` is marked `blocked-by-gap` here per the same lifecycle, then skipped with the rest; §4(1)–(2) proceed without marking. Skip any ticket whose `Status:` is `blocked-by-gap` per the `to-tickets` §4 lifecycle: continue the frontier and request a fix.<!-- CUSTOM-END --> <!-- CUSTOM-BEGIN: both-pick, reason: first-wins is order-dependent; retirement: delete markers if upstream adopts a selection rubric -->Both collision (2+ unranked bare `Both: yes` claims): apply `to-tickets` §4 arbitration once per wave when 2+ ready-claimants stand unranked (initial collision counts as a trigger) and at most once per evidence trigger thereafter, after the step-6 frontier recompute (wave-1: arbitrate initial frontier in step 4 before routing, no S6 prerequisite; later waves: S6 recompute → step-4 re-arbitration); `Both: active <ticket#>` and `Both: yes (queued, reason:…)` plus challenger re-entry are well-formed per §4; `Blocked:`→ready re-entry is budget-free; the `Both: active <ticket#>` marker is immune to re-queue per §4; re-arbitrate on any Active→Blocked transition per §4; with no logged pre-approval the autonomous default is deny (route as `Arena: yes`); log the ranked table per the §4 schema (ticket#, a, Rmax, score, Active|Queued|→Arena, reason ≤140 chars) plus deferral note.<!-- CUSTOM-END --> Each implementer subagent:
   - checks drift before starting: `git rev-list --left-right --count $INTEGRATION...HEAD` for magnitude and `git merge-tree $(git merge-base HEAD $INTEGRATION) HEAD $INTEGRATION` for conflict prediction; the correct commands above replace `rebase --dry-run`, which git lacks; if diverged or conflicted, rebase onto `$INTEGRATION` before calling `tdd`;
   - calls the Skill tool with `tdd` to build the ticket;
   - merges `$INTEGRATION` into its own branch before reporting done

<!-- CUSTOM-BEGIN: flag-routing-table, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->
Route each ticket once per frontier state (re-route on promotion/vacate/challenger re-entry):
- `Architect: yes` goes through **architect** (sketch first, then a single implementer fills in the sketch) before any code is written.
- `Arena: yes` (which implies `Architect: no` per `to-tickets` §4) goes through **arena** instead of a single implementer.
 - `Both: active <ticket#>` takes the Both path (architect sketch scaffold first, then code-arena on bodies, then verify); queued tickets wait; other claimants route as `Arena: yes` per `to-tickets` §4. The sketch keeps architect Phase C checkpoint rules (per architect Phase C).
- Routine tickets skip both — a single attempt is the default.
<!-- CUSTOM-END -->

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**. <!-- CUSTOM-BEGIN: merger-gate, reason: over-broad grep bounces green merges; retirement: delete markers if upstream narrows the grep -->Merger gate is typecheck (must run on every merge and block landing on red) plus ticket-scoped tests (red) plus grep. DENY regex is scoped to src/** here: deny `\.skip\(|\bdescribe\.skip\b|\bit\.skip\b|\btest\.skip\b|\bxdescribe\b|\bxit\b|\bTODO\(tdd\)|\bFIXME\(tdd\)|@ts-nocheck` plus the scaffolder markers (`ARCHITECT-NOTE`, `ARENA-NOTE`, `DO-NOT-SUBMIT`). Producer contract (scoped to src/**): architect Phase C scaffold-first lands types/signatures behind the skip flag plus arena synthesis output, so producers must emit exactly these literals. WARN (lands, must clear by step 7) is `as` + whitespace + `any` with word boundaries plus `eslint-disable`-style suppressions: each WARN entry clears iff deleted or step 7 lists its ticket ID + reason; any unlisted entry fails step 7. More than 3 `as any` instances re-escalate to DENY. Allow `eslint-disable`-style suppressions only with an inline reason plus ticket ref (a reason-less suppression counts as warn, not deny); full suite runs advisory and async per merge and never blocks landing — only ticket-scoped reds gate landing (no retry counter); collect advisory reds and WARN entries into the step-7 must-clear list.<!-- CUSTOM-END --> <!-- CUSTOM-BEGIN: gap-handling, reason: one red ticket must not block the frontier; retirement: delete markers if upstream adds gap handling -->On ticket-scoped red (log 1), return the log to the implementer for one repair pass and re-gate (log 2); on second red, rerun once with no code change as a flaky probe — a pass alone counts as flaky (re-gate once, no escalation rung); a fail confirms deterministic red 2: add one escalation rung (architect sketch for design-cause reds, new-pointer retry otherwise) and re-gate (log 3); on third consecutive deterministic red write `.scratch/<spec>/gaps/<ticket>.md` with gate logs 1–3 plus SHAs plus the old-to-new edge map (edge syntax per `to-tickets`), land nothing, reparent only tickets whose 'Blocked by' edges name the gap ticket, and continue the frontier around it.<!-- CUSTOM-END -->

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. If step 4 skipped any `blocked-by-gap` ticket, each frontier pass re-checks per the `to-tickets` §4 lifecycle; fixed tickets re-enter as ready. After 3 consecutive frontier passes with the 'blocked-by-gap' set unchanged, report the blocked ticket IDs plus gap paths to the user and continue the unblocked frontier (no new fan-out onto blocked tickets until fixed). Report names requester + clearer so none starves.

7. Once all tickets are complete, call the Skill tool with `code-review` on the integration branch — its opt-in Interrogate gate covers `Interrogate: yes` tickets and contested designs (flag criteria: `to-tickets` §4). Fix all issues raised by the code review plus every step-7 must-clear (WARN/advisory) entry in a single **implementer subagent**.

8. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes work, and report the integration branch. Corrections per the `to-tickets` §4 iff rule; cite its path + count in the report and carry a one-line count + link in the PR body. When a PR exists or is created (step 3 draft or step 8 mark-ready), call the Skill tool with `pr` to shape the body.

9. Clean up all **implementer subagent** worktrees. Per-worktree timeout 2–5 minutes: list worktrees, `remove --force`, prune, log the path, non-blocking. A gap is recorded only if unremovable after force.

<!-- CUSTOM-BEGIN: scratch-gc, reason: .scratch grows O(runs) and stale notes poison spec lookup; retirement: delete markers if upstream adds retention -->
On spec close, list `.scratch/<spec>/{gaps,blast}` unreferenced by open tickets or merged PRs and delete; log the paths. rm only paths listed as unreferenced: `shopt -s nullglob; for f in ".scratch/<spec>/gaps/"* ".scratch/<spec>/blast/"*; do [ -e "$f" ] || continue; grep -rl --exclude-dir=archive "$(basename "$f")" ".scratch/<spec>/issues" ".scratch/<spec>/spec.md" .scratch/<spec>/map* 2>/dev/null | grep -q . || echo "unreferenced: $f"; done` then rm only listed paths. `issues/` and `spec.md` archive under `.scratch/<spec>/archive/`; map files persist while referenced by any open ticket, else archive; `gaps/` persist while named in any open `Blocked by`; `blast/` persist while linked from an open PR. `flag-corrections.md` archives with spec close; never delete it while linked from the report or PR.
<!-- CUSTOM-END -->
