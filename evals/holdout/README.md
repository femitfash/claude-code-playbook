# Held-out eval cases

One case per skill, written to measure the plugin on tasks it was **not** tuned against. Case names start with `holdout-` and carry the `holdout` tag.

## The rule

**Never edit these cases, and never change a skill in response to how it scores here.** The in-sample cases in `evals/` are for tuning; this set is for reporting.

`FROZEN.sha256` is a checksum manifest of every file here except this README. `tests/run.sh` (and CI) fails if any case file changes. That makes edits visible. It does not make them impossible: whoever regenerates the manifest can change a case, so reviewers should look at any diff that touches `FROZEN.sha256`.

If a held-out case turns out to be broken (for example its fixture does not build):
1. Do not fix it in place to improve a score.
2. Add a new `holdout-...` case, leave the broken one, and note why in the log below.
3. Regenerate the manifest in a commit that touches nothing else.

To regenerate (only for step 3 or when adding cases):

```bash
cd evals/holdout
find . -type f ! -name FROZEN.sha256 ! -name README.md | LC_ALL=C sort | xargs sha256sum > FROZEN.sha256
```

## Running and reporting

```bash
claude plugin eval . --case 'holdout-*' --runs 10 --scaffold --keep-temp --no-publish --trust-plugin \
  --allow-tools Bash Edit Write --max-cost-usd <budget>
evals/check-outcomes.sh <case-name> <kept scaffold dir>
```

Report held-out results in their own table, separate from the in-sample table. Slash-invoked skills (`implementer`, `phase-gate`, `resume`, `project-init`) are **conformance** cases: a model cannot start those skills on its own, so there is no meaningful no-plugin comparison and no lift should be claimed from them.

## Limits of this set

- **Same author, same session.** These were written by the same author, at the same time, as the in-sample cases, after reading the skills. They are different tasks and domains, not independent ones. A truly independent set needs cases written by someone who has not seen or tuned the skills.
- **One case per skill.** That is enough to catch gross failures, not to estimate a rate.
- **Never run.** At the time of writing none of these cases has been executed under a model. The first run may expose broken fixtures or graders; follow the rule above if so.
- **Slash invocation unverified.** Prompts for the conformance cases begin with `/playbook:<skill>`. Whether `claude plugin eval` expands that into the skill is unconfirmed; the `skill-fired` indicator in the first run will show it.

## Log

| Date | Change | Reason |
|---|---|---|
| 2026-11-02 | Initial set of 9 cases | v3.0 phase B |
