#!/usr/bin/env bash
set -euo pipefail
mkdir -p app
cat > README.md <<'T'
# Accounts service
Flask + SQLite. Users sign in with email and password (bcrypt hashes) and get a session cookie.
T
cat > app/models.py <<'T'
import sqlite3


def init(conn):
    conn.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, email TEXT UNIQUE, password_hash TEXT)")
T
cat > app/auth.py <<'T'
import bcrypt


def check_password(stored_hash: bytes, password: str) -> bool:
    return bcrypt.checkpw(password.encode(), stored_hash)
T
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
