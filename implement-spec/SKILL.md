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

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration. For multi-slice exploration (several subsystems, coverage matrices), run the exploration as a **swarm** instead of a single subagent. Single exploration for 2 or fewer subsystems / ~500 LOC or less; swarm for 3+ subsystems or a real coverage matrix. Sub-threshold swarm only with a declared shape (`first-pass` / `rank-all` / `best-of`) plus N=2 plus a one-line justification in the exploration notes. Briefs stay pointer-based (spec path, ticket IDs, SHAs, grounding dir); cite by path.

<!-- CUSTOM-BEGIN: fanout-depth, reason: ticket-times-angle-times-hypothesis explodes; retirement: delete markers if upstream adopts a depth rule -->
If invoked as a fanned child, run serially; only the top-level invocation fans. Briefs state `depth: top | child`.
<!-- CUSTOM-END -->

3. Create the integration branch named `integration/<spec-slug>` (`$INTEGRATION`). Pass `$INTEGRATION` in every implementer and merger brief; drift, merge, and PR-base commands all use `$INTEGRATION`. Prune `$INTEGRATION` (local plus remote) when the spec resolves. If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets.

4. Use **implementer subagents** to implement each ticket, each in its own worktree on its own branch. <!-- CUSTOM-BEGIN: flag-routing-check, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->Before routing, check all four flag lines (`Architect:`, `Arena:`, `Interrogate:`, `Both:`); for tickets with `yes` on any line, with any line missing or malformed, or where flags contradict, re-check against `to-tickets` §4 autonomous (1)/(2)/(3) in one cheap pass (cite — well-formed per (1), normalizable per (2), otherwise (3)); a ticket meeting §4(3) only with `Status:` not already `blocked-by-gap` is marked `blocked-by-gap` here per the same lifecycle, then skipped with the rest; §4(1)–(2) proceed without marking. Skip any ticket whose `Status:` is `blocked-by-gap` per the `to-tickets` §4 lifecycle (distinct from `blocked-by-gap-candidate` per `to-tickets` §4 — import match, never auto-ready): continue the frontier and request a fix.<!-- CUSTOM-END --> <!-- CUSTOM-BEGIN: both-pick, reason: first-wins is order-dependent; retirement: delete markers if upstream adopts a selection rubric -->Both collision (2+ tickets claim `Both:` in any value): apply `to-tickets` §4 arbitration once per wave when 2+ ready-claimants stand unranked (initial collision counts as a trigger) and at most once per evidence trigger thereafter, after the step-6 frontier recompute; `Both: active <ticket#>` and `Both: yes (queued, reason:…)` are well-formed under §4(1)/(2); `Blocked:`→ready re-entry is budget-free; the `Both: active <ticket#>` marker is immune to re-queue; re-arbitrate on any Active→Blocked transition per §4; with no logged pre-approval the autonomous default is deny (route as `Arena: yes`); log the ranked table per the §4 schema (ticket#, a, Rmax, score, Active|Queued|→Arena, reason ≤140 chars) plus deferral note.<!-- CUSTOM-END --> Each implementer subagent:
   - checks drift before starting: `git rev-list --left-right --count $INTEGRATION...HEAD` for magnitude and `git merge-tree $(git merge-base HEAD $INTEGRATION) HEAD $INTEGRATION` for conflict prediction; the correct commands above replace `rebase --dry-run`, which git lacks; if diverged or conflicted, rebase onto `$INTEGRATION` before calling `tdd`;
   - calls the Skill tool with `tdd` to build the ticket;
   - merges `$INTEGRATION` into its own branch before reporting done

<!-- CUSTOM-BEGIN: flag-routing-table, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->
Route each ticket once:
- `Architect: yes` goes through **architect** (sketch first, then a single implementer fills in the sketch) before any code is written.
- `Arena: yes` (which implies `Architect: no` per `to-tickets` §4) goes through **arena** (full A–F, rule is best-of plus graft) instead of a single implementer.
 - `Both: active <ticket#>` takes the Both path (architect sketch scaffold first, then code-arena on bodies, then verify, with no Phase D code before the arena); queued tickets wait and other claimants route as `Arena: yes` per `to-tickets` §4. The sketch keeps architect Phase C checkpoint rules (hard-to-reverse plus contested findings, 2 rounds exhausted, cited ADR, or human-value question pauses before code-arena).
- Routine tickets skip both — a single attempt is the default.
<!-- CUSTOM-END -->

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**. <!-- CUSTOM-BEGIN: merger-gate, reason: over-broad grep bounces green merges; retirement: delete markers if upstream narrows the grep -->Merger gate is typecheck (always red) plus ticket-scoped tests (red) plus grep. DENY regex is canonical here; never restate it elsewhere: deny `\.skip\(|describe\.skip|it\.skip|test\.skip|xdescribe|xit|TODO\(tdd\)|FIXME\(tdd\)|@ts-nocheck` plus the scaffolder markers (`ARCHITECT-NOTE`, `ARENA-NOTE`, `DO-NOT-SUBMIT`). Producer contract: no other file defines these literals; architect Phase C scaffold-first lands types/signatures behind the skip flag plus arena synthesis output, so producers must emit exactly these literals. WARN (lands, must clear by step 7) is `as any` instances plus reason-less `eslint-disable`-style suppressions: each WARN entry clears iff deleted or step 7 lists its ticket ID + reason; any unlisted entry fails step 7. More than 3 `as any` instances re-escalate to DENY. Allow `eslint-disable`-style suppressions only with an inline reason plus ticket ref (a reason-less suppression counts as warn, not deny); full suite runs advisory and async per merge and never blocks landing — count only ticket-scoped reds toward the strike counter; collect advisory reds and WARN entries into the step-7 must-clear list (every entry cleared at step 7).<!-- CUSTOM-END --> <!-- CUSTOM-BEGIN: gap-handling, reason: one red ticket must not block the frontier; retirement: delete markers if upstream adds gap handling -->On ticket-scoped red, return the log to the implementer for one repair pass and re-gate; on second ticket-scoped red, rerun once to test flaky (a pass on rerun alone counts as flaky: re-gate once with no escalation rung); otherwise for deterministic reds add one escalation rung (architect sketch or a new-pointer retry), then on third deterministic red write `.scratch/<spec>/gaps/<ticket>.md` with all three gate logs plus SHAs plus the old-to-new edge map (per `to-tickets` edge syntax), land nothing, reparent only tickets whose `Blocked by` edges do not name the gap ticket (edges govern; `blocked-by-gap-candidate` per `to-tickets` §4), and continue the frontier around it.<!-- CUSTOM-END -->

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. This allows for maximum concurrency. If step 4 skipped any `blocked-by-gap` ticket, each frontier pass re-checks per the `to-tickets` §4 lifecycle; fixed tickets re-enter as ready. Report names requester + clearer so none starves.

7. Once all tickets are complete, call the Skill tool with `code-review` on the integration branch — its opt-in Interrogate gate covers `Interrogate: yes` tickets and contested designs (flag criteria: `to-tickets` §4). Fix all issues raised by the code review in a single **implementer subagent**.

8. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes work, and report the integration branch. Corrections per the `to-tickets` §4 iff rule; cite its path + count in the report and carry a one-line count + link in the PR body. When a PR exists or is created (step 3 draft or step 8 mark-ready), call the Skill tool with `pr` to shape the body.

9. Clean up all **implementer subagent** worktrees. Per-worktree timeout 2–5 minutes (not 30): list worktrees, `remove --force`, prune, log the path, non-blocking. A gap is recorded only if unremovable after force.

<!-- CUSTOM-BEGIN: scratch-gc, reason: .scratch grows O(runs) and stale notes poison spec lookup; retirement: delete markers if upstream adds retention -->
On spec close, list `.scratch/<spec>/{gaps,blast}` unreferenced by open tickets or merged PRs and delete; log the paths. Never delete a file another open file links to (grep before rm). `issues/`, `spec.md`, and map files archive under `.scratch/<spec>/archive/`; `gaps/` persist while named in any open `Blocked by`; `blast/` persist while linked from an open PR, else 30d from PR close (mtime fallback). `flag-corrections.md` archives with spec close; never delete it while linked from the report or PR. Branch prune lives in step 3: delete `$INTEGRATION` locally after push plus remote delete when published.
<!-- CUSTOM-END -->
