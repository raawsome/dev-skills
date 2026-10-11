---
name: arena
description: Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use ONLY when the user says /arena, arena this, throw it in the arena, asks for parallel attempts at a non-trivial artifact, or when another skill routes here (architect Phase B, implement-spec Both code-arena).
license: MIT
---

# Arena

Fan out N parallel attempts at the same task. Read every candidate end to end. Pick the strongest as the base. Graft the best ideas from the others into it. Verify the synthesized result.

Do not use for routine tracer-bullet tickets. This is expensive by design. One attempt is the default; arena is the opt-in for high-uncertainty, hard-to-reverse shapes.

Route: see ask-matt routing. Rule here is best-of plus graft. Briefs stay pointer-based (task path, SHAs, grounding dir).

`code-arena` (the term `implement-spec` step 4 and `ask-matt` cite for the `to-tickets` §4 `Both: yes` escape) means an arena run over code bodies against a settled architect sketch/scaffold: candidates implement the bodies, then pick, graft, and verify per phases A–F.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Cross-judge (parallel with parent reading in Pick)
4. Pick
5. Graft
6. Verify

## Phase A: Frame

The N candidates will receive the same prompt, so the prompt is the contract.

1. State the artifact each candidate is producing.
2. Derive the rubric. State what success looks like for *this* task, then turn it into 3-6 concrete gradeable criteria. The rubric is the picker's tool in Phase D. Candidates only see the task.
3. Pick the runners. N is 3 by default. Use N=5 only when hard-to-reverse plus (wide space or rework cost far above 1.6x) plus parent-readable size. Same approach 3 times when the work is generation-bound rather than judgment-sensitive.
4. Assign output paths. Each candidate writes to its own location (a git worktree where possible, otherwise `/tmp/arena-<slug>/candidate-<n>/`). Separate before serializing shared state: no candidate edits the shared branch directly.

## Phase B: Fan out

Spawn N parallel subagents in the background, each with the task, the path to the shared grounding, its own output path, and instructions to produce both the artifact and a short rationale.

Each rationale names the alternatives the candidate considered and what it rejected.

If a candidate fails to produce output, proceed with N-1 and note the dropout in the synthesis record.

## Phase C: Cross-judge

After all Phase B candidates complete, spawn one readonly judge subagent. It sees the rubric and the candidates by path label, scores each criterion in a table, and recommends a base with rationale. It runs after candidates finish, in parallel with the parent's own reading in Phase D. Don't spawn the judge while candidates are still writing. Quorum is 2 valid for N=3 (proceed, note dropout in report) and 3-4 valid for N=5; below quorum, reframe rather than picking from too few.

## Phase D: Pick a base

Read every candidate end to end before picking.

Score each candidate against the rubric criterion by criterion, not on holistic feel. Compare against the cross-judge. Agreement on the base confirms the pick. Disagreement means one of you is biased or the rubric was ambiguous. Read both rationales before deciding.

Pick the base on which a future maintainer can extend most easily without breaking invariants. Prefer the cleaner boundary or smaller API when two feel tied.

Record the pick and the reason in a short synthesis note alongside the base artifact, including the cross-judge's verdict.

## Phase E: Graft

Walk each losing candidate once more and identify what is worth porting into the base. The signal is usually one or two things per candidate, not most of it. Cap grafts at 2-3 total, not per loser.

Fold each graft in by hand to keep one mental model. The result has to remain coherent under one mental model.

<!-- CUSTOM-BEGIN: graft-coherence, reason: picker blind, judge pre-graft, verify tests-only; retirement: delete markers if upstream adds a coherence pass -->
When at least one graft was folded: run one coherence pass with a fresh readonly subagent (not the Phase D picker, not the Phase C judge) — checks single-mental-model plus the 8 flags in `architect/references/design-red-flags.md`, emits PASS/FLAG plus one line each. One round max; the picker hand-folds FLAG fixes, then Phase F verify. The base stays the base and the graft set stays closed. Skip when no graft was folded. If `architect/references/design-red-flags.md` is absent (standalone arena without architect installed), skip the flag check, emit `COHERENCE-WITHOUT-FLAGS` explicitly, and log the skip; treat COHERENCE-WITHOUT-FLAGS as PASS on mental-model for Phase F entry.
<!-- CUSTOM-END -->

Record what was grafted, from which candidate, and what was rejected and why.

When N candidates converge on the same shape, that is a strong agreement signal. Note the convergence in the record and ship the consensus shape. No graft is needed. When N candidates wildly diverge, Phase A was under-specified. Reframe and re-run rather than averaging the divergence.

## Phase F: Verify

The synthesized artifact has to hold up under the same scrutiny as any other output: run typechecking, run the relevant tests, and (for implement-spec integration) run the full suite once at the end.

If verification surfaces a problem the arena did not catch, either Phase A was wrong (re-frame and re-run) or one candidate caught it and you missed the graft (go back to Phase E). Fix the frame or graft instead of covering it.

## Outputs

One synthesized artifact. One short synthesis note alongside, naming the base, the grafts (with source candidate), the rejections, the dropouts if any, and the verification result.
