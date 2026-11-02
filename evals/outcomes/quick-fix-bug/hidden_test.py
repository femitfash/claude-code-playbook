"""Hidden acceptance tests for the quick-fix-bug case.

These are never copied into the fixture, so the agent cannot see them. They are
copied into a throwaway copy of the finished workspace by evals/check-outcomes.sh.
"""
import sys
import unittest

sys.path.insert(0, ".")

from cart import checkout_total  # noqa: E402


class HiddenCartTests(unittest.TestCase):
    ITEMS = [{"price": 100, "qty": 1}]

    def test_discount_over_100_is_clamped_to_zero(self):
        self.assertEqual(checkout_total(self.ITEMS, discount_percent=150), 0.0)

    def test_discount_far_over_100_is_clamped_to_zero(self):
        self.assertEqual(checkout_total(self.ITEMS, discount_percent=1000), 0.0)

    def test_discount_exactly_100_is_zero(self):
        self.assertEqual(checkout_total(self.ITEMS, discount_percent=100), 0.0)

    def test_normal_discount_unchanged(self):
        self.assertEqual(checkout_total(self.ITEMS, discount_percent=50), 55.0)

    def test_no_discount_unchanged(self):
        self.assertEqual(checkout_total([{"price": 10, "qty": 1}]), 11.0)

    def test_tax_rate_still_applies(self):
        self.assertEqual(checkout_total(self.ITEMS, discount_percent=0, tax_rate=0.5), 150.0)


if __name__ == "__main__":
    unittest.main()
