---
description: A feature touching multi-tenant user data. With the plugin, security-grill-me should read the code, then interview one question at a time with a recommended answer, starting from the threat model rather than the implementation.
tags: [security-grill-me]
max_turns: 15
timeout_seconds: 400
allowed_tools: [Read, Glob, Grep, Skill]
---

I'm adding document upload so tenants can attach files to their invoices. Before we build it, work through the security design with me.
