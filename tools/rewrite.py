#!/usr/bin/env python3

"""A simple python script template.
"""

import argparse
from functools import reduce
import math
import re
import sys

activity_pattern = re.compile(
    r"activity\((?P<step>[^>v<^]+)(?P<direction>[>v<^])(?P<other>.+)\)"
)
entity_pattern = re.compile(r"(?P<type>\w+)\((?P<name>[^,]+)\)")


def minimum_version_included(minimum, target):
    """Only breaking changes are relevant; therefore, versions might be
    represented via floats as `major.minor` only"""
    return math.isclose(minimum - 0.001, target) or (minimum > target)


def switch_suffix_to_prefix(target, line):
    if minimum_version_included(0.4, target):
        return line

    match = activity_pattern.search(line)
    if match is None:
        return line

    return "activity({direction}{step}{other})".format(
        step=match.group("step"),
        direction=match.group("direction"),
        other=match.group("other"),
    )


def fix_name(target, line):
    if minimum_version_included(0.5, target):
        return line

    match = entity_pattern.search(line)
    if match is None:
        return line

    if match.group("type") != "Boundary":
        return "introduce({name}, {type}({name}))".format(
            type=match.group("type"), name=match.group("name")
        )

    return line


def process_line(target, line):
    converters = [switch_suffix_to_prefix, fix_name]
    result = reduce(lambda acc, rewrite: rewrite(target, acc), converters, line)

    if result.endswith("\n"):
        return result
    else:
        return result + "\n"


def parse_arguments(arguments):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("infile", help="Input file", type=argparse.FileType("r"))
    parser.add_argument(
        "-t", "--target", help="Target version", default=math.inf, type=float
    )
    parser.add_argument("-o", "--outfile", help="Output file", default="stdout")
    args = parser.parse_args(arguments)
    return args


def main(arguments):
    args = parse_arguments(arguments)

    if args.outfile == "stdout":
        output = sys.stdout
    else:
        output = open(args.outfile, "w")

    for line in args.infile.readlines():
        output.write(process_line(args.target, line))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
