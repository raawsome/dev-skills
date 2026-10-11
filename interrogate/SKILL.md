---
name: interrogate
description: Use ONLY for interrogate, adversarial review, multi-model review, challenge this, stress test this code, find blind spots, or tear this apart, or when another skill routes here (code-review §5 gate, architect Phase C). Multiple independent reviewers challenge the same change, then a lead synthesizes one verdict.
license: MIT
---

# Interrogate

Spawn independent reviewers to adversarially review code changes. Each reviewer gets the same prompt and rubric. The adversarial signal comes from reviewer independence, not assigned personas: independent readers differ in blind spots, priors, and reasoning patterns. Agreement across reviewers is high-confidence signal; lone-reviewer findings are worth reading but lower confidence.

The deliverable is a synthesized verdict. Do NOT auto-apply changes.

## Step 1, Determine scope

Identify what to review from context:

- If the user points at specific files or a diff, use that
- If on a feature branch, run `git diff main...HEAD` (or the appropriate base branch) for the full changeset
- If the user's message references recent work, gather the relevant files

Package the diff (or file contents) plus any surrounding context files the reviewers need to understand the code.

## Step 2, State the intent

Before spawning reviewers, state the intent explicitly. Derive this from:

- The user's message
- Commit messages
- PR description if one exists
- The code itself

Write one clear paragraph. If you're unsure about the intent, ask the user before proceeding.

## Step 3, Spawn reviewers

Launch N (default 2) readonly reviewer subagents in a single message, in the background. When run as code-review §5 gate, run foreground (blocking) under code-review after §4 axes complete; standalone runs background. If the user explicitly asks for more reviewers, extend the Reviewer A/B labels to fit.

<!-- CUSTOM-BEGIN: reviewer-count, reason: free re-rolls launder noise as consensus; retirement: delete markers if upstream pre-registers N -->
Pre-register the reviewer count N (default 2) before spawning and run exactly N reviewers once; never add reviewers after seeing results for any reason. Consensus is a majority AND at least 2 when N is greater than 2, not a bare 2+ (N=2→2, N=3→2, N=5→3). Report N and the per-finding agreement rate (k/N) in the agreement map, plus `reviewers spawned: N, rounds: R` (R counts synthesis passes over the fixed N results, never re-spawns) under Reviewers.
<!-- CUSTOM-END -->

Read `references/reviewer-prompt.md` and fill in the template with:

1. The stated intent
2. The diff or file contents
3. The review rubric from `references/rubric.md`
4. The code-quality lens from `references/code-quality-review.md`

The same filled template goes to all reviewers, so every reviewer applies the code-quality lens.

## Step 4, Synthesize

As results come back, build a unified picture:

1. **Parse all findings** from the reviewers
2. **Identify consensus** (per Step 3 reviewer-count rule). Lone-reviewer findings are lower confidence. Single-reviewer security/correctness findings escalate to Consider minimum, never auto-Dismiss.
3. **Identify lone-reviewer findings**. Still worth reading, but weight accordingly.
4. **Deduplicate**. Different reviewers may describe the same issue differently. Merge these and note which reviewers raised it.
5. **Note disagreements**. If one reviewer flags something and another explicitly says the opposite, that's useful context for the verdict.

## Step 5, Lead judgment

You are the lead reviewer, a pragmatic senior engineer, not a neutral aggregator.

Read `references/lead-judgment.md` for the full framework.

Categorize every finding using these buckets:

- **Act on**. Real issues affecting correctness, security, or maintainability given the actual goals. These would block a real PR.
- **Consider**. Legitimate points, but you're not sure they outweigh the cost of addressing them right now. Worth the user's attention.
- **Noted**. Technically valid but not actionable. Context-dependent, premature optimization, or low-impact given the current stage.
- **Dismissed**. Wrong, nitpicky, or missing context. Brief explanation why.

For each finding, include:

- Which reviewer(s) raised it
- The category (act on / consider / noted / dismissed)
- A one-line rationale for the categorization

## Output format

Present the verdict in this structure:

### Intent

> [The stated intent paragraph from Step 2]

### Reviewers

- Reviewer [label]: [N findings] (one bullet per reviewer)
- reviewers spawned: N, rounds: R

### Act On

[Findings that should be addressed. For each: description, which reviewers raised it, why it matters.]

### Consider

[Findings worth thinking about. For each: description, which reviewers raised it, tradeoff involved.]

### Noted

[Valid but low-priority. Brief list.]

### Dismissed

[Rejected findings with brief rationale.]

### Agreement map

[Where did reviewers agree, where did they diverge, and what does the pattern of agreement/disagreement tell us?]
