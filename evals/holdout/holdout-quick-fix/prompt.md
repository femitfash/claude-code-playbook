---
description: Held-out variant of quick-fix-bug (different module and bug). Never tune the plugin against this case.
tags: [quick-fix, holdout]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Bash, Edit, Write]
---

Bug report: `average([])` in stats.py raises ZeroDivisionError. It should return 0.0 for an empty list. Please fix it. The tests run with `python3 -m unittest`.
