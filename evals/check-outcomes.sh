#!/usr/bin/env bash
# Outcome checks: did the agent leave the workspace in a correct end state?
# Deterministic, no model. Complements the process graders in each case's graders/.
#
# Usage: evals/check-outcomes.sh <case-name> <workspace-dir>
#   <workspace-dir> is the scaffold directory after a run (keep it with `claude plugin eval --keep-temp`).
# Exit 0 if every check passes, 1 if a check fails, 2 on usage errors.
set -uo pipefail

case_name="${1:-}"; ws="${2:-}"
if [[ -z "$case_name" || -z "$ws" || ! -d "$ws/.git" ]]; then
  echo "usage: $0 <case-name> <workspace-dir (a git repo)>" >&2; exit 2
fi
here="$(cd "$(dirname "$0")" && pwd)"
ws="$(cd "$ws" && pwd)"
fail=0
ok()  { echo "  ok   $1"; }
bad() { echo "  FAIL $1"; fail=1; }
check() { if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

# Files changed since the initial commit, ignoring Python bytecode caches.
changed() { git -C "$ws" status --porcelain | sed 's/^...//' | grep -v '__pycache__' | sort; }

hidden_dir() {
  if [[ -d "$here/outcomes/$case_name" ]]; then echo "$here/outcomes/$case_name"
  else echo "$here/holdout/outcomes/$case_name"; fi
}

# check_py_fix <src> <test> <no_removed_lines: yes|no>
check_py_fix() {
  local src="$1" tst="$2" scope="$3" hd work
  hd="$(hidden_dir)"
  work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
  cp -R "$ws"/. "$work"/
  cp "$hd/hidden_test.py" "$work/hidden_test.py"
  check "hidden acceptance tests pass"  "cd '$work' && python3 -B -m unittest hidden_test"
  check "the project's own tests pass"  "cd '$work' && python3 -B -m unittest discover -p 'test_*.py'"
  check "$src was changed"              "changed | grep -qx '$src'"
  check "a test was added to $tst"      "git -C '$ws' diff -U0 -- '$tst' | grep -qE '^\+.*def test_'"
  check "no unrelated files changed"    "[ -z \"\$(changed | grep -vxE '$src|$tst')\" ]"
  if [[ "$scope" == yes ]]; then
    check "no existing line removed from $src (scope lock)" \
      "[ -z \"\$(git -C '$ws' diff -U0 -- '$src' | grep -E '^-' | grep -vE '^---')\" ]"
  fi
}

unchanged_tree() {
  check "no tracked file modified"  "git -C '$ws' diff --quiet"
  check "no new files created"      "[ -z \"\$(changed)\" ]"
}

echo "Outcome checks: $case_name"
case "$case_name" in
  quick-fix-bug)            check_py_fix cart.py test_cart.py no ;;
  holdout-quick-fix)        check_py_fix stats.py test_stats.py no ;;
  implementer-scope-lock)   check_py_fix greeter.py test_greeter.py yes ;;
  holdout-implementer)      check_py_fix textutil.py test_textutil.py yes ;;
  debug-read-only)
    unchanged_tree
    check "inventory.py still has the bug (diagnosed, not fixed)" "grep -q 'stock.get(sku, 0) > qty' '$ws/inventory.py'"
    ;;
  holdout-debug)
    unchanged_tree
    check "paginate.py still has the bug (diagnosed, not fixed)" "grep -q 'start = page \* size' '$ws/paginate.py'"
    ;;
  grill-me-scans-first|holdout-grill-me|planner-plan-shape|holdout-planner|\
  security-grill-me-domains|holdout-security-grill-me|phase-gate-blocks|holdout-phase-gate|\
  resume-orient|holdout-resume|project-init-gated|holdout-project-init)
    unchanged_tree
    ;;
  *)
    echo "  no outcome checks defined for '$case_name'" >&2; exit 2 ;;
esac

[[ $fail -eq 0 ]] && echo "RESULT: pass" || echo "RESULT: FAIL"
exit $fail
