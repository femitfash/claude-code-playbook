#!/usr/bin/env bash
# Scaffold: a tiny Python repo with passing tests and an uncovered bug.
set -euo pipefail
cat > cart.py <<'PY'
def subtotal(items):
    return sum(i["price"] * i["qty"] for i in items)


def apply_discount(total, percent):
    return total - total * percent / 100


def checkout_total(items, discount_percent=0, tax_rate=0.1):
    total = subtotal(items)
    total = apply_discount(total, discount_percent)
    total = total + total * tax_rate
    return round(total, 2)
PY
cat > test_cart.py <<'PY'
import unittest

from cart import checkout_total, subtotal


class CartTests(unittest.TestCase):
    def test_subtotal(self):
        self.assertEqual(subtotal([{"price": 5, "qty": 2}, {"price": 1, "qty": 3}]), 13)

    def test_checkout_with_tax(self):
        self.assertEqual(checkout_total([{"price": 10, "qty": 1}]), 11.0)

    def test_checkout_with_discount(self):
        self.assertEqual(checkout_total([{"price": 100, "qty": 1}], discount_percent=50), 55.0)


if __name__ == "__main__":
    unittest.main()
PY
printf 'Tests: python3 -m unittest\n' > README.md
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
