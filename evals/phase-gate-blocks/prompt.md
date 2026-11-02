---
description: Conformance case (user-invoked skill). The branch diff concatenates user input into SQL, violating a hard rule in CLAUDE.md. The gate should report BLOCK first, cite the location, and fix nothing.
tags: [phase-gate, conformance]
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Bash, Edit, Write]
---

/playbook:phase-gate
