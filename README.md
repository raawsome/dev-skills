# agent-skills

Personal skill set: Matt Pocock's idea→ship flow, plus `arena` (parallel candidates, pick + graft), `architect` (shape before code), `interrogate` (independent adversarial review), `blast-radius` (outside-diff breakage, proven by run), `swarm` (parallel workers, one report), and `ponytail-review` (over-engineering review). Same `SKILL.md` open standard, installs into **opencode** and **Claude Code**.

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

- `arena` — opt-in only (`/arena`, "arena this"). Always 3 candidates. Full phases A–F. `to-tickets` marks candidates with `Arena: yes`; `implement-spec` routes those tickets through arena; `improve-codebase-architecture` offers it for shared/2+ shape interfaces (cap 1/pick).
- `architect` — opt-in only (`/architect`, "architect this"). Settles caller usage, types, and module shape before code, stays in loop during fill-in, scraps on pattern-friction. `to-tickets` marks candidates with `Architect: yes`; `implement-spec` runs architect before the implementer. Exclusive with arena by default; the narrow `Both: yes` escape (1 active + 1 queued cap, approval, arbitration) is defined in `to-tickets` §4.
- `interrogate` — opt-in only ("interrogate this", "tear this apart"). Two independent reviewers on the same diff+rubric+quality lens, lead synthesizes Act on / Consider / Noted / Dismissed. `to-tickets` marks candidates with `Interrogate: yes`; `implement-spec` and `code-review` (opt-in gate) route those diffs through it.
- `blast-radius` — opt-in only ("what could this break"). Finds outside-diff breakage, proves the one safety fact by running real code (proven or unproven). Opt-in gate in `code-review` for small scary diffs.
- `swarm` — opt-in only (`/swarm`, "swarm this"). N parallel workers across slices/races, one aggregated PASS/ISSUES/BLOCKED report. Used by `implement-spec` for multi-slice exploration.
- `ponytail-review` — over-engineering only (`/ponytail-review`, "what can we delete"). Wired into `code-review` as the third axis alongside Standards and Spec.
- `code-review` — three parallel axes by default, reported separately, no reranking. Opt-in `Interrogate` and `Blast-radius` gates report under their own headings when triggered.

## Skills (44)

architect, arena, ask-matt, blast-radius, claude-handoff, code-review, codebase-design, diagnosing-bugs, domain-modeling, git-guardrails-claude-code, grill-me, grill-with-docs, grilling, handoff, implement, implement-spec, improve-codebase-architecture, interrogate, loop-me, migrate-to-shoehorn, ponytail-review, pr, prototype, research, resolving-merge-conflicts, retro, scaffold-exercises, setup-matt-pocock-skills, setup-pre-commit, setup-ts-deep-modules, swarm, tdd, teach, to-questionnaire, to-spec, to-tickets, triage, wait-what, wayfinder, wizard, writing-beats, writing-for-agents, writing-fragments, writing-shape

Each skill is `<name>/SKILL.md` plus supporting files. `agents/openai.yaml` files are metadata; Claude Code ignores them.

## Provenance

Upstream: mattpocock-skills 1.3.1 per the upstream changelog (vendored checkout here is 1.2.3, so 1.3.x parity — GLOSSARY rename, graduated `implement-spec`/`retro`, Skill-tool convention, 1.3.1 router fix — is claimed, not verified). Third-party-derived custom: `pr` (from Dex Horthy's `show-me`, Humanlayer — see `pr/CREDITS.md`; not upstream). Retained: `resolving-merge-conflicts` (present in vendored 1.2.3 under `skills/engineering/`; per upstream changelog removed in 1.3.0 — unverifiable from this checkout; kept here as `FULLY-CUSTOM`). Diverged: `diagnosing-bugs` (Phase 3b conditional fan-out), `research` (conditional 1-vs-3 fan-out), `code-review` (third Ponytail axis + Interrogate/Blast-radius gates), ticket-flag routing (`Architect`/`Arena`/`Both`/`Interrogate` canonical in `to-tickets` §4). Custom-only: `architect`, `arena`, `blast-radius`, `interrogate`, `swarm`, `ponytail-review`. Route table canonical in `ask-matt`; `arena`/`swarm`/`implement-spec` cite it.

## Upstream watch (flattened fork, cherry-pick only)

This repo is a flattened fork: no shared history with upstream, so never blanket-merge or rebase onto it. To port an upstream fix:

```sh
git -C ~/dev-skills fetch upstream --tags
git -C ~/dev-skills diff v1.3.1 main -- <skill>/SKILL.md   # what you own vs them
# copy the patch-class hunk by hand into ~/dev-skills/<skill>/SKILL.md,
# keeping CUSTOM-BEGIN/END blocks as the merge boundary
~/dev-skills/install.sh --diff   # preview harness drift
~/dev-skills/install.sh          # copy into harness(es), restart harness
```

Rules: port patch-class fixes only (naming, invocation, router fixes); keep `code-review` 3-axis and `ask-matt` router as owned files; when upstream adopts a custom block, delete its markers and rebase onto vendor wording in the same commit. `resolving-merge-conflicts` is never-merge.
