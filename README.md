# agent-skills

Personal skill set: Matt Pocock's idea→ship flow, plus `arena` (parallel candidates, pick + graft) and `ponytail-review` (over-engineering review). Same `SKILL.md` open standard, installs into **opencode** and **Claude Code**.

## Install

```sh
git clone https://github.com/raawsome/dev-skills.git ~/dev-skills
~/dev-skills/install.sh                    # copy into both harnesses
~/dev-skills/install.sh --claude-only --symlink   # Claude only, live-linked
~/dev-skills/install.sh --opencode-only    # opencode only
~/dev-skills/install.sh --list             # list skills
```

Targets (overridable via `OPENCODE_SKILLS_DIR` / `CLAUDE_SKILLS_DIR`):

- opencode → `~/.config/opencode/skills/<name>/`
- Claude Code → `~/.claude/skills/<name>/` (symlinks supported)

Restart the harness after installing so new skills register. Re-run after `git pull` to pick up updates.

## Flow

Router: `ask-matt`. Main path: `grill-with-docs` (or `grill-me` with no repo) → `to-spec` → `to-tickets` → `implement` / `implement-spec` (drives `tdd`, closes with `code-review`) → `retro`.

- `arena` — opt-in only (`/arena`, "arena this"). N=2 default, max 3. Full phases A–F. `to-tickets` marks candidates with `Arena: yes`; `implement-spec` routes those tickets through arena; `improve-codebase-architecture` offers it for shared/ADR-worthy/2+ shape interfaces (cap 1/pick).
- `ponytail-review` — over-engineering only (`/ponytail-review`, "what can we delete"). Wired into `code-review` as the third axis alongside Standards and Spec.
- `code-review` — three parallel axes, reported separately, no reranking.

## Skills (39)

arena, ask-matt, claude-handoff, code-review, codebase-design, diagnosing-bugs, domain-modeling, git-guardrails-claude-code, grill-me, grill-with-docs, grilling, handoff, implement, implement-spec, improve-codebase-architecture, loop-me, migrate-to-shoehorn, ponytail-review, pr, prototype, research, retro, scaffold-exercises, setup-matt-pocock-skills, setup-pre-commit, setup-ts-deep-modules, tdd, teach, to-questionnaire, to-spec, to-tickets, triage, wait-what, wayfinder, wizard, writing-beats, writing-for-agents, writing-fragments, writing-shape

Each skill is `<name>/SKILL.md` plus supporting files. `agents/openai.yaml` files are metadata; Claude Code ignores them.
