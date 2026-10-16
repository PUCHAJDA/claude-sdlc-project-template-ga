#!/usr/bin/env bash
# Shared helpers for SDLC hooks. Sourced, never run directly.
#
# Hook contract (Claude Code):
#   stdin  = JSON event: { "tool_name": ..., "tool_input": {...}, "cwd": ... }
#   exit 0 = allow;  exit 2 = BLOCK, and stderr is fed back to Claude as the reason.
#   Any other exit code is a hook error and does NOT block.
#
# Windows: these run under Git Bash. Keep them POSIX and fast — they sit on every edit.

# Read the whole event once; callers use $HOOK_INPUT.
HOOK_INPUT="$(cat)"

# json_str <key> — first string value for <key>, unescaped enough for paths.
json_str() {
  printf '%s' "$HOOK_INPUT" \
    | tr -d '\n' \
    | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"\\\\]\|\\\\.\)*\"" \
    | head -1 \
    | sed "s/^\"$1\"[[:space:]]*:[[:space:]]*\"//; s/\"$//; s/\\\\\\\\/\//g; s/\\\\\"/\"/g"
}

# norm_path <path> — repo-relative-ish, forward slashes, no leading ./
norm_path() {
  printf '%s' "$1" | tr '\\' '/' | sed 's#//*#/#g; s#^\./##'
}

# block <message> — refuse the tool call and tell Claude why.
block() {
  printf '%s\n' "$1" >&2
  exit 2
}
