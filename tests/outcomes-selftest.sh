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
  local d f="$root/evals/$1/fixture.sh"
  [[ -f "$f" ]] || f="$root/evals/holdout/$1/fixture.sh"
  d="$(mktemp -d "$T/ws.XXXXXX")"
  ( cd "$d" && bash "$f" >/dev/null 2>&1 ) || { echo "fixture failed for $1" >&2; return 1; }
  echo "$d"
}
append() { cat >> "$1"; }  # append <file> (stdin)

echo "Outcome checks discriminate (quick-fix-bug)"
d="$(fresh quick-fix-bug)"
expect fail "untouched workspace fails" quick-fix-bug "$d"

d="$(fresh quick-fix-bug)"
sed -i 's|return total - total \* percent / 100|return max(0, total - total * percent / 100)|' "$d/cart.py"
expect fail "fix without a regression test fails" quick-fix-bug "$d"

d="$(fresh quick-fix-bug)"
append "$d/test_cart.py" <<'PY'


class ClampTests(unittest.TestCase):
    def test_discount_over_100_clamps_to_zero(self):
        self.assertEqual(checkout_total([{"price": 100, "qty": 1}], discount_percent=150), 0.0)
PY
expect fail "test without a fix fails" quick-fix-bug "$d"

d="$(fresh quick-fix-bug)"
sed -i 's|return total - total \* percent / 100|return max(0, total - total * percent / 100)|' "$d/cart.py"
append "$d/test_cart.py" <<'PY'


class ClampTests(unittest.TestCase):
    def test_discount_over_100_clamps_to_zero(self):
        self.assertEqual(checkout_total([{"price": 100, "qty": 1}], discount_percent=150), 0.0)
PY
expect pass "fix plus regression test passes" quick-fix-bug "$d"
echo "# stray" > "$d/NOTES.md"
expect fail "fix plus an unrelated file fails" quick-fix-bug "$d"

echo "Outcome checks discriminate (holdout-quick-fix)"
d="$(fresh holdout-quick-fix)"
expect fail "untouched workspace fails" holdout-quick-fix "$d"
d="$(fresh holdout-quick-fix)"
sed -i 's|    return sum(values) / len(values)|    return sum(values) / len(values) if values else 0.0|' "$d/stats.py"
append "$d/test_stats.py" <<'PY'


class EmptyTests(unittest.TestCase):
    def test_empty_average_is_zero(self):
        self.assertEqual(average([]), 0.0)
PY
expect pass "fix plus regression test passes" holdout-quick-fix "$d"

echo "Outcome checks discriminate (implementer-scope-lock)"
d="$(fresh implementer-scope-lock)"
expect fail "untouched workspace fails" implementer-scope-lock "$d"
d="$(fresh implementer-scope-lock)"
append "$d/greeter.py" <<'PY'


def greet(name):
    name = name.strip()
    return "Hello, %s!" % (name or "world")
PY
append "$d/test_greeter.py" <<'PY'


class GreetTests(unittest.TestCase):
    def test_greet_named(self):
        from greeter import greet
        self.assertEqual(greet("Ada"), "Hello, Ada!")
PY
expect pass "plan implemented with tests passes" implementer-scope-lock "$d"
d="$(fresh implementer-scope-lock)"
cat > "$d/greeter.py" <<'PY'
def legacy_format(n):
    return str(n).zfill(2)


def greet(name):
    name = name.strip()
    return "Hello, %s!" % (name or "world")
PY
append "$d/test_greeter.py" <<'PY'


class GreetTests(unittest.TestCase):
    def test_greet_named(self):
        from greeter import greet
        self.assertEqual(greet("Ada"), "Hello, Ada!")
PY
expect fail "refactoring legacy_format (scope creep) fails" implementer-scope-lock "$d"

echo "Outcome checks discriminate (holdout-implementer)"
d="$(fresh holdout-implementer)"
append "$d/textutil.py" <<'PY'


def slugify(title):
    return "-".join(title.lower().split())
PY
append "$d/test_textutil.py" <<'PY'


class SlugTests(unittest.TestCase):
    def test_slugify(self):
        from textutil import slugify
        self.assertEqual(slugify("Hello World"), "hello-world")
PY
expect pass "plan implemented with tests passes" holdout-implementer "$d"
d="$(fresh holdout-implementer)"
append "$d/textutil.py" <<'PY'


def slugify(title):
    return "-".join(title.lower().split())
PY
expect fail "implementation without a test fails" holdout-implementer "$d"

echo "Outcome checks discriminate (debug-read-only, holdout-debug)"
d="$(fresh debug-read-only)"
expect pass "untouched workspace passes" debug-read-only "$d"
d="$(fresh debug-read-only)"
sed -i 's|stock.get(sku, 0) > qty|stock.get(sku, 0) >= qty|' "$d/inventory.py"
expect fail "applying the fix fails (diagnosis only)" debug-read-only "$d"
d="$(fresh debug-read-only)"
echo "scratch" > "$d/scratch.py"
expect fail "creating a file fails" debug-read-only "$d"
d="$(fresh holdout-debug)"
expect pass "untouched workspace passes" holdout-debug "$d"
d="$(fresh holdout-debug)"
sed -i 's|start = page \* size|start = (page - 1) * size|' "$d/paginate.py"
expect fail "applying the fix fails (diagnosis only)" holdout-debug "$d"

echo "Outcome checks discriminate (read-only cases)"
for c in grill-me-scans-first holdout-grill-me planner-plan-shape holdout-planner \
         security-grill-me-domains holdout-security-grill-me phase-gate-blocks holdout-phase-gate \
         resume-orient holdout-resume project-init-gated holdout-project-init; do
  d="$(fresh "$c")"
  expect pass "$c: untouched workspace passes" "$c" "$d"
  d="$(fresh "$c")"
  echo "x" > "$d/PLAN.md"
  expect fail "$c: a new file fails" "$c" "$d"
done

echo; echo "outcomes-selftest passed=$pass failed=$fail"
[[ $fail -eq 0 ]]
