# Worked example: `/playbook:debug` finds a root cause without editing

> **How to read this.** Commands and outputs are real, produced from `evals/debug-read-only/fixture.sh` by following [`skills/debug/SKILL.md`](../../skills/debug/SKILL.md) by hand. It is not a recorded Claude session. In the plugin, the skill's `disallowed-tools` setting removes `Edit`, `Write` and `NotebookEdit`, so a real run cannot change files; running tests and read-only commands is allowed.

**Task:** `python3 -m unittest` fails. Find out why. Do not change any files.

## 1. Reproduce

```console
$ python3 -m unittest 2>&1 | tail -14
F..
======================================================================
FAIL: test_reserve_exactly_all_remaining (test_inventory.ReserveTests.test_reserve_exactly_all_remaining)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "./test_inventory.py", line 14, in test_reserve_exactly_all_remaining
    self.assertTrue(reserve(stock, "abc", 3))
    ~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: False is not true

----------------------------------------------------------------------
Ran 3 tests in 0.001s

FAILED (failures=1)
```

## 2. Read the code on the failing path

```console
$ cat -n inventory.py
     1	def normalize_sku(sku):
     2	    return sku.strip().upper()
     3	
     4	
     5	def reserve(stock, sku, qty):
     6	    """Reserve qty units of sku. Returns True if reserved."""
     7	    sku = normalize_sku(sku)
     8	    if stock.get(sku, 0) > qty:
     9	        stock[sku] -= qty
    10	        return True
    11	    return False
```

## 3. Hypotheses

| # | Hypothesis | Evidence that would confirm or rule it out |
|---|---|---|
| A | `reserve()` compares with `>` instead of `>=` | A reserve of exactly the remaining stock fails; reserving less succeeds |
| B | `normalize_sku` mangles the key | Reserving with a pre-normalised key would also fail |
| C | The test is wrong | The other tests share its setup and pass |

## 4. Test one hypothesis at a time (read-only)

Rule out B first (cheapest): use an already-normalised key and exactly the remaining stock.

```console
$ python3 -c "from inventory import reserve; s={'ABC': 3}; print(reserve(s, 'ABC', 3), s)"
False {'ABC': 3}
```

Still `False`, so normalisation is not the cause. Now confirm A by trying one unit less than the stock:

```console
$ python3 -c "from inventory import reserve; s={'ABC': 3}; print(reserve(s, 'ABC', 2), s)"
True {'ABC': 1}
```

**Root cause: `inventory.py:8`.** `if stock.get(sku, 0) > qty` uses a strict comparison, so a reservation for exactly the remaining stock is rejected. It should be `>=`. The experiments changed nothing on disk.

**Proposed fix (described, not applied):** change `>` to `>=` on that line, then run the suite. Hand off to `/playbook:implementer` only after you agree.
```console
$ git status --short | wc -l
1
```

