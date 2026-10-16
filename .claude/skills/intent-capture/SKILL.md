---
name: intent-capture
description: Turn a raw problem, complaint, feature idea or pain point into a committed docs/sdlc/intent.md. Use when someone describes something that is broken, missing, slow or annoying and no intent.md exists yet — including phrasings like "we should build", "users keep complaining", "it would be good if", "can we add". Do not use when an intent.md for this problem already exists; use spec-writer instead.
---

# Capture intent

The first stage of the SDLC. Output is `docs/sdlc/intent.md` — a statement of the problem,
not of the solution. Everything downstream is judged against it, so a vague intent produces
a confident spec for the wrong thing.

## Interview first

Ask **one question at a time**. Stop when you can answer all six sections without guessing,
or when the human says to write it — whichever comes first.

Ask about what was not said:

- Who is actually blocked by this, and how do they work around it today?
- How often, and what does each occurrence cost?
- What happens if nothing is done for a quarter?
- Which constraint is being treated as fixed that is not actually fixed?
- Who has to agree before this ships?
- What would make this a failure even if it shipped on time?

Do not propose solutions during the interview. If the human describes a solution, ask what
problem it solves and record that instead.

## Then write

Write `docs/sdlc/intent.md` using the template already in that directory:

- **Problem** — observable, present tense, no proposed fix.
- **Desired outcome** — how we would know it worked, with a number where one exists.
- **Affected users** — named roles, not "users".
- **Constraints** — regulatory, technical, deadline, budget. Mark each as hard or assumed.
- **Open questions** — anything vague, carried over **verbatim**. Do not resolve these
  yourself; an unresolved question is information, a guessed answer is a defect.
- **Out of scope** — what this deliberately does not cover.

## Hand off

Commit the file alone: `docs: capture intent for <slug>`. Tell the human that the product
owner reviews and accepts it before Design starts, and that the next step is `/sdlc-spec`.

## Done means

Someone who was not in the conversation can read `intent.md` and correctly say what problem
is being solved and for whom — without asking you anything.
