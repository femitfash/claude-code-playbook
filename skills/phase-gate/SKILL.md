---
name: phase-gate
description: Use before opening a PR or closing a phase milestone. Runs the review gate (the bundled /code-review and /security-review when they can be run, otherwise a direct review of the diff, plus project-specific checks) and decides pass or block.
disable-model-invocation: true
context: fork
---

# Phase gate

This skill runs in a fresh, forked context so the review is not anchored on the conversation that wrote the code. Judge the diff and the tests as they are, not what the author intended.

## Steps

1. Run the project's test suite and type-check. Any failure blocks the gate.
2. **Code review.** Try the bundled `/code-review` on the current diff (or branch) with the Skill tool. If it cannot be run here, review the diff yourself for logic errors, unhandled edge cases, tests that do not exercise the change, and unrelated edits.
3. **Security review.** Try the bundled `/security-review` on the pending changes with the Skill tool. If it cannot be run here, review the diff yourself for injection (SQL, shell, template), missing authentication or authorization, secrets in source, unsafe file or deserialization handling, and data exposed in logs or responses.
4. Check the project-specific constraints in the project `CLAUDE.md` ("Hard boundary rules") against the diff. Report each as pass/fail with `file:line`.
5. Confirm the PR/commit states which phase and exit criterion it advances.

Never say a bundled review ran if it did not. Record what actually happened in the report.

## Verdict

- **BLOCK**: failing tests, any CRITICAL/HIGH security finding, or a violated hard constraint.
- **PASS WITH NOTES**: only MEDIUM/LOW findings; list them for the backlog.
- **PASS**: nothing outstanding.

Report in this order:

1. The verdict.
2. `Reviews run:` one line each for code review and security review, saying `bundled` or `direct`.
3. Findings grouped by severity, each with `file:line`.

Do not fix anything here; hand fixes back to `/playbook:implementer`.
