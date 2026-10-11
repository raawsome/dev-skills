---
name: ponytail-review
description: >
  Use ONLY when the user says "review for over-engineering", "what can we
  delete", "is this over-engineered", "simplify review", or invokes
  /ponytail-review, or when another skill routes a diff here (code-review §4, swarm Phase D). Code review focused exclusively on over-engineering. Finds what to delete:
  reinvented standard library, unneeded dependencies, speculative abstractions,
  dead flexibility. One line per finding: location, what to cut, what replaces
   it. Complements correctness-focused review, this one only
  hunts complexity.
---

Review diffs for unnecessary complexity. One line per finding: location, what
to cut, what replaces it. The diff's best outcome is getting shorter.

## Format

`L<line>: <tag> <what>. <replacement>.`, or `<file>:L<line>: ...` for
multi-file diffs.

Tags:

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same logic, fewer lines. Show the shorter form.

## Examples

❌ "This EmailValidator class might be more complex than necessary, have you
considered whether all these validation rules are needed at this stage?"

✅ `L12-38: stdlib: 27-line validator class. "@" in email, 1 line, real validation is the confirmation mail.`

✅ `L4: native: moment.js imported for one format call. Intl.DateTimeFormat, 0 deps.`

✅ `repo.py:L88: yagni: AbstractRepository with one implementation. Inline it until a second one exists.`

✅ `L52-71: delete: retry wrapper around an idempotent local call. Nothing replaces it.`

✅ `L30-44: shrink: manual loop builds dict. dict(zip(keys, values)), 1 line.`

## Scoring

<!-- CUSTOM-BEGIN: ponytail-metric, reason: absolute N rewards golf; retirement: delete markers if upstream adds a denominator -->
End with `net: -<N> / touched <M> (+/-), -<P>%` where P is round(100×N/M) and M is added+modified+deleted diff lines under the same `-w` and comment-only exclusions as N. Measure with `git diff --numstat -w <base>...HEAD`, then subtract comment-only lines from the counts. M=0 → P=—. Each `shrink:` shows the shorter form; each `delete:` / `yagni:` names the absent caller or need. `Lean already. Ship.` is a passing result but must still be accompanied by a `Ponytail ran` status line and the `net:` line.
<!-- CUSTOM-END -->

If there is nothing to cut, say `Ponytail ran. Lean already. Ship.` with the `net:` line and stop.

## Boundaries

Scope: over-engineering and complexity only. Correctness bugs, security holes,
and performance are explicitly out of scope. Route them to a normal review
pass, not this one. A single smoke test or `assert`-based
self-check is the ponytail minimum, not bloat, never flag it for deletion.
Does not apply the fixes, only lists them.
