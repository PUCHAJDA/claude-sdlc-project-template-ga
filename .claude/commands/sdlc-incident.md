---
description: Stage 6 — diagnose a production signal read-only and turn it back into intent.md
argument-hint: <metric> crossed <band> — value vs baseline, since when
---

Signal: $ARGUMENTS

Check `docs/sdlc/bands.yaml` for what this band authorizes. Do not exceed it:

- **1σ** — log only. Say so and stop.
- **2σ** — diagnose read-only. No edits, no PR.
- **3σ** — a PR or a pre-approved runbook is allowed, after you have said which one and why.

Diagnose by correlating the signal window against recent merges, config changes and
deploys. Give me the three most likely causes ranked by evidence, the observation that
would separate them, and the cheapest safe mitigation.

Then close the loop:

1. Append the incident to `docs/sdlc/LESSONS.md` — what happened, root cause, what would
   have caught it earlier.
2. Write `docs/sdlc/intent.md` for the **underlying problem**, not the symptom. The loop
   restarts at Stage 1.
3. Propose an eval task under `evals/tasks/` whose acceptance check fails if this
   regression returns.
