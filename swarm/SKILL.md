---
name: swarm
description: Fan out N parallel workers, drain them, and return one report. ONLY parallel races/coverage (declare shape per Phase A), implement-spec step 2.
license: MIT
---

<!-- FULLY-CUSTOM: no upstream in v1.3.1, never merge; retirement: delete this file if upstream re-adds the skill -->
# Swarm

Fan out N parallel workers. They may cover separate slices, race the same brief, or mix both. The parent waits, aggregates, and returns one report.

Route: see ask-matt routing. Briefs stay pointer-based (SHAs, paths, method). Subagents do not further fan out.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning. Restrict `first pass` to deterministic pass/fail measurements; judgment races must use rank-all/best-of.
3. Set N from the user or derive it from the shape. N is total workers, not a concurrency limit. Keep it small by default (2-4); go larger only for genuine coverage matrices.
4. Give each worker its own writable output when it writes (a git worktree where possible, otherwise a per-worker subdirectory). When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers in one message, in the background. Each worker needs only local tools unless it must touch something off-machine — say so in its brief if so.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap; re-scope slice or downgrade to partial report with gap listed as BLOCKED. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front (`first pass`, `rank all`, or `best-of`). Return the compact table instead of raw dumps.

Keep a compact result table, one-line evidenced issues, and explicit gaps or dropouts.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.

For race or mixed winners only, verify with typecheck plus the brief's tests and add a ponytail bloat pass as pre-review hygiene; code-review axis authoritative. For coverage or table shapes there is no winner review. Ponytail never substitutes for correctness review or downstream code-review.
