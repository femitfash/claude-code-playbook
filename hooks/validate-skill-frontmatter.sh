#!/usr/bin/env bash
# PreToolUse hook: validate SKILL.md frontmatter on Write/Edit.
# Blocks writes to any file under `.claude/skills/` ending in `SKILL.md`
# that lacks valid YAML frontmatter with `name` and `description` fields.
#
# Input (stdin, JSON): { "tool_name": "...", "tool_input": { "file_path": "...", "content": "..." } }
# Exit 0 = allow; exit 2 = block (stderr is shown to Claude).

set -euo pipefail

payload="$(cat)"

tool_name="$(printf '%s' "$payload" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")"

if [[ "$tool_name" != "Write" && "$tool_name" != "Edit" ]]; then
  exit 0
fi

file_path="$(printf '%s' "$payload" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")"

# Only guard SKILL.md files under .claude/skills/
case "$file_path" in
  *.claude/skills/*/SKILL.md|*/.claude/skills/*/SKILL.md)
    ;;
  *)
    exit 0
    ;;
esac

content="$(printf '%s' "$payload" | python3 -c "
import json, sys
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('content') or ti.get('new_string') or '')
" 2>/dev/null || echo "")"

# Validate frontmatter exists
if ! printf '%s' "$content" | head -1 | grep -q '^---[[:space:]]*$'; then
  echo "SKILL.md frontmatter missing. First line must be '---'." >&2
  echo "File: $file_path" >&2
  exit 2
fi

# Extract frontmatter block (between first pair of --- markers)
frontmatter="$(printf '%s' "$content" | awk '/^---[[:space:]]*$/{c++; next} c==1{print} c==2{exit}')"

if ! printf '%s' "$frontmatter" | grep -qE '^name:[[:space:]]*[a-z0-9-]+[[:space:]]*$'; then
  echo "SKILL.md frontmatter invalid: 'name' field missing or not kebab-case." >&2
  echo "File: $file_path" >&2
  echo "Required: 'name: <kebab-case-name>' matching directory name." >&2
  exit 2
fi

if ! printf '%s' "$frontmatter" | grep -qE '^description:[[:space:]]*.+'; then
  echo "SKILL.md frontmatter invalid: 'description' field missing." >&2
  echo "File: $file_path" >&2
  echo "Required: 'description: Use when <specific triggers>. <What it does>.'" >&2
  exit 2
fi

exit 0
