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
        line = "Person(a, Albert)"
        expected = "introduce(a, Person(Albert))"

        with self.subTest(target=0.4):
            actual = rewriter(0.4, line)
            self.assertEqual(line, actual)

        with self.subTest(target=minimum_version):
            actual = rewriter(minimum_version, line)
            self.assertEqual(expected, actual)

        with self.subTest(target=0.6):
            actual = rewriter(0.6, line)
            self.assertEqual(expected, actual)

    def test_rewrite_named_elements(self):
        """
        Test that named persons will be rewritten as explicitly named persons
        """
        cases = [
            ("Person(Pete)", "introduce(Person(Pete))"),
            ("Person(Sarah, Smart Sarah)", "introduce(Sarah, Person(Smart Sarah))"),
            (
                "Person(Frida, Funny Frida, funny)",
                "introduce(Frida, Person(Funny Frida, funny))",
            ),
            (
                "Person(Hannah, Happy Hannah, happy, real happy)",
                "introduce(Hannah, Person(Happy Hannah, happy, real happy))",
            ),
            (
                "Person(Quentin, Questioning Quentin, $color = blue, $scale = 2)",
                "introduce(Quentin, Person(Questioning Quentin, $color = blue, $scale = 2))",
            ),
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = rewriter(minimum_version, line)
                self.assertEqual(expected, actual)


if __name__ == "__main__":
    unittest.main()
