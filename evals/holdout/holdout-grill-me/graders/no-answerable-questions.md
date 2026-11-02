---
type: llm
weight: 2
---
PASS if the question concerns a genuine design decision (for example who is notified, delivery channel and read/unread state, retention, what counts as "paid", idempotency) and does NOT ask what the repo already answers (which framework, which task queue or broker).
FAIL if it asks what web framework, task queue or message broker the app uses.
