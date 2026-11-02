# Claude Code Playbook

A design-first, phase-gated workflow for shipping software with Claude Code, packaged as a plugin.

It doesn't re-document features. For those, read the official [best practices](https://code.claude.com/docs/en/best-practices). This repo adds the project-level process on top: design doc, interrogation, planning, scoped implementation, review gate, resume.

## Install

```
/plugin install playbook --marketplace femitfash/claude-code-playbook
```

(or `claude plugin marketplace add femitfash/claude-code-playbook`, then `claude plugin install playbook@claude-code-playbook`)

## What's inside

| Skill | Use |
|---|---|
| `/playbook:grill-me` | Interview you on a vague design, one question at a time, until resolved |
| `/playbook:security-grill-me` | Same, for threat modeling (auth, data, tenancy, secrets) |
| `/playbook:planner` | Phase-scoped plan template; run in plan mode |
| `/playbook:implementer` | Execute an approved plan, test-first, scope-locked (user-invoked only) |
| `/playbook:phase-gate` | Tests + `/code-review` + `/security-review` + project constraints, then PASS/BLOCK |
| `/playbook:debug` | Read-only root-cause diagnosis; never writes fixes |
| `/playbook:project-init` | 5-step approval-gated bootstrap from a `DESIGN.md` |
| `/playbook:resume` | Orient, verify, confirm direction at session start |

| File | Purpose |
|---|---|
| `skills/project-init/DESIGN-TEMPLATE.md` | Blank design doc; fill in before `project-init` |
| `templates/settings.baseline.json` | Permission deny/ask rules to copy into `.claude/settings.json` |
| `templates/verify.sh.example` | Copy to `<project>/.claude/verify.sh`; the plugin's Stop hook runs it and blocks "done" if it fails |
| `templates/CLAUDE.user.md` | Lean personal conventions for `~/.claude/CLAUDE.md` |

## The method

1. **Design first.** A `DESIGN.md` with locked decisions, phases and exit criteria is the source of truth across sessions.
2. **Interrogate, then plan.** `grill-me` removes ambiguity; `planner` (plan mode) gets approval before any code.
3. **Implement narrowly.** Test-first, small commits, no scope creep.
4. **Gate.** `phase-gate` must pass before a PR or phase close.
5. **Enforce, don't just advise.** Rules that can't have exceptions live in permission rules and hooks, not in prose.
6. **Close phases.** Update the decision log, seed the next phase, then move on.

## Maintenance

Run `claude plugin validate --strict .` after changes. See [docs/MIGRATION.md](docs/MIGRATION.md) for what changed from v1 and why. Re-audit against the official docs every quarter or so; they move quickly.

## License

MIT
