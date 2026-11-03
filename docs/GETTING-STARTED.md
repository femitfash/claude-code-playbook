# Getting started

Copy-paste prompts to start a new project with the playbook. Paste them into the Claude Code chat box (VS Code panel or terminal). Replace anything in `<angle brackets>`, and delete any `[optional]` line you do not want.

## 1. Install the plugin (you type this, once)

Claude cannot type `/plugin` commands for you. Use one of these.

**Plugin menu:**

```
/plugin marketplace add femitfash/claude-code-playbook
/plugin install playbook@claude-code-playbook
```

**Terminal** (needs the `claude` command on your PATH):

```
claude plugin marketplace add femitfash/claude-code-playbook
claude plugin install playbook@claude-code-playbook
```

**Project settings file** (when `/plugin` is not available): create `.claude/settings.json` in your project with the text below, reload the window and accept the install prompt.

```json
{
  "extraKnownMarketplaces": {
    "claude-code-playbook": {
      "source": { "source": "github", "repo": "femitfash/claude-code-playbook" }
    }
  },
  "enabledPlugins": { "playbook@claude-code-playbook": true }
}
```

**To update an existing install** (it only updates when the plugin's version changes):

```
claude plugin marketplace update claude-code-playbook
claude plugin update playbook@claude-code-playbook
```

Then restart Claude Code or reload the VS Code window. In the plugin menu, `/plugin marketplace update claude-code-playbook` does the first step. If the update does not take, uninstall and reinstall (`claude plugin uninstall playbook@claude-code-playbook`, then install again).

**Check it worked:** type `/` in the chat box and look for `playbook:` skills such as `playbook:planner`.

## 2. Setup prompt (once per project, before you start building)

Open an empty project folder, then paste:

```
I'm starting a new project with the Playbook plugin. Set up the environment
only. Do NOT write application code and do NOT start planning.
Writes under .claude/ will trigger permission prompts; I will approve them.

1. If this folder is not a git repo, run `git init`. If it already has files,
   list them and ask me before continuing.
2. Confirm the "playbook" plugin is installed (`claude plugin list`, or look
   under ~/.claude/plugins). If not, tell me what to type and stop.
3. Confirm the installed plugin is CURRENT. Find its folder (search
   ~/.claude/plugins for settings.baseline.json) and check that ALL are true:
   - .claude-plugin/plugin.json has a version of 3.0.1 or higher
   - skills/grill-me/SKILL.md contains "Use proactively"
   - skills/implementer/SKILL.md contains "Start only when an approved plan exists"
   - skills/phase-gate/SKILL.md contains "Reviews run:"
   If any is false, tell me to update it (`claude plugin marketplace update claude-code-playbook`, then
   `claude plugin update playbook@claude-code-playbook`, then restart) and stop.
   If you cannot find the folder, fetch the files from
   https://github.com/femitfash/claude-code-playbook instead and tell me.
4. Create:
   - .claude/settings.json, merging templates/settings.baseline.json and
     templates/settings.sandbox.json, and KEEPING any existing
     extraKnownMarketplaces and enabledPlugins keys. SHOW me the merged file
     and wait for my OK before writing it.
   - .claude/verify.sh (executable), copied from
     templates/verify.wrapper.sh.example. It delegates to scripts/check.sh, so
     the checks can be written later without more .claude/ approvals.
   - .gitignore for this project's language, plus .env and
     .claude/settings.local.json.
   - [optional] AI-NOTES.md, copied from templates/AI-LOG.md.
   - [optional] The workflow rule from templates/CLAUDE.project.md, added to CLAUDE.md.
5. Do not create scripts/check.sh yet (the stack and checks are not chosen).
6. Commit as "chore: project scaffold (no application code)".
7. Report what you created and what you did NOT do, then wait for me.
```

## 3. Kickoff prompt (when you are ready to build)

```
Project: <one or two sentences on what to build, or "read BRIEF.md", or "read <URL>">
[optional] Time limit: I have <N> minutes. Run `date +%H:%M` now and tell me
the start time and the <90% mark>. Run `date` at each milestone so we track time.

Work in this order and do not skip ahead:
1. If I gave a brief (a file or a URL), read it fully. If you cannot read it,
   say so and ask me to paste it. Do not guess.
2. Run the grill-me skill [optional: with a limit of <N> questions]: one
   question at a time, each with a recommended answer. It writes PRD.md once I
   confirm its summary. [optional: Skip security-grill-me.]
3. Write the spec file (SPEC.md or CLAUDE.md) from PRD.md: the outcome, any
   constraints copied VERBATIM from the brief, acceptance criteria, and the
   automated checks the work must pass.
4. Put the checks in scripts/check.sh (executable; prints PASS or FAIL per
   check; exits non-zero on any failure). .claude/verify.sh already delegates
   to it, so the Stop hook blocks "done" while it fails. Do not write under
   .claude/.
5. Enter plan mode (I will press Shift+Tab if needed) and use the planner skill
   for a short plan. I will approve it with the normal plan approval. After I
   approve, continue AUTOMATICALLY: implement it (implementer), then run the
   phase-gate checks, and fix any BLOCK findings (at most 2 rounds). Do not wait
   for me to type skills. If a handoff does not fire, tell me which skill to
   type. If you cannot enter plan mode, show the plan as text and wait for me
   to say "approved".
6. Build test-first, the smallest end-to-end slice. Commit often. Tell me when
   you cut scope.

Rules for the whole run:
- Never say a check passes without running it and showing the output.
- Before you rely on or repeat a claim from a review (a file, a line number, a
  tool result), check it yourself.
- [optional] After each non-trivial AI interaction, append a COMPLETE entry to
  AI-NOTES.md (asked / got / kept / changed / rejected / why / instead). Only
  real interactions; never invent or embellish one.
- [optional, if the project calls a model] Route EVERY model call through one
  function that appends the exact text sent and the response to
  model-calls.log. Label any mock clearly.
- At the end, draft the README from the code and mark it "DRAFT, for me to edit".
```

## What to expect

- **Approval prompts for `.claude/` files.** Claude Code treats them as sensitive. You will be asked to approve `.claude/settings.json` and `.claude/verify.sh` once, during setup.
- **Skills that start by themselves:** `grill-me` when you begin a project or feature, then `planner`, then (after you approve the plan) `implementer`, then `phase-gate`. `quick-fix` and `debug` also start by themselves, by their descriptions. Claude does not always invoke a skill when it should. If a handoff does not happen, type it, for example `/playbook:planner`.
- **Skills you type yourself:** `/playbook:project-init` and `/playbook:resume`.
- **`security-grill-me`** is meant to run for work involving authentication, user data, payments or secrets. It walks eight areas and can be long. Tell Claude to skip it, or to keep it short, if you are short on time.
- **The session-start hint** that makes this order happen applies to every session where the plugin is enabled. Set `PLAYBOOK_NO_WORKFLOW_HINT=1` to turn it off.

## If something is off

| Symptom | Likely cause and fix |
|---|---|
| No `playbook:` skills in the `/` menu | The plugin is not installed or loaded here. Redo step 1 and reload the window. |
| `/plugin` is not available | You may be in a web or cloud session. Use the VS Code extension or the terminal, or the project settings file in step 1. |
| Setup says the plugin is not current | Refresh it (step 1). The version must change for an update to be picked up. |
| `grill-me` does not start | Say "run grill-me". Check that the session-start hint is not switched off. |
| The Stop hook keeps blocking | `PLAYBOOK_VERIFY_DISABLE=1` skips it; `PLAYBOOK_VERIFY_MAX_RETRIES` changes how often it blocks. |
| A review cites a line or file that does not exist | Reviews can be wrong. Check any citation before you act on it. |

For a hard time limit, also read [`TIMEBOXED.md`](TIMEBOXED.md). For what has and has not been measured, read [`SCORECARD.md`](SCORECARD.md).
