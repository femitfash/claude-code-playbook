# v3.0 scorecard

The v3.0 plan set seven success criteria for reaching 9.5 / 10. This page says which are met, which are partly met, and which have not been measured, as of the commit that last touched it. It is updated by hand; check `git log` for its age.

The score is a judgement, not a measurement. It combines how sound the design and enforcement are with how much is *proven* by data. Nothing here has been run under a model by the people who wrote it.

| # | Criterion | Status | Detail |
|---|---|---|---|
| 1 | Every skill has an eval case with a measured lift | **Partly** | All 9 skills have an in-sample and a held-out case. A lift has been measured only for 4 skills, by the original author, on a suite tuned after the first run (see `evals/README.md`). Four skills (`implementer`, `phase-gate`, `resume`, `project-init`) are user-invoked only, so no baseline is possible; for them the criterion is restated as a conformance pass, with the limitation stated in the decision rules. |
| 2 | Outcome-based graders | **Partly** | `evals/check-outcomes.sh` covers every case and a self-test proves it separates good from bad results. It is not wired into `claude plugin eval` scoring, because no documented grader runs a command on the final workspace. |
| 3 | A held-out set never used for tuning | **Partly** | 9 cases, frozen by checksum, never run. Written by the same author in the same session as the in-sample cases, so independent in task and domain only. |
| 4 | At least 10 runs per arm on at least 2 models | **Not done** | `evals/run-suite.sh` and a manual workflow exist and are tested in dry-run mode. No paid run has been made. |
| 5 | No known enforcement gap described only in prose | **Mostly** | The debug skill now has a guard hook with deterministic tests, the Stop hook is tested, and a sandbox template ships. Open: whether the skill hook fires for a plugin skill, and whether a forked `phase-gate` can run `/code-review`, are untested under a model. The guard cannot see writes made from inside a script. |
| 6 | Tests and a smoke eval on every pull request | **Partly** | `tests/run.sh`, ShellCheck and plugin validation run on every pull request. The model-backed evals run only by hand, because they cost money and need a secret. |
| 7 | Skills with no demonstrated lift are removed or merged | **Not done** | Decision rules are fixed in `evals/README.md` before any data. Applying them needs the runs from criterion 4. |

## What would move the score

The score cannot honestly reach 9.5 until criteria 1, 3, 4 and 7 are measured. In order:

1. Install `bubblewrap` and `socat`, then run `evals/run-suite.sh --set insample --runs 10 --models "<two models>" --budget <USD>`. Fix broken fixtures and graders, which is expected on a first run.
2. Run the held-out set once with the same settings and report it separately. Do not tune against it.
3. Apply the decision rules and record every removal in `docs/MIGRATION.md`.
4. Re-run once after any change, and update this page with the numbers.

## Estimated position

My estimate, not a measurement: the design and enforcement are now strong, and the evidence is still thin. Treat the playbook as roughly where the reassessment put it plus the phase A to C work, and treat 9.5 as unproven until the runs above exist.

## Live smoke test (2026-11-02)

One headless run each on the default model, with a spending cap per run, about $0.42 in total. It finds breakage; it does not measure reliability.

| Piece | Result |
|---|---|
| Stop hook with a failing `verify.sh` | Worked: blocked with "attempt 1 of 3", Claude fixed it, the next stop passed. |
| Slash-invoking `/playbook:debug` | Worked: the skill was expanded and its skill-scoped hook fired. |
| Debug guard | Worked: `echo > file` and `sed -i` were both blocked and the repo stayed unchanged. |
| Forked `phase-gate` | Correct verdict (BLOCK, with file and line), but it did not invoke the bundled reviews; an unforked run behaved the same. Fixed by the phase-gate change above: the skill now falls back to a direct review and reports which kind ran. Re-run after the fix (one run, about $0.05): BLOCK first, then `Reviews run: direct` for both reviews. |

Not covered: interactive sessions, multi-turn skills, and the eval suite.
