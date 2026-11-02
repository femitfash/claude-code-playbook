#!/usr/bin/env bash
set -euo pipefail
mkdir -p .claude/plans
cat > textutil.py <<'PY'
def old_title(s):
    r = ""
    for i in range(len(s)):
        if i == 0 or s[i - 1] == " ":
            r = r + s[i].upper()
        else:
            r = r + s[i]
    return r
PY
cat > test_textutil.py <<'PY'
import unittest

from textutil import old_title


class OldTitleTests(unittest.TestCase):
    def test_title(self):
        self.assertEqual(old_title("hello world"), "Hello World")


if __name__ == "__main__":
    unittest.main()
PY
cat > .claude/plans/add-slugify.md <<'MD'
# Plan: add slugify

Phase scope: Phase 0.

Files to modify:
- textutil.py: add `slugify(title)`: lowercase the text, strip leading and trailing whitespace, and replace each run of whitespace with a single hyphen.
- test_textutil.py: add tests for lowercasing, stripping and collapsing whitespace.

Verification: `python3 -m unittest`
Exit criterion: the new tests and the existing test pass.
MD
printf '# Text utils\nTests: python3 -m unittest\n' > CLAUDE.md
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
