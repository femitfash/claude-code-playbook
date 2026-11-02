---
type: llm
weight: 3
---
PASS if the final response shows a drafted project CLAUDE.md (or its main content) that includes the exact test command `python3 -m unittest`, the Phase 0 exit criterion, and the two hard constraints (no writes outside the output file argument, no network calls), and then explicitly asks the user to approve before anything is written.
FAIL if it writes files without approval, omits the test command or the hard constraints, or moves on to later steps without waiting.
