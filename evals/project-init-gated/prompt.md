---
description: Conformance case (user-invoked skill). Given a filled DESIGN.md, project-init should draft CLAUDE.md in step 1 using the design's exact commands and constraints, and pause for approval without writing any file.
tags: [project-init, conformance]
max_turns: 20
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

/playbook:project-init DESIGN.md
