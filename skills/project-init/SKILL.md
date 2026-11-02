---
name: project-init
description: Use to bootstrap a new project from an existing DESIGN.md. Runs a 5-step, approval-gated initiation: project CLAUDE.md, rules, Phase 0 plan, execution with review gate, and closeout.
disable-model-invocation: true
argument-hint: "[path to DESIGN.md]"
---

# Project initiation

Design doc: ${ARGUMENTS:-DESIGN.md}

A `DESIGN.md` must already exist (see [DESIGN-TEMPLATE.md](DESIGN-TEMPLATE.md)). If it doesn't, stop and tell the user to write one first; initiation executes decisions, it doesn't make them.

Execute the steps **in order**, pausing for explicit user approval after each. Do not pull work forward.

Rules for the whole run:
- Read the design doc first; do not re-derive decisions already in it.
- Ask via `AskUserQuestion` for any blocking decision. Do not guess.
- Never overwrite an existing file without reading it. No `git push` during initiation.

## Step 1: Project `CLAUDE.md` and rules

Ask for (or extract from the design doc) the stack, test stack, Phase 0 exit criterion and critical constraints. Then draft:

- `CLAUDE.md` (under 200 lines; link to DESIGN.md, don't duplicate it) with: authoritative-reference pointer, the exact **test / typecheck / lint commands**, commit conventions (conventional commits, trunk-based, each PR names its phase and exit criterion), Phase 0 exit criterion verbatim, "Hard boundary rules" (constraints verbatim), and a must-plan-first rule.
- Topic-specific conventions in `.claude/rules/<topic>.md`, using `paths:` frontmatter so they load only for matching files (e.g. testing rules for `**/*.test.ts`).
- A `CLAUDE.local.md` entry in `.gitignore`.

Show the drafts; write only after approval.

## Step 2: Safety baseline

Propose a project `.claude/settings.json` based on the playbook's `templates/settings.baseline.json` (permission deny rules for secrets and destructive commands, test-on-Stop hook configuration). Show it; write after approval.

## Step 3: Phase 0 plan

Enter plan mode and run `/playbook:planner` scoped to **Phase 0 only**. Surface blocking decisions via `AskUserQuestion`. Stop after the user approves the plan.

## Step 4: Execute and gate

Run `/playbook:implementer` on the approved plan, then `/playbook:phase-gate`. Fix every BLOCK finding. Show the passing test output and gate report; wait for approval.

## Step 5: Commit and close

1. Initialize git if needed (`.gitignore`, minimal README).
2. Optionally add the official `anthropics/claude-code-security-review` GitHub Action on `pull_request` (ask first).
3. Conventional commits, one per logical module.
4. Append a Phase 0 closeout to the design doc's decision log (date, exit criterion met, deviations).
5. Create `PHASE-1.md` with the Phase 1 exit criteria from the design doc.

Report commits, follow-ups, and readiness for Phase 1.
