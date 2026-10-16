#!/usr/bin/env bash
# PostToolUse(Write|Edit) — format the file that was just written.
#
# Keep this under a second. Heavy checks (full lint, typecheck, tests) belong at commit
# or PR time, not on every edit — a slow hook turns into a disabled hook.
#
# Never exit 2 here: the edit already happened, and failing the hook only adds noise.
set -euo pipefail
. "$(dirname "$0")/_common.sh"

FILE="$(norm_path "$(json_str file_path)")"
[ -n "$FILE" ] && [ -f "$FILE" ] || exit 0

have() { command -v "$1" >/dev/null 2>&1; }

case "$FILE" in
  *.py)              have ruff     && ruff format --quiet "$FILE" || true ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md)
                     have prettier && prettier --write --log-level warn "$FILE" || true ;;
  *.go)              have gofmt    && gofmt -w "$FILE" || true ;;
  *.rs)              have rustfmt  && rustfmt --quiet "$FILE" || true ;;
  *.sh)              have shfmt    && shfmt -w "$FILE" || true ;;
esac

exit 0
