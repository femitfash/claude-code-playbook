# Tasks API: Team Workspaces — Design Document (worked example)

> **Illustrative.** A filled-in example of [`DESIGN-TEMPLATE.md`](../../skills/project-init/DESIGN-TEMPLATE.md), for the same small FastAPI/Postgres tasks service used in the `grill-me-scans-first` eval. The product and every decision are invented to show what "good enough to initiate from" looks like.

**Status:** Draft v0.2
**Last updated:** 2026-11-02
**Owner:** (you)

---

## 1. What this is

Adds team workspaces to an existing tasks API so several users can share and manage tasks, with per-workspace roles.

## 2. Goals and non-goals

### Goals
- A user can create a workspace and invite members.
- Tasks belong to exactly one workspace; members see and edit that workspace's tasks according to their role.
- Existing personal tasks keep working with no user action.

### Non-goals (v1)
- Cross-workspace task moves, SSO/SAML, audit-log UI, billing.

## 3. Locked architectural decisions

| Decision | Choice | Notes |
|---|---|---|
| Stack | Unchanged: FastAPI, SQLAlchemy, Postgres | Read from the repo; not re-litigated |
| Auth | Unchanged: JWT bearer tokens | Workspace membership is looked up per request, not put in the token |
| Tenancy model | Shared tables with a `workspace_id` column | Row-level filtering in one query helper |
| Roles | `owner`, `member` | Two roles only in v1 |
| Migration of existing tasks | Each user gets an auto-created personal workspace; their tasks move into it | Runs as a reversible Alembic migration |

## 4. Architecture

```
client -> FastAPI -> auth (JWT) -> workspace guard (membership + role) -> task queries (filtered by workspace_id) -> Postgres
```

### Key principles
- Every task query goes through one helper that requires a `workspace_id`; there is no unscoped query path.
- Authorization is decided server-side on every request.

## 5. Data model

```
workspaces(id, name, created_by)
memberships(workspace_id, user_id, role)        -- primary key (workspace_id, user_id)
tasks(id, workspace_id, owner_id, title)        -- owner_id kept as "created by"
```

## 6. Control flow (end-to-end)

Create task: authenticate -> resolve `workspace_id` from the path -> check membership -> insert with that `workspace_id`.

### Failure semantics
Non-members get 404 (not 403) so workspace existence isn't leaked. A request with a missing or invalid token gets 401.

## 7. Security & governance

### Threat actors
Authenticated user probing other workspaces; removed member holding a valid token.

### Controls
- Membership checked on every request (a removed member loses access immediately).
- All task queries scoped by `workspace_id`; covered by tests that try cross-workspace reads and writes.

### Residual risks
Token lifetime does not matter for access (membership is live), but a leaked token still acts as that user until it expires.

## 8. Repo layout

```
app/auth.py, app/models.py   (existing)
app/workspaces.py            (new: routes, membership guard)
migrations/                  (new: personal-workspace backfill)
```

## 9. Phased delivery

### Phase 0 — Foundations
- Models and migration for workspaces and memberships; backfill personal workspaces.

**Exit criteria:** after running the migration on a copy of production-shaped data, every existing task belongs to a workspace and the downgrade restores the original schema; migration tests pass.

### Phase 1 — MVP
- Workspace CRUD, invite and remove members, workspace-scoped task routes with roles.

**Exit criteria:** a test proves user A cannot read, update or delete a task in user B's workspace by any route; owner/member permissions behave as specified; full suite passes.

### Phase 2 — Production
- Pagination, rate limits on invites, operational runbook.

**Exit criteria:** load test of the task list at 10k tasks per workspace stays under the agreed latency budget.

## 10. Open questions

| # | Question | Resolution timeline | Status |
|---|---|---|---|
| 1 | Can an owner leave if they are the last owner? | Before Phase 1 | Open |
| 2 | Invitation by email link or by existing user id only? | Before Phase 1 | Open |

## 11. Decision log

| Date | Decision | Rationale |
|---|---|---|
| 2026-11-02 | Membership looked up per request, not embedded in the JWT | Revocation takes effect immediately; token stays small |
| 2026-11-02 | 404 for non-members | Avoids confirming that a workspace exists |
