#!/usr/bin/env bash
# Run the eval suite: each task gets a clean worktree, a non-interactive Claude session,
# and its acceptance check. Prints a pass rate and exits non-zero if anything failed.
#
#   ./evals/run-evals.sh            all tasks
#   ./evals/run-evals.sh add-endpoint   one task by filename stem
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TASKS="$ROOT/evals/tasks"
WORK="${TMPDIR:-/tmp}/evals-$$"
FILTER="${1:-}"

command -v claude >/dev/null 2>&1 || { echo "claude CLI not found on PATH"; exit 1; }

# Each task runs on its own worktree, so tasks cannot see each other's edits and a failed
# task cannot leave the repo dirty.
if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
  echo "Working tree is dirty. Commit or stash first — each task runs on a fresh copy."
  exit 1
fi

mkdir -p "$WORK"
trap 'git -C "$ROOT" worktree prune >/dev/null 2>&1; rm -rf "$WORK"' EXIT

# field <file> <key> — read a frontmatter value
field() { sed -n "/^---$/,/^---$/p" "$1" | grep -m1 "^$2:" | sed "s/^$2:[[:space:]]*//"; }
# body <file> — everything after the closing frontmatter fence
body()  { awk 'f>1{print} /^---$/{f++}' "$1"; }

pass=0; fail=0; failed=""

for task in "$TASKS"/*.md; do
  [ -e "$task" ] || { echo "No tasks in $TASKS"; exit 1; }
  slug="$(basename "$task" .md)"
  [ -n "$FILTER" ] && [ "$slug" != "$FILTER" ] && continue

  check="$(field "$task" check)"
  timeout_s="$(field "$task" timeout)"; timeout_s="${timeout_s:-600}"
  prompt="$(body "$task")"

  if [ -z "$check" ]; then
    echo "SKIP $slug — no 'check' in frontmatter; a task without an acceptance check proves nothing"
    continue
  fi

  wt="$WORK/$slug"
  git -C "$ROOT" worktree add --detach "$wt" >/dev/null 2>&1

  printf '%-28s ' "$slug"
  ( cd "$wt" && printf '%s' "$prompt" | timeout "$timeout_s" claude -p >/dev/null 2>&1 )

  if ( cd "$wt" && eval "$check" >/dev/null 2>&1 ); then
    echo "PASS"; pass=$((pass + 1))
  else
    echo "FAIL"; fail=$((fail + 1)); failed="$failed $slug"
  fi

  git -C "$ROOT" worktree remove --force "$wt" >/dev/null 2>&1
done

total=$((pass + fail))
[ "$total" -eq 0 ] && { echo "No tasks matched."; exit 1; }

echo
echo "pass rate: $pass/$total"
[ "$fail" -gt 0 ] && echo "failed:$failed"
exit $((fail > 0))
