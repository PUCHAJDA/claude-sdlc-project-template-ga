#!/usr/bin/env bash
# PreToolUse(Write|Edit|NotebookEdit) — during a TDD bug fix, the test is the spec.
# If the agent may edit the test, "make it pass" has a trivial wrong solution.
#
# Active when SDLC_TDD=1 is set in the environment, or .claude/.tdd-lock exists.
# Prefer the env var when this has to be binding: the marker file can be removed
# with Bash, the environment of the running session cannot.
#
#   Git Bash:   SDLC_TDD=1 claude
#   PowerShell: $env:SDLC_TDD=1; claude
set -euo pipefail
. "$(dirname "$0")/_common.sh"

[ "${SDLC_TDD:-}" = "1" ] || [ -f "${CLAUDE_PROJECT_DIR:-.}/.claude/.tdd-lock" ] || exit 0

FILE="$(norm_path "$(json_str file_path)")"
[ -n "$FILE" ] || exit 0

case "$FILE" in
  */tests/*|*/test/*|*/spec/*|*_test.*|*.test.*|*.spec.*|test_*.py|*/conftest.py)
    block "Blocked: TDD mode is active and '$FILE' is a test file.

The failing test defines what 'fixed' means. Editing it now would let the fix pass by
changing the question instead of answering it.

Change only the implementation. If the test itself is genuinely wrong — wrong expectation,
wrong fixture, wrong assumption about the API — stop and tell the human what is wrong
with it and why. Do not work around it."
    ;;
esac

exit 0
