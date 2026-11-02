#!/usr/bin/env bash
# PreToolUse guard for the debug skill: blocks the common ways of changing files while diagnosing.
# Wired from skills/debug/SKILL.md (frontmatter `hooks`). Reads the hook JSON on stdin.
# Exit 0 = allow, exit 2 = block (the reason goes to stderr and back to Claude).
#
# What it blocks: the Edit/Write/NotebookEdit tools; in Bash, output redirection to files,
# file-changing commands (rm, mv, cp, touch, tee, ...), in-place edits (sed -i), mutating git
# subcommands, package installs, and downloads to disk.
#
# What it cannot block: code that writes files from inside an interpreter (for example
# `python3 -c "open('f','w')..."`), which debugging legitimately needs for repro scripts.
# This is a guardrail, not a sandbox. For a real boundary, enable sandboxing
# (see templates/settings.sandbox.json and templates/SETTINGS-NOTES.md).
#
# Test: printf '{"tool_name":"Bash","tool_input":{"command":"rm -rf x"}}' | ./readonly-guard.sh; echo $?
set -uo pipefail

payload="$(cat)"
tool="$(printf '%s' "$payload" | sed -n 's/.*"tool_name"[[:space:]]*:[[:space:]]*"\([A-Za-z_]*\)".*/\1/p' | head -n 1)"

deny() {
  printf 'playbook debug is read-only: %s\nRun read-only commands (tests, git log/diff/show, grep, cat), or end the debug session before changing anything.\n' "$1" >&2
  exit 2
}

case "$tool" in
  Edit|Write|NotebookEdit|MultiEdit) deny "the $tool tool is blocked." ;;
  Bash) ;;
  *) exit 0 ;;
esac

# Pull the command string out of the JSON, cut it at its closing quote, and unescape it.
cmd="$(printf '%s' "$payload" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)/\1/p' | head -n 1 \
  | sed -E 's/^(([^"\\]|\\.)*)".*/\1/' \
  | sed -e 's/\\"/"/g' -e 's/\\n/ /g' -e 's/\\t/ /g' -e 's/\\\\/\\/g')"
[[ -n "$cmd" ]] || deny "could not read the command, so it is blocked to be safe."

# Look only at the shell syntax: drop quoted strings (so code inside python -c "..." is not scanned),
# then drop harmless redirections.
bare="$(printf '%s' "$cmd" | sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g")"
safe="$(printf '%s' "$bare" | sed -E 's/[0-9]?>&[0-9-]//g; s/&?>>?[[:space:]]*\/dev\/null//g; s/[0-9]>>?[[:space:]]*\/dev\/null//g')"

[[ "$safe" == *">"* ]] && deny "output redirection to a file (>)."

w='(^|[^[:alnum:]_./-])'   # left word boundary
e='([^[:alnum:]_-]|$)'     # right word boundary

if printf '%s' "$safe" | grep -Eq "${w}(rm|rmdir|mv|cp|mkdir|touch|chmod|chown|ln|tee|truncate|dd|install|patch)${e}"; then
  deny "a file-changing command (rm, mv, cp, touch, tee, mkdir, ...)."
fi
if printf '%s' "$safe" | grep -Eq "(sed|perl|ruby|awk)[^|;&]*[[:space:]](-[a-zA-Z]*i|--in-place)"; then
  deny "an in-place edit (sed -i and similar)."
fi
if printf '%s' "$safe" | grep -Eq "find[^|;&]*[[:space:]](-delete|-exec|-ok)"; then
  deny "find with -delete or -exec."
fi
if printf '%s' "$safe" | grep -Eq "${w}git[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?(add|commit|checkout|switch|reset|restore|clean|stash|apply|am|merge|rebase|cherry-pick|revert|push|pull|fetch|tag|rm|mv|worktree|config|init|clone|gc|prune|update-ref)${e}"; then
  deny "a git command that changes the repository."
fi
if printf '%s' "$safe" | grep -Eq "${w}git[[:space:]]+branch[[:space:]]+(-[dDmMcC]|--delete|--move|--copy)"; then
  deny "a git command that changes branches."
fi
if printf '%s' "$safe" | grep -Eq "${w}(npm|pnpm|yarn|pip|pip3|poetry|cargo|go)[[:space:]]+(install|add|remove|uninstall|update|upgrade|publish|get)${e}"; then
  deny "a package install or change."
fi
if printf '%s' "$safe" | grep -Eq "${w}wget${e}|${w}curl[^|;&]*[[:space:]](-o|-O|--output|--remote-name)"; then
  deny "a download to disk."
fi
exit 0
