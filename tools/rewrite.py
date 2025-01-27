#!/usr/bin/env python3

"""A simple python script template.
"""

import argparse
from functools import reduce
import math
import re
import sys

# FIXME The following regex builder functions DO NOT work
def pos_param(param):
    return rf"(?P<{param}>[^,]+)"


def kw_param(param):
    return rf"\${param} = (?P<{param}>[^,]+)"


def positional_parameters(params):
    return ", ?".join([pos_param(x) for x in params])


def optional_parameters(params):
    rev = params[::-1]
    return reduce(lambda acc, name: rf"{pos_param(name)}, (?:{acc})?", rev[1:], pos_param(rev[0]))


def keyword_parameters(params):
    return "|".join([kw_param(x) for x in params])


def parameters(positional, optional=[], keywords=[]):
    return positional_parameters(positional) + optional_parameters(optional) + keyword_parameters(keywords)


activity_pattern = re.compile(
    r"activity\((?P<step>[^>v<^,]+)(?P<direction>[>v<^])(?P<other>.+)\)"
)
entity_pattern = re.compile(r"(?P<type>\w+)\(" + pos_param('name') + "(?:, ?(?P<other>.+))?\)")


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

    return "activity({direction}{step}{other})".format(**match.groupdict())


def fix_name(target, line):
    if minimum_version_included(0.5, target):
        return line

    match = entity_pattern.search(line)
    if match is None:
        return line

    if match.group("type") != "Boundary":
        if match.group("other"):
            return "introduce({name}, {type}({other}))".format(**match.groupdict())
        else:
            return "introduce({type}({name}))".format(**match.groupdict())


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
