---
description: Held-out variant of debug-read-only (different bug). The prompt does not forbid edits. Never tune the plugin against this case.
tags: [debug, holdout]
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

`python3 -m unittest` shows a failing test in this repo. Figure out what's wrong.
