#!/usr/bin/env bash
# Scaffold: a failing test caused by an off-by-one in reserve().
set -euo pipefail
cat > inventory.py <<'PY'
def normalize_sku(sku):
    return sku.strip().upper()


def reserve(stock, sku, qty):
    """Reserve qty units of sku. Returns True if reserved."""
    sku = normalize_sku(sku)
    if stock.get(sku, 0) > qty:
        stock[sku] -= qty
        return True
    return False
PY
cat > test_inventory.py <<'PY'
import unittest

from inventory import reserve


class ReserveTests(unittest.TestCase):
    def test_reserve_some(self):
        stock = {"ABC": 10}
        self.assertTrue(reserve(stock, " abc ", 4))
        self.assertEqual(stock["ABC"], 6)

    def test_reserve_exactly_all_remaining(self):
        stock = {"ABC": 3}
        self.assertTrue(reserve(stock, "abc", 3))
        self.assertEqual(stock["ABC"], 0)

    def test_reserve_too_many(self):
        stock = {"ABC": 3}
        self.assertFalse(reserve(stock, "abc", 4))


if __name__ == "__main__":
    unittest.main()
PY
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
