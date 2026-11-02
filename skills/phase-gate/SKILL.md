---
name: phase-gate
description: Use before opening a PR or closing a phase milestone. Runs the review gate (Claude Code's bundled /code-review and /security-review plus project-specific checks) and decides pass or block.
disable-model-invocation: true
context: fork
---

# Phase gate

Claude Code ships `/code-review` and `/security-review`; use them rather than re-implementing their checks.

This skill runs in a fresh, forked context so the review is not anchored on the conversation that wrote the code. Judge the diff and the tests as they are, not what the author intended.

## Steps

1. Run the project's test suite and type-check. Any failure blocks the gate.
2. Run `/code-review` on the current diff (or branch) and collect findings.
3. Run `/security-review` on the pending changes and collect findings.
4. Check the project-specific constraints in the project `CLAUDE.md` ("Hard boundary rules") against the diff. Report each as pass/fail with `file:line`.
5. Confirm the PR/commit states which phase and exit criterion it advances.

## Verdict

- **BLOCK**: failing tests, any CRITICAL/HIGH security finding, or a violated hard constraint.
- **PASS WITH NOTES**: only MEDIUM/LOW findings; list them for the backlog.
- **PASS**: nothing outstanding.

Report the verdict first, then findings grouped by severity. Do not fix anything here; hand fixes back to `/playbook:implementer`.
