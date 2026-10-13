---
name: ship-it
description: "Route a request from fog to done through wayfinder or grill-with-docs, then to-spec, to-tickets, implement-spec, using nested Task subagents."
disable-model-invocation: true
---

# Ship-it — router-orchestrator with nesting

You are the top-level orchestrator (depth: top). You route, then run one phase at a time. Each phase is one Task subagent. Briefs carry pointers (map URL, spec path, ticket IDs, SHAs, grounding dir), never pasted bodies.

Requires `subagent_depth >= 2` in `opencode.jsonc` (3 configured gives one level headroom). Chain: primary(0) → phase(1) → worker(2, leaf). Without it the depth-2 fan-out fails with `Subagent depth limit reached`.

<!-- CUSTOM-BEGIN: nested-orchestrator, reason: upstream has no cross-phase orchestrator; user-invoked skills cannot Skill-invoke user-invoked skills per writing-for-agents SKILL-MECHANICS:10,22, so phases run as Task subagents following SKILL.md files as reference — an intentional waiver of the router-hint-only rule, cost is maintenance + context load, human accepts; retirement: delete markers if upstream adds an orchestrator -->
## Depth protocol (binding)

Follow research §fanout-depth: one fan-out level per invocation. State `depth: top|child` in every brief. A fanned child runs its payload serially in-ticket; it performs leaf work only (read, write, test, report) and spawns nothing further — run serially, never fan out to swarm, arena, or parallel implementers. Swarm subagents never fan out.

Recursion guard: max chain primary(0) → phase(1) → worker(2). A worker at depth 2 is a leaf. Fan-out sites: Phase 1 research tickets only (mirrors wayfinder charting step 5) and Phase 4 implementers/mergers. No other phase fans; no worker fans.
<!-- CUSTOM-END -->

## Route (in-session, no subagent)

Read the target SKILL.md before each phase; summaries here are a cache. Routing cites `ask-matt`.

1. Tracker check: if the issue tracker is unconfigured, stop and tell the user to run `/setup-matt-pocock-skills`.
2. Pick exactly one sharpening path:
   - Huge, foggy, greenfield, destination unclear, larger than one session holds → Path A (`wayfinder`: chart map, work tickets until clear, merge at `to-spec`).
   - In a working directory and holdable in one session → Path B (`grill-with-docs`: the phase subagent calls the Skill tool twice for `grilling` + `domain-modeling` — both model-invoked, so the Skill path is legal).
   - No working directory → Path B' (`grill-me`: Skill tool with `grilling` only, stateless).
   - Conversation already holds settled decisions (cleared map, finished grilling) → skip to Phase 2.
3. Open a todolist: Route / Sharpen / Spec / Tickets / Implement / Review.

## Phases (one Task subagent each, sequential, HITL gates hold)

### 1. Sharpen (depth: top → child serial)

- Path A: phase subagent follows `wayfinder/SKILL.md` as reference. Chart once, then one ticket per follow-up run (claim-by-assignee first, before any work; resolve by `wayfinder:<type>` label — read the label, not just the body; labels are `wayfinder:`-only, never `ready-for-agent`; resolution comment + close + Decisions-so-far pointer). Research tickets may run parallel at depth 2 (findings on throwaway `research/<name>` branch, pushed, never merged, no PR); grilling/prototype tickets pause for the human (never answer for the human side); task tickets unblock decisions (checklist when HITL, solo when AFK). Graduate fog as the frontier advances (move specifiable patches out of Not yet specified into tickets, rule beyond-destination work out of scope with a close + line). Exit when no open tickets remain and no fog is left.
- Path B/B': phase subagent runs the grilling rounds (frontier per round, recommended answer each, facts via leaf reads, decisions via user) plus `domain-modeling` discipline on Path B (`GLOSSARY.md` inline, ADRs only when hard-to-reverse + surprising + traded-off). Done when frontier empty + user confirms shared understanding.
- GATE 1: user confirms the destination (Path A) or shared understanding (Path B).

### 2. Spec (depth: top → child serial)

Phase subagent follows `to-spec/SKILL.md` as reference: explore repo, use glossary vocabulary, respect ADRs, propose test seams. Publish one spec issue, label `ready-for-agent`. Done when the spec issue URL is reported.
- GATE 2: user approves seams + spec. Pass the spec path/URL plus decision pointers forward to Phase 3 (Task boundaries clear context, so carry pointers, never assume shared memory).

### 3. Tickets (depth: top → child serial)

Phase subagent follows `to-tickets/SKILL.md` as reference: tracer-bullet vertical slices (prefactor first, expand–contract for wide refactors), blocking edges, four routing flags (`Architect:/Arena:/Interrogate:/Both:`, criteria canonical in `to-tickets` §4 — cite, never restate), grep-clean gate. Publish blockers-first with `ready-for-agent`. Done when ticket URLs/IDs are reported blockers-first.
- GATE 3: user approves slices (default-on when any `Both: yes` present).

### 4. Implement (depth: top → child fans; workers depth: child, leaf)

Phase subagent follows `implement-spec/SKILL.md` as reference on `integration/<spec-slug>` (`$INTEGRATION`, prune on resolve). It fans workers at depth 2 (each worker brief states `depth: child` plus `$INTEGRATION`): one implementer per frontier ticket (own worktree/branch, drift check, `tdd`, merge `$INTEGRATION` in), one merger per completion (typecheck + ticket-tests + grep DENY gate; WARN/advisory to must-clear list), flag routing per `implement-spec` §4 (`Architect: yes` → sketch-then-fill serially in-ticket at depth 2 — fill serially, never fan a deeper arena). Exploration swarm only when `implement-spec` step 2 triggers it (≥3 slices, declared shape + N), and only at phase level, never inside a worker. Done when every ticket is landed or gapped and the frontier is empty.
- If a worker hits triple-red, it writes `.scratch/<spec>/gaps/<ticket>.md` and continues around the gap per `implement-spec` step 5.

### 5. Review and close (depth: top → child serial)

Phase subagent (brief states `depth: child`) runs `code-review` on `$INTEGRATION` (Interrogate gate for `Interrogate: yes` tickets, autonomous rule: log-and-continue), fixes review + must-clear in one serial pass, marks draft PR ready (body via `pr`) or resolves tickets per tracker, reports branch + corrections count + link, cleans worktrees, GCs scratch per `setup-matt-pocock-skills/issue-tracker-local.md` §scratch GC convention. Done when the must-clear list is empty, review issues are closed, and the report is posted.

## Report

Map link, spec link, ticket count, `$INTEGRATION`/PR link, blocked/gap IDs + paths, corrections path + count. One line per artifact, names not bare numbers.
