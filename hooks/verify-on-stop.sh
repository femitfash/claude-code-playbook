#!/usr/bin/env bash
# Stop hook: before Claude finishes a turn, run the project's verify command.
# - Looks for an executable `.claude/verify.sh` in the project; if absent, does nothing.
# - On failure exits 2 so Claude sees the output and keeps working.
# - Retries are capped per session (PLAYBOOK_VERIFY_MAX_RETRIES, default 3) so a check that
#   can't be fixed never loops forever. After the cap the hook lets Claude stop and says so.
# - Set PLAYBOOK_VERIFY_DISABLE=1 to skip the hook (e.g. for a Q&A-only session).
# Test: echo '{"session_id":"t1"}' | CLAUDE_PROJECT_DIR=/path/to/project ./verify-on-stop.sh; echo $?
set -uo pipefail

[[ "${PLAYBOOK_VERIFY_DISABLE:-0}" == "1" ]] && exit 0

payload="$(cat)"
root="${CLAUDE_PROJECT_DIR:-$PWD}"
verify="$root/.claude/verify.sh"
[[ -x "$verify" ]] || exit 0

max="${PLAYBOOK_VERIFY_MAX_RETRIES:-3}"
sid="$(printf '%s' "$payload" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)".*/\1/p' | head -n 1)"
state="${TMPDIR:-/tmp}/playbook-verify-${sid:-nosession}"

if out="$(cd "$root" && "$verify" 2>&1)"; then
  rm -f "$state"
  exit 0
fi

count=$(( $(cat "$state" 2>/dev/null || echo 0) + 1 ))
if (( count > max )); then
  rm -f "$state"
  echo "playbook: verify.sh still failing after $max retries; allowing stop. Report the failure to the user." >&2
  exit 0
fi
echo "$count" > "$state"
printf 'Verification failed (.claude/verify.sh), attempt %s of %s. Fix before finishing:\n%s\n' "$count" "$max" "$(printf '%s' "$out" | tail -n 40)" >&2
exit 2
