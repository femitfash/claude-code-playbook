---
type: llm
weight: 3
---
PASS if the final response is a plan that includes ALL of: (a) concrete files to create or modify, named by path (for example server.py, test_server.py); (b) a verification step naming a runnable command or specific tests (for example `python3 -m unittest`); (c) an explicit exit criterion or definition of done; (d) open decisions or assumptions to confirm (for example storage of counters, behaviour on limit exceeded, clock or window semantics).
FAIL if any of (a) to (d) is missing, or the response is only prose advice with no concrete file list.
