---
type: llm
weight: 2
---
PASS if the final response reports what was implemented against the plan's items (greet() and its tests), states that the tests pass, and mentions no changes beyond the plan (no refactor of legacy_format, no extra helpers or error handling).
FAIL if it claims success without showing the tests passed, or reports changes outside the plan.
