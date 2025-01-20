import unittest
import os
import sys

minimum_version = 0.5

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../tools")))
from rewrite import fix_name as rewriter  # the rewrite function to be tested


class TestActivityStepDirection(unittest.TestCase):
    def test_minimum_version(self):
        """
        Test that the target version must be >= 0.5
        """
        line = "Person(Albert)"
        expectation = "introduce(Albert, Person(Albert))"

        with self.subTest(target=0.4):
            actual = rewriter(0.4, line)
            self.assertEqual(actual, line)

        with self.subTest(target=minimum_version):
            actual = rewriter(minimum_version, line)
            self.assertEqual(actual, expectation)

        with self.subTest(target=0.6):
            actual = rewriter(0.6, line)
            self.assertEqual(actual, expectation)

    def test_rewrite_named_entities(self):
        """
        Test that named persons will be rewritten as explicitly named persons
        """
        cases = [
            ("Person(Pete)", "namedPerson(Pete)"),
            ("Person(Sarah, Smart Sarah)", "namedPerson(Sarah, Smart Sarah)"),
            (
                "Person(Frida, Funny Frida, funny)",
                "namedPerson(Frida, Funny Frida, funny)",
            ),
            (
                "Person(Hannah, Happy Hannah, happy, real happy)",
                "namedPerson(Hannah, Happy Hannah, happy, real happy)",
            ),
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = rewriter(minimum_version, line)
                self.assertEqual(actual, expected)


if __name__ == "__main__":
    unittest.main()
