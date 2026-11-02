---
type: llm
weight: 3
---
PASS if the final response shows a drafted project CLAUDE.md (or its main content) that includes the exact commands `npm test`, `npm run lint` and `npm run typecheck`, the Phase 0 exit criterion, and the two hard constraints (never log request bodies, never use `any`), and then explicitly asks the user to approve before anything is written.
FAIL if it writes files without approval, omits the commands or the hard constraints, or moves on to later steps without waiting.
