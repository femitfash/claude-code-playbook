---
type: llm
weight: 3
---
PASS if the final response states the verdict BLOCK before listing findings, identifies the hard-coded API key in config.py as a violation of the hard boundary rule (secrets in source), and cites the file.
FAIL if the verdict is PASS or PASS WITH NOTES (the tests pass, but the hard rule is violated), the verdict is buried after the findings, or the committed key is not identified.
