---
name: code-review
description: "Review the changes since a fixed point (commit, branch, tag, or merge-base) along three axes: Standards (does the code follow this repo's documented coding standards?), Spec (does the code match what the originating issue/spec asked for?), and Ponytail (what over-engineering can be deleted?). Runs all three reviews in parallel sub-agents and reports them side by side, with opt-in Interrogate and Blast-radius gates. Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to \"review since X\"."
---

Three-axis review of the diff between `HEAD` and a fixed point the user supplies:

- **Standards**: does the code conform to this repo's documented coding standards?
- **Spec**: does the code faithfully implement the originating issue / spec?
- **Ponytail**: what over-engineering can be cut (reinvented stdlib, needless deps, speculative abstractions)?

All three axes run as **parallel sub-agents** so they don't pollute each other's context, then this skill aggregates their findings.

The issue tracker should have been provided to you. If `docs/agents/issue-tracker.md` is missing, tell the user to run `/setup-matt-pocock-skills`.

## Process

### 1. Pin the fixed point

Whatever the user said is the fixed point (a commit SHA, branch name, tag, `main`, `HEAD~5`, etc.). If they didn't specify one, ask for it.

Capture the diff command once: `git diff <fixed-point>...HEAD` (three-dot, so the comparison is against the merge-base). Also note the list of commits via `git log <fixed-point>..HEAD --oneline`.

Before going further, confirm the fixed point resolves (`git rev-parse <fixed-point>`) and the diff is non-empty. A bad ref or empty diff should fail here, not inside three parallel sub-agents.

<!-- CUSTOM-BEGIN: triage-prepass, reason: gate decisions need signals without loading diffs; retirement: delete markers if upstream adds a triage pass -->
Triage pre-pass (stat only, no diff load): run `git diff --stat <fixed-point>...HEAD` plus `git log <fixed-point>..HEAD --oneline` and scan for signals (`auth, login, token, secret, perm, crypto, sql, shell, eval, unsafe, lock, mutex, race, migrate, proto, openapi`, version bumps in `Cargo.toml`/`package.json`/`go.mod`). Use it to decide gates in §5 without loading rubric or diff into reviewers. Keyword hits are advisory only: match on word boundaries plus paths and confirm each hit against the stat before firing a gate.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: large-diff, reason: silent cap leaves hunks unreviewed yet looking reviewed; retirement: delete markers if upstream defines sharding -->
Above 300 LOC, warn and shard for axis review (at most 300 LOC per shard, max 4 shards per axis report, 250 words per shard). Beyond 4 shards, review entry points, shared code, and wire boundaries first and list unreviewed paths explicitly. Never silently cap. Evaluate the 800-LOC/10-file prompt on TOTAL triage pre-pass size, not per-shard.
<!-- CUSTOM-END -->

### 2. Identify the spec source

Look for the originating spec, in this order:

1. Issue references in the commit messages (`#123`, `Closes #45`, GitLab `!67`, etc.), fetched via the workflow in `docs/agents/issue-tracker.md`.
2. A path the user passed as an argument.
3. A spec file under `docs/`, `specs/`, or `.scratch/` matching the branch name or feature.
4. If nothing is found, ask the user where the spec is. If they say there isn't one, the **Spec** sub-agent will skip and report "no spec available".

### 3. Identify the standards sources

Anything in the repo that documents how code should be written, such as `CODING_STANDARDS.md` or `CONTRIBUTING.md`.

On top of whatever the repo documents, the Standards axis always carries the **smell baseline** below: a fixed set of Fowler code smells (_Refactoring_, ch.3) that applies even when a repo documents nothing. Two rules bind it:

- **The repo overrides.** A documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell.
- **Always a judgement call.** Each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation. Like any standard here, skip anything tooling already enforces.

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Spawn all three sub-agents in parallel

**Standards sub-agent prompt** should include:

- The full diff command and commit list.
- The list of standards-source files you found in step 3, **plus the smell baseline from step 3** pasted in full (the sub-agent has no other access to it).
- The brief: "Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. <!-- CUSTOM-BEGIN: standards-scope, reason: Generality/YAGNI ownership split between axes; retirement: delete markers if upstream scopes the briefs -->Report documented-standard violations and non-generality smells only; leave generality/YAGNI structure to the Ponytail axis.<!-- CUSTOM-END --> Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 250 words. Priority inside the cap: documented-standard hard violations first, then smells; drop the lowest priority first and state the count dropped and list dropped finding titles."

**Spec sub-agent prompt** should include:

- The diff command and commit list.
- The path or fetched contents of the spec.
- The brief: "Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. <!-- CUSTOM-BEGIN: spec-scope, reason: Spec findings kept even under Ponytail overlap; retirement: delete markers if upstream scopes the briefs -->Quote the spec line for each finding, even if Ponytail may also flag the structure.<!-- CUSTOM-END --> Under 250 words. Priority: missing or partial requirements first, then scope creep, then wrong implementation; state the count dropped and list dropped finding titles."

If the spec is missing, skip the Spec sub-agent and note this in the final report.

<!-- CUSTOM-BEGIN: ponytail-axis, reason: over-engineering needs a dedicated pass; retirement: delete markers if upstream adds a third axis -->
**Ponytail sub-agent prompt** should include:

- The diff command and commit list.
- The brief: "Call the Skill tool with `ponytail-review` and review this diff for over-engineering only. One line per finding (`<file>:L<line>: <tag> <what>. <replacement>.`), tags `delete` / `stdlib` / `native` / `yagni` / `shrink`. Correctness bugs, security holes, and performance are out of scope — leave those to the other axes. End with the ponytail-review Scoring line (`net: -N / touched M (+/-), -P%`, or `Lean already. Ship.`). Under 250 words. Priority: delete and yagni first, then stdlib and native, then shrink; state the count dropped and list dropped finding titles."

Skip Ponytail on docs-only micro-diffs: added lines per `git diff --numstat` under 20 AND changed files matching only `\.(md|mdx|txt|rst)$`. Note "Ponytail skipped (docs-only, under 20 lines)" in the report. Review code-adjacent docs (e.g. `**/openapi.* **/schema/**`).
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: opt-in-gates, reason: contested designs need adversarial review and breakage proof; retirement: delete markers if upstream adds review gates -->
### 5. Opt-in gates (Interrogate / Blast-radius)

These run only when triggered. Use the Step 1 triage pre-pass to decide without loading the diff into reviewers. Report each under its own heading; do not merge or rerank with the three axes. Interrogate flag definitions canonical in `to-tickets` §4 (cite-only; do not redefine); Blast-radius properties canonical in blast-radius Escalation rule. The size prompt is not a firing; default no.

- **Interrogate** (flags per `to-tickets` §4): Call the Skill tool with `interrogate` on the diff command from step 1 and report its verdict verbatim under `## Interrogate`. In interactive runs, a diff above 800 LOC or above 10 files showing Divergent Change or Shotgun Surgery earns one prompt: ask the user whether to interrogate, default no, with a one-line reason. In autonomous runs (`implement-spec` step 7), log the suggested interrogation with its reason and continue; never block.
- **Blast-radius** (properties per blast-radius Escalation rule): Call the Skill tool with `blast-radius` on the change and report its writeup verbatim under `## Blast-radius`, keeping the proven-or-unproven safety fact. Fires when the user says they don't trust a small diff (≤300 LOC), or on shared code / library version / concurrency-lifecycle / wire-format triggers.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: aggregate-fallback, reason: overlap links and fallback keep smells reported; retirement: delete markers if upstream changes aggregation -->
### 6. Aggregate

Present the three reports under `## Standards`, `## Spec`, and `## Ponytail` headings, verbatim or lightly cleaned, plus `## Interrogate` / `## Blast-radius` when those gates ran. Do **not** merge or rerank findings, because the axes are deliberately separate (see _Why three axes_). Keep both findings when Spec scope-creep and Ponytail overlap on one hunk; append `Overlaps Ponytail <loc>` / `Overlaps Spec <item>` rather than deleting either.

If Ponytail failed (tool error/timeout), run fallback; otherwise continue without fallback. Ownership per §4 Ponytail brief above.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: ponytail-status, reason: fallback trigger was untestable; retirement: delete markers if upstream enumerates skip reasons -->
Always log one status line verbatim as one of: `Ponytail ran` / `Ponytail skipped (docs-only, under 20 lines)` / `Ponytail skipped (tool-missing: <tool>)` / `Ponytail failed (<reason>)`. Any other `skipped (<reason>)` is WARN (log and continue, no fallback). When the status line is missing, log WARN and retry once; fail only on second miss as `Ponytail failed (no status after retry)`. Run the fallback only when status is `failed (tool error/timeout)`.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: why-three-axes, reason: separation rationale covers three axes plus gates; retirement: delete markers if upstream changes the axis model -->
End with a one-line summary: total findings per axis (and per gate that ran), and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why three axes

A change can pass one axis and fail another:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**
- Code that is correct and conventional but over-built → **Standards pass, Spec pass, Ponytail fail.**

Reporting them separately stops one axis from masking the other. Ponytail owns Speculative Generality / YAGNI so Standards doesn't double-report it.
<!-- CUSTOM-END -->
