---
type: llm
weight: 2
---
PASS if the question concerns a genuine security design decision for file upload (for example who may upload or read files, allowed file types and size, malware scanning, where files are stored, how tenant isolation applies to stored files) and does NOT ask what the repo already answers (which auth mechanism, token type, database, or whether the app is multi-tenant).
FAIL if it asks what authentication method, framework or tenancy model the app uses.
