---
type: llm
weight: 3
---
PASS if the final response is a plan that includes ALL of: (a) concrete files to create or modify, named by path (for example reports.py, web.py, test_reports.py); (b) a verification step naming a runnable command or specific tests; (c) an explicit exit criterion or definition of done; (d) open decisions or assumptions to confirm (for example CSV dialect, escaping, header row, large-report handling, auth on the endpoint).
FAIL if any of (a) to (d) is missing, or the response is only prose advice with no concrete file list.
