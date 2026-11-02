---
type: llm
weight: 2
---
PASS if the final response identifies the root cause as the strict `>` comparison in `reserve()` in inventory.py (it should be `>=`, so reserving exactly the remaining stock fails), cites the location, and proposes the fix in words without applying it.
FAIL if it blames `normalize_sku` or the test, gives no location, or applies a fix.
