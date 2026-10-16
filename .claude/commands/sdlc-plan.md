---
description: Stage 3 — build an interrogated implementation plan from spec.md and commit it
argument-hint: [optional: constraint or area to focus on]
---

**Enter plan mode (Shift+Tab) before running this** so you cannot edit files until I accept.

Read `docs/sdlc/spec.md`. $ARGUMENTS

Before planning, read the files you will actually change. Do not plan against guesses about
what the code looks like.

Produce a plan listing, in order:

- every file touched and why
- the test added or changed for each acceptance criterion
- the sequence of commits
- anything in `spec.md` you cannot implement as written

Then interrogate your own plan and answer in it: what is the riskiest assumption here, what
breaks if it is wrong, and what is the cheapest way to find out before writing code?

When I accept, write `docs/sdlc/plan.md` and commit it **before** touching any other file.
