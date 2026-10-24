# Issue tracker: Local Markdown

Issues and specs for this repo live as markdown files in `.scratch/`.

## Conventions

- One feature per directory: `.scratch/<feature-slug>/`
- The spec is `.scratch/<feature-slug>/spec.md`
- Implementation issues are one file per ticket at `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01`, never a single combined tickets file
- Triage state is recorded as a `Status:` line near the top of each issue file (see `triage-labels.md` for the role strings)
- Comments and conversation history append to the bottom of the file under a `## Comments` heading
- Blocking: a `Blocked by: NN, NN` line naming ticket file numbers
- Close: set `Status: done`

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

Applies on spec close, on any tracker. Run it after the final report, which cites paths as they stand before GC. Order matters: check references first, then delete, then archive.

1. List unreferenced files in `gaps/` and `blast/` with the script below. A file is referenced while any open ticket names it (a gapped ticket carries a `Gap:` line pointing at its gap file), or an open PR does. Set `TRACKER` from `docs/agents/issue-tracker.md`. On GitHub/GitLab the script searches open issues and PRs; if that search fails (no auth, no network), it keeps the file. <!-- CUSTOM-BEGIN: blast-unmerged, reason: with no open ticket every blast/ file lists as unreferenced while the integration branch is unmerged; retirement: delete markers if upstream adds a retention rule -->`blast/` files are also kept while `integration/<spec>` is unmerged. They are released once it is merged into the default ref, is gone (pruned after the merge), or its PR/MR shows merged (GitHub/GitLab; this covers a squash merge). When the merge cannot be confirmed, keep them and list them as `kept:` for the user; never delete on uncertainty.<!-- CUSTOM-END -->
2. Delete only the listed paths, and log each one.
3. Archive `issues/` and `spec.md` under `.scratch/<spec>/archive/`, only when every ticket is closed; while any is open (gapped or blocked), skip this step. Map files (`.scratch/<spec>-map/`) persist while any open ticket references them, else archive. `flag-corrections.md` archives on spec close; never delete it while the report or PR links it.

Listing script. It uses `find` and no globs, so it runs the same under bash and zsh:

```sh
S=<absolute path to the main checkout>/.scratch/<spec>
TRACKER=local   # or github / gitlab
INTEGRATION=integration/<spec>   # CUSTOM-BEGIN blast-unmerged (see above)
DEFAULT=<default-ref>   # origin/<default-branch>, or the local default branch
ref=$(git -C "$S" rev-parse -q --verify "refs/heads/$INTEGRATION" || git -C "$S" rev-parse -q --verify "refs/remotes/origin/$INTEGRATION")
merged=0
if [ -z "$ref" ]; then merged=1   # branch gone: pruned after the merge
elif git -C "$S" merge-base --is-ancestor "$ref" "$DEFAULT"; then merged=1
else
  case $TRACKER in
    github) m=$(gh pr list --head "$INTEGRATION" --state merged --json number --jq length 2>/dev/null); [ "${m:-0}" -gt 0 ] 2>/dev/null && merged=1 ;;
    gitlab) m=$(glab mr list --source-branch "$INTEGRATION" --merged --output json 2>/dev/null); [ -n "$m" ] && [ "$m" != "[]" ] && merged=1 ;;
  esac
fi
open=$(find "$S/issues" -name '*.md' -exec grep -L -E '^\**Status:\**[[:space:]]*(done|resolved|closed)' {} + 2>/dev/null)
find "$S/gaps" "$S/blast" -type f 2>/dev/null | while IFS= read -r f; do
  n=$(basename "$f")
  case $f in "$S"/blast/*) [ "$merged" = 1 ] || { echo "kept (merge not confirmed): $f"; continue; } ;; esac   # CUSTOM-END blast-unmerged
  printf '%s\n' "$open" | grep -v '^$' | while IFS= read -r t; do grep -qF -- "$n" "$t" && echo hit; done | grep -q hit && continue
  case $TRACKER in
    github)
      [ "$(gh issue list --state open --search "\"$n\" in:body,comments" --json number --jq length 2>/dev/null)" = 0 ] || continue
      [ "$(gh pr list --state open --search "\"$n\" in:body,comments" --json number --jq length 2>/dev/null)" = 0 ] || continue ;;
    gitlab)
      [ "$(glab issue list --search "$n" --output json 2>/dev/null)" = "[]" ] || continue
      [ "$(glab mr list --search "$n" --output json 2>/dev/null)" = "[]" ] || continue ;;
  esac
  echo "unreferenced: $f"
done
# Delete only the paths listed as unreferenced above; log them. Never delete "kept" paths; list them for the user.
```
