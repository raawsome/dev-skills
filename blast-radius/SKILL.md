---
name: blast-radius
description: "What a change breaks beyond the diff, proven by running code. ONLY blast-radius asks, untrusted small diff, shared code, library version, concurrency-lifecycle, wire-format, dev-code-review §5."
license: MIT
metadata:
  upstream: "cursor/plugins@1e5c90a4b6f249917bd21fe361b3a2a7deb741b8 pstack/skills/blast-radius (compared 2026-10-14; fork point unknown)"
---

<!-- FULLY-CUSTOM: no upstream in mattpocock/skills v1.3.1, never merge from it; pstack fork, see metadata.upstream; retirement: delete this file if upstream re-adds the skill -->
# Blast radius

Find what a change breaks somewhere else, before it ships.

Listing the callers is not the job. The callers can be grepped in a second. The job is the breakage grep won't show you.

## Don't trust your own writeup

A blast-radius writeup that sounds right is worthless. It reads as convincing whether or not it's true. So don't hand back the writeup. Find the one or two facts the whole thing depends on and prove them by running code.

### How sure are you

For each fact the change's safety depends on, get it as far down this list as is cheap, and say where it stopped.

1. You said so. Worthless on its own.
2. You pointed at the line. A real `file:line`, or the library's own source.
3. You showed the bad case can't happen. You walked the failure step by step and it doesn't reach.
4. You ran it. A script or test that calls the real code and fails loud if you're wrong.
5. You reproduced it in the running app.

Step 4 is usually one small script that imports the same library the app ships and calls the exact function you're worried about.

### Escalation rule

- Attempt level 4 only when all hold: (a) you can execute code here (probe with an exec command with a timeout; if no probe command fits in the timeout, treat as no exec env), (b) the risk is non-trivial — non-trivial means it touches any of: shared code, library version, concurrency/lifecycle, wire format — (c) levels 2-3 did not already clear it (cleared = cited file:line + walked failure path that doesn't reach; persisted-document field with other writers: clearance is the writer-enumeration Fact at level 4).
- Attempt level 5 only when level 4 passed but integration doubt remains — doubt means naming the specific untested hop (e.g. downstream consumer, wire peer, lifecycle host) — AND the app is runnable in under 2 minutes (probe with a start/build/test command with a timeout; if no probe command fits in the timeout, automatically report "Level 4 proven, level 5 not attempted because <reason>").
- No exec env means stopping at the highest cheap level. Mark `UNPROVEN (highest: level N; cheapest next check: <one command>)`. Non-wire-format UNPROVEN stays advisory; UNPROVEN wire-format is merge-blocking.
<!-- CUSTOM-BEGIN: writer-fact, reason: a reader-only proof misses other writers of a persisted document; retirement: delete markers if upstream freezes the fact to a writer -->
- A new, retyped, or newly owned field on a persisted document or replace-all request is wire-format even when the write handler is absent from the diff. Enumerate other writers of that document (PUT replace, form Save, merge, rebuild). Other writers: freeze `Fact:` as "<writer> then <observable>"; level 4 is that writer call plus the read; clearance is that Fact at level 4. No other writer: freeze `Fact:` as "sole writer: <this change>"; levels 2-3 may clear it. The Fact names a writer; reader observables (CSV cell, report projection, prompt render, legacy-empty) are the proof's check.
<!-- CUSTOM-END -->

## Steps

1. Read the change. The diff, the symbols it adds, changes, and deletes, and what it now does differently, including the part the diff doesn't spell out. Pull the PR description and commits for history where available.
2. Find the one fact it's safe because of. Most changes that look risky are safe because of a single fact, like "this call only drops already-dead cache entries and does nothing else". Find that fact. If it holds, most risky cases are cleared at once. Spend your time here, not on a long list of maybes. Persisted-document fields: the Fact is the Escalation writer-enumeration.
3. Look where grep stops. Read the source of the library you call, and check its pinned version and any local patch. Work out when things run: microtasks, unmount and teardown, framework lifecycle semantics. Follow what a symbol search misses: the JSON an API returns, a DB column, a wire format, another language reading the same bytes, a feature flag, code three hops downstream.
4. Be honest about each risk. Give it a real chance of happening and a real cost if it does. Keep the risks you confirmed. List the ones you checked and cleared separately. Cite a real `file:line`; a search that finds nothing is still an answer, and never make up a caller or an API.
5. Prove the one fact when the escalation rule fires. Write the script or test under `.scratch/<slug>/blast/` (`<slug>`: the spec's slug when there is one; in a worktree, use the main checkout's absolute path from your brief) so it is rerunnable, run it against the real code, and paste what happened. Otherwise skip and say why (no exec env, or levels 2-3 already cleared it).

<!-- CUSTOM-BEGIN: fact-linkage, reason: free exec invites retrofit-proofing; retirement: delete markers if upstream freezes the fact -->
Freeze one sentence in step 2 as `Fact: "<...>"`. Step 5 cites it verbatim: `Proves Fact: "<...>" → level N→M (N, M in 1..5 per How sure are you) via .scratch/<slug>/blast/...` plus output. A changed fact is restated and re-proved. `UNPROVEN` still names the fact: `Fact: "<...>" — UNPROVEN [wire-format|other] (highest: level N; cheapest next check: <one command>)`.
<!-- CUSTOM-END -->
6. For a big or wide change, run it as an **arena** (read `arena/SKILL.md` and follow it; never via the Skill tool) only via Arena: yes routing (Architect: no + 2+ approaches) per `to-tickets` §4. Ask more than one candidate the same question and merge the answers. Different attempts catch different real bugs.

## What to hand back

- **What it does.** What changed, including the part that isn't obvious.
- **The one fact it's safe because of.** State it, say which certainty step you got it to, and show the proof. If you couldn't prove it, write unproven.
- **Risks.** Each names how it breaks, the `file:line`, how likely and how bad, and how to check. Paste the proof for the ones that matter.
- **Cleared.** What you checked and why it's fine.
- **Before you merge.** The cheapest test or repro that catches the real bug, including the script you wrote.

**Reply:** the writeup above, with the one safety fact either proven or marked unproven.
