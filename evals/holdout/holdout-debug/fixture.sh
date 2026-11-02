#!/usr/bin/env bash
set -euo pipefail
cat > paginate.py <<'PY'
"""Pages are 1-indexed: page 1 is the first page."""


def paginate(items, page, size):
    start = page * size
    return items[start:start + size]


def page_count(total, size):
    return (total + size - 1) // size
PY
cat > test_paginate.py <<'PY'
import unittest

from paginate import page_count, paginate


class PaginateTests(unittest.TestCase):
    def test_first_page(self):
        self.assertEqual(paginate(list(range(10)), 1, 3), [0, 1, 2])

    def test_page_count(self):
        self.assertEqual(page_count(10, 3), 4)

    def test_beyond_last_page_is_empty(self):
        self.assertEqual(paginate(list(range(10)), 5, 3), [])


if __name__ == "__main__":
    unittest.main()
PY
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
