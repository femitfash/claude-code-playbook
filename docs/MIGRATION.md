# Migrating from v1 to v2

v1 was a set of files you copied by hand. v2 is a plugin: `/plugin install playbook --marketplace femitfash/claude-code-playbook`.

| v1 | v2 | Why |
|---|---|---|
| `skills/reviewer`, `skills/security-auditor` | `playbook:phase-gate` | Claude Code now bundles `/code-review` and `/security-review`; the gate calls them and adds project checks. |
| `skills/planner` (`context: fork`) | `playbook:planner`, no fork | Native plan mode is the approval gate. The skill only supplies the template. |
| `grill-me`, `security-grill-me` (`context: fork`) | same, no fork | They ask one question at a time, which needs the live conversation. Fork mode runs as a background subagent by default. |
| `implementer` | `disable-model-invocation: true` | Claude should never start building unprompted. |
| `debug` | kept; `model: opus` replaced by `effort: high` | Not verified to be equivalent to the bundled `/debug`, so kept. |
| `templates/MASTER-PROMPT.md` | `playbook:project-init` | A skill instead of a 200-line paste. |
| `templates/RESUME-PROMPT.md` | `playbook:resume` | Same. |
| `templates/HOW-TO-USE.md` | README | Folded in. |
| `hooks/validate-skill-frontmatter.sh` | removed | It blocked every partial `Edit` of a SKILL.md (it validated only `new_string`). Use `claude plugin validate`. |
| (none) | `hooks/verify-on-stop.sh`, `templates/settings.baseline.json` | Enforcement: tests on Stop, deny rules for secrets and destructive commands. |
| `CLAUDE.md` "50% compact" rule | `/context` guidance | A model can't reliably read its own context usage. |
| `CLAUDE.md` memory claim | removed | `/compact` summaries are not auto memory. Use `--continue`/`--resume` and committed plans. |
| `CLAUDE.md` model rules | aliases and `/effort` | Avoids stale version names. |
