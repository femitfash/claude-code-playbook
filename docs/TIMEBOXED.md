# Running the playbook inside a time box

For a build with a hard limit, such as a 30-minute challenge, the full path (`project-init`, long `grill-me` sessions, every gate) takes more time than you have. This plan keeps the parts that earn their cost.

Adjust the minutes to your limit. The order matters more than the numbers.

## Before the clock starts (not counted)

- Install the plugin. Copy the right `templates/verify.*.sh.example` to `.claude/verify.sh` and `chmod +x`.
- Merge `templates/settings.baseline.json` and `templates/settings.sandbox.json` into `.claude/settings.json` if you want the guardrails (add any domains your build needs to the sandbox allowlist).
- Create an empty `AI-NOTES.md` from `templates/AI-LOG.md`.
- Do a dry run on a throwaway task so nothing in the toolchain is a surprise.

## The 30-minute plan

| Minutes | Do | Playbook |
|---|---|---|
| 0 to 3 | **Decide the smallest end-to-end slice.** One user, one path, finished beats a large slice that does not run. Write down what you are cutting. | none |
| 3 to 8 | **Write the spec file first** (outcome, constraints copied from the brief, acceptance criteria). You write it; the AI may help. Name the 3 or more automated checks the work must pass. | `CLAUDE.md`, `SPEC.md` or `AGENTS.md` |
| 8 to 10 | **Turn the checks into `.claude/verify.sh`** so the one-command test is also what stops Claude from finishing early. | Stop hook |
| 10 to 11 | **Short plan** in plan mode: files, verification command, exit criterion. Approve it. | `planner` |
| 11 to 24 | **Build test-first.** Run the checks often. Commit about every 10 minutes. Log each non-trivial AI interaction in `AI-NOTES.md` as it happens. | `implementer` |
| 24 to 27 | **Final check.** Run the one-command test. Run the gate once. Fix BLOCK findings only. | `phase-gate` (optional) |
| 27 to 30 | **README and AI log** from your notes. Do not start new features. | `templates/AI-LOG.md` |

Record any video after the build, separately. Plan its content from your notes while the build is fresh.

## Skip these in a time box

- `project-init`: five approval stops.
- A full `grill-me` or `security-grill-me`: a few minutes of the first, or the eight security domains as a quick checklist, is enough.
- `resume`: you have no previous session.
- Anything that adds a new tool or service.

## Rules that save time

- **Cut scope, not checks.** If the tests are red at minute 25, remove a feature. Do not remove a test.
- **One boundary at a time.** If the brief has a hard boundary (for example, certain data must never reach the model), put it in the spec and test it explicitly. Route all model calls through one function so you can log and check them in one place.
- **Say what is real and what is mocked.** Label mocks clearly in the README.
- **Do not trust unreviewed AI output for the thing being scored.** Read the code behind your checks and your boundary yourself.
- **Stop hook in the way?** `PLAYBOOK_VERIFY_DISABLE=1` skips it; `PLAYBOOK_VERIFY_MAX_RETRIES` changes how many times it blocks.
- **`phase-gate` takes too long?** Skip it and review the diff yourself. It reports whether the bundled reviews or a direct review ran.

## What the playbook does not do for you

It does not write your README summary, your AI log, your scale and privacy reasoning, or your video. Those are scored on your own understanding, so write them in your own words from your own notes.
