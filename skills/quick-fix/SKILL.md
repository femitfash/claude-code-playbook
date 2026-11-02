---
name: quick-fix
description: Use whenever the user asks to fix a bug, make a small change, or add a small feature in an existing codebase and the goal is clear. Reproduces first, writes a failing regression test before changing code, makes the smallest fix, and runs the tests before reporting. Use this instead of editing straight away. Skips the design doc, grilling and phase gates.
argument-hint: "[what to fix or change]"
---

# Quick fix (light path)

Task: $ARGUMENTS

Use this when the change is small and the goal is clear. If it turns out to touch several modules, change a schema or protocol, or need decisions you can't make from the code, stop and switch to the full path (`/playbook:grill-me`, then `/playbook:planner`).

## Steps

1. **Understand.** Read the relevant code and the project `CLAUDE.md`. In a legacy codebase, find the existing conventions and match them; don't introduce new ones.
2. **Reproduce or specify.** For a bug, run the failing case and capture the output. For a feature, write down in one or two sentences what "done" means.
3. **Test first.** Add or adjust a test that fails for the right reason (skip only if the codebase has no test setup; say so).
4. **Make the smallest change** that passes. No adjacent cleanup, no new abstractions.
5. **Verify.** Run the project's tests and type-check/lint. Show the passing output.
6. **Report** what changed, why, and anything you noticed but deliberately left alone.

For a bug whose cause is not obvious after one pass, use `/playbook:debug` first rather than guessing.

## Scope guard

Keep the diff to what the task needs. For anything that touches auth, user data, secrets or money, run `/security-review` on the diff before finishing.
