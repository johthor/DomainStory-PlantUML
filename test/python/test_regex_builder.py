import unittest
from rewrite import pos_param, kw_param, positional_parameters, optional_parameters, keyword_parameters


class TestRegexBuilder(unittest.TestCase):
    def test_positional_parameter(self):
        self.assertEqual(r"(?P<name>\s*[^$,\s][^,]*)", pos_param("name"))

    def test_keyword_parameter(self):
        self.assertEqual(r"\$name = (?P<name>[^,]+)", kw_param("name"))

    def test_one_positional(self):
        actual = positional_parameters(["subject"])
        expected = r"(?P<subject>\s*[^$,\s][^,]*)"
        self.assertEqual(expected, actual)

    def test_two_positional(self):
        actual = positional_parameters(["subject", "predicate"])
        expected = r"(?P<subject>\s*[^$,\s][^,]*), ?(?P<predicate>\s*[^$,\s][^,]*)"
        self.assertEqual(expected, actual)

    def test_one_optional(self):
        actual = optional_parameters(["label"])
        expected = r"(?P<label>\s*[^$,\s][^,]*)"
        self.assertEqual(expected, actual)

    # def test_two_optional(self):
    #     actual = optional_parameters(["label", "tag"])
    #     expected = r"?(?P<label>[^,]+?)(?:, ?(?P<tag>[^,]+?))?)?"
    #     self.assertEqual(expected, actual)

    def test_one_keyword(self):
        actual = keyword_parameters(["scale"])
        expected = r"\$scale = (?P<scale>[^,]+)"
        self.assertEqual(expected, actual)

    def test_two_keyword(self):
        actual = keyword_parameters(["scale", "color"])
        expected = r"\$scale = (?P<scale>[^,]+)|\$color = (?P<color>[^,]+)"
        self.assertEqual(expected, actual)


if __name__ == '__main__':
    unittest.main()
