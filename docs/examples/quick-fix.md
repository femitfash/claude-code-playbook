# Worked example: `/playbook:quick-fix` on a small bug

> **How to read this.** The commands and outputs below are real. They were produced by running the playbook's eval fixture (`evals/quick-fix-bug/fixture.sh`) and following the six steps in [`skills/quick-fix/SKILL.md`](../../skills/quick-fix/SKILL.md) by hand. This is **not** a recorded Claude session; it shows what a correct run looks like so you can compare a real one against it. Automated checking of real runs is in [`evals/`](../../evals/README.md).

**Task:** `checkout_total` returns a negative total when `discount_percent` is greater than 100. It should never go below 0.

## 1. Understand
The repo is two files and a passing test suite:

```console
$ ls; python3 -m unittest 2>&1 | tail -4
README.md
cart.py
test_cart.py
----------------------------------------------------------------------
Ran 3 tests in 0.001s

OK
```

## 2. Reproduce

```console
$ python3 -c "from cart import checkout_total; print(checkout_total([{'price': 100, 'qty': 1}], discount_percent=150))"
-55.0
```

## 3. Test first
Add a regression test; it must fail for the right reason before any source change.

```console
$ python3 -m unittest 2>&1 | tail -9
  File "./test_cart.py", line 17, in test_discount_over_100_never_goes_negative
    self.assertEqual(checkout_total([{"price": 100, "qty": 1}], discount_percent=150), 0.0)
    ~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: -55.0 != 0.0

----------------------------------------------------------------------
Ran 4 tests in 0.001s

FAILED (failures=1)
```

## 4. Smallest change
Clamp the discounted total at 0. One line, no refactor:

```console
$ git diff -U0 cart.py | tail -4
+++ b/cart.py
@@ -6 +6 @@ def apply_discount(total, percent):
-    return total - total * percent / 100
+    return max(total - total * percent / 100, 0)
```

## 5. Verify

```console
$ python3 -m unittest 2>&1 | tail -4
----------------------------------------------------------------------
Ran 4 tests in 0.000s

OK
```

## 6. Report

```console
$ git diff --stat
 cart.py      | 2 +-
 test_cart.py | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)
```

**Report to the user (shape to expect):** reproduced the negative total (`-55.0`); added `test_discount_over_100_never_goes_negative`, which failed before the fix; clamped the discounted total at 0 in `apply_discount`; full suite passes (4 tests). Noticed but left alone: `apply_discount` does not validate negative percentages.

**What a bad run looks like (what the eval graders check for):** editing `cart.py` before adding the test, running the suite only once, claiming success without output, or rewriting `checkout_total` instead of the one-line clamp.
