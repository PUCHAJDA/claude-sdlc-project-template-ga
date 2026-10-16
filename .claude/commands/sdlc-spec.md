---
description: Stage 2 — turn the accepted intent.md into spec.md, then have it reviewed
argument-hint: [optional: what to focus on]
---

Use the `spec-writer` skill.

Read `docs/sdlc/intent.md` and write `docs/sdlc/spec.md`. $ARGUMENTS

Apply every relevant skill in `.claude/skills/` and flag what they raise as
`> **CONCERN (<skill>):**` blocks inline. Do not resolve a concern by narrowing the spec.

When the draft is written, run the `spec-reviewer` subagent against it and show me its
verdict before we go further. Revise on **Blocking** items; bring **Worth fixing** items
to me as a short list rather than acting on all of them.

Commit as `docs: spec for <slug>` once I accept it.
