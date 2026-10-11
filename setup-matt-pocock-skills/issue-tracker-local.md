# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading

## When a skill says "publish to the issue tracker"

Create a new file under `.scratch/<feature-slug>/` (creating the directory if needed).

## When a skill says "fetch the relevant ticket"

Read the file at the referenced path. The user will normally pass the path or the issue number directly.

## Wayfinding operations

Used by `/wayfinder`. The **map** is a file with one **child** file per ticket.

- **Map**: `.scratch/<effort>/map.md` (the Notes / Decisions-so-far / Fog body).
- **Child ticket**: `.scratch/<effort>/issues/NN-<slug>.md`, numbered from `01`, with the question in the body. A `Type:` line records the ticket type (`research`/`prototype`/`grilling`/`task`); a `Status:` line records `claimed`/`resolved`.
- **Blocking**: a `Blocked by: NN, NN` line near the top. A ticket is unblocked when every file it lists is `resolved`.
- **Frontier**: scan `.scratch/<effort>/issues/` for files that are open, unblocked, and unclaimed; first by number wins.
- **Claim**: set `Status: claimed` and save before any work.
- **Resolve**: append the answer under an `## Answer` heading, set `Status: resolved`, then append a context pointer (gist + link) to the map's Decisions-so-far in `map.md`.

## scratch GC convention (canonical listing)

On spec close, GC unreferenced `.scratch/<spec>/`; archive `issues/` + `spec.md` under `.scratch/<spec>/archive/`.

Listing (`nullglob` + `grep -rl` unreferenced, rm-only-listed):

```sh
shopt -s nullglob; for f in ".scratch/<spec>/gaps/"* ".scratch/<spec>/blast/"*; do [ -e "$f" ] || continue; grep -rl --exclude-dir=archive "$(basename "$f")" ".scratch/<spec>/issues" ".scratch/<spec>/spec.md" .scratch/<spec>/map* 2>/dev/null | grep -q . || echo "unreferenced: $f"; done
# rm only paths listed as unreferenced above; log the paths.
```

Retention: `issues/` + `spec.md` → archive; map files persist while referenced by any open ticket, else archive; `gaps/` persist while named in any open `Blocked by`; `blast/` persist while linked from an open PR; `flag-corrections.md` archives on spec close, never delete while linked from the report or PR.
