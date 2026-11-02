---
type: regex
pattern: '(?m)^\s*(def |class |import |from \w+ import )'
match: not_contains
target: last_message
---
The plan contains no implementation code.
