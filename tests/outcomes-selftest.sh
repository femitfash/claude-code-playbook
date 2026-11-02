#!/usr/bin/env bash
# Proves the outcome checks discriminate: known-good workspaces pass, known-bad ones fail.
# No model needed. Builds each fixture in a temp dir, applies a hand-written result, runs the checker.
# Run: tests/outcomes-selftest.sh   (also called from tests/run.sh)
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
root="$PWD"
pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT

expect() {  # expect <pass|fail> <description> <case> <dir>
  local want="$1" desc="$2" case="$3" dir="$4" rc
  "$root/evals/check-outcomes.sh" "$case" "$dir" >/dev/null 2>&1; rc=$?
  if { [[ $want == pass && $rc -eq 0 ]] || [[ $want == fail && $rc -eq 1 ]]; }; then
    pass=$((pass+1)); echo "  ok   $desc"
  else
    fail=$((fail+1)); echo "  FAIL $desc (checker exit $rc, wanted $want)"
  fi
}
fresh() {  # fresh <case> -> prints dir of a freshly scaffolded workspace
  local d; d="$(mktemp -d "$T/ws.XXXXXX")"
  ( cd "$d" && bash "$root/evals/$1/fixture.sh" >/dev/null 2>&1 ) || { echo "fixture failed for $1" >&2; return 1; }
  echo "$d"
}

echo "Outcome checks discriminate (quick-fix-bug)"
d="$(fresh quick-fix-bug)"
expect fail "untouched workspace fails" quick-fix-bug "$d"

d="$(fresh quick-fix-bug)"
sed -i 's|return total - total \* percent / 100|return max(0, total - total * percent / 100)|' "$d/cart.py"
expect fail "fix without a regression test fails" quick-fix-bug "$d"

d="$(fresh quick-fix-bug)"
cat >> "$d/test_cart.py" <<'PY'


class ClampTests(unittest.TestCase):
    def test_discount_over_100_clamps_to_zero(self):
        self.assertEqual(checkout_total([{"price": 100, "qty": 1}], discount_percent=150), 0.0)
PY
expect fail "test without a fix fails" quick-fix-bug "$d"

d="$(fresh quick-fix-bug)"
sed -i 's|return total - total \* percent / 100|return max(0, total - total * percent / 100)|' "$d/cart.py"
cat >> "$d/test_cart.py" <<'PY'


class ClampTests(unittest.TestCase):
    def test_discount_over_100_clamps_to_zero(self):
        self.assertEqual(checkout_total([{"price": 100, "qty": 1}], discount_percent=150), 0.0)
PY
expect pass "fix plus regression test passes" quick-fix-bug "$d"

d="$(fresh quick-fix-bug)"
sed -i 's|return total - total \* percent / 100|return max(0, total - total * percent / 100)|' "$d/cart.py"
cat >> "$d/test_cart.py" <<'PY'


class ClampTests(unittest.TestCase):
    def test_discount_over_100_clamps_to_zero(self):
        self.assertEqual(checkout_total([{"price": 100, "qty": 1}], discount_percent=150), 0.0)
PY
echo "# stray" > "$d/NOTES.md"
expect fail "fix plus an unrelated file fails" quick-fix-bug "$d"

echo "Outcome checks discriminate (debug-read-only)"
d="$(fresh debug-read-only)"
expect pass "untouched workspace passes" debug-read-only "$d"
d="$(fresh debug-read-only)"
sed -i 's|stock.get(sku, 0) > qty|stock.get(sku, 0) >= qty|' "$d/inventory.py"
expect fail "applying the fix fails (diagnosis only)" debug-read-only "$d"
d="$(fresh debug-read-only)"
echo "scratch" > "$d/scratch.py"
expect fail "creating a file fails" debug-read-only "$d"

echo "Outcome checks discriminate (grill-me-scans-first)"
d="$(fresh grill-me-scans-first)"
expect pass "untouched workspace passes" grill-me-scans-first "$d"
d="$(fresh grill-me-scans-first)"
echo "x" > "$d/PLAN.md"
expect fail "writing a plan file fails" grill-me-scans-first "$d"

echo; echo "outcomes-selftest passed=$pass failed=$fail"
[[ $fail -eq 0 ]]
