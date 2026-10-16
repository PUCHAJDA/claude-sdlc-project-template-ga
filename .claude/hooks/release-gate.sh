#!/usr/bin/env bash
# PreToolUse(Bash) — tier autonomy by environment.
#
#   development  free
#   staging      allowed, logged
#   production   requires a named release manager in RELEASE_APPROVAL
#
# This is the change-advisory board written as code: same control, no meeting.
# Adjust PROD_PATTERNS to match how this project actually deploys.
set -euo pipefail
. "$(dirname "$0")/_common.sh"

# One extended-regex pattern per line. Patterns contain spaces and character classes,
# so this list is iterated line by line — word-splitting it would turn
# "make *deploy-prod" into a bare "make" and block every build in the project.
PROD_PATTERNS='
deploy.*prod
release.*prod
kubectl.*--context[= ].*prod
kubectl.*-n[= ]*production
terraform +apply
helm +upgrade.*prod
aws .*--profile[= ]*prod
make +deploy-prod
'

CMD="$(json_str command)"
[ -n "$CMD" ] || exit 0

while IFS= read -r pat; do
  [ -n "$pat" ] || continue
  if printf '%s' "$CMD" | grep -Eqi -- "$pat"; then
    if [ -z "${RELEASE_APPROVAL:-}" ]; then
      block "Blocked: this looks like a production action and RELEASE_APPROVAL is not set.

  command: $CMD
  matched: $pat

Production changes need a named human who authorized this release. Stop and ask for one.
Do not route around this by rewording the command, splitting it, or writing it to a script.

Once authorized, the human re-runs with:
  RELEASE_APPROVAL=\"<name> <ticket>\" claude"
    fi
    printf 'release-gate: production action authorized by %s\n' "$RELEASE_APPROVAL" >&2
    exit 0
  fi
done <<PATTERNS
$PROD_PATTERNS
PATTERNS

exit 0
