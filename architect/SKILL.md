---
name: architect
description: Sketch types, signatures, module structure before code, then stay in the loop while implementation fills in. ONLY /architect, architect this, design this (new code, before implementation), implement-spec Architect/Both flags, non-trivial work where jumping to code locks in wrong shape.
disable-model-invocation: true
license: MIT
metadata:
  upstream: "cursor/plugins@1e5c90a4b6f249917bd21fe361b3a2a7deb741b8 pstack/skills/architect (compared 2026-10-14; fork point unknown)"
---

<!-- FULLY-CUSTOM: no upstream in mattpocock/skills v1.3.1, never merge from it; pstack fork, see metadata.upstream; retirement: delete this file if upstream re-adds the skill -->
# Architect

Design before implementing. Sketch types, function signatures, class shapes, and module boundaries with `not implemented` bodies and pseudocode. Synthesize across multiple candidate perspectives, then fill in code against the chosen sketch. If implementation proves the sketch wrong, throw it out and redesign.

## Start

Open a todolist with one entry per phase before starting.

1. Ground
2. Sketch
3. Agree
4. Implement
5. Scrap

## Phase A: Ground the problem

Build a real mental model of every system the new code touches. Trace the relevant subsystems from entry points through call chains, types, and data flow until you can describe the full path from input to output without hand-waving any step. If the exploration skill (`research`) is installed, use it for this; otherwise explore directly with Glob/Grep/Read.

Naming a file isn't grounding. If the design redefines ownership or layering, also dig up the rationale behind the existing shape (commit history, ADRs, issue threads) so the old reason becomes a constraint, not a guess.

Skip Phase A only when the work is genuinely greenfield with no surrounding system to integrate.

## Phase B: Sketch

Read `arena/SKILL.md` and follow it as reference (never via the Skill tool; it is user-invoked only) with the design-sketch task and the Phase A grounding artifacts. Pass `references/runner-prompt.md` as each runner's prompt. Each candidate produces a design package shaped per `references/rationale-template.md`. Dependency note: `arena`'s Phase E coherence pass reads back `architect/references/design-red-flags.md`, so keep that path stable.

Design it twice. Require at least two structurally distinct candidates before synthesis, even when the first looks sufficient. Whole-shape alternatives, not point fixes inside one shape.

Screen every candidate against `references/design-red-flags.md` before synthesis. Assume the next contributor is an agent that sees only the files it opened, copies the nearest example, and takes the shortest path that compiles. Prefer the design where a change that looks right from one file is right for the whole repo.

Compare viable candidates on interface depth. Prefer the design that hides more complexity behind a smaller, simpler public surface. A rich interface can keep call chains short by concentrating capability instead of scattering it across layers. Do not put transport or wire types on the public API; parse into domain types behind the interface.

Arena returns one synthesized design package. The synthesis decision populates the rationale's "Synthesis decision" section. The synthesis note must include a single red-flag table for the base plus grafts (8 flags from `design-red-flags.md` by PASS/FLAG plus one line each, about 150 tokens). Screening stays internal per candidate; only the synthesized table is emitted.

## Phase C: Agree (checkpoint when asked or triggered)

Default: proceed directly to implementation with the synthesized design, with no human checkpoint, unless the invoker asks for one or the trigger below fires.

Opt in to a checkpoint when the invoker explicitly asks: "architect this with a checkpoint," "stop and show me before implementing," or similar. Then surface the synthesized design and pause for sign-off.

<!-- CUSTOM-BEGIN: architect-checkpoint, reason: broad triggers pause every run; retirement: delete markers if upstream narrows the trigger -->
The checkpoint also fires, unasked, only when a hard-to-reverse tradeoff meets one of: Interrogate findings the picker disputes with reasons, 2 Interrogate rounds exhausted, a cited ADR contradiction (ADR-ID plus one line why it reopens), or a human-value question (naming, permissions, data loss, cost, or shipped UX meaning). Hard-to-reverse alone without one of the four proceeds; Interrogate below remains the backstop. This asymmetry is intentional: interrogate fires on bare hard-to-reverse as backstop; checkpoint requires hard-to-reverse plus one of four.
<!-- CUSTOM-END -->

The synthesis can ship as its own commit on the ticket's branch either way (scaffold-first: types and signatures land behind the repo-convention skip flag with ticket link plus TODO, so CI stays green), never merged alone: the merger gate denies skip markers, so only the flag-free fill-in lands. Planned and scoped breakage during fill-in is replaced by flagged scaffolding; the Phase D implementer brief must list flag removal as an acceptance criterion, and merger plus final review must grep the flag and reject residuals. For adversarial pressure on the design before implementing, run the **interrogate** skill on the synthesized sketch (if installed). Mandatory when the synthesis names a hard-to-reverse tradeoff: scope to the sketch package only, Act-On findings re-run Phase B, max 2 rounds before a human checkpoint. When the settled sketch still leaves 2+ concrete hard-to-reverse implementation approaches open, emit a Both-signal in the synthesis decision per `to-tickets` §4 (section+axis+reason+band per cited approach): the run lead (`implement-spec` step 4) turns this signal into a `Both: yes` claim per `to-tickets` §4.
<!-- CUSTOM-BEGIN: both-cap-pointer, reason: cap lives in one place; retirement: keep while Both escape exists -->Both cap is canonical in `to-tickets` §4; architect emits the signal only, never the cap.<!-- CUSTOM-END -->

If the human pushes back on the shape (in a checkpoint or after the fact), treat that as Phase A evidence. Re-ground and re-run Phase B before writing more code.

## Phase D: Implement against the sketch

<!-- CUSTOM-BEGIN: reground, reason: sketch grounds at T0, frontier moves the tip; retirement: delete markers if upstream adds drift handling -->
Before fill-in: run the implementer drift check defined in `implement-spec` Step 4 (see implement-spec Step 4 for exact commands), then diff `old-tip..new-tip --name-only` and intersect with the sketch touch set (Phase A files plus module map plus GLOSSARY/ADR deps). Disjoint work proceeds with the tip SHA noted under Rationale/Problem. Intersecting work re-grounds the delta and re-screens the 8 flags in `references/design-red-flags.md`; full Phase B re-arena only when the delta hits split-ownership, a seam, or a wire-type boundary (cite the flag plus file:line).
<!-- CUSTOM-END -->

Replace `not implemented` bodies with code, pseudocode with logic. The synthesized sketch is the contract.

Deviations from the sketch are signal worth surfacing, not friction to absorb silently. If a function needs a parameter the sketch didn't anticipate, ask whether the sketch was wrong, the requirement was missed, or the implementation is overreaching.

## Phase E: Scrap when the architecture is wrong

If implementation keeps producing friction the sketch can't absorb, throw the sketch out. Don't bolt fixes onto a wrong design.

The signal is a *pattern*, not single instances. Tells:

- The same shape of workaround appearing repeatedly across unrelated code.
- Multiple unrelated edge cases that all need special-case branches.
- Types that need escape hatches (`any`, casts, optional fields always set in practice) to compile.
- The "we need a lock" reflex when the sketch said the state wasn't shared.
- Callers having to know the abstraction's internal rules to use it.
- Two or more independent Phase D deviations of the same shape across the implementation.

Use judgment. A few edge cases don't condemn an architecture. Some problems are legitimately complex. Complexity in the data is not complexity in the design.

<!-- CUSTOM-BEGIN: scrap-discipline, reason: free re-arena invites thrash; retirement: delete markers if upstream caps scraps -->
Scrap requires all three: (1) 2 or more independent Phase D deviations matching one tell in the list above (same workaround, same escape-hatch type, same caller-knows-internals shape — cite the tell plus file:line pairs, not two edits in one file); (2) Phase A re-trace evidence over the built reality; (3) a subtracted-X claim naming what the new sketch deletes or merges (interface entries, modules, or call sites) before it adds. One scrap proceeds unreviewed; the second pauses for a human checkpoint. Re-arena after scrap at N=3 default; escalate to N=5 only when arena Phase A N=5 criteria met, cite which.
<!-- CUSTOM-END -->

When you scrap:

1. Re-trace what has actually been built (Phase A over the new reality).
2. Redesign as if the new constraints had been day-one assumptions.
3. Subtract before adding. The new sketch should be smaller than the old one before it grows.
4. Return to Phase B and re-run arena (read `arena/SKILL.md` and follow it).

## Outputs

The caller's usage is written first and the type sketch derived from it. One file with new types and signatures for small changes. Module map plus type definitions for larger work. The rationale ships alongside, shaped per `references/rationale-template.md`, including the usage sketch and the synthesis decision.
