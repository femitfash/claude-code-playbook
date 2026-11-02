#!/usr/bin/env bash
set -euo pipefail
cat > stats.py <<'PY'
def average(values):
    return sum(values) / len(values)


def spread(values):
    return max(values) - min(values)
PY
cat > test_stats.py <<'PY'
import unittest

from stats import average, spread


class StatsTests(unittest.TestCase):
    def test_average(self):
        self.assertEqual(average([2, 4]), 3.0)

    def test_spread(self):
        self.assertEqual(spread([1, 9, 4]), 8)


if __name__ == "__main__":
    unittest.main()
PY
printf 'Tests: python3 -m unittest\n' > README.md
git init -q && git add -A && git -c user.name=eval -c user.email=eval@example.com commit -q -m "initial"
