#!/usr/bin/env bash
set -euo pipefail
cat > DESIGN.md <<'MD'
# Relay: Design Document

**Status:** Draft v0.1

## 1. What this is
A small HTTP service that forwards webhooks to configured destinations.

## 2. Goals and non-goals
### Goals
- Accept a webhook and forward it to a destination URL with retries.
### Non-goals (v1)
- No dashboard, no persistent queue.

## 3. Locked architectural decisions
| Decision | Choice | Notes |
|---|---|---|
| Stack | Node 22, TypeScript (strict) | |
| Test stack | Vitest | Run with `npm test` |
| Lint | ESLint | Run with `npm run lint` |
| Typecheck | `npm run typecheck` | |

## 7. Security & governance
Hard constraints:
- Never log request bodies.
- Never use the `any` type.

## 9. Phased delivery
### Phase 0: Foundations
- Project skeleton, health endpoint, one passing test.
**Exit criteria:** `npm test` passes and `GET /health` returns 200.
MD
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "Add design doc"
