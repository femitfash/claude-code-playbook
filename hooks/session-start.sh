#!/usr/bin/env bash
# SessionStart hook: puts the playbook workflow in front of Claude at the start of a session, so the
# skills run in order without being typed. Its output is added to the session context.
# Opt out with PLAYBOOK_NO_WORKFLOW_HINT=1.
# Test: ./session-start.sh; echo $?
[[ "${PLAYBOOK_NO_WORKFLOW_HINT:-0}" == "1" ]] && exit 0
cat <<'TXT'
Playbook workflow. When the user starts a new project or a non-trivial feature, do NOT start by planning or coding:
1. Run the `grill-me` skill FIRST: it interviews the user one question at a time (with a recommended answer) and writes the resolved decisions to PRD.md.
2. Then use the `planner` skill in plan mode, working from PRD.md. Wait for the user's plan approval.
3. After approval, the `implementer` skill builds it test-first, then `phase-gate` reviews it.
Skip step 1 only if the user says to skip it, or a PRD.md or DESIGN.md already settles the requirements. If the user gives a limit on questions or time, keep to it. For a clear bug fix or small change use `quick-fix` instead. For work involving authentication, user data, payments or secrets, also run `security-grill-me` before planning.
TXT
