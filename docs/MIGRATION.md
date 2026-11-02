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

# v3.0.0 release

Plugin version bumped from 2.2.0 to 3.0.0. Claude Code decides whether an installed plugin has an update by its version, so installs made at 2.2.0 would not have picked up any of the v3.0 changes below until the version changed. To refresh an existing install: `/plugin marketplace update claude-code-playbook`, then uninstall and reinstall `playbook@claude-code-playbook`.

The sections headed "in progress" below are all part of this release.

# v3.0 (in progress): automatic chain

| Change | Why |
|---|---|
| `implementer` and `phase-gate` no longer set `disable-model-invocation` | v2 made them user-only so Claude would never build unprompted. For a run where you approve the plan with Claude Code's normal plan-mode approval and want the rest to run itself, that meant typing two commands. Plan-mode approval is the gate now. |
| `planner`: after approval, invoke `implementer`; if not approved, revise and do not build | The chain starts at your approval. |
| `implementer`: starts only with an approved plan; on completion invokes `phase-gate`; on BLOCK fixes and re-runs, at most 2 times, then stops and reports | Automatic, but bounded, and never without an approved plan. |
| `phase-gate`: description now says it runs when an implementation is finished | So it triggers without being typed. |
| `resume` and `project-init` stay user-only | They are session starters you choose to run. |
| Not guaranteed | Claude does not always invoke a skill when it should (`quick-fix` initially never did). If a handoff does not fire, type the skill. |

# v3.0 (in progress): AI log and time box

| Change | Why |
|---|---|
| `templates/AI-LOG.md` | The playbook had nothing for documenting AI use, which reviews of AI-assisted work score. Rules: only real interactions, complete entries, specific over polished; a copyable notes block, a three-part pushback structure, and a clearly labelled made-up example. |
| `docs/TIMEBOXED.md` | The full path does not fit a hard time limit. A minute-by-minute plan for a 30-minute build, which skills to skip, and what the playbook does not do for you. |
| README: both linked, plus a "hard time limit" route in "Which path?" | Discoverability. |

# v3.0 (in progress): phase-gate fix

| Change | Why |
|---|---|
| `phase-gate`: tries the bundled `/code-review` and `/security-review`, falls back to a direct review of the diff, and must report `Reviews run:` as `bundled` or `direct` | In a live headless test (one run each, forked and unforked) the model never invoked the bundled reviews and read the diff itself, while the skill text said it ran them. The skill now says what it does and the report says what actually ran. The verdict was correct in both runs. The fork is kept: it made no difference to the result in the test. |
| Removed the sentence telling the model to use the bundled reviews "rather than re-implementing their checks" | It conflicted with the fallback. |

# v3.0 (in progress): phases D to F

| Change | Why |
|---|---|
| `evals/run-suite.sh`: runs the suite per model with a mandatory total cost cap and `--dry-run` | Phase D tooling. No paid run has been made; the dry-run behaviour is covered by `tests/run.sh`. |
| `.github/workflows/evals.yml`: manual only, budget input required | Lets the suite run from GitHub without ever running on pushes or pull requests. Untested. |
| `evals/README.md`: pre-registered keep / revise / remove rules | Phase E: set before any data so results cannot move the goalposts. No skill has been removed, because there is no data yet. |
| README: quick start and a "What this does not cover" section | Phases E and F documentation. |
| `docs/SCORECARD.md` | Phase F: states which of the seven criteria are met, partly met or unmeasured. It does not claim 9.5. |

# v3.0 (in progress): phase C

| Change | Why |
|---|---|
| `debug`: registers a PreToolUse guard (`skills/debug/readonly-guard.sh`) through skill frontmatter `hooks`; blocks Edit/Write/NotebookEdit and common Bash file writes; fails closed if the script cannot be found | In v2.1 the read-only rule rested on `disallowed-tools` in the skill's frontmatter. In CLI 2.1.316 I found no sign that the skill loader reads that field (it appears as an agent field and a CLI flag), so that rule may never have been enforced. The line is kept but no longer relied on. |
| The guard is a guardrail, not a sandbox | It cannot see a file write made from inside a script the agent runs (for example `python3 -c`). Use the sandbox for a real boundary. |
| `phase-gate`: `context: fork` | Review in a fresh context so it is not anchored on the conversation that wrote the code. Unverified under a model; the `phase-gate-blocks` case is the check, including whether the forked context can still run `/code-review`. Revert if it cannot. |
| Stop hook skips the check when the working tree has not changed since the last passing run; `PLAYBOOK_VERIFY_ALWAYS=1` restores run-every-stop | Question-and-answer turns no longer pay for the test suite. Fingerprint covers HEAD, status, diff and untracked file contents; non-git projects always run. |
| `settings.baseline.json`: more `rm` and `find -delete` spellings denied; plain `rm -r *` moved from deny to ask | Close the bypasses listed in the settings notes without blocking legitimate cleanups. |
| New `templates/settings.sandbox.json` | Ship the real boundary, not only a note recommending it. |
| New `verify.python.sh.example`, `verify.go.sh.example`, `verify.rust.sh.example` | The Stop hook is useful beyond npm projects. |
| CI ShellCheck now also covers skill scripts, held-out fixtures and templates | New shell files are linted. |

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
