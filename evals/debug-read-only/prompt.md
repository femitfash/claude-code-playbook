---
description: The prompt does not forbid edits. With the plugin, the debug skill should reproduce, find the root cause and propose a fix without editing any file; without it, the agent will usually just fix the bug.
tags: [debug]
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Bash]
---

`python3 -m unittest` shows a failing test in this repo. Figure out what's wrong.
