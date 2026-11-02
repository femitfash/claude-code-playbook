#!/usr/bin/env bash
# Scaffold: a base commit, then a branch commit that adds SQL built by string concatenation.
set -euo pipefail
cat > CLAUDE.md <<'MD'
# Users service
Tests: python3 -m unittest

## Hard boundary rules
- Never build SQL by concatenating or formatting user input. Use parameterised queries.
- Every PR names the phase and exit criterion it advances.
MD
cat > db.py <<'PY'
import sqlite3


def connect():
    return sqlite3.connect(":memory:")
PY
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "base"
git checkout -q -b add-lookup
cat > users.py <<'PY'
from db import connect


def find_user(conn, name):
    cur = conn.execute("SELECT id, name FROM users WHERE name = '" + name + "'")
    return cur.fetchone()
PY
cat > test_users.py <<'PY'
import unittest

from db import connect
from users import find_user


class UserTests(unittest.TestCase):
    def setUp(self):
        self.conn = connect()
        self.conn.execute("CREATE TABLE users (id INTEGER, name TEXT)")
        self.conn.execute("INSERT INTO users VALUES (1, 'ada')")

    def test_find_user(self):
        self.assertEqual(find_user(self.conn, "ada"), (1, "ada"))


if __name__ == "__main__":
    unittest.main()
PY
git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "Add user lookup"
