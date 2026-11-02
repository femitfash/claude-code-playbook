#!/usr/bin/env bash
# Scaffold: only a filled-in DESIGN.md.
set -euo pipefail
cat > DESIGN.md <<'MD'
# Tally: Design Document

**Status:** Draft v0.1

## 1. What this is
A command-line tool that totals expenses from CSV files.

## 2. Goals and non-goals
### Goals
- Read one or more CSV files and print totals per category.
### Non-goals (v1)
- No GUI, no network access.

## 3. Locked architectural decisions
| Decision | Choice | Notes |
|---|---|---|
| Stack | Python 3.12, standard library only | No third-party packages |
| Test stack | unittest | Run with `python3 -m unittest` |
| Lint | `python3 -m pyflakes .` | |

## 7. Security & governance
Hard constraints:
- The tool never writes outside its output file argument.
- The tool never makes network calls.

## 9. Phased delivery
### Phase 0: Foundations
- Project skeleton, CSV reader, one passing test.
**Exit criteria:** `python3 -m unittest` passes and `tally sample.csv` prints a total.
MD
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "Add design doc"
