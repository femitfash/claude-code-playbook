# Claude Code Playbook

A design-first, phase-gated workflow for shipping software with Claude Code, packaged as a plugin.

It doesn't re-document features. For those, read the official [best practices](https://code.claude.com/docs/en/best-practices). This repo adds the project-level process on top: design doc, interrogation, planning, scoped implementation, review gate, resume.

## Install

Plugin menu (type these in the Claude Code chat box):

```
/plugin marketplace add femitfash/claude-code-playbook
/plugin install playbook@claude-code-playbook
```

Terminal (needs the `claude` command on your PATH):

```
claude plugin marketplace add femitfash/claude-code-playbook
claude plugin install playbook@claude-code-playbook
```

Install once per machine, not per project. If `/plugin` is not available in your environment, see the other install routes in [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md).

## Update

An installed plugin does not update itself reliably, and it only updates when its version number changes. To get the latest version:

```
claude plugin marketplace update claude-code-playbook
claude plugin update playbook@claude-code-playbook
```

Then restart Claude Code (or reload the VS Code window). In the plugin menu, `/plugin marketplace update claude-code-playbook` does the first step. If the second step does not pick up the new version, uninstall and reinstall:

```
claude plugin uninstall playbook@claude-code-playbook
claude plugin install playbook@claude-code-playbook
```

Check the installed version: `claude plugin list`. The current version is in [`.claude-plugin/plugin.json`](.claude-plugin/plugin.json).

## Quick start

Copy-paste prompts for installing, setting up a project and kicking it off are in [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md). In short:

1. Install the plugin (above), and check that `playbook:` skills show up when you type `/`.
2. Paste the setup prompt in an empty project folder. It writes the guardrails and the Stop-hook wrapper (`.claude/verify.sh`, from `templates/verify.wrapper.sh.example`, which runs `scripts/check.sh`).
3. Paste the kickoff prompt. Claude interviews you (`grill-me`), writes `PRD.md`, plans in plan mode, and after you approve, builds and reviews it.
4. For a clear bug, skip all that: `/playbook:quick-fix <what is broken>`.

See also [the new-project example](#example-starting-a-new-project) below.

## What's inside

| Skill | Use |
|---|---|
| `/playbook:grill-me` | Interview you on a vague design, one question at a time, until resolved; starts by itself when you begin a project or feature, then writes the answers to `PRD.md` and hands off to `planner` |
| `/playbook:security-grill-me` | Same, for threat modeling (auth, data, tenancy, secrets) |
| `/playbook:planner` | Phase-scoped plan template, planned from `PRD.md`; run in plan mode |
| `/playbook:implementer` | Execute an approved plan, test-first, scope-locked; starts by itself once you approve a plan, and hands off to `phase-gate` |
| `/playbook:phase-gate` | Tests + code review + security review (the bundled `/code-review` and `/security-review` when they can be run, otherwise a direct review that says so) + project constraints, then PASS/BLOCK; runs in a fresh forked context; runs by itself when `implementer` finishes |
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
| `templates/verify.wrapper.sh.example` | Copy to `.claude/verify.sh` once. It runs `scripts/check.sh`, so the checks can be written and edited later without more `.claude/` approval prompts |
| `templates/CLAUDE.project.md` | The workflow rule (grill-me, then plan, then implement) to paste into a project's `CLAUDE.md`, so it applies even if the session-start hint is switched off |
| `templates/AI-LOG.md` | Template and rules for logging how you used AI (asked / got / kept-changed-rejected / why), for READMEs and reviews that ask for it |
| [`docs/TIMEBOXED.md`](docs/TIMEBOXED.md) | A minute-by-minute plan for a 30-minute build, and which skills to skip |

## Which path?

- **Greenfield project or a large, ambiguous feature:** just describe what you want. A session-start hook reminds Claude of the order, so it runs `grill-me` first (the answers become `PRD.md`), then `planner` in plan mode, then, after you approve, `implementer` and `phase-gate`. Set `PLAYBOOK_NO_WORKFLOW_HINT=1` to switch the hint off. Full path with a design doc: `project-init`.
- **Bug fix, small change, or legacy code:** `/playbook:quick-fix` (and `/playbook:debug` if the cause is unclear).
- **A hard time limit (for example a 30-minute challenge):** [`docs/TIMEBOXED.md`](docs/TIMEBOXED.md).
- **Resuming:** `claude --continue`, or `/playbook:resume` if the conversation is gone.

## Example: starting a new project

An illustrative walkthrough for a greenfield project, here a small invoicing tool for freelancers. It shows the order of steps and where you stay in control. It is not a recorded session, and the prompts and replies are paraphrased.

**1. Install and set up guardrails (install once per machine; set up once per project, about 5 minutes)**

```
/plugin marketplace add femitfash/claude-code-playbook
/plugin install playbook@claude-code-playbook
```

- Paste the setup prompt from [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md). It merges `templates/settings.baseline.json` and `templates/settings.sandbox.json` into `.claude/settings.json` (read `templates/SETTINGS-NOTES.md`: these are guardrails, not a security boundary) and creates `.claude/verify.sh`, a wrapper that runs `scripts/check.sh`.
- Later, put your real typecheck and tests in `scripts/check.sh`. From then on Claude cannot finish a turn while it fails (up to 3 retries per session).

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
/playbook:phase-gate     # tests + code and security review + your constraints -> PASS / BLOCK
```

Resolve every BLOCK finding before opening the PR. For features touching auth, client data or money, run `/playbook:security-grill-me` before `planner`.

**6. Day to day after launch**

- A bug report: `/playbook:quick-fix` (or `/playbook:debug` first if the cause is unclear).
- Back after a break with the conversation gone: `/playbook:resume`.

**What to expect:** several approval stops in the first session, then a short loop per phase. If that is too heavy for your project, skip `project-init` and use `quick-fix` plus `planner` as needed.

## The method

1. **Design first.** A `DESIGN.md` with locked decisions, phases and exit criteria is the source of truth across sessions.
2. **Interrogate, then plan.** `grill-me` removes ambiguity and writes the answers to `PRD.md`; `planner` (plan mode) plans from it and gets approval before any code.
3. **Implement narrowly.** Test-first, small commits, no scope creep.
4. **Gate.** `phase-gate` must pass before a PR or phase close.
5. **Enforce, don't just advise.** Rules that can't have exceptions live in permission rules and hooks, not in prose.
6. **Close phases.** Update the decision log, seed the next phase, then move on.

## What this does not cover

- **Prompt injection.** Text Claude reads (web pages, issues, dependency READMEs, tool output) can carry instructions. Permission rules and the debug guard do not stop that. The sandbox's network allowlist limits the damage; review what you let Claude fetch.
- **Supply chain.** Package installs and their scripts run code. Pin and review dependencies; the sandbox limits what that code can reach but does not vet it.
- **Unattended runs.** The skills expect a person at the approval points. `project-init`, `grill-me` and `resume` ask questions; in headless mode they stop or guess. The Stop hook's retry cap prevents loops, not bad results.
- **Secrets.** Deny rules match command text and are easy to route around. Keep secrets out of the working tree.
- **Model variability.** Skills are prompts, not programs. The same skill can behave differently across models and runs; see [`evals/`](evals/README.md) for what has and has not been measured.
- **Windows.** The hooks are bash scripts.

## Evidence

- [`evals/`](evals/README.md): behavioural evals with a with/without-plugin comparison, and the results of the runs so far, including what they got wrong.
- [`docs/examples/`](docs/examples/README.md): worked examples (real command output from the eval fixtures, plus clearly labelled illustrative ones).
- `tests/run.sh`: deterministic checks (skill lint, settings baseline, Stop hook behaviour, debug guard, eval coverage, frozen held-out set, `claude plugin validate --strict`). No model needed.
- [`docs/SCORECARD.md`](docs/SCORECARD.md): the v3.0 success criteria and which are met, partly met, or not yet measured.

## Maintenance

Run `tests/run.sh` after changes. See [docs/MIGRATION.md](docs/MIGRATION.md) for what changed from v1 and why. Re-audit against the official docs every quarter or so; they move quickly.

## License

MIT
