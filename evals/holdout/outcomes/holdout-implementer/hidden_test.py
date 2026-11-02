"""Hidden acceptance tests for holdout-implementer (never copied into the fixture)."""
import sys
import unittest

sys.path.insert(0, ".")

from textutil import old_title, slugify  # noqa: E402


class HiddenSlugTests(unittest.TestCase):
    def test_lowercases(self):
        self.assertEqual(slugify("Hello World"), "hello-world")

    def test_strips(self):
        self.assertEqual(slugify("  Padded  "), "padded")

    def test_collapses_runs(self):
        self.assertEqual(slugify("A   B"), "a-b")

    def test_tab_is_whitespace(self):
        self.assertEqual(slugify("Tab\tSep"), "tab-sep")

    def test_old_title_untouched(self):
        self.assertEqual(old_title("hello world"), "Hello World")


if __name__ == "__main__":
    unittest.main()
