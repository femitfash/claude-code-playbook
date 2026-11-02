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

# v2.1

| Change | Why |
|---|---|
| `debug`: no longer forked; `disallowed-tools: Edit Write NotebookEdit`; may run tests and read-only commands | It asks the user questions, so it can't be a background fork. Edit tools are now actually disabled instead of "never edit" being prose, and reproducing a failure is allowed. |
| `security-grill-me`: removed "Use Opus" line | No hard-coded models. |
| Stop hook: per-session retry cap (default 3) instead of a single retry; `PLAYBOOK_VERIFY_DISABLE` | A failing check is enforced several times, and an unfixable one can't loop forever. |
| `settings.baseline.json`: extra deny patterns; new `templates/SETTINGS-NOTES.md` | Documents that rules are guardrails, not a boundary, and recommends sandboxing. |
| New `quick-fix` skill | A light path for small tasks, bug fixes and legacy code. |

# v3.0 (in progress): phase A

| Change | Why |
|---|---|
| `evals/check-outcomes.sh` + hidden acceptance tests for `quick-fix-bug`; end-state checks for `debug-read-only` and `grill-me-scans-first` | Score whether the result is correct, not only how the agent got there. |
| `tests/outcomes-selftest.sh`, called from `tests/run.sh` | Proves the outcome checks fail bad results and pass good ones. |
| `.github/workflows/ci.yml`: ShellCheck, `tests/run.sh`, pinned CLI for `plugin validate --strict` | Regressions are caught on every pull request. No model calls, no secrets. |

# v3.0 (in progress): phase B

| Change | Why |
|---|---|
| 6 new in-sample eval cases: `planner-plan-shape`, `security-grill-me-domains`, `implementer-scope-lock`, `phase-gate-blocks`, `resume-orient`, `project-init-gated` | Every skill now has an eval case. |
| `evals/holdout/`: 9 held-out cases (one per skill), frozen by `FROZEN.sha256` | Report results on tasks the plugin was not tuned against. |
| Outcome checks for all new cases, with hidden acceptance tests for the code-changing ones; self-test extended | Score the end state, and prove the checks discriminate. |
| `tests/run.sh`: eval coverage and frozen-manifest checks | A skill cannot silently lose its eval, and held-out cases cannot be edited unnoticed. |
| README: illustrative new-project walkthrough | Shows the order of steps for a greenfield project. |
| `grill-me-one-question`: added the `skill-fired` indicator | Consistency; the coverage check requires one on every case. |

# v2.2

| Change | Why |
|---|---|
| New `evals/` suite (4 cases, with/without-plugin comparison), `tests/run.sh`, `docs/examples/` | Evidence of efficacy; see `evals/README.md` for results and caveats. |
| `quick-fix` description rewritten | The first eval run showed the skill never triggered on a plain bug-fix request. |
| `grill-me`, `security-grill-me`: explicit "exactly one question per turn" rule | The eval showed the plugin arm bundling several questions into one turn. |
| `phase-gate`: removed migration history from the skill text | Instructions to Claude should not carry changelog notes. |
