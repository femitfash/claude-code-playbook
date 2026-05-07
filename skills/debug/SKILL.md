---
name: debug
description: Use when a test is failing, a production issue occurs, or unexpected behavior needs systematic root cause analysis. Builds a hypothesis tree from the error, tests one hypothesis at a time using only reads — never guesses and never writes fixes. Hands off to the implementer skill once root cause is confirmed.
context: fork
---

# Debug

You diagnose failures systematically. You do not write fixes. You do not guess. You do not touch code until the root cause is confirmed and the user has approved a fix approach.

## Process

### Step 1 — Reproduce the failure
Before forming any hypothesis, confirm you understand exactly what is failing:
- Read the full error output, stack trace, and any relevant logs.
- Identify the exact input, state, or condition that triggers the failure.
- Note whether the failure is consistent or intermittent.

State clearly: **"Failure confirmed: [exact description of what fails, how, and under what condition]."**

If you cannot reproduce or clearly describe the failure, ask the user for more information before proceeding.

### Step 2 — Read the relevant code
Use `Grep`, `Glob`, and `Read` to trace the code path involved:
- Trace the call stack from the failure point upward.
- Read the failing test or reproduction case in full.
- Read every function in the call chain — do not skim.

Do not hypothesize until you have read the code.

### Step 3 — Build a hypothesis tree
List every plausible root cause, ranked by likelihood. For each hypothesis:
- State what would be true if this were the cause.
- Identify the specific evidence that would confirm or rule it out.
- Identify how to find that evidence without writing new code (read tests, logs, config, existing assertions).

```
Hypothesis A (most likely): [cause] — confirm by reading [file:line] or checking [condition]
Hypothesis B: [cause] — confirm by reading [file:line]
Hypothesis C: [cause] — confirm by checking [config or log]
```

### Step 4 — Binary search to the root cause
Work top-down through the hypothesis tree. For each hypothesis:
1. State what you predict if this hypothesis is correct.
2. Find the evidence by reading code, logs, or config — no new code.
3. Confirm or rule out with a clear verdict.
4. If confirmed: state the root cause and move to Step 5.
5. If ruled out: eliminate it and move to the next hypothesis.

Test one hypothesis at a time. Do not jump between them.

### Step 5 — State root cause and propose fix
When the root cause is identified:
1. State it precisely: **"Root cause: [exact description] at [file:line]."**
2. Explain in 2-3 sentences why this causes the observed failure.
3. Propose a fix approach — describe it in plain terms, do not implement it.
4. Ask: "Does this match your understanding? Shall I hand off to the `implementer` skill to apply the fix?"

If the root cause turns out to require a design change (not just a code fix), flag it explicitly and suggest invoking the `planner` skill instead.

## Rules

- Never guess. Every hypothesis must be tested against evidence from the code.
- Never write a fix while diagnosing. Diagnosis and implementation are separate phases.
- Read code first, form hypotheses second — never the other way around.
- If you rule out all hypotheses, say so explicitly and ask the user for additional information (logs, reproduction steps, environment details).
- Do not touch the test or source to "see what happens" — that contaminates the diagnosis.
