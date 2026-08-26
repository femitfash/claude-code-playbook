# Global Instructions

## CLAUDE.md length discipline

Every `CLAUDE.md` (this file, project-level, nested) must stay **under 200 lines**; **60 is optimal**. Beyond that, Claude starts ignoring rules. Keep them lean:

- Link to authoritative sources (design docs, READMEs) — do **not** duplicate their content
- Project-level `CLAUDE.md` holds conventions + links, not exhaustive architecture
- Split long guidance into `.claude/rules/<topic>.md` and reference from `CLAUDE.md`

## Model selection

- **Opus** for: planning, architecture, design reviews, complex refactors, debugging stuck states, security review
- **Sonnet** for: implementation, test writing, straightforward CRUD, doc generation, small edits
- Default to Sonnet — switch via `/model` when the task needs depth

## Context hygiene

- When context reaches **50%**, run `/compact` before starting a new major task
- Use `/rewind` (Esc Esc) to undo a mistaken turn rather than talking through it
- Name important sessions after the task or phase (e.g., `my-project-phase0`) for resumability

## Subagent budget

- Default to sequential skill handoffs (planner → implementer → reviewer), not parallel
  fan-out, unless the tasks are genuinely independent.
- Cap concurrent forked subagents at 2-3 per session. Batch remaining work rather than
  spawning more.
- Trivial, single-file edits skip `implementer` entirely — handle them inline in the main
  session instead of forking.

## Session ceilings

- Hard-stop and checkpoint (write current state to `.claude/plans/current-task.md`, then
  run `/compact`) every 2 hours of active work, or at each phase boundary — whichever comes
  first.
- Background or autonomous runs must declare an explicit exit condition up front (e.g. "all
  tests pass," "N files changed") before starting. No open-ended loops.

## Skill creation & management

### Structure
- A skill is a **directory**, not a bare file: `<scope>/.claude/skills/<skill-name>/SKILL.md`
- Use **kebab-case** for skill directory names
- Colocate supporting files (scripts, templates, references) **inside the skill directory**

### Scope
| Use case | Location |
|---|---|
| Personal (all projects) | `~/.claude/skills/<name>/SKILL.md` |
| Project-specific (shared via git) | `<project>/.claude/skills/<name>/SKILL.md` |

Default to **project-level**. Use personal only for truly cross-project utilities.

### Frontmatter (required)
```yaml
---
name: skill-name              # kebab-case, matches directory name
description: Use when <specific trigger conditions>. <What it does>.
context: fork                 # optional — see below
---
```

- `description` drives activation — make it **specific about trigger conditions**, not vague
- Include keywords that match likely user phrasings

### Context forking
Add `context: fork` for skills that do substantial isolated work (planning, implementation runs, reviews). The skill executes in a subagent, preserving the main conversation's context window.

- **Fork**: planner, implementer, reviewer, security-auditor, grill-me, security-grill-me, debug, deep-research skills
- **Don't fork**: quick-reference skills, lookups, templates, short how-tos

### Content quality
- Keep `SKILL.md` focused and actionable — instructions to Claude, not human docs
- Use progressive disclosure: core in `SKILL.md`, reference material in separate files
- Prefer imperatives and checklists over prose
- If `SKILL.md` exceeds ~300 lines, split into referenced files

### Maintenance
- Remove stale skills rather than leaving them
- When renaming, rename both the directory and the `name:` field
- Check for duplicates before creating new skills

## Context & Session Handoff
- **Active Plan**: Always check `.claude/plans/current-task.md` (or the most recent file in that directory) to understand the current work state.
- **Resuming**: When starting a new session, the developer will likely say "continue" or "next step." Refer to the Active Plan to identify the current objective.
- **Memory**: Use `/compact` before ending a session to summarize progress. This summary is automatically available to new sessions via the system's background memory.

## Agent Collaboration
When documenting skills in a table (e.g., a role roster in a project `CLAUDE.md`), use **"Role / Persona"** as the column header — not "Invoke" or "Slash Command." Skills are custom personas activated by description matching, not native CLI commands. Native slash commands (`/compact`, `/model`, `/rewind`) are a distinct built-in mechanism.
