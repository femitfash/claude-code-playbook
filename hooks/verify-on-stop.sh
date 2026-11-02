#!/usr/bin/env bash
# Stop hook: before Claude finishes a turn, run the project's verify command.
# Looks for an executable `.claude/verify.sh` in the project; if absent, does nothing.
# On failure exits 2 so Claude sees the output and keeps working.
# Guard: if this hook already forced a continuation, let Claude stop (avoids loops).
set -uo pipefail

payload="$(cat)"
if printf '%s' "$payload" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

root="${CLAUDE_PROJECT_DIR:-$PWD}"
verify="$root/.claude/verify.sh"
[[ -x "$verify" ]] || exit 0

if out="$(cd "$root" && "$verify" 2>&1)"; then
  exit 0
fi
printf 'Verification failed (.claude/verify.sh). Fix before finishing:\n%s\n' "$(printf '%s' "$out" | tail -n 40)" >&2
exit 2
