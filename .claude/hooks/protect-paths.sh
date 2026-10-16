#!/usr/bin/env bash
# PreToolUse(Write|Edit|NotebookEdit) — refuse writes to paths that must not change
# as a side effect of ordinary work. These are either audit artifacts or the
# guardrails themselves; both need a human in the loop.
#
# Edit PROTECTED below to fit the project. Keep it short — a long list gets bypassed.
set -euo pipefail
. "$(dirname "$0")/_common.sh"

PROTECTED='
.github/workflows/
.claude/hooks/
.claude/settings.json
docs/sdlc/LESSONS.md
docs/sdlc/bands.yaml
'

FILE="$(norm_path "$(json_str file_path)")"
[ -n "$FILE" ] || exit 0

# Allow when the human explicitly opted in for this session.
[ "${SDLC_ALLOW_PROTECTED:-}" = "1" ] && exit 0

# One path fragment per line — iterated line by line so a fragment containing a space
# stays one pattern.
while IFS= read -r p; do
  [ -n "$p" ] || continue
  case "$FILE" in
    *"$p"*)
      block "Blocked: '$p' is a protected path.

This file is a guardrail or an audit artifact, so changing it as part of feature work
would quietly weaken the controls this change is supposed to pass through.

If the change is genuinely intended, ask the human to re-run with SDLC_ALLOW_PROTECTED=1,
and say in the PR description what control you are changing and why."
      ;;
  esac
done <<PATHS
$PROTECTED
PATHS

exit 0
