---
name: resume
description: Use at the start of a session to pick up mid-project work. Orients on the design doc, git state and test status, then confirms direction before any code is written.
disable-model-invocation: true
argument-hint: "[session goal]"
---

# Resume

Session goal (optional): $ARGUMENTS

Do NOT write code until all three steps are done. Prefer `claude --continue` / `--resume` when the previous conversation still exists; use this skill when it doesn't.

## Step 1: Load context

1. Read `CLAUDE.md` and `DESIGN.md`. Note the current phase, its exit criterion, and open questions.
2. Run `git log --oneline -10`.
3. Read the active plan in `.claude/plans/` (most recent file) if one exists; note done vs remaining.
4. Report in 3-5 sentences: where the project stands, current phase, goal.

## Step 2: Verify state

1. `git status`; note in-progress changes.
2. Run the test suite (command is in `CLAUDE.md`); report pass/fail counts.
3. If tests fail, diagnose with `/playbook:debug` before any new work.

## Step 3: Confirm direction

Use `AskUserQuestion`: continue the existing plan, start new planning (`/playbook:grill-me` or `/playbook:security-grill-me` first if requirements are unclear, then `/playbook:planner`), or something else. Then follow the answer.

## Do not

- Assume the codebase matches memory; verify with `git status` and tests.
- Open a new phase before the current exit criterion passes.
