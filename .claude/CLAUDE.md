# claude-code-playbook

A Claude Code plugin (`playbook`) plus templates. See README.md.

- Skills live in `skills/<name>/SKILL.md`; hooks in `hooks/`; manifests in `.claude-plugin/`.
- After any change run `claude plugin validate --strict .` and fix everything it reports.
- Test hooks by piping sample JSON into them (see `hooks/verify-on-stop.sh` header).
- Prefer bundled commands (`/code-review`, `/security-review`, `/plan`) over re-implementing them.
- Do not hard-code model version names; use aliases (`opus`, `sonnet`, `opusplan`).
- Record user-visible changes in `docs/MIGRATION.md`.
