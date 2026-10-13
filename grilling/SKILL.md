---
name: grilling
description: Grill user relentlessly on plan, decision, idea.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

<!-- CUSTOM-BEGIN: invocation-scope, reason: bare "grill" phrases would bypass the grill-me vs grill-with-docs working-directory decision; retirement: delete markers if upstream scopes the trigger -->
Invoke this primitive via the Skill tool only; the `grill*` trigger phrases (`grill me`, `grill this`, `stress-test this`, `challenge this`) route to `/grill-me` vs `/grill-with-docs` per `ask-matt` (working directory decides), never via trigger phrases here.
<!-- CUSTOM-END -->

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. Ask the whole frontier in one round: number each question and give your recommended answer. Then wait for the user's answers before the next round.

Format a round like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>

---

❓ **Q2** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

<!-- CUSTOM-BEGIN: yes-framing, reason: yes-means-recommended keeps rounds decisive; retirement: delete markers if upstream pins question framing -->
Word each question so "yes" accepts your recommended answer.
<!-- CUSTOM-END -->

Each round the user answers reshapes the tree: settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question still open in this round belongs to a _later_ round, not this one.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report; ask the rest of the frontier now. The _decisions_ are the user's: put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
