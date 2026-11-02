# Example: what `/playbook:grill-me` should look like (illustrative)

> **Illustrative, not a recording.** This dialogue was written to show the behaviour the skill asks for. It is not output from a real session. The behaviour is checked by the `grill-me-scans-first` and `grill-me-one-question` cases in [`evals/`](../../evals/README.md).

Setup: the repo from `evals/grill-me-scans-first` (FastAPI, SQLAlchemy/Postgres, JWT auth).

**You:** I want to add team workspaces so several users can share tasks. I haven't thought it through. Grill me.

**Claude** *(reads `README.md`, `app/auth.py`, `app/models.py` first; does not ask what database or auth the app uses)*:

> I've read the repo: Postgres via SQLAlchemy, JWT bearer auth, and tasks are owned by a single user through `tasks.owner_id`. Here is the first decision, because the rest depends on it.
>
> **Should a task belong to one workspace, or can it be shared into several?**
> My recommendation: exactly one workspace. It keeps every query a simple `WHERE workspace_id = ?` and avoids a many-to-many table in v1. Accept, change, or tell me why not?

**You:** One workspace is fine.

**Claude:**

> Next, since tasks now live in workspaces: **what happens to everyone's existing tasks?**
> My recommendation: auto-create a personal workspace per user and move their tasks into it in a reversible migration, so nothing changes for people who never use teams. OK?

*(...and so on, one question at a time, each with a recommended answer, until every branch is settled; then it restates the whole design, lists each decision, asks "Does this match your intent?", and suggests `/playbook:planner`. The finished result looks like [DESIGN-example.md](DESIGN-example.md).)*

What the evals look for: it reads code before asking, asks **one** question at a time, always offers a recommended answer, and writes no code.
