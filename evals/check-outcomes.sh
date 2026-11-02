#!/usr/bin/env bash
# Outcome checks: did the agent leave the workspace in a correct end state?
# Deterministic, no model. Complements the process graders in each case's graders/.
#
# Usage: evals/check-outcomes.sh <case-name> <workspace-dir>
#   <workspace-dir> is the scaffold directory after a run (keep it with `claude plugin eval --keep-temp`).
# Exit 0 if every check passes, 1 otherwise.
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

echo "Outcome checks: $case_name"
case "$case_name" in
  quick-fix-bug)
    work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
    cp -R "$ws"/. "$work"/
    cp "$here/outcomes/quick-fix-bug/hidden_test.py" "$work/hidden_test.py"
    check "hidden acceptance tests pass"        "cd '$work' && python3 -B -m unittest hidden_test"
    check "the project's own tests pass"        "cd '$work' && python3 -B -m unittest test_cart"
    check "cart.py was changed"                 "changed | grep -qx 'cart.py'"
    check "a regression test was added to test_cart.py" "git -C '$ws' diff -U0 -- test_cart.py | grep -qE '^\+.*def test_'"
    check "no unrelated files changed"          "[ -z \"\$(changed | grep -vxE 'cart.py|test_cart.py')\" ]"
    ;;
  debug-read-only)
    check "no tracked file modified"            "git -C '$ws' diff --quiet"
    check "no new files created"                "[ -z \"\$(changed)\" ]"
    check "inventory.py still has the bug (diagnosed, not fixed)" "grep -q 'stock.get(sku, 0) > qty' '$ws/inventory.py'"
    ;;
  grill-me-scans-first)
    check "no tracked file modified"            "git -C '$ws' diff --quiet"
    check "no new files created"                "[ -z \"\$(changed)\" ]"
    ;;
  *)
    echo "  no outcome checks defined for '$case_name'" >&2; exit 2 ;;
esac

[[ $fail -eq 0 ]] && echo "RESULT: pass" || echo "RESULT: FAIL"
exit $fail
