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
| `/playbook:phase-gate` | Tests + `/code-review` + `/security-review` + project constraints, then PASS/BLOCK; runs in a fresh forked context |
| `/playbook:debug` | Root-cause diagnosis; a guard hook blocks the edit tools and common Bash file writes (not a sandbox) |
| `/playbook:quick-fix` | Light path for bug fixes, small changes and legacy code: no design doc or gates |
| `/playbook:project-init` | 5-step approval-gated bootstrap from a `DESIGN.md` |
| `/playbook:resume` | Orient, verify, confirm direction at session start |

| File | Purpose |
|---|---|
| `skills/project-init/DESIGN-TEMPLATE.md` | Blank design doc; fill in before `project-init` |
| `templates/settings.baseline.json` | Permission deny/ask rules to copy into `.claude/settings.json`. Guardrails, not a boundary: read `templates/SETTINGS-NOTES.md` and add a sandbox |
| `templates/verify.sh.example` (npm), `verify.python.sh.example`, `verify.go.sh.example`, `verify.rust.sh.example` | Copy the one for your stack to `<project>/.claude/verify.sh`; the plugin's Stop hook runs it and blocks "done" if it fails, up to 3 retries per session. It runs only when the working tree changed since the last passing run (`PLAYBOOK_VERIFY_ALWAYS=1` to run on every stop, `PLAYBOOK_VERIFY_MAX_RETRIES` to change the cap, `PLAYBOOK_VERIFY_DISABLE=1` to skip) |
| `templates/settings.sandbox.json` | Sandbox settings to merge into `.claude/settings.json`: sandbox on, no opt-out, network limited to package registries. The real boundary; the permission rules above are guardrails |
| `templates/CLAUDE.user.md` | Lean personal conventions for `~/.claude/CLAUDE.md` |

## Which path?

- **Greenfield project or a large, ambiguous feature:** full path below (`project-init`, `grill-me`, `planner`, `implementer`, `phase-gate`).
- **Bug fix, small change, or legacy code:** `/playbook:quick-fix` (and `/playbook:debug` if the cause is unclear).
- **Resuming:** `claude --continue`, or `/playbook:resume` if the conversation is gone.

## Example: starting a new project

An illustrative walkthrough for a greenfield project, here a small invoicing tool for freelancers. It shows the order of steps and where you stay in control. It is not a recorded session, and the prompts and replies are paraphrased.

**1. Install and set up guardrails (once per machine or project, about 5 minutes)**

```
/plugin install playbook --marketplace femitfash/claude-code-playbook
```

- Copy `templates/settings.baseline.json` into the project's `.claude/settings.json`, and read `templates/SETTINGS-NOTES.md` (these rules are guardrails, not a security boundary; add a sandbox).
- Copy `templates/verify.sh.example` to `.claude/verify.sh`, edit it to run your real typecheck and tests, then `chmod +x`. From now on Claude cannot finish a turn while that script fails (up to 3 retries per session).

**2. Pin down the idea before any code**

```
/playbook:grill-me
> I'm building a small invoicing tool for freelancers. Grill me.
```

Claude reads whatever exists in the repo, then asks one question at a time, each with a recommended answer you can accept or change ("Single currency per invoice for v1? Recommended: yes, to avoid exchange-rate handling."). Stop when it summarises the full design and you confirm it.

The tool handles client data and payments, so also run:

```
/playbook:security-grill-me
```

It walks eight areas (threat actors, trust boundaries, data, authentication, authorization, input, secrets, audit) one question at a time and ends with a threat model you can paste into the design doc.

**3. Write the design doc**

Copy `skills/project-init/DESIGN-TEMPLATE.md` to `DESIGN.md` in the project root. Fill in the goals and non-goals, the locked decisions, the phases with a testable exit criterion for each, and the threat model from step 2. Keep Phase 0 small: for example "a user can create and download one PDF invoice, with tests passing". A filled-in sample is in [`docs/examples/DESIGN-example.md`](docs/examples/DESIGN-example.md).

**4. Bootstrap the project (approval-gated)**

```
/playbook:project-init DESIGN.md
```

It pauses for your approval after each of five steps:

1. Drafts `CLAUDE.md` (with your real test, typecheck and lint commands) and `.claude/rules/`. You review before anything is written.
2. Proposes `.claude/settings.json` from the baseline.
3. Plans **Phase 0 only** in plan mode. You approve the plan.
4. Implements it test-first, then runs the gate (`phase-gate`). You see the passing output.
5. Makes small commits, closes Phase 0 in the decision log and seeds `PHASE-1.md`.

It will refuse to start if `DESIGN.md` does not exist; initiation carries out decisions, it does not make them.

**5. Build each later phase with the same loop**

```
/playbook:planner        # in plan mode: files, verification commands, exit criterion; approve or edit
/playbook:implementer    # test-first, scope-locked to the approved plan
/playbook:phase-gate     # tests + /code-review + /security-review + your constraints -> PASS / BLOCK
```

Resolve every BLOCK finding before opening the PR. For features touching auth, client data or money, run `/playbook:security-grill-me` before `planner`.

**6. Day to day after launch**

- A bug report: `/playbook:quick-fix` (or `/playbook:debug` first if the cause is unclear).
- Back after a break with the conversation gone: `/playbook:resume`.

**What to expect:** several approval stops in the first session, then a short loop per phase. If that is too heavy for your project, skip `project-init` and use `quick-fix` plus `planner` as needed.

## The method

1. **Design first.** A `DESIGN.md` with locked decisions, phases and exit criteria is the source of truth across sessions.
2. **Interrogate, then plan.** `grill-me` removes ambiguity; `planner` (plan mode) gets approval before any code.
3. **Implement narrowly.** Test-first, small commits, no scope creep.
4. **Gate.** `phase-gate` must pass before a PR or phase close.
5. **Enforce, don't just advise.** Rules that can't have exceptions live in permission rules and hooks, not in prose.
6. **Close phases.** Update the decision log, seed the next phase, then move on.

## Evidence

- [`evals/`](evals/README.md): behavioural evals with a with/without-plugin comparison, and the results of the runs so far, including what they got wrong.
- [`docs/examples/`](docs/examples/README.md): worked examples (real command output from the eval fixtures, plus clearly labelled illustrative ones).
- `tests/run.sh`: deterministic checks (skill lint, settings baseline, Stop hook behaviour, `claude plugin validate --strict`). No model needed.

## Maintenance

Run `tests/run.sh` after changes. See [docs/MIGRATION.md](docs/MIGRATION.md) for what changed from v1 and why. Re-audit against the official docs every quarter or so; they move quickly.

## License

MIT
