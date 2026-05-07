# Session resume prompt

> **Editable fields** (change these for each resume session; leave the body intact):
>
> - **PROJECT_NAME:** [Your Project Name]
> - **REPO_PATH:** [Absolute path to repo]
> - **DESIGN_DOC_PATH:** `DESIGN.md` (at repo root)
> - **CURRENT_PHASE:** [e.g., Phase 1]
> - **CURRENT_PLAN_PATH:** [e.g., `.claude/plans/phase1-auth.md` — or "none" if starting fresh]
> - **SESSION_GOAL:** [What you want to accomplish this session — one concrete sentence]

---

## Your task

You are resuming work on **PROJECT_NAME** at **REPO_PATH**. Do NOT start coding. Execute the 3 orientation steps below before taking any action.

**Universal rules for this session:**
- Read **DESIGN_DOC_PATH** before doing anything. It is the authoritative reference. Do not re-derive decisions already captured there.
- Follow all conventions in `CLAUDE.md`.
- Stop and ask via `AskUserQuestion` whenever a blocking decision is needed. Do not guess.
- **Context hygiene**: when context reaches 50%, run `/compact` before starting the next major unit of work.
- **Model selection**: Opus for planning and design decisions, Sonnet for implementation and commits.

---

## Step 1 — Load project context

1. Read `CLAUDE.md` at REPO_PATH.
2. Read DESIGN_DOC_PATH. Note: current phase, its exit criterion, and any open questions.
3. Run `git log --oneline -10` to understand recent progress.
4. If **CURRENT_PLAN_PATH** is not "none", read the plan in full. Note completed items and what remains.

Report back in 3-5 sentences: where the project stands, what phase you are in, and what the session goal is.

---

## Step 2 — Verify state

1. Run `git status` — confirm the working tree is clean or note any in-progress changes.
2. Run the test suite (command is in CLAUDE.md). Report: pass count, fail count, any errors.
3. If tests are failing: invoke the `debug` skill to diagnose before any new work begins.

Do not proceed to Step 3 until the test suite is passing (or the user explicitly acknowledges known failures).

---

## Step 3 — Confirm direction

Using `AskUserQuestion`, ask:

> "We're in **CURRENT_PHASE** targeting [exit criterion from DESIGN_DOC_PATH]. Today's goal: SESSION_GOAL.
>
> How would you like to proceed?
> (a) Continue the existing plan at CURRENT_PLAN_PATH
> (b) Start a new planning session — invoke `grill-me` or `security-grill-me` first if requirements are unclear, then `planner`
> (c) Something else — [describe]"

Wait for the user's answer. Then execute:

| Answer | Action |
|---|---|
| (a) | Invoke `implementer` skill with the current plan |
| (b) | Invoke `grill-me` or `security-grill-me` (if security-sensitive), then `planner` |
| (c) | Follow user direction |

---

## Do not:
- Write code before completing Steps 1–3
- Assume the codebase matches what you remember — always verify with `git status` and tests
- Skip the test suite check — failing tests block new work
- Open a new phase before the current one has a passing exit criterion
