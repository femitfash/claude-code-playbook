# Personal conventions (copy to ~/.claude/CLAUDE.md)

Keep every CLAUDE.md under 200 lines (the official target). Move topic-specific guidance to
`.claude/rules/<topic>.md`, using `paths:` frontmatter to load it only for matching files.
Use `@path` imports to pull in other files; imports load with the importer, so they do not save context.
Personal, uncommitted notes go in `CLAUDE.local.md` (gitignored).

## Workflow
- Non-trivial change: plan first (plan mode / `/plan`), then implement, then verify.
- Always give Claude a way to check its own work (tests, typecheck, lint) and put those commands in the project CLAUDE.md.
- Use `/rewind` (Esc Esc) to undo a bad turn instead of arguing it back.

## Models and effort
- Use aliases, not version numbers: `opusplan` (Opus plans, Sonnet executes) is a good default for feature work.
- Raise `/effort` for hard debugging or design; lower it for mechanical edits.

## Context
- Check `/context` when sessions feel degraded; `/compact <focus>` or start fresh with a written plan.
- Resume with `claude --continue` / `--resume`. Project CLAUDE.md is re-injected after compaction.

## Subagents
- Use Explore for broad searches so file dumps stay out of the main context.
- Prefer sequential handoffs; fan out only for genuinely independent work.
- Trivial single-file edits: do them inline.

## Autonomous runs
- Declare an exit condition up front (e.g. "all tests pass"). No open-ended loops.
