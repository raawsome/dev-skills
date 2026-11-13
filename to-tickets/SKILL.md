---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker (edges as text in one file per ticket locally, or native blocking links on a real tracker).
metadata:
  upstream: "mattpocock/skills@49dd158d1076134a641b33efb035946536778336 skills/engineering/to-tickets (compared 2026-10-14; fork point unknown)"
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to invoke the `setup-matt-pocock-skills` skill.

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

### 4. Mark routing flags

Mark each ticket's three routing flags before publishing. Criteria, Both arbitration, grep-clean, corrections, and the `blocked-by-gap` lifecycle live in `~/.config/opencode/references/flag-routing.md`. Read that file and follow it. Cite it; do not restate.

### 5. Publish the tickets to the configured tracker

Publish the tickets. **How** depends on the tracker the `setup-matt-pocock-skills` skill configured; the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's `Blocked by:` line lists the file numbers it depends on (`Blocked by: 01, 03`). Use the per-ticket file template below: one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. <!-- CUSTOM-BEGIN: blocking-via-tracker-doc, reason: native edges need tracker-specific calls (GitHub numeric db id, GitLab Premium) that §5 never named, so agents skipped or botched them; retirement: delete markers if upstream points §5 at the tracker doc -->Set blocking edges per the tracker doc's Wayfinding operations "Blocking" entry (with its fallback); with no such entry, use the platform's native blocking relationship where it has one, else set each ticket's "Blocked by" to the blocking issues.<!-- CUSTOM-END --> If the source was an existing issue, make each ticket its sub-issue (tracker doc's operation). Apply the `ready-for-agent` triage label; the tickets are agent-grabbable by construction. <!-- CUSTOM-BEGIN: create-labels, reason: setup writes no labels without triage, and a create with a missing label fails; retirement: delete markers if setup creates labels -->On GitHub/GitLab, create the label first if it's missing (`gh label create <name>` / `glab label create --name <name>`).<!-- CUSTOM-END --> <!-- CUSTOM-BEGIN: second-pass-ids, reason: Both: active <n> and cross-references need ids that exist only after creation; retirement: delete markers if upstream wires ids in a second pass -->Write each `Both: active <n>` marker and every cross-reference after all tickets exist, in a second pass, with real ids: a placeholder `#<n>` auto-links to an unrelated issue.<!-- CUSTOM-END -->

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue. <!-- CUSTOM-BEGIN: sub-issue-exception, reason: linking sub-issues touches the parent and read as a contradiction; retirement: delete markers if upstream words the exception -->Linking each ticket as the parent's sub-issue is the one allowed change.<!-- CUSTOM-END -->

<local-ticket-template>

# <NN>: <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective, not a layer-by-layer implementation list.

**Blocked by:** the file numbers of the tickets that gate this one (`01, 03`), or "None (can start immediately)".

**Imports:** optional — only if this ticket produces shared outputs another ticket reads; else omit.

**Status:** ready-for-agent (see `~/.config/opencode/references/flag-routing.md` for `blocked-by-gap`)

<!-- CUSTOM-BEGIN: routing-flags-local, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->
Architect: <yes|no>
Arena: <yes|no>
Both: <value per flag-routing.md Both value syntax>
<!-- CUSTOM-END -->

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

- A reference to each blocking ticket, or "None (can start immediately)". Omit this section when blockers were set as native edges.

## Imports

- Optional: shared outputs this ticket produces that another ticket reads; else omit.

## Routing flags

<!-- CUSTOM-BEGIN: routing-flags-tracker, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->
Architect: <yes|no>
Arena: <yes|no>
Both: <value per flag-routing.md Both value syntax>
<!-- CUSTOM-END -->

</issue-template>

In either form, avoid specific file paths or code snippets: they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.
