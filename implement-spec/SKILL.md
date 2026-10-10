---
name: implement-spec
description: "Implement the result of /to-spec and /to-tickets in code. Reads tickets as a task graph, runs implementer subagents across the ready frontier in parallel, lands everything on one integration branch. Use when the user wants to build a whole spec at once rather than ticket by ticket."
---

You have been provided a spec. This spec should have tickets associated with it, describing how to implement the spec.

The issue tracker should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

The goal is the entire spec implemented on a single **integration branch**, with every ticket resolved the way the issue tracker closes work.

The tickets are not a list of steps. They are a **task graph** with blocking relationships between them. This means there is always a **frontier** of tickets which are ready to be grabbed.

Communication to and from subagents should be sparse. Communicate primarily through **context pointers**: to the spec, tickets, research notes, and previous commits. Cite by path instead of duplicating pointed-to material.

**Implementer subagents** should be run in the background where possible for maximum concurrency.

## Steps

1. Read the spec and tickets to understand the task graph.

2. (optional) Use an **exploration subagent** to conduct any exploration required by the tickets - relevant codebase files or external documentation. Ensure the exploration subagent can save files - it should save its markdown notes in a directory outside the repo, accessible by all future subagents. This lets **implementer subagents** focus on implementation rather than exploration. For multi-slice exploration (several subsystems, coverage matrices), run the exploration as a **swarm** instead of a single subagent. Single exploration for 2 or fewer subsystems / ~500 LOC or less; swarm for 3+ subsystems or a real coverage matrix. Briefs stay pointer-based (spec path, ticket IDs, SHAs, grounding dir); cite by path. Subagents do not further fan out.

3. Create the integration branch named `integration`. If the issue tracker closes work through PRs, or the user asks for one, open a draft PR after the first merge in step 5 (a branch with no commits ahead of main can't open one), marked as closing the spec and tickets.

4. Use **implementer subagents** to implement each ticket, each in its own worktree on its own branch. Before routing, check all four flag lines (`Architect:`, `Arena:`, `Interrogate:`, `Both:`); for tickets marked `Architect: yes`/`Arena: yes`/`Both: yes`, or where flags contradict, re-check against `to-tickets` §4 in one cheap pass (ticket flag wins unless it contradicts §4). Enforce `Both:` cap: if 2 or more tickets claim `Both: yes`, keep the first, downgrade the rest to `Architect: yes`, and confirm the kept one with the user. Each implementer subagent:
   - checks drift before starting: `git rev-list --left-right --count integration...HEAD` for magnitude and `git merge-tree $(git merge-base HEAD integration) HEAD integration` for conflict prediction; the correct commands above replace `rebase --dry-run`, which git lacks; if diverged or conflicted, rebase onto the integration tip before calling `tdd`;
   - calls the Skill tool with `tdd` to build the ticket;
   - merges the integration branch tip into its own branch before reporting done

   Route each ticket once:
   - `Architect: yes` goes through **architect** (sketch first, then a single implementer fills in the sketch) before any code is written.
   - `Arena: yes` (which implies `Architect: no` per `to-tickets` §4) goes through **arena** (full A–F, rule is best-of plus graft) instead of a single implementer.
   - `Both: yes` (cap 1/spec, needs approval) goes architect sketch scaffold first, then code-arena on bodies, then verify, with no Phase D code before the arena.
   - Routine tickets skip both — a single attempt is the default.

5. Once an **implementer subagent** completes, merge its work to the integration branch with a **merger subagent**. Merger gate is typecheck (always) plus ticket-scoped tests only (full suite stays at step 7) plus grep for scaffold skip flags with rejection of residuals. On red, return the log to the implementer for one repair pass and re-gate; on second red, write `.scratch/<spec>/gaps/<ticket>.md` with the failing log, land nothing, reparent blocked tickets onto the gap ticket, and continue the frontier around it.

6. If this changes the **frontier** of available tickets, kick off more **implementer subagents** to work on the new tickets. This allows for maximum concurrency.

7. Once all tickets are complete, call the Skill tool with `code-review` on the integration branch — its opt-in Interrogate gate covers `Interrogate: yes` tickets and contested designs (flag criteria: `to-tickets` §4). Fix all issues raised by the code review in a single **implementer subagent**.

8. If a draft PR exists, mark it ready for review. Otherwise, resolve each ticket the way the issue tracker closes work, and report the integration branch.

9. Clean up all **implementer subagent** worktrees. Per-worktree timeout 2–5 minutes (not 30): list worktrees, `remove --force`, prune, log the path, non-blocking. A gap is recorded only if unremovable after force.
