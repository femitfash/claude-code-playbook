# Notes on `settings.baseline.json`

These permission rules are **guardrails against accidents, not a security boundary.** Rules match command text, so they are easy to route around:

- `Read(./.env)` blocks the Read tool only. A shell command such as `cat .env`, `less .env` or `python -c "open('.env')"` is a different tool call. The baseline adds `Bash(cat .env*)`, but cannot list every way to read a file.
- `rm -rf`, `rm -fr`, `rm -r -f`, `rm -f -r`, `rm --recursive` and `find -delete` are all different strings. The baseline denies each of these. A plain `rm -r *` is set to ask rather than deny, because denying it would block legitimate cleanups; `rm -r` with other spellings or other commands that delete files can still get through.
- `git push --force`, `-f` and `git push origin +branch` are different strings.

For a real boundary, add the layers that don't depend on matching text:

1. **Sandbox the shell.** Turn on Claude Code's sandboxing so Bash runs with filesystem and network limits. `templates/settings.sandbox.json` is a starting point: it enables the sandbox, stops commands from opting out of it (`allowUnsandboxedCommands: false`), keeps the normal permission prompts (`autoAllowBashIfSandboxed: false`), and allows network access only to a short list of package registries. Merge it into your `.claude/settings.json`, add any other domains your build needs, and check the current docs for the full set of keys. On Linux the sandbox needs `bubblewrap` and `socat` installed. With an empty or short `allowedDomains` list, commands such as `git fetch` or `npm install` from other hosts will fail until you add them.
2. **Keep secrets out of the working tree.** Use a secrets manager or a path outside the project, not `.env` files Claude can reach.
3. **Run risky or unattended work in a disposable environment** (a container, a worktree, a cloud session) with no production credentials.
4. **Use a managed or project settings file** for rules that must apply to everyone, and review MCP servers and plugins before trusting them.
5. **Treat fetched content and dependencies as untrusted.** Prompt injection and malicious packages are not stopped by these rules.

## Using the baseline

Copy `settings.baseline.json` into your project's `.claude/settings.json` and merge with any existing `permissions`. Deny rules win over allow rules.

## The debug skill's guard

`skills/debug/readonly-guard.sh` is a PreToolUse hook that the debug skill registers while it runs. It blocks the edit tools and the common ways of changing files from Bash (output redirects, `rm`/`mv`/`cp`/`touch`/`tee`, `sed -i`, mutating `git` commands, package installs, downloads to disk). It cannot block a file write made from inside a script the agent runs (for example `python3 -c "open('f','w')..."`), because debugging legitimately needs repro scripts. Treat it as the same kind of guardrail as the permission rules above, and use the sandbox for a real boundary.
