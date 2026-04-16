# Hooks

Claude Code hooks are shell commands that run automatically on specific events. They enforce rules that CLAUDE.md can only advise.

## Available hooks

### `validate-skill-frontmatter.sh`

**Event:** PreToolUse (Write, Edit)
**What it does:** Blocks any write to a `SKILL.md` file under `.claude/skills/` that lacks valid YAML frontmatter with `name` (kebab-case) and `description` fields.

## Installation

### 1. Copy the hook script

```bash
mkdir -p ~/.claude/hooks
cp hooks/validate-skill-frontmatter.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/validate-skill-frontmatter.sh
```

### 2. Register in settings

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.claude/hooks/validate-skill-frontmatter.sh\""
          }
        ]
      }
    ]
  }
}
```

If you already have a `hooks` section, merge the `PreToolUse` entry into it.

## How hooks work

- **PreToolUse**: runs before a tool executes. Exit 0 = allow, exit 2 = block (stderr shown to Claude).
- **PostToolUse**: runs after a tool executes. Useful for auto-formatting, logging, etc.
- **Stop**: runs when Claude finishes its turn. Useful for verification or nudges.

Hooks receive JSON on stdin with `tool_name` and `tool_input` fields. They can inspect the payload and decide whether to allow, block, or modify behavior.

See the [official docs](https://code.claude.com/docs) for the full hooks specification.
