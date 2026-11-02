#!/usr/bin/env bash
# Scaffold: Phase 1 in progress, one plan item done, one failing test, Phase 2 waiting.
set -euo pipefail
mkdir -p .claude/plans
cat > DESIGN.md <<'MD'
# Invoicer
## Phases
### Phase 1: Export
Exit criteria: `python3 -m unittest` passes and `export_csv` handles an empty invoice list.
### Phase 2: Payments
Exit criteria: payments recorded against invoices.
## Open questions
1. Which CSV dialect? Open, before Phase 1 closes.
MD
printf '# Invoicer\nTests: python3 -m unittest\nCurrent phase: 1\n' > CLAUDE.md
cat > export.py <<'PY'
def export_csv(invoices):
    lines = ["id,total"]
    for inv in invoices:
        lines.append("%s,%s" % (inv["id"], inv["total"]))
    return "\n".join(lines)
PY
cat > test_export.py <<'PY'
import unittest

from export import export_csv


class ExportTests(unittest.TestCase):
    def test_rows(self):
        self.assertEqual(export_csv([{"id": 1, "total": 5}]), "id,total\n1,5")

    def test_empty_has_header_and_newline(self):
        self.assertEqual(export_csv([]), "id,total\n")


if __name__ == "__main__":
    unittest.main()
PY
cat > .claude/plans/phase1-export.md <<'MD'
# Phase 1 plan
- [x] export_csv for non-empty lists
- [ ] export_csv for an empty list (header plus trailing newline)
MD
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "Add export_csv for non-empty lists"
