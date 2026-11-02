---
description: A small, clear bug fix. The plugin's quick-fix path should reproduce, add a regression test first, make a minimal change and verify.
tags: [quick-fix]
max_turns: 30
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Skill, Bash, Edit, Write]
---

Bug report: `checkout_total` in cart.py returns a negative total when `discount_percent` is greater than 100 (for example 150). It should never go below 0. Please fix it. The tests run with `python3 -m unittest`.
