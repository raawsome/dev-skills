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

### 4. Mark routing flags

Mark each ticket's four routing flags yourself before publishing. The flag criteria, the `Both` arbitration, and the grep-clean check below govern the markings.

<!-- CUSTOM-BEGIN: no-interview-routing, reason: upstream §4 quizzes the user and has no ticket flags; this fork routes autonomously; retirement: delete markers if upstream adopts both no-interview and ticket-flag routing -->

- `Architect: yes` when the interface, usage, or module shape must still be settled before implementation, `no` otherwise.
- `Arena: yes` only when `Architect: no` AND the implementation approach itself is high-uncertainty or hard to reverse, with 2+ concrete approaches under a settled interface (a shared seam, 2+ data-flow or state-ownership shapes). `No` on everything else — including every `Architect: yes` ticket, since architect already runs an internal arena over sketches in its Phase B.
- `Interrogate: yes` if contested, security-sensitive, or hard-to-reverse with a single approach (where `Arena: no`), `no` on the rest.
- `Both: yes` only as a narrow escape: when the architect Phase C synthesis decision still names 2+ cited hard-to-reverse implementation approaches after the sketch settles. Each counted approach cites its sketch section plus a distinct axis (API shape / data model / failure semantics / external contract) plus a 1-line reason; variants without an axis diff do not count. The arbitration rubric below is the only `Both:` gate. Both cap: 1 active + 1 queued per spec; Both code-arena N=3 default, N=5 only with arena Phase A criteria cite. The holder self-marks Both: active <its-own-ticket#> in its own flag line; the next holds Both: yes (queued, reason: <2+ approaches + what is hard-to-reverse>). Transitions (vacate / promote / re-enter / downgrade): see arbitration table below (re-enter as Both: yes, re-arbitrate). Blocked: means dependency-blocked, distinct from Status: blocked-by-gap and the Blocked by: body field. `to-tickets` and `implement-spec` step 4 write the `Both:` markers and `## arbitration` entries; any consumer appends `## corrections`; `Status:` belongs to implement-spec step 4. Re-score budget and promotion order: see arbitration table below (re-entry is budget-free).

Both arbitration (canonical — consumers cite, do not restate): filter to frontier-ready first; blocked claimants keep flags untouched and hold no slots (they enter the next scoring pass on unblock, subject to the cap); when none is ready, defer scoring until one unblocks (leave flags, note the deferral). Otherwise score ready tickets by `score = Rmax × f(n_raw)` where `n_raw` is the cited approach count, `f(n_raw)`: 2→1.0, 3→1.2, ≥4→1.3; `Rmax` is the max cited hard-to-reverse weight (b-scale, each band cited to the current-spec synthesis section ID: 1 reversible <1d refactor no migration, 2 costly 1–5d migration or internal break, 3 hard persisted-data/external-contract break or >5d rewrite). Gate: eligible iff `n_raw ≥ 2` AND `Rmax ≥ 2` (cross-spec or missing cites count as uncited). Uncited or single-approach `Both: yes` claims are ineligible, never auto-fill (holds empty; downgrades to `Arena: yes` linked to the sketch in the same pass). Total-order tiebreak: score desc, then Rmax desc, then n_raw desc, then lowest ticket number (no tie band). Rank top ready-eligible to `Both: active <ticket#>`, next to queued, downgrade the rest to `Arena: yes` linked to the settled sketch ID (downgrades route to `Arena: yes` only; re-escalate only on a newly discovered hard axis with sketch amendment).

Both lifecycle transitions (Both value syntax (canonical): `no` | `yes` | `yes (queued, reason: ...)` | `active <n> [(ex-queued: <reason>)]`; log per §4 schema below):

| Transition | From → To | Trigger | Flag write |
|---|---|---|---|
| vacate | `active` → empty | holder becomes `Blocked:` (dependency-blocked) | clear slot, log vacate |
| promote | `queued` → `active` | active slot vacated | self-mark `Both: active <ticket#>`, log promote |
| re-enter | `no` → `yes` | unblocked, re-arbitrate in next scoring pass | re-claim `Both: yes`, log re-entry |
| downgrade | `yes` → `Arena: yes` | ineligible or cap excess | downgrade, log `→Arena` |

Log `ticket#, a=n_raw, Rmax, score, N, Active|Queued|→Arena, one-line reason` per decision under `## arbitration` in `.scratch/<spec>/flag-corrections.md` (N = code-arena size, 3 default; 5 only with arena Phase A criteria cite; N optional, defaults to 3 for 6-tuple readers), which has two sections, `## arbitration` (per-decision Both scoring logs) and `## corrections` (normalizer/gap fixes).

Flag criteria are canonical here. Consumers (`implement`, `implement-spec`, `code-review`) cite the flags; they don't redefine them. Before publishing, require grep-clean: each ticket file carries all four ^Architect: / ^Arena: / ^Interrogate: / ^Both: lines outside fenced code; grep-clean passes when the check prints nothing. Rewrite the file and re-run this grep until clean.

No `Blast:`/`Swarm:` flags by design: wide refactors sequence via §3 expand–contract (:40); blast analysis fires via `code-review` §5 property triggers; multi-slice exploration fans out via `implement-spec` step 2. These route on properties, not flags (properties per blast-radius Escalation rule).

When a consumer (`implement`, `implement-spec` step 4) finds a flag line missing, malformed, or contradicting another flag, it re-checks against the criteria above in one cheap pass:
(1) well-formed contradictions resolve by priority Both > Architect > Arena (Interrogate orthogonal; the ticket flag wins unless it contradicts the criteria; e.g. `Arena: yes` with `Architect: yes` forces `Arena: no`), log-not-silent — append each to `## corrections` like (3);
(2) normalizable values per the canonical map (case, surrounding whitespace, strip trailing `./,` punctuation, then `y`/`yes` only) normalize and proceed; well-formed `Both:` values (cited, not restated) proceed without normalize;
(3) an unnormalizable or missing line marks that ticket `blocked-by-gap` — the consumer writes `Status:`, skips it, and continues the rest of the frontier; a routine ticket missing only an irrelevant line proceeds (missing line defaults to `no`, logged). A syntactically well-formed but ineligible `Both:` claim downgrades per the arbitration rule above, never gaps.
Append each correction to `## corrections` in `.scratch/<spec>/flag-corrections.md` (create the file with empty `## arbitration` and `## corrections` sections if absent) and cite its path + count in the integration report; the PR body carries a one-line count + link. Corrections occurred iff `## corrections` is non-empty; escalate contradictions outside these pairs. `Blocked-by-gap` lifecycle (canonical): implement-spec step 4 alone writes the `blocked-by-gap` `Status:` transitions, skips the ticket, and re-runs the four-line grep each frontier pass — fixed = grep-clean + re-check passes + Both-cap compliant; the clearer (whoever edits the flags) resets `Status:` to ready-for-agent and appends to `## corrections`; the run lead owns the fix request. Import matches on gate-failure gaps are `blocked-by-gap-candidate` for lead check, never auto-ready.
<!-- CUSTOM-END -->

### 5. Publish the tickets to the configured tracker

Publish the tickets. **How** depends on the tracker `/setup-matt-pocock-skills` configured; the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below: one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Use the platform's native blocking relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. If the source was an existing issue, make each ticket its sub-issue (tracker doc's operation). Apply the `ready-for-agent` triage label; the tickets are agent-grabbable by construction.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

# <NN>: <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective, not a layer-by-layer implementation list.

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None (can start immediately)".

**Imports:** optional — only if this ticket produces shared outputs another ticket reads; else omit.

**Status:** ready-for-agent (see §4 for `blocked-by-gap`)

<!-- CUSTOM-BEGIN: routing-flags-local, reason: upstream has no ticket flags; retirement: delete markers if upstream adopts routing flags -->
Architect: <yes|no>
Arena: <yes|no>
Interrogate: <yes|no>
Both: <see §4 Both value syntax> (per §4 above; do not restate the criteria here).
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
Interrogate: <yes|no>
Both: <see §4 Both value syntax> (per §4 above; do not restate the criteria here).
<!-- CUSTOM-END -->

</issue-template>

In either form, avoid specific file paths or code snippets: they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.
