#!/usr/bin/env bash
set -euo pipefail
cat > reports.py <<'PY'
def build_report(rows):
    totals = {}
    for row in rows:
        totals[row["category"]] = totals.get(row["category"], 0) + row["amount"]
    return [{"category": k, "total": v} for k, v in sorted(totals.items())]
PY
cat > web.py <<'PY'
from reports import build_report


def report_endpoint(request):
    return {"status": 200, "body": build_report(request["rows"])}
PY
cat > test_reports.py <<'PY'
import unittest

from reports import build_report


class ReportTests(unittest.TestCase):
    def test_totals(self):
        rows = [{"category": "a", "amount": 1}, {"category": "a", "amount": 2}]
        self.assertEqual(build_report(rows), [{"category": "a", "total": 3}])


if __name__ == "__main__":
    unittest.main()
PY
printf '# Reports\nTests: python3 -m unittest\n' > CLAUDE.md
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
