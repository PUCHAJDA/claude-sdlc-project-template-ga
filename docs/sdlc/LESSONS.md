<!--
STAGE 6 — Maintain. Append-only record of what production taught us.

Written after every incident, by whoever ran it (human or Claude on call). Protected path:
it is evidence, so it does not get edited as a side effect of feature work.

Each entry must leave three things behind, or it was not worth writing:
  1. an eval task under evals/tasks/ that fails if this returns
  2. a line in CLAUDE.md, if the cause was a trap an agent would walk into again
  3. an intent.md, if the real problem is bigger than the fix
-->

# Lessons

## <YYYY-MM-DD> — <short title>

**Signal:** <metric, band crossed, how it was noticed>
**Impact:** <who was affected, for how long, how badly>

**What happened:** <sequence, in plain language>

**Root cause:** <the cause, not the trigger. "Deploy X went out" is a trigger; whatever
made deploy X breakable is the cause.>

**Why it was not caught earlier:** <the gap in the loop — missing test, missing eval,
guardrail in the wrong place, spec that never stated the requirement>

**Closed the loop:**

- [ ] Eval added: `evals/tasks/<slug>.md`
- [ ] `CLAUDE.md` updated — <which line, or n/a>
- [ ] Hook or lint rule added — <which, or n/a>
- [ ] `intent.md` raised for the underlying problem — <link, or n/a>

---
