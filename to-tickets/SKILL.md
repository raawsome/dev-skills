---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker (edges as text in one file per ticket locally, or native blocking links on a real tracker).
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Ticket titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges**: the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket; green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work

<!-- CUSTOM-BEGIN: flag-criteria, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->
Mark routing candidates yourself and present the markings with the breakdown below — the user vetoes, you don't interrogate.

- `Architect: yes` when the interface, usage, or module shape must still be settled before implementation, `no` otherwise.
- `Arena: yes` only when `Architect: no` AND the implementation approach itself is high-uncertainty or hard to reverse, with 2+ concrete approaches under a settled interface (a shared seam, 2+ data-flow or state-ownership shapes). `No` on everything else — including every `Architect: yes` ticket, since architect already runs an internal arena over sketches in its Phase B.
- `Interrogate: yes` if contested, security-sensitive, or hard-to-reverse with a single approach (where `Arena: no`), `no` on the rest.
- `Both: yes` only as a narrow escape: when the architect Phase C synthesis decision still names 2+ concrete hard-to-reverse implementation approaches after the sketch settles. Requires lead/user approval. Both cap: 1 active + max 1 queued per spec, marked `Both: yes (queued, reason: <2+ approaches + what is hard-to-reverse>)`. Re-score once when the frontier first contains the queued ticket or the active Both resolves; otherwise leave flags untouched. On promotion the `(queued, reason:)` marker strips to plain `Both: yes`; a close is a land or a gap-out. Default is exclusive flags above.

Both arbitration (canonical — consumers cite, do not restate): filter to frontier-ready first; when none is ready, defer scoring until one unblocks (leave flags, note the deferral). Otherwise score ready tickets by max(a×b) where (a) is the count of concrete approaches named and (b) is the hard-to-reverse weight (b-scale: 1 reversible, 2 costly to reverse, 3 hard-to-reverse); tie goes to higher b, then lowest ticket number. Downgrade the rest to `Architect: yes`, except one runner-up within the tie band may stay `Both: yes (queued, reason: …)` to run after the active Both lands.

Flag criteria are canonical here. Consumers (`implement`, `implement-spec`, `code-review`) cite the flags; they don't redefine them. Before routing, check all four lines (0-cost): `for f in .scratch/<slug>/issues/*.md; do grep -q 'Arena:' "$f" && grep -q 'Architect:' "$f" && grep -q 'Interrogate:' "$f" && grep -q 'Both:' "$f" || echo "missing flags: $f"; done` must print nothing.

No `Blast:`/`Swarm:` flags by design: wide refactors sequence via §3 expand–contract (:40); blast analysis fires via `code-review` §5 property triggers; multi-slice exploration fans out via `implement-spec` step 2. These route on properties, not flags.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: flag-contradiction, reason: silent downgrade hides contested signal; retirement: delete markers if upstream adopts a contradiction rule -->
For tickets marked `Architect: yes`/`Arena: yes`/`Both: yes`, or where flags contradict each other, re-check against §4 in one cheap pass. In this file (interactive): collect all contradictions into the §4 quiz as one table (ticket / flags / §4-correct value / accept?) — single user pass; malformed values get one quiz-table row each. In `implement-spec` (autonomous): (1) well-formed §4 contradictions use the silent default (ticket flag wins unless it contradicts §4; e.g. `Arena: yes` with `Architect: yes` forces `Arena: no`); (2) normalizable values per the canonical map (case, surrounding whitespace, `y`/`yes` only) normalize and proceed; (3) missing lines, unnormalizable values, or Both-cap overflow mark that ticket `blocked-by-gap`, continue the rest of the frontier, and request a fix. Append each correction to `flag-corrections.md` and cite its path + count in the integration report; the PR body carries a one-line count + link. Corrections occurred iff `flag-corrections.md` is non-empty. Escalate mid-run only contradictions outside §4 pairs. `Blocked-by-gap` lifecycle (canonical): producer marks `Status:` per (3) above; autonomous consumers skip (never ready); each frontier pass re-runs the §4 four-line grep — fixed = grep-clean + §4 re-check passes + Both-cap compliant; the clearer (whoever edits the flags) resets `Status:` to ready-for-agent and appends to `flag-corrections.md`; the run lead owns the fix request (user in interactive runs). Import matches on gate-failure gaps are `blocked-by-gap-candidate` for lead check, never auto-ready.
<!-- CUSTOM-END -->

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

<!-- CUSTOM-BEGIN: flag-table, reason: batch veto stays legible; retirement: delete markers if upstream adopts a flag presentation -->
Present flags as a table (`| ticket | Architect | Arena | Interrogate | Both |`), veto by row, approve once; isolate the `Both:` row with its approval checkbox.
<!-- CUSTOM-END -->

### 5. Publish the tickets to the configured tracker

Publish the approved tickets. **How** depends on the tracker `/setup-matt-pocock-skills` configured; the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below: one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise; the tickets are agent-grabbable by construction.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

# <NN>: <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective, not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None (can start immediately)".

**Imports:** optional — only if this ticket produces shared outputs another ticket reads; else omit.

**Status:** ready-for-agent (see §4 flag-contradiction for `blocked-by-gap`)

<!-- CUSTOM-BEGIN: routing-flags-local, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->Architect / Arena / Interrogate / Both: per §4 above (do not restate the criteria here).<!-- CUSTOM-END -->

- [ ] Acceptance criterion 1
- [ ] Acceptance criterion 2

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Blocked by

- A reference to each blocking ticket, or "None (can start immediately)".

## Imports

- Optional: shared outputs this ticket produces that another ticket reads; else omit.

## Routing flags

<!-- CUSTOM-BEGIN: routing-flags-tracker, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->Architect / Arena / Interrogate / Both: per §4 above (do not restate the criteria here).<!-- CUSTOM-END -->

</issue-template>

In either form, avoid specific file paths or code snippets: they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.
