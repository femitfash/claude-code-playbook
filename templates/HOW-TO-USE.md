# How to use this project-initiation template

A reusable workflow for bootstrapping new software projects with Claude Code following best practices: **design-first**, **plan-first**, **phased delivery**, **version-controlled conventions and dev skills**.

## Files in this folder

- **`HOW-TO-USE.md`** — this file; read first
- **`MASTER-PROMPT.md`** — the prompt template to adapt and paste into Claude Code
- **`DESIGN-TEMPLATE.md`** — blank design doc skeleton; fill out before running the master prompt

## Prerequisite: write a DESIGN.md before initiating

**Every project must have a DESIGN.md at its repo root before you run the master prompt.** Initiation executes an already-decided design — it is not a substitute for architecture.

Use `DESIGN-TEMPLATE.md` as a starting point. Your design doc should cover:

1. What the product is, goals and non-goals
2. Locked architectural decisions (as a table)
3. Architecture diagram
4. Data models (canonical shapes)
5. Control flow for the main use case
6. Security and governance
7. Repo layout
8. Phased delivery plan with **explicit exit criteria per phase**
9. Open questions with target resolution timing
10. Decision log (date + decision + rationale)

## How to initiate a project

### 1. Adapt `MASTER-PROMPT.md`

Edit only the **Editable fields** block at the top:

- `PROJECT_NAME`
- `REPO_PATH`
- `DESIGN_DOC_PATH`
- `STACK`
- `TEST_STACK`
- `PHASE_0_EXIT_CRITERION`
- `CRITICAL_CONSTRAINTS`

The body (Steps 1-5) is generic and should not change per project.

### 2. Open a fresh Claude Code session

```bash
cd <REPO_PATH>
```

Start a new session. Do NOT reuse an existing session with unrelated context.

**Name the session** after the phase (e.g., `my-project-phase0`). Rename via Ctrl+N.

### 3. Paste the adapted prompt verbatim

Claude Code will execute 5 steps in order, pausing for approval between each:

| Step | Output |
|---|---|
| 1 | Project-level `CLAUDE.md` |
| 2 | Four project-scoped dev skills: `planner`, `implementer`, `reviewer`, `security-auditor` |
| 3 | Phase 0 scaffolding plan (plan mode, your approval via ExitPlanMode) |
| 4 | Phase 0 code executed, tests passing, reviewer + security-auditor reports clean |
| 5 | Phase 0 committed, closeout in DESIGN.md, PHASE-1.md seed created |

### 4. After Phase 0, kick off subsequent phases the same way

The auto-generated `PHASE-<n>.md` seed is the starting context for the next session.

## Why this structure works

- **Design doc before code** — prevents drift and half-baked assumptions
- **Project CLAUDE.md** — every future session loads conventions automatically
- **Four dev skills** — planner/implementer/reviewer/security-auditor are version-controlled and shared
- **Hard scope per phase** — exit criteria are concrete; each PR advances a specific criterion
- **Plan-first mode** — no code without an approved plan

## Do not

- Run the master prompt without a DESIGN.md
- Paste into a session with unrelated context
- Skip checkpoints between steps
- Collapse phases — close Phase 0 before opening Phase 1
- Edit the body of MASTER-PROMPT.md per project — only the top block should change
