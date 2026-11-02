# AI usage log (template)

Use this while you build, not afterwards. Evaluators of AI-assisted work look for specific moments where you directed, questioned or corrected the AI. Entries written from memory an hour later come out generic. Entries made as it happens come out specific.

Copy the notes block into a scratch file (for example `AI-NOTES.md`) at the start. Add to it every time something non-trivial happens. At the end, turn the best three or more entries into the README log.

## Rules

1. **Only real interactions.** Never invent or embellish an entry. If you have only two real moments, log two and say so.
2. **Complete entries.** Every field filled in. A cut-off or half-finished entry is worse than none.
3. **Specific beats polished.** Name the file, function, number or constraint. Avoid "the AI wasn't quite right".
4. **Include the best and the worst.** Log a moment the AI saved you time and a moment it was wrong.

## Notes block (copy per interaction)

```
### <number>. <short title>   <time>

Asked:      what I asked the AI to do, and the constraints I gave it
Got:        what it produced, specific (what file or function, what approach)
Kept:       the parts I used as they were
Changed:    the parts I edited, and what I changed
Rejected:   the parts I threw away
Why:        the specific property that fell short, or that I valued
            (not "it was wrong": which requirement, constraint or risk did it miss?)
Instead:    what I did in its place
```

## The pushback moment

Many reviews ask for one moment where you disagreed with the AI, pushed back or redirected it. Prepare it as you go, in three parts:

1. **What it produced.** Quote it or paraphrase it closely.
2. **Why it fell short.** Name the specific property: "it violated the constraint that X", "it optimised for Y when the requirement was Z", "it assumed A, but the data shows B".
3. **What you did instead.** The concrete change you made, and the result.

Test: could a stranger tell, from your answer alone, which line or decision you are talking about?

## README section (what to submit)

For each of at least three significant interactions:

- **What I asked the AI to help with**
- **What it gave me**
- **What I kept, changed or rejected, and why**

You do not need to log everything. Three well-chosen, complete entries beat ten vague ones.

## Illustrative example

This is from a made-up project (sorting a to-do list) and exists only to show the level of detail. Do not copy its wording.

```
### 2. Sort order for overdue tasks   10:42

Asked:      Sort tasks by due date, overdue first. Constraint: no task with a
            missing due date may be dropped.
Got:        A sort_tasks() in tasks.py that filtered out tasks where due is None,
            then sorted the rest.
Kept:       The comparison key (due date, then priority).
Changed:    Replaced the filter with a sentinel so undated tasks sort last.
Rejected:   The filter itself.
Why:        It silently dropped undated tasks, which broke the stated constraint.
            My own test (test_undated_tasks_kept) failed on its first version.
Instead:    Wrote the failing test first, then changed the key to
            (due is None, due, priority). Test passes.
```
