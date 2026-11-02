# Evals

Behavioural evals for the plugin, run with `claude plugin eval`. Each case runs the same prompt **with** the plugin and **without** it (a no-plugin baseline arm), grades both, and reports the difference (Δ). The point is to measure what the plugin adds, not whether Claude can do the task at all.

## Run them

```bash
claude plugin eval . --runs 3 --no-publish --trust-plugin \
  --scaffold --allow-tools Bash Edit Write --max-cost-usd 10
```

- `--scaffold` runs each case's `fixture.sh` (builds a tiny repo). Only use it on case files you trust.
- Granting `Bash` needs a working sandbox. On Linux install `bubblewrap` and `socat` (`apt install bubblewrap socat`); without them runs are refused.
- Results are written to `evals/results/` (gitignored). A full run costs roughly $1 to $1.50.
- Cheap structural checks that need no model: `tests/run.sh`.

## Cases

| Case | Checks | Grader types |
|---|---|---|
| `quick-fix-bug` | On a plain bug report: tests run at least twice, a regression test is edited before the source, the final report is evidenced and minimal | `tool_used`, `tool_order`, `llm` |
| `debug-read-only` | Failing test, prompt does not forbid edits: no `Edit`/`Write` calls, failure reproduced, root cause (`>` should be `>=` at `inventory.py:8`) identified and fix only proposed | `tool_used`, `llm` |
| `grill-me-scans-first` | Reads the code first and does not ask what the repo already answers (DB, ORM, auth); no code in the reply | `tool_used`, `llm`, `regex` |
| `grill-me-one-question` | Exactly one question with a recommended answer | `llm`, `tool_used` |

Each case also has a `skill-fired` grader marked `arm: with-only`; it reports whether the skill was invoked and is excluded from the score.

## Results (what I actually ran)

CLI 2.1.316, plugin v2.1.0 plus the edits listed below, 3 runs per arm (2 in the first pass), CLI default model (the results file does not record it), 2026-11-02. Scores are the mean fraction of weighted graders passed.

| Case | With plugin | Without | Δ |
|---|---|---|---|
| `quick-fix-bug` | 1.00 | 0.00 | **+1.00** |
| `debug-read-only` | 1.00 | 0.80 | +0.20 |
| `grill-me-scans-first` | 1.00 | 1.00 | 0.00 |
| `grill-me-one-question` | 0.78 | 0.56 | +0.22 |

### How to read this

- **These are not independent test results.** The first pass found problems that I then fixed, so the table above is the second pass on a suite I tuned after seeing results. Treat it as evidence the evals work and the plugin can help, not as a benchmark.
- **First pass (2 runs/arm), before any fix:** mean Δ was 0.00. `quick-fix-bug` scored 0.00 in both arms because the `quick-fix` skill never triggered: Claude fixed the bug directly, with no regression test and one test run. `grill-me-scans-first` failed a flaky LLM grader in both arms. `debug-read-only` could not discriminate because its prompt said "don't change any files".
- **What changed because of the evals:**
  1. `quick-fix` description rewritten so it triggers on ordinary bug-fix requests (it now fired 3 of 3 times; Δ went from 0 to +1.00).
  2. `debug-read-only` prompt made neutral, so the skill's disabled edit tools are what is being tested.
  3. `grill-me-scans-first/no-code` replaced by a deterministic code-fence check.
  4. `grill-me` and `security-grill-me` now say "exactly one question per turn, one question mark, no compound questions". Before that, the plugin arm of `grill-me-one-question` scored **0.33 against 0.78 without it** (a regression: the skill bundled sub-questions in 3 of 3 runs).
- **Small samples.** With 3 runs per arm, one run changes a score by 0.33 or more. In the last pass one plugin run of `grill-me-one-question` still bundled its questions, and the baseline arm passed only 1 of 3. `debug-read-only` Δ of +0.20 is a single baseline run that edited a file, and the `debug` skill fired in only 2 of 3 plugin runs (the third passed without invoking it).
- **No lift measured for `grill-me-scans-first`.** The baseline already reads the repo and asks good questions; this case works as a regression guard.
- **Not covered:** `planner` (needs plan mode), `implementer`, `phase-gate` (needs the bundled review commands), `resume`, `project-init`, `security-grill-me`, and the Stop hook (see `tests/run.sh` for the hook). One scenario per skill is thin; add more before drawing conclusions.
- **The `test-before-fix` grader** only recognises `Edit`. A run that writes the test with `Write` fails it, so a single failure there is a prompt to read the trace.

## Outcome checks (v3.0, phase A)

The graders above mostly score *process* (which tools ran, in what order, what the reply said). Outcome checks score the *end state* of the workspace, deterministically and without a model:

```bash
claude plugin eval . --runs 1 --scaffold --keep-temp ...   # keep the scaffold dirs
evals/check-outcomes.sh quick-fix-bug /path/to/kept/scaffold
```

| Case | Outcome checks |
|---|---|
| `quick-fix-bug` | Hidden acceptance tests pass (never copied into the fixture); the project's own tests pass; `cart.py` changed; a regression test was added; nothing unrelated changed |
| `debug-read-only` | No file modified or created; the bug is still present (diagnosed, not fixed) |
| `grill-me-scans-first` | No file modified or created |

`tests/outcomes-selftest.sh` (run by `tests/run.sh`) proves the checks discriminate: it builds each fixture, applies a hand-written good or bad result, and asserts the checker passes or fails it accordingly.

**Not yet wired into `claude plugin eval` scoring.** The eval CLI's grader types that I could confirm are `tool_used`, `tool_order`, `llm` and `regex`; I found no documented grader that runs a command against the final workspace. Until one exists, outcome checks run as a separate step after a `--keep-temp` run. Phase B will either wire them in or report them alongside the eval scores.

**Known gap:** the `test-before-fix` grader still recognises only `Edit` (see its note). The grader schema does not document an either/or on tool name, so I have not changed it blind.

## Adding a case

`claude plugin eval init --bare <name>` scaffolds one. Keep prompts natural (don't name the skill or state the behaviour you want, or the baseline arm gets it for free), add at least one deterministic grader, and run with the baseline arm so you can see whether the plugin adds anything.
