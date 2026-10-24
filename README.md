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

Router: `ask-matt`. Main path: `grill-with-docs` (or `grill-me` with no repo) → `to-spec` → `to-tickets` → `implement` / `implement-spec` (drives `tdd`, closes with `dev-code-review`) → `retro`.

- `arena` — opt-in only ("arena this"). Always 3 candidates. Full phases A–F. `to-tickets` marks candidates with `Arena: yes`; `implement-spec` routes those tickets through arena; `improve-codebase-architecture` offers it for shared/2+ shape interfaces (cap 1/pick).
- `architect` — opt-in only ("architect this"). Settles caller usage, types, and module shape before code, stays in loop during fill-in, scraps on pattern-friction. `to-tickets` marks candidates with `Architect: yes`; `implement-spec` runs architect before the implementer. Exclusive with arena by default; the narrow `Both: yes` escape (1 active + 1 queued cap, model-arbitrated, no user approval) is defined in `to-tickets` §4.
- `interrogate` — opt-in only ("interrogate this", "tear this apart"). Two independent reviewers on the same diff+rubric+quality lens, lead synthesizes Act on / Consider / Noted / Dismissed. `to-tickets` marks candidates with `Interrogate: yes`; `implement-spec` and `dev-code-review` (opt-in gate) route those diffs through it.
- `blast-radius` — opt-in only ("what could this break"). Finds outside-diff breakage, proves the one safety fact by running real code (proven or unproven). Opt-in gate in `dev-code-review` for small scary diffs.
- `swarm` — opt-in only ("swarm this"). N parallel workers across slices/races, one aggregated PASS/ISSUES/BLOCKED report. Used by `implement-spec` for multi-slice exploration.
- `ponytail-review` — over-engineering only ("what can we delete"). Wired into `dev-code-review` as the third axis alongside Standards and Spec.
- `dev-code-review` — three parallel axes by default, reported separately, no reranking. Opt-in `Interrogate` and `Blast-radius` gates report under their own headings when triggered.

## Skills (30)

architect, arena, blast-radius, codebase-design, dev-code-review, diagnosing-bugs, domain-modeling, grill-me, grill-with-docs, grilling, implement, implement-spec, improve-codebase-architecture, interrogate, ponytail-review, pr, prototype, research, resolving-merge-conflicts, retro, setup-matt-pocock-skills, ship-it, swarm, tdd, to-questionnaire, to-spec, to-tickets, wayfinder, wizard, writing-for-agents

Each skill is `<name>/SKILL.md` plus supporting files. `agents/openai.yaml` files are metadata; Claude Code ignores them.

## Provenance

Upstream: mattpocock-skills 1.3.1 per the upstream changelog (static grep/diff verification against the `v1.2.3`/`v1.3.1` tags, not a behavioural check; no vendored checkout exists in this repo). Per-item: GLOSSARY rename VERIFIED (`GLOSSARY` in 10 `SKILL.md` files; no `CONTEXT` leftovers; glossary-retirement marker removed; matches upstream `CONTEXT.md => GLOSSARY.md` rename per CHANGELOG `006a52b`); Skill-tool convention VERIFIED (27 `Skill tool` hits across 14 files — wayfinder×6, dev-code-review×3, implement×3, implement-spec×3, improve-codebase-architecture×3, claude-handoff×1, grill-me×1, grill-with-docs×1, grilling×1, handoff×1, retro×1, setup-ts-deep-modules×1, tdd×1, triage×1; e.g. `implement` calls it with `tdd`/`dev-code-review`, per upstream #878); 1.3.1 router line consistent-with (`ask-matt:58` cf. `v1.3.1:skills/engineering/ask-matt/SKILL.md:48`: same diagnosing-bugs → `/retro` + seam-only `/improve-codebase-architecture` wording, paraphrased not byte-identical; `diagnosing-bugs` Phase 6 is Cleanup-only in both), not a full router-fix parity claim; `dev-code-review` 3-axis (+ Interrogate/Blast-radius gates) intentionally diverged from upstream. Graduation structure VERIFIED (`implement-spec`/`pr`/`retro` exist top-level); content intentionally diverged (custom overlays with retirement markers: `implement-spec` fanout-depth/flag-routing/merger-gate/gap-handling, `pr` blast-gate, `retro` checklist + scratch-gc). Third-party-derived custom: `pr` (from Dex Horthy's `show-me`, Humanlayer — see `pr/CREDITS.md`; not upstream). Retained: `resolving-merge-conflicts` retained-from-1.2.3, consistent-with-`v1.2.3`-tag (diff vs `v1.2.3:skills/engineering/resolving-merge-conflicts/SKILL.md` is only the em-dash fix plus the `FULLY-CUSTOM` marker; removed upstream in 1.3.0 per CHANGELOG `daa01d8`, so never-merge). Diverged: `diagnosing-bugs` (Phase 3b conditional fan-out), `research` (conditional 1-vs-3 fan-out), `dev-code-review` (third Ponytail axis + Interrogate/Blast-radius gates), ticket-flag routing (`Architect`/`Arena`/`Both`/`Interrogate` canonical in `to-tickets` §4, which routes autonomously with no user quiz and no approval step). Custom-only: `architect`, `arena`, `blast-radius`, `interrogate`, `swarm`, `ponytail-review`. Route table canonical in `ask-matt`; `arena`/`swarm`/`implement-spec` cite it. I14 (slice-7 invocation policy): `dev-code-review` + `pr` are intentionally open callers — their `agents/openai.yaml` files carry no `policy: allow_implicit_invocation: false` block (same as upstream `v1.3.1`), because the model must invoke them implicitly mid-flow and they fan out to gated callees; the callee skills they fan out to retain `false` (user/opt-in-gated), and 5 locked-callee flags in this slice retain a false (non-issue) verdict under that rationale. Census: 44 total `agents/openai.yaml`, 28 with `false`.

## Upstream watch (flattened fork, cherry-pick only)

This repo is a flattened fork: no shared history with upstream, so never blanket-merge or rebase onto it. To port an upstream fix:

```sh
git -C ~/dev-skills fetch upstream --tags
git -C ~/dev-skills show v1.3.1:skills/<group>/<skill>/SKILL.md | diff - ~/dev-skills/<skill>/SKILL.md   # what you own vs them
# group per skill: engineering|productivity|misc|in-progress — list with: git -C ~/dev-skills ls-tree -d --name-only v1.3.1 skills/
# copy the patch-class hunk by hand into ~/dev-skills/<skill>/SKILL.md,
# keeping CUSTOM-BEGIN/END blocks as the merge boundary
~/dev-skills/install.sh --diff --dry-run   # preview harness drift (safe: no copies)
~/dev-skills/install.sh          # copy into harness(es), restart harness
```

Rules: port patch-class fixes only (naming, invocation, router fixes); keep `dev-code-review` 3-axis and `ask-matt` router as owned files; when upstream adopts a custom block, delete its markers and rebase onto vendor wording in the same commit. `resolving-merge-conflicts` is never-merge.

Marker audit (`SKILL.md` scope only — this marker-audit block + ask-matt marker-convention paragraph are prose, not markers):
`grep -rho '<!-- CUSTOM-BEGIN: [^>]*-->' --include=SKILL.md . | wc -l` must equal
`grep -rho '<!-- CUSTOM-END[^>]*-->' --include=SKILL.md . | wc -l`.
Sequence (no nesting, every BEGIN closed in-file):
`for f in */SKILL.md; do perl -ne 'while(/<!-- CUSTOM-BEGIN: [^>]*-->|<!-- CUSTOM-END[^>]*-->/g){if($&=~/BEGIN/){$d++;print"$ARGV:$.: nested\n"if$d>1}else{if($d<1){print"$ARGV:$.: stray END\n"}$d--}}END{if($d!=0){print"$ARGV: unclosed\n"}}' "$f"; done`
Bare `grep -c CUSTOM-BEGIN` false-fails (prose line + multi-block lines count as 1).
