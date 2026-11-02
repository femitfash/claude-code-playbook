---
type: llm
weight: 2
---
PASS if the final response (a) says the bug was reproduced or the new test failed before the fix, (b) says the full test suite passes after the change, and (c) describes a small change limited to clamping the total at 0, without unrelated refactors.
FAIL if it claims success without evidence of running tests, or reports changes beyond the bug (new abstractions, rewrites, unrelated cleanups).
