import unittest
from rewrite import switch_to_dynamic_naming  # the rewrite function to be tested

minimum_version = [0, 5]


class TestRewriteElementNames(unittest.TestCase):
    def test_minimum_version(self):
        """
        Test that the target version must be >= 0.5
        """
        line = "Person(a, Albert)"
        expected = "introduce(a, Person(Albert))"

        with self.subTest(target=0.4):
            actual = switch_to_dynamic_naming([0, 4], line)
            self.assertEqual(line, actual)

        with self.subTest(target=0.5):
            actual = switch_to_dynamic_naming(minimum_version, line)
            self.assertEqual(expected, actual)

        with self.subTest(target=0.6):
            actual = switch_to_dynamic_naming([0, 6], line)
            self.assertEqual(expected, actual)

    def test_rewrite_named_elements(self):
        """
        Test that named persons will be explicitly introduced
        """
        cases = [
            ("Person(Pete)", "introduce(Person(Pete))"),
            ("Person($name)", "introduce(Person($name))"),
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
            ("Person(confirmation, $note = default)", "introduce(Person(confirmation, $note = default))")
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = switch_to_dynamic_naming(minimum_version, line)
                self.assertEqual(expected, actual)

    def test_rewrite_element_creation(self):
        """
        Test that named actors and work objects will be explicitly introduced
        """
        cases = [

            ('Actor("Bus", "$ma_bus", BusBus)', 'introduce(Actor("Bus", "$ma_bus", BusBus))'),
            (
                'Actor("Bus", "$ma_bus", foo, $label, $tag, $note, $shape, $scale, $color, $background)',
                'introduce(foo, Actor("Bus", "$ma_bus", $label, $tag, $note, $shape, $scale, $color, $background))'
            ),
            (
                'Object("Customer", "$ma_crown", foo, $label, $tag, $color = red)',
                'introduce(foo, Object("Customer", "$ma_crown", $label, $tag, $color = red))'
            ),
        ]
        for line, expected in cases:
            with self.subTest(line=line, expected=expected):
                actual = switch_to_dynamic_naming(minimum_version, line)
                self.assertEqual(expected, actual)

    def test_other_macros_are_not_rewritten(self):
        """
            Test that the following lines won't be rewritten
        """
        cases = [
            "Boundary(team) {",
            "Boundary(team, Best Team) {",
            "activity(1, person, reads, Document:a document)",
            "introduce(Person(Pete))",
            "introduce(m, Person(Maria))",
            "namedPerson(Pete)",
            "namedPerson(m, Maria)",
            "startActivity(+, Person(A), works on, Document(w))",
            "append(using, Document(v))",
            "split(to, Person(B))",
            "continue(and, Person(C)",
            'customizeStyleProperty("LimeGreen", BackgroundColor, Actor, Person, friendly)',
            '!unquoted procedure Merchant($name, $label = "", $tag = "", $note = "", $shape = $Actor_Shape, $scale = $Actor_IconScale, $color = $Actor_IconColor, $background = "")'
        ]
        for line in cases:
            with self.subTest(line=line):
                actual = switch_to_dynamic_naming(minimum_version, line)
                self.assertEqual(line, actual)


if __name__ == "__main__":
    unittest.main()
