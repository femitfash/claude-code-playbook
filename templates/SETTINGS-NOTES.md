# Notes on `settings.baseline.json`

These permission rules are **guardrails against accidents, not a security boundary.** Rules match command text, so they are easy to route around:

- `Read(./.env)` blocks the Read tool only. A shell command such as `cat .env`, `less .env` or `python -c "open('.env')"` is a different tool call. The baseline adds `Bash(cat .env*)`, but cannot list every way to read a file.
- `rm -rf`, `rm -fr`, `rm -r -f` and `find -delete` are all different strings.
- `git push --force`, `-f` and `git push origin +branch` are different strings.

For a real boundary, add the layers that don't depend on matching text:

1. **Sandbox the shell.** Turn on Claude Code's sandboxing (`/sandbox`) so Bash runs with filesystem and network limits. Check the current docs for setup and settings keys.
2. **Keep secrets out of the working tree.** Use a secrets manager or a path outside the project, not `.env` files Claude can reach.
3. **Run risky or unattended work in a disposable environment** (a container, a worktree, a cloud session) with no production credentials.
4. **Use a managed or project settings file** for rules that must apply to everyone, and review MCP servers and plugins before trusting them.
5. **Treat fetched content and dependencies as untrusted.** Prompt injection and malicious packages are not stopped by these rules.

## Using the baseline

Copy `settings.baseline.json` into your project's `.claude/settings.json` and merge with any existing `permissions`. Deny rules win over allow rules.
