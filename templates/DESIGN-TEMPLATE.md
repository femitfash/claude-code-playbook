# [Product Name] — Design Document

**Status:** Draft v0.1
**Last updated:** YYYY-MM-DD
**Owner:** [Name]

---

## 1. What this is

[1-2 sentences: what the product does and who it serves.]

---

## 2. Goals and non-goals

### Goals
- [Goal 1]
- [Goal 2]
- [Goal 3]

### Non-goals (v1)
- [Explicitly out of scope item 1]
- [Explicitly out of scope item 2]

---

## 3. Locked architectural decisions

| Decision | Choice | Notes |
|---|---|---|
| Execution model | | |
| Data model | | |
| Deployment | | |
| State model | | |
| Auth | | |
| Stack | | |
| [Add rows as needed] | | |

---

## 4. Architecture

```
[ASCII diagram of system components and data flow]
```

### Key principles
- [Principle 1]
- [Principle 2]

---

## 5. Data model

[Canonical shape of the core entity — YAML, JSON, or TypeScript type. Include comments explaining non-obvious fields.]

```yaml
# Example
id: example-entity
version: 1
# ...
```

---

## 6. Control flow (end-to-end)

```
[ASCII sequence diagram of the primary use case]
```

### Failure semantics
- [What happens when X fails]
- [What happens when Y fails]

---

## 7. Security & governance

> **Before filling this section out:** invoke the `security-grill-me` skill. It interrogates your threat model across 8 domains — threat actors, trust boundaries, data classification, authentication, authorization, input/injection, secrets, and audit — and produces a threat model summary you can paste directly here.

### Threat actors

| Actor | Goal if malicious | Mitigation |
|---|---|---|
| Unauthenticated external | | |
| Authenticated user (cross-tenant) | | |
| Compromised dependency | | |
| Insider / privilege escalation | | |

### Controls

| Concern | Mechanism |
|---|---|
| User auth | |
| Authorization (route + data layer) | |
| Tenant isolation (query-level enforcement) | |
| Secret storage | |
| Audit log (append-only, tamper-evident) | |
| Input validation boundaries | |
| [Add rows as needed] | |

### Residual risks

- [Risk 1 — known, accepted, reason]
- [Risk 2 — known, tracked in open questions]

---

## 8. Repo layout

```
project-name/
├── [directory structure]
```

---

## 9. Phased delivery

### Phase 0 — Foundations
- [Deliverable 1]
- [Deliverable 2]

**Exit criteria:** [Concrete, testable statement of what "done" means]

### Phase 1 — MVP
- [Deliverable 1]
- [Deliverable 2]

**Exit criteria:** [Concrete, testable]

### Phase 2 — Production
- [Deliverable 1]

**Exit criteria:** [Concrete, testable]

---

## 10. Open questions

| # | Question | Resolution timeline | Status |
|---|---|---|---|
| 1 | | Before Phase 0 | Open |
| 2 | | Before Phase 1 | Open |

---

## 11. Decision log

| Date | Decision | Rationale |
|---|---|---|
| YYYY-MM-DD | | |
