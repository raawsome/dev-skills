---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

<!-- CUSTOM-BEGIN: conditional-fanout, reason: unconditional background agent wastes context when source known; retirement: delete markers if upstream conditions fan-out -->
Use a single agent with the owning angle below when the source is known. Spin up **up to 3 background agents in parallel** only when the question spans 2 or more source types (for example docs say X but behavior is Y) and the answer feeds downstream work — so you keep working while they read:

1. **Docs angle**: official docs, specs, first-party API references.
2. **Source angle**: the source code that implements it.
3. **Field angle**: changelogs, issue trackers, community reports of real-world behaviour.

Then synthesise: merge the reports into a single Markdown file, citing each claim's source. Follow every claim back to the source that owns it, not a secondary write-up; resolve disagreements in favour of the owning source. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where. One fan-out level per invocation.
<!-- CUSTOM-END -->

<!-- CUSTOM-BEGIN: fanout-depth, reason: nested fan-out multiplies agents; see research §fanout-depth; retirement: delete markers if upstream adopts a depth rule -->
When invoked as a fanned child, run single-angle serially in-ticket; only the top-level invocation fans. State `depth: top | child` in the brief.
<!-- CUSTOM-END -->
