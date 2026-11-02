#!/usr/bin/env bash
set -euo pipefail
mkdir -p .claude/plans
cat > DESIGN.md <<'MD'
# Notes app
## Phases
### Phase 1: Storage
Exit criteria: `python3 -m unittest` passes and notes persist to disk.
### Phase 2: Search
Exit criteria: full-text search over notes.
MD
printf '# Notes\nTests: python3 -m unittest\nCurrent phase: 1\n' > CLAUDE.md
cat > store.py <<'PY'
import json


def save(path, notes):
    with open(path, "w") as f:
        json.dump(notes, f)


def load(path):
    with open(path) as f:
        return json.load(f)
PY
cat > test_store.py <<'PY'
import os
import tempfile
import unittest

from store import load, save


class StoreTests(unittest.TestCase):
    def test_round_trip(self):
        with tempfile.TemporaryDirectory() as d:
            p = os.path.join(d, "n.json")
            save(p, ["a", "b"])
            self.assertEqual(load(p), ["a", "b"])


if __name__ == "__main__":
    unittest.main()
PY
printf '# Phase 1 plan\n- [x] save\n- [x] load\n' > .claude/plans/phase1.md
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "Implement storage"
