# Master project-initiation prompt

> **Editable fields** (change these for each project; leave the body intact):
>
> - **PROJECT_NAME:** [Your Project Name]
> - **REPO_PATH:** [Absolute path to repo]
> - **DESIGN_DOC_PATH:** `DESIGN.md` (at repo root)
> - **STACK:** [e.g., TypeScript + Express + Postgres + Prisma, pnpm workspaces]
> - **TEST_STACK:** [e.g., Vitest + Testcontainers (real DB, no mocks)]
> - **PHASE_0_EXIT_CRITERION:** [Concrete, testable statement from your DESIGN.md Phase 0]
> - **CRITICAL_CONSTRAINTS:**
>   - [Non-negotiable constraint 1]
>   - [Non-negotiable constraint 2]
>   - [Non-negotiable constraint 3]

---

## Your task

You are initiating the **PROJECT_NAME** project at **REPO_PATH**. Execute the 5 steps below **in order**, pausing for my approval between each step. Do NOT skip steps, collapse steps, or pull work forward across steps.

**Universal rules for this entire initiation:**
- Read **DESIGN_DOC_PATH** before doing anything. It is the authoritative reference. Do not re-derive or second-guess decisions that are already captured there.
- Follow the global skill-creation best practices in `~/.claude/CLAUDE.md` for every `SKILL.md` you author.
- Use the Write tool for new files, Edit for modifications. Never overwrite existing files without reading them first.
- Stop and ask via `AskUserQuestion` whenever a blocking decision is needed. Do not guess.
- After each step, produce a short checkpoint summary and wait for my explicit "proceed" before starting the next step.
- **Context hygiene**: when context reaches 50%, run `/compact` before starting the next major step. Do not wait for automatic compaction.
- **Model selection**: use Opus for Steps 1-3 (design-heavy planning), Sonnet for Steps 4-5 (implementation + commits). Switch via `/model`.

---

## Step 1 — Create the project-level `CLAUDE.md`

**Deliverable:** `REPO_PATH/CLAUDE.md` — loads automatically in every Claude Code session opened in this repo. **Keep it under 200 lines; target 60.** Link to DESIGN.md for architecture detail rather than duplicating.

**Required content:**
1. **Authoritative reference** — point to `DESIGN_DOC_PATH`. State clearly: *"All architectural decisions live in DESIGN.md. Do not re-derive; read it first."*
2. **Stack conventions** for STACK:
   - Strict TypeScript (`strict: true`, no `any`, no `@ts-ignore` without comment explaining why)
   - All external boundaries validate with schema library (zod, joi, etc.)
   - Error handling: custom error classes, never throw plain `Error`
   - Async: prefer `async/await`, never mix with `.then()`
3. **Testing standards** for TEST_STACK:
   - Unit tests colocated as `*.test.ts`
   - Integration tests in `<package>/test/integration/`
   - DB integration tests must use real database — no mocking the DB layer
   - Minimum bar: every public API, every API endpoint, every protocol message has a test
4. **Commit + PR conventions**:
   - Conventional commits (`feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`)
   - Trunk-based: short-lived branches, one phase-milestone per PR
   - Every PR states which phase and which exit criterion it advances
5. **Phase 0 exit criterion** (copy verbatim from PHASE_0_EXIT_CRITERION)
6. **Hard boundary rules** — copy all CRITICAL_CONSTRAINTS verbatim
7. **Must-plan-first rule**: for any non-trivial change, invoke the `planner` skill first. No implementation without an approved plan.

**Checkpoint:** show me the full CLAUDE.md content before writing it. After I approve, write the file and stop.

---

## Step 2 — Create seven project-scoped dev skills

**Deliverable:** Seven skills at `REPO_PATH/.claude/skills/`, each as `<name>/SKILL.md` with proper frontmatter per global skill best practices.

### Skill 2a: `planner`

- **Frontmatter must include `context: fork`** — planning runs in isolation to preserve the main session's context.
- **Trigger description:** *"Use when starting any non-trivial implementation work: new packages, new subsystems, schema changes, protocol changes, phase transitions, or any request that would touch multiple files across multiple packages. Produces a concrete plan and refuses to code until user approves."*
- **Content must cover:**
  - Must read DESIGN_DOC_PATH first; plans that contradict the design are invalid
  - Plans must enumerate files to create/modify with paths
  - Plans must state which phase the work belongs to, and call out if anything crosses a phase boundary
  - Plans must identify open decisions and surface them via `AskUserQuestion`
  - Plans must include the test(s) that will verify the work
  - Output lives in the plan file; final approval via `ExitPlanMode`

### Skill 2b: `implementer`

- **Frontmatter must include `context: fork`** — implementation generates many tool calls; isolation keeps the main session lean.
- **Trigger description:** *"Use during implementation phase, after planner has produced an approved plan. Writes code following the project's CLAUDE.md conventions. Test-first, small incremental commits, refuses to exceed the plan's scope."*
- **Content must cover:**
  - Always starts by reading CLAUDE.md + the approved plan
  - Test-first: write the failing test, then the code to pass it, then refactor
  - Small commits: one logical unit per commit, conventional commit message
  - Do not add error handling, abstractions, or comments beyond what the plan specifies
  - If the plan is ambiguous or a decision is needed, STOP and ask — do not guess
  - Before marking work done, run the test suite and type-check

### Skill 2c: `reviewer`

- **Frontmatter must include `context: fork`** — reviews read many files; isolation prevents polluting implementation context.
- **Trigger description:** *"Use before opening a PR or before marking a phase-milestone complete. Code review covering correctness, error handling, test coverage, and performance. Produces a pass/fail report. NOTE: security is handled by the separate `security-auditor` skill."*
- **Content must cover:**
  - Correctness: success + failure paths tested, error types are specific, transactions used correctly, idempotency on side effects
  - Coverage: every public function tested, every API endpoint has a contract test, DB tests use real database
  - Performance: N+1 detection, connection pooling, no blocking I/O on hot paths
  - Output format: pass/fail per category, specific issues with file:line references
  - Explicit handoff: report ends with "Security review: delegated to `security-auditor` — invoke next."

### Skill 2d: `security-auditor`

- **Frontmatter must include `context: fork`** — deep security analysis in isolation; use Opus model.
- **Trigger description:** *"Use for security review of code changes before PR merge or phase-milestone close. Mirrors Claude Code's built-in `/security-review` command and the official `anthropics/claude-code-security-review` GitHub Action. Analyzes changes for vulnerabilities with severity + CWE classification + remediation code. Hard-blocks on CRITICAL findings."*
- **Content must cover:**
  - **Methodology**: static analysis of pending changes (staged + unstaged); no code execution
  - **Vulnerability taxonomy** (mirrors the official GitHub Action):
    - Injection: SQL, command, LDAP, XPath, NoSQL, XXE
    - Authentication & authorization: auth flaws, IDOR, privilege escalation, broken access control
    - Secrets: hardcoded credentials, tokens, API keys, sensitive data exposure
    - Cryptography: weak algorithms, improper key management, insecure randomness
    - Input validation: unvalidated inputs, missing bounds checks, type confusion
    - Business logic: race conditions, TOCTOU, state management flaws
    - Configuration: insecure defaults, exposed debug endpoints, overly permissive CORS
    - Dependency vulnerabilities: known CVEs in lockfile
    - RCE/deserialization: unsafe deserialization, code execution paths
    - XSS: reflected, stored, DOM-based
  - **False-positive filtering** (match official Action): exclude DoS, rate limiting, generic validation, open redirects (unless auth-linked)
  - **Project-specific checks**: pulled from CRITICAL_CONSTRAINTS — customize this section per project
  - **Output format** (mirrors the official Action):
    - **Severity**: CRITICAL / HIGH / MEDIUM / LOW / INFO
    - **CWE**: classification (e.g., `CWE-89: SQL Injection`)
    - **Location**: `file:line`
    - **Vulnerable snippet**: code excerpt
    - **Remediation**: ready-to-use replacement code
    - **Rationale**: 1-2 sentences explaining the risk
  - **Hard-block rule**: CRITICAL blocks merge; HIGH requires acknowledgment; MEDIUM/LOW to backlog
  - **Model preference**: Opus (matches official Action); remind user to `/model opus` before invoking

### Skill 2e: `grill-me`

- **Frontmatter must include `context: fork`**.
- **Trigger description:** *"Use when the user says 'grill me', wants to stress-test a plan, needs rigorous pre-implementation interrogation, or wants to resolve design ambiguity before building."*
- **Content:** Relentless one-question-at-a-time design interrogation. Scans codebase before asking. Always provides a recommended answer. Walks every branch of the design tree top-down. Hands off to `planner` when done. Copy from the playbook's `skills/grill-me/SKILL.md` without modification.

### Skill 2f: `security-grill-me`

- **Frontmatter must include `context: fork`** — use Opus.
- **Trigger description:** *"Use before planning any feature that handles authentication, authorization, user data, multi-tenancy, secrets, financial transactions, or external integrations. Interrogates the security design one question at a time until every threat vector is modeled."*
- **Content:** Threat model interrogation across 8 domains: threat actors, trust boundaries, data classification, authentication, authorization, input/injection, secrets, audit. Scans codebase first. Always provides recommended answers. Produces threat model summary for the design doc's security section. Hands off to `planner` when done. Customize the project-specific section with CRITICAL_CONSTRAINTS. Based on playbook's `skills/security-grill-me/SKILL.md`.

### Skill 2g: `debug`

- **Frontmatter must include `context: fork`**.
- **Trigger description:** *"Use when a test is failing, a production issue occurs, or unexpected behavior needs systematic root cause analysis."*
- **Content:** Reproduce failure first, read code before hypothesizing, build hypothesis tree, binary search to root cause. Never writes fixes — hands off to `implementer` once root cause is confirmed. Copy from the playbook's `skills/debug/SKILL.md` without modification.

**Checkpoint:** show me all seven SKILL.md contents as a single preview before writing. After I approve, write all seven files and stop.

---

## Step 3 — Run Phase 0 scaffolding in plan mode

**Preconditions:** CLAUDE.md + the four skills must already be written (Steps 1 and 2 done).

**Deliverable:** An approved Phase 0 plan (via `ExitPlanMode`) that, when executed, produces the minimum viable scaffolding to hit PHASE_0_EXIT_CRITERION.

**Instructions:**
1. Invoke the `planner` skill.
2. Enter plan mode.
3. Hard scope rule: **Phase 0 only.** Anything from Phase 1+ in the design doc is out of scope. Refuse to plan it.
4. Surface blocking decisions via `AskUserQuestion` before finalizing (e.g., library versions, local dev setup, tooling choices not covered by the design doc).
5. Write the plan to the plan file. Call `ExitPlanMode` when done.

**Checkpoint:** After I approve the plan, stop. Do NOT auto-execute. Wait for "proceed to step 4."

---

## Step 4 — Execute the plan and verify end-to-end

**Preconditions:** Phase 0 plan approved.

**Deliverable:** A working repo where the end-to-end integration test passes, proving PHASE_0_EXIT_CRITERION.

**Instructions:**
1. Invoke the `implementer` skill.
2. Execute the plan incrementally, package by package (or module by module).
3. Between each unit, run the test suite and type-check. Do not move on with failing tests.
4. When the end-to-end test passes, invoke the `reviewer` skill (correctness, coverage, performance).
5. Then invoke the `security-auditor` skill. Switch to Opus (`/model opus`) before invoking.
6. Fix any CRITICAL or HIGH issues from **either** reviewer or security-auditor before declaring Phase 0 complete.

**Checkpoint:** Show me the passing test output + both review reports. Wait for "proceed to step 5."

---

## Step 5 — Commit, document, and close Phase 0

**Preconditions:** Phase 0 code complete, tests passing, both review reports passed.

**Deliverable:** Clean commit history on `main`, Phase 0 closeout in the decision log, next-phase seed.

**Instructions:**
1. Initialize git repo if not already (`git init`, `.gitignore`, minimal `README.md`).
2. **Install the official Claude security-review GitHub Action** at `.github/workflows/security-review.yml` using `anthropics/claude-code-security-review`, configured on `pull_request` events. Reference: https://github.com/anthropics/claude-code-security-review
3. Create commits per conventional commits style. Group logically — one commit per package/module.
4. Append a **Phase 0 closeout entry** to the design doc's decision log with the date, exit criterion met, and any deviations.
5. Create a `PHASE-1.md` skeleton listing Phase 1 exit criteria from the design doc.
6. Report: commits created, follow-ups captured, readiness for Phase 1.

**Checkpoint:** Show me the git log and PHASE-1.md. That's the end of project initiation.

---

## Do not:
- Create files outside `REPO_PATH` (except plans in the designated plans directory)
- Run any git commands that push to a remote (local commits only during initiation)
- Install dependencies until the Phase 0 plan is approved (Step 4)
- Add dependencies not justified by the approved plan
- Create a README beyond a minimal stub (docs come later)

## When stuck:
- Ask via `AskUserQuestion`
- Never guess architectural decisions — the design doc or the user will provide them
