---
type: llm
weight: 2
---
PASS if the question concerns a genuine security design decision for password reset (for example token entropy and expiry, single use, rate limiting, account enumeration, session invalidation after reset) and does NOT ask what the repo already answers (how passwords are hashed, which framework or database is used).
FAIL if it asks how passwords are stored or which framework or database the app uses.
