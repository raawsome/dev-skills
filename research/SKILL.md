---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
---

Spin up **3 background agents in parallel**, each from a different angle, so you keep working while they read:

1. **Docs angle**: official docs, specs, first-party API references.
2. **Source angle**: the source code that implements it.
3. **Field angle**: changelogs, issue trackers, community reports of real-world behaviour.

Then synthesise: merge the three reports into a single Markdown file, citing each claim's source. Follow every claim back to the source that owns it, not a secondary write-up; resolve disagreements in favour of the owning source. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.
