#!/usr/bin/env bash
# Stop hook: before Claude finishes a turn, run the project's verify command.
# - Looks for an executable `.claude/verify.sh` in the project; if absent, does nothing.
# - On failure exits 2 so Claude sees the output and keeps working.
# - Skips the check when nothing changed since the last passing run in this session (so
#   question-and-answer turns cost nothing). "Changed" means the git HEAD, the status, the
#   diff, or the contents of untracked files. Outside a git repo it always runs.
#   Set PLAYBOOK_VERIFY_ALWAYS=1 to run on every stop.
# - Retries are capped per session (PLAYBOOK_VERIFY_MAX_RETRIES, default 3) so a check that
#   can't be fixed never loops forever. After the cap the hook lets Claude stop and says so.
# - Set PLAYBOOK_VERIFY_DISABLE=1 to skip the hook entirely.
# Test: echo '{"session_id":"t1"}' | CLAUDE_PROJECT_DIR=/path/to/project ./verify-on-stop.sh; echo $?
set -uo pipefail

[[ "${PLAYBOOK_VERIFY_DISABLE:-0}" == "1" ]] && exit 0

payload="$(cat)"
root="${CLAUDE_PROJECT_DIR:-$PWD}"
verify="$root/.claude/verify.sh"
[[ -x "$verify" ]] || exit 0

max="${PLAYBOOK_VERIFY_MAX_RETRIES:-3}"
sid="$(printf '%s' "$payload" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([A-Za-z0-9_-]*\)".*/\1/p' | head -n 1)"
tmp="${TMPDIR:-/tmp}"
state="$tmp/playbook-verify-${sid:-nosession}"
fp_file="$tmp/playbook-verify-fp-${sid:-nosession}"

# A short fingerprint of the working tree; fails (non-zero) outside a git repository.
fingerprint() {
  git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
  {
    git -C "$root" rev-parse -q --verify HEAD
    git -C "$root" status --porcelain=v1 -uall
    git -C "$root" diff HEAD
    git -C "$root" ls-files --others --exclude-standard -z | (cd "$root" && xargs -0 cksum)
  } 2>/dev/null | cksum | cut -d' ' -f1,2
}

use_skip=0
if [[ "${PLAYBOOK_VERIFY_ALWAYS:-0}" != "1" && -n "$sid" ]]; then use_skip=1; fi

if (( use_skip )); then
  fp="$(fingerprint)" || fp=""
  if [[ -n "$fp" && -f "$fp_file" && "$(cat "$fp_file")" == "$fp" ]]; then
    exit 0
  fi
fi

if out="$(cd "$root" && "$verify" 2>&1)"; then
  rm -f "$state"
  if (( use_skip )); then
    fp="$(fingerprint)" && echo "$fp" > "$fp_file"
  fi
  exit 0
fi

rm -f "$fp_file"
count=$(( $(cat "$state" 2>/dev/null || echo 0) + 1 ))
if (( count > max )); then
  rm -f "$state"
  echo "playbook: verify.sh still failing after $max retries; allowing stop. Report the failure to the user." >&2
  exit 0
fi
echo "$count" > "$state"
printf 'Verification failed (.claude/verify.sh), attempt %s of %s. Fix before finishing:\n%s\n' "$count" "$max" "$(printf '%s' "$out" | tail -n 40)" >&2
exit 2
