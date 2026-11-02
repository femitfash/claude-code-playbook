"""Hidden acceptance tests for holdout-quick-fix (never copied into the fixture)."""
import sys
import unittest

sys.path.insert(0, ".")

from stats import average, spread  # noqa: E402


class HiddenStatsTests(unittest.TestCase):
    def test_empty_is_zero(self):
        self.assertEqual(average([]), 0.0)

    def test_single(self):
        self.assertEqual(average([5]), 5.0)

    def test_pair(self):
        self.assertEqual(average([2, 4]), 3.0)

    def test_negatives(self):
        self.assertEqual(average([-1, 1]), 0.0)

    def test_spread_unchanged(self):
        self.assertEqual(spread([1, 9, 4]), 8)


if __name__ == "__main__":
    unittest.main()
