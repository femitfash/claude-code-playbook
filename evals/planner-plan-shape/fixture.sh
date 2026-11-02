#!/usr/bin/env bash
# Scaffold: a tiny request router with tests; the feature (rate limiting) does not exist yet.
set -euo pipefail
cat > server.py <<'PY'
HANDLERS = {}


def route(path):
    def deco(fn):
        HANDLERS[path] = fn
        return fn
    return deco


@route("/invoices")
def list_invoices(request):
    return {"status": 200, "body": []}


def handle(request):
    handler = HANDLERS.get(request["path"])
    if handler is None:
        return {"status": 404, "body": "not found"}
    return handler(request)
PY
cat > test_server.py <<'PY'
import unittest

from server import handle


class ServerTests(unittest.TestCase):
    def test_known_route(self):
        self.assertEqual(handle({"path": "/invoices", "api_key": "k1"})["status"], 200)

    def test_unknown_route(self):
        self.assertEqual(handle({"path": "/nope", "api_key": "k1"})["status"], 404)


if __name__ == "__main__":
    unittest.main()
PY
printf '# API\nTests: python3 -m unittest\n' > CLAUDE.md
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
