# Claude Code Playbook

A battle-tested methodology for shipping software products with Claude Code — from architecture to production.

**This is not a feature guide.** If you want to learn what Claude Code can do, see the [official docs](https://code.claude.com/docs) or [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice). This repo answers a different question: **how do you reliably use Claude Code to ship a product?**

## What's inside

| Path | What it is |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Global conventions — drop into `~/.claude/CLAUDE.md` to load in every session |
| [`templates/HOW-TO-USE.md`](templates/HOW-TO-USE.md) | Step-by-step project initiation workflow |
| [`templates/MASTER-PROMPT.md`](templates/MASTER-PROMPT.md) | The 5-step initiation prompt — paste into Claude Code to bootstrap a new project |
| [`templates/DESIGN-TEMPLATE.md`](templates/DESIGN-TEMPLATE.md) | Blank design doc skeleton — fill this out before running the master prompt |
| [`skills/planner/`](skills/planner/SKILL.md) | Plans work before code is written; refuses to implement without approval |
| [`skills/implementer/`](skills/implementer/SKILL.md) | Executes approved plans; test-first, small commits, scope-locked |
| [`skills/reviewer/`](skills/reviewer/SKILL.md) | Code review for correctness, coverage, and performance |
| [`skills/security-auditor/`](skills/security-auditor/SKILL.md) | Security review mirroring Claude's `/security-review` + the official GitHub Action |
| [`hooks/validate-skill-frontmatter.sh`](hooks/validate-skill-frontmatter.sh) | PreToolUse hook that blocks malformed SKILL.md writes |
| [`hooks/README.md`](hooks/README.md) | How to install hooks |

## The methodology

### Design-first, not vibe-first

Every project starts with a **design document** — locked architectural decisions, phased delivery plan with exit criteria, decision log. Claude Code sessions consume the design doc; they don't replace it.

Why: without a design doc, each Claude Code session re-derives architecture from scratch. You get inconsistent decisions, scope creep, and sessions that contradict each other. A design doc is the single source of truth that survives across sessions.

### 5-step project initiation

The master prompt walks Claude Code through five steps, with approval gates between each:

1. **Create project CLAUDE.md** — conventions, links to design doc, hard constraints
2. **Create four dev skills** — planner, implementer, reviewer, security-auditor
3. **Plan Phase 0** in plan mode — scoped to the design doc's exit criteria
4. **Execute and verify** — test-first implementation, reviewer + security-auditor pass
5. **Commit and close** — clean git history, decision log updated, next-phase seed created

Each step produces a checkpoint. You review and say "proceed." No runaway agents.

### Four-skill development triad

Instead of one monolithic "do everything" prompt, split responsibilities into focused skills:

| Skill | Role | When |
|---|---|---|
| **Planner** | Breaks requests into plans; refuses to code without approval | Before any non-trivial implementation |
| **Implementer** | Writes code following the plan; test-first, scope-locked | After plan is approved |
| **Reviewer** | Correctness, coverage, performance review | Before PR / milestone close |
| **Security Auditor** | Vulnerability scan mirroring official Claude tools | After reviewer, before merge |

All four use `context: fork` — they run in isolated subagent contexts, preserving the main session's context window.

### Phase-gated delivery

Work is organized into phases with explicit, measurable exit criteria. A phase is closed (committed, documented) before the next one opens. This prevents scope creep and makes progress visible.

## Practices adopted and where they came from

This playbook synthesizes three sources:

### Internal methodology (original to this repo)
- Design-doc-first workflow
- 5-step project initiation template with approval gates
- Four-skill dev triad (planner / implementer / reviewer / security-auditor)
- Phase-gated delivery with exit criteria
- Auto-memory strategy for persisting architectural decisions across sessions
- Master prompt as a reusable, editable template

### Anthropic official tools
- [Plan mode](https://code.claude.com/docs) for structured planning with `ExitPlanMode` approval
- [`/security-review`](https://code.claude.com/docs/en/security) command — the security-auditor skill mirrors its methodology
- [`anthropics/claude-code-security-review`](https://github.com/anthropics/claude-code-security-review) GitHub Action — the security-auditor skill mirrors its vulnerability taxonomy and output format
- Skills architecture (`SKILL.md` with frontmatter, context forking, progressive disclosure)
- `AskUserQuestion` tool for forcing decisions before implementation

### Community practices (from [claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice))
- CLAUDE.md length discipline — under 200 lines, 60 optimal
- `context: fork` for skills that do substantial isolated work
- Model selection strategy — Opus for planning, Sonnet for implementation
- `/compact` at 50% context to avoid degradation
- Session naming for resumability
- PreToolUse hooks for enforcement (not just advisory rules)

## Quick start

### 1. Install global conventions

Copy `CLAUDE.md` to your Claude Code config:

```bash
cp CLAUDE.md ~/.claude/CLAUDE.md
```

### 2. Install the hook

Add the skill-validation hook to your settings:

```bash
cp hooks/validate-skill-frontmatter.sh ~/.claude/hooks/
```

Then add to `~/.claude/settings.json`:

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

### 3. Start a new project

1. Fill out [`templates/DESIGN-TEMPLATE.md`](templates/DESIGN-TEMPLATE.md) for your project
2. Copy the four skills from `skills/` into your project's `.claude/skills/`
3. Open Claude Code in your project directory
4. Paste the contents of [`templates/MASTER-PROMPT.md`](templates/MASTER-PROMPT.md) (edit the top fields first)
5. Approve each step as Claude progresses

See [`templates/HOW-TO-USE.md`](templates/HOW-TO-USE.md) for the full walkthrough.

## Philosophy

- **Design before code.** Architecture decisions in a doc, not in a chat.
- **Plan before implement.** No code without an approved plan.
- **Verify before merge.** Reviewer + security auditor, every time.
- **Phase before scope creep.** Explicit exit criteria; close phases, don't let them drift.
- **Advisory is not enforcement.** Use hooks where rules must be mandatory.
- **Context is finite.** Manage it actively — fork skills, compact early, name sessions.

## License

MIT
