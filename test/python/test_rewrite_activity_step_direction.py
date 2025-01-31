import unittest
from rewrite import switch_suffix_to_prefix  # the rewrite function to be tested

minimum_version = 0.4


class TestActivityStepDirection(unittest.TestCase):
    def test_minimum_version(self):
        """
        Test that the target version must be >= 0.4
        """
        line = "activity(1>, A, uses, w)"
        expected = "activity(>1, A, uses, w)"

        with self.subTest(target=0.3):
            actual = switch_suffix_to_prefix(0.3, line)
            self.assertEqual(line, actual)

        with self.subTest(target=minimum_version):
            actual = switch_suffix_to_prefix(minimum_version, line)
            self.assertEqual(expected, actual)

        with self.subTest(target=0.5):
            actual = switch_suffix_to_prefix(0.5, line)
            self.assertEqual(expected, actual)

    def test_rewrite_indicator_up(self):
        """
        Test that the upward direction indicator will be a prefix
        """
        cases = [
            ("activity(_^, A, uses, w)", "activity(^_, A, uses, w)"),
            ("activity(|^, A, uses, w)", "activity(^|, A, uses, w)"),
            ("activity(.^, A, uses, w)", "activity(^., A, uses, w)"),
            ("activity( ^, A, uses, w)", "activity(^ , A, uses, w)"),
            ("activity(^, A, uses, w)", "activity(^, A, uses, w)"),
            ("activity(1^, A, uses, w)", "activity(^1, A, uses, w)"),
            ("activity(=1^, A, uses, w)", "activity(^=1, A, uses, w)"),
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = switch_suffix_to_prefix(minimum_version, line)
                self.assertEqual(expected, actual)

    def test_rewrite_indicator_right(self):
        """
        Test that the right direction indicator will be a prefix
        """
        cases = [
            ("activity(_>, A, uses, w)", "activity(>_, A, uses, w)"),
            ("activity(|>, A, uses, w)", "activity(>|, A, uses, w)"),
            ("activity(.>, A, uses, w)", "activity(>., A, uses, w)"),
            ("activity( >, A, uses, w)", "activity(> , A, uses, w)"),
            ("activity(>, A, uses, w)", "activity(>, A, uses, w)"),
            ("activity(1>, A, uses, w)", "activity(>1, A, uses, w)"),
            ("activity(=1>, A, uses, w)", "activity(>=1, A, uses, w)"),
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = switch_suffix_to_prefix(minimum_version, line)
                self.assertEqual(expected, actual)

    def test_rewrite_indicator_down(self):
        """
        Test that the downward direction indicator will be a prefix
        """
        cases = [
            ("activity(_v, A, uses, w)", "activity(v_, A, uses, w)"),
            ("activity(|v, A, uses, w)", "activity(v|, A, uses, w)"),
            ("activity(.v, A, uses, w)", "activity(v., A, uses, w)"),
            ("activity( v, A, uses, w)", "activity(v , A, uses, w)"),
            ("activity(v, A, uses, w)", "activity(v, A, uses, w)"),
            ("activity(1v, A, uses, w)", "activity(v1, A, uses, w)"),
            ("activity(=1v, A, uses, w)", "activity(v=1, A, uses, w)"),
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = switch_suffix_to_prefix(minimum_version, line)
                self.assertEqual(expected, actual)

    def test_rewrite_indicator_left(self):
        """
        Test that the left direction indicator will be a prefix
        """
        cases = [
            ("activity(_<, A, uses, w)", "activity(<_, A, uses, w)"),
            ("activity(|<, A, uses, w)", "activity(<|, A, uses, w)"),
            ("activity(.<, A, uses, w)", "activity(<., A, uses, w)"),
            ("activity( <, A, uses, w)", "activity(< , A, uses, w)"),
            ("activity(<, A, uses, w)", "activity(<, A, uses, w)"),
            ("activity(1<, A, uses, w)", "activity(<1, A, uses, w)"),
            ("activity(=1<, A, uses, w)", "activity(<=1, A, uses, w)"),
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = switch_suffix_to_prefix(minimum_version, line)
                self.assertEqual(expected, actual)

    def test_rewrite_indicator_special_cases(self):
        """
        Test that the left direction indicator will be a prefix
        """
        cases = [
            ("activity(1, vip, joins, party)", "activity(1, vip, joins, party)")
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = switch_suffix_to_prefix(minimum_version, line)
                self.assertEqual(expected, actual)

    if __name__ == "__main__":
        unittest.main()
