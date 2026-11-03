# Workflow (copy into the project's CLAUDE.md)

For a new project or a non-trivial feature, do not start by planning or coding:

1. Run the `grill-me` skill first. It interviews me one question at a time, with a recommended answer, and writes the resolved decisions to `PRD.md`.
2. Then use the `planner` skill in plan mode, working from `PRD.md`. Wait for my plan approval.
3. After approval, the `implementer` skill builds it test-first, then `phase-gate` reviews it. Fix BLOCK findings, at most 2 rounds.

Skip step 1 only if I say so, or `PRD.md` or `DESIGN.md` already settles the requirements. If I give a limit on questions or time, keep to it. Use `quick-fix` for a clear bug fix or small change. For authentication, user data, payments or secrets, also run `security-grill-me` before planning.
