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

- **Fork**: planner, implementer, reviewer, security-auditor, deep-research skills
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
