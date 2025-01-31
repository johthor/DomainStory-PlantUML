#!/usr/bin/env python3

"""A simple python script template.
"""
from __future__ import annotations

import argparse
from functools import reduce
import math
import re
import sys


# FIXME The following regex builder functions DO NOT work
def pos_param(param: str):
    return rf"(?P<{param}>\s*[^$,\s][^,]*)"


def kw_param(param: str):
    return rf"\${param} = (?P<{param}>[^,]+)"


def positional_parameters(params: tuple[str, ...]):
    return ", ?".join([pos_param(x) for x in params])


def optional_parameters(params: tuple[str, ...]):
    rev = params[::-1]
    return reduce(lambda acc, name: rf"{pos_param(name)}, (?:{acc})?", rev[1:], pos_param(rev[0]))


def keyword_parameters(params: tuple[str, ...]):
    return "|".join([kw_param(x) for x in params])


def parameters(positional, optional=(), keywords=()):
    return positional_parameters(positional) + optional_parameters(optional) + keyword_parameters(keywords)


indentation_pattern = re.compile(r"(\s*)")

activity_pattern = re.compile(
    r"activity\((?P<step>[^>v<^,]+)(?P<direction>[>v<^])(?P<other>.+)\)"
)

entity_pattern = re.compile(
    r"(?P<type>\w+)\(" + pos_param('name') + "(?:," + pos_param('label') + ")?" + r"(?P<other>(?:,.+)?)\)")


def minimum_version_included(minimum: str, target: list[int]):
    return str_to_version(minimum) > target


def switch_suffix_to_prefix(target, line):
    if minimum_version_included('0.4', target):
        return line

    match = activity_pattern.search(line)
    if match is None:
        return line

    return "activity({direction}{step}{other})".format(**match.groupdict())


def fix_name(target, line):
    if minimum_version_included('0.5', target):
        return line

    match = entity_pattern.search(line)
    if match is None:
        return line

    group_dict = match.groupdict()

    macro_name = match.group("type")
    forbidden_macro_names = ["introduce", "Boundary", "activity", "startActivity", "append", "split", "continue", "customizeStyleProperty"]

    if macro_name not in forbidden_macro_names and not macro_name.startswith("named"):

        if match.group("label"):
            group_dict['label'] = group_dict['label'].lstrip()
            return "introduce({name}, {type}({label}{other}))".format(**group_dict)
        else:
            return "introduce({type}({name}{other}))".format(**group_dict)

    return line


def process_line(target, line):
    if line.startswith("'"):
        return line

    content = line.lstrip()
    indentation_amount = len(line) - len(content)
    if indentation_amount > 1:
        indentation = " " * indentation_amount
    else:
        indentation = ""

    converters = [switch_suffix_to_prefix, fix_name]
    result = reduce(lambda acc, rewrite: rewrite(target, acc), converters, content)

    if result.endswith("\n"):
        return indentation + result
    else:
        return indentation + result + "\n"


def parse_arguments(arguments):
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("infile", help="Input file", type=argparse.FileType("r"))
    parser.add_argument("-t", "--target", help="Target version", default='', type=str_to_version)
    parser.add_argument("-o", "--outfile", help="Output file", default="stdout")
    args = parser.parse_args(arguments)
    return args


def str_to_version(target: str):
    if not target:
        return [math.inf]
    else:
        return [int(component) for component in target.split('.')]


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
