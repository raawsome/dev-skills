# Skill mechanics

The skill-specific branch of [`writing-for-agents`](SKILL.md): what changes when the document is a skill (frontmatter, invocation, nested reach, and shared reference). Everything else about writing it is the universal reference in `SKILL.md`.

## Invocation (this harness)

OpenCode does not read `disable-model-invocation`. A skill with a `description` is reachable by the model, by nested agents, and by the Skill tool. Do not set that flag. Do not claim a skill is human-only.

Write every description as model-facing: front-load the leading word, one trigger per branch (pointer rules in `SKILL.md`). Nested agents are first-class callers, so a missing trigger is a miss for them too.

## Nested reach

An orchestrator may reach another skill in either way:

- **Skill tool** — load the callee as its own session.
- **Read-as-reference** — follow that skill's `SKILL.md` (and the files it points at) inside a subagent brief.

Both are legal. Prefer the Skill tool when the callee is a whole session. Prefer read-as-reference when the orchestrator is already running the callee's steps as a named phase (ship-it phase leads, implement-spec flagged tickets).

## Shared reference

A table several skills need (flag routing, fan-out depth, tracker GC) lives in a **plain file**, not inside one skill. Cite the file; do not restate. Flag routing lives at `~/.config/opencode/references/flag-routing.md`. Scratch GC listing lives in `setup-matt-pocock-skills/issue-tracker-local.md` (applies on every tracker).

## Splitting

Split off a skill when a distinct leading word should trigger it on its own, or another skill must reach that procedure as a unit. You pay context load for the always-loaded description, so that independent reach has to be worth it.

## Router skills

A router (ship-it) names the other skills and runs them as nested phase leads. It may Skill-invoke or follow `SKILL.md` as reference. It is not hint-only.
