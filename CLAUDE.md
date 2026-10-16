# {{PROJECT_NAME}}

<!--
Keep this file to ONE page. It is read on every turn — length costs attention, not just tokens.
Run /init first to generate a draft from the codebase, then cut it down to the sections below.

THE RULE THAT MATTERS: when you correct Claude on the same thing twice, the correction
belongs here. That is what makes this file a memory instead of a README.
-->

## Commands

<!-- Single commands that exit non-zero on failure. This is Claude's feedback loop. -->

| Task | Command |
|---|---|
| Install | `make install` |
| Test | `make test` |
| Lint + format | `make lint` |
| Typecheck | `make typecheck` |
| Run locally | `make dev` |
| Full check (what CI runs) | `make check` |

## Conventions

- Source lives in `src/`, tests mirror it under `tests/`.
- <!-- naming, error handling, logging, dependency injection — the things a reviewer would flag -->
- Never edit files under `docs/sdlc/` without being asked — they are SDLC artifacts, not docs.
- Commit messages: imperative mood, reference the `intent.md` heading they serve.

## Architecture

<!-- 5-10 lines. What the system is, what the main boundaries are, what talks to what.
     Enough that Claude does not have to re-derive it by reading twenty files. -->

- Entry point: `src/main.*`
- Data flows: <!-- request → handler → service → repository → store -->
- External systems: <!-- name each one and what it is the source of truth for -->
- Source of truth per artifact: requirements live in `docs/sdlc/`, tickets live in <!-- Jira/Linear/repo -->.
  When these disagree, the repo wins for code and the tracker wins for scope.

## Things Claude gets wrong

<!--
Append-only. One line per mistake, phrased as the correction, not as a complaint.
Delete an entry only when the underlying cause is gone (e.g. the API was removed).
Entries here are also the best source of eval tasks — see evals/README.md.
-->

- <!-- e.g. "Do not add `async` to repository methods — the driver is synchronous." -->
- <!-- e.g. "Config is read via `settings.get()`, never `os.environ` directly." -->

## Workflow

- Start in **plan mode** (Shift+Tab) with the relevant `docs/sdlc/spec.md`. Commit the
  accepted plan as `docs/sdlc/plan.md` before editing code.
- "Done" means verified: paste the output of `make check` as evidence, do not assert success.
- Bug fixes are TDD: failing test first, committed separately, then the fix. Do not edit
  the test to make it pass — a hook blocks that.
