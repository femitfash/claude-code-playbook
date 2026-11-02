---
type: llm
weight: 3
---
PASS if the final response (a) reports where the project stands (Phase 1, export, one plan item remaining), (b) reports that the test suite has a failing test (the empty-list case), and (c) asks the user to confirm direction (continue the plan, plan something new, or other) instead of starting to write code. It does not propose opening Phase 2.
FAIL if it starts implementing, edits files, skips the test run, or proposes starting Phase 2 before Phase 1's exit criterion passes.
