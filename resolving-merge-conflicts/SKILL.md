---
name: resolving-merge-conflicts
description: "Resolve in-progress git merge/rebase conflict."
metadata:
  upstream: "mattpocock/skills removed in 1.3.0 (daa01d8); last upstream version unknown"
---

<!-- FULLY-CUSTOM: no upstream in v1.3.1, never merge; retirement: delete this file if upstream re-adds the skill -->
1. **See the current state** of the merge/rebase. Check git history, and the conflicting files.

2. **Find the primary sources** for each conflict. Understand deeply why each change was made, and what the original intent was. Read the commit messages, check the PRs, check original issues/tickets.

3. **Resolve each hunk.** Preserve both intents where possible. Where incompatible, pick the one matching the merge's stated goal and note the trade-off. Do **not** invent new behaviour. <!-- CUSTOM-BEGIN: needs-user-carveout, reason: ship-it merger worktrees need a NEEDS-USER carve-out from never-abort; retirement: delete markers if upstream re-adds the skill -->Resolve every hunk you can. If one needs the user, stop and ask the user (as a subagent: return `NEEDS-USER: <question>`) leaving the tree as it is; never `--abort` yourself (a ship-it lead resets; standalone, the user decides).<!-- CUSTOM-END -->

4. Discover the project's **automated checks** and run them, typically typecheck, then tests, then format. Fix anything the merge broke.

5. **Finish the merge/rebase.** <!-- CUSTOM-BEGIN: no-add-all, reason: `git add -A` swept untracked check/test output into the commit; retirement: delete markers if upstream re-adds the skill -->Stage only the paths you resolved or edited, never `git add -A` (untracked check/test output), and commit.<!-- CUSTOM-END --> If rebasing, continue the rebase process until all commits are rebased.
