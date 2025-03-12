#!/usr/bin/env python3

"""A simple python script template.
"""
from __future__ import annotations

import argparse
from functools import reduce
import math
import re
import sys


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


def minimum_version_not_reached(minimum: str, target: list[int]):
    return str_to_version(minimum) > target


def join_positional_params(positional_params):
    if len(positional_params) > 0:
        return ', '.join(positional_params)
    else:
        return ''


def join_keyword_params(keyword_params):
    if len(keyword_params) > 0:
        return ', ' + ', '.join([x[0] + " = " + x[1] for x in keyword_params])
    else:
        return ''


activity_direction_pattern = re.compile(
    r"activity\((?P<step>[^>v<^,]+)(?P<direction>[>v<^])(?P<other>.+)\)"
)


def switch_activity_direction_suffix_to_prefix(target, line):
    if minimum_version_not_reached('0.4', target):
        return line

    match = activity_direction_pattern.search(line)
    if match is None:
        return line

    return "activity({direction}{step}{other})".format(**match.groupdict())


entity_pattern = re.compile(
    r"(?P<type>\w+)\((?P<params>[^)]+)\)")


def switch_to_dynamic_naming(target, line):
    if minimum_version_not_reached('0.5', target):
        return line

    match = entity_pattern.search(line)
    if match is None or 'procedure' in line or 'function' in line:
        return line

    macro_name = match.group("type")
    forbidden_macro_names = ["introduce", "Boundary", "activity", "startActivity", "append", "split", "continue",
                             "customizeStyleProperty"]
    if macro_name not in forbidden_macro_names and not macro_name.startswith("named"):
        params = match.group('params').split(',')
        keyword_params = [[v.strip() for v in x.split('=')] for x in params if '=' in x]
        positional_params = [x.strip() for x in params if '=' not in x]

        if macro_name == 'Actor' or macro_name == 'Object':
            return rewrite_abstract_element_macros(macro_name, positional_params, keyword_params)
        else:
            return rewrite_concrete_element_macros(macro_name, positional_params, keyword_params)

    return line


def rewrite_abstract_element_macros(macro_name, positional_params, keyword_params):
    param_name = positional_params[2]
    leading_args = join_positional_params(positional_params[0:2])
    trailing_args = join_positional_params(positional_params[3:])
    kw_args = join_keyword_params(keyword_params)

    if len(positional_params) <= 3:
        return f"introduce({macro_name}({leading_args}, {param_name}{kw_args}))"
    elif trailing_args:
        return f"introduce({param_name}, {macro_name}({leading_args}, {trailing_args}{kw_args}))"
    else:
        return f"introduce({param_name}, {macro_name}({leading_args}, {trailing_args}{kw_args}))"


def rewrite_concrete_element_macros(macro_name, positional_params, keyword_params):
    param_name = positional_params[0]
    remaining_args = join_positional_params(positional_params[1:])
    kw_args = join_keyword_params(keyword_params)

    if len(positional_params) > 1:
        return f"introduce({param_name}, {macro_name}({remaining_args}{kw_args}))"
    else:
        return f"introduce({macro_name}({param_name}{kw_args}))"


def process_line(target, line):
    if line.startswith("'"):
        return line

    content = line.lstrip()
    indentation_amount = len(line) - len(content)
    if indentation_amount > 1:
        indentation = " " * indentation_amount
    else:
        indentation = ""

    converters = [switch_activity_direction_suffix_to_prefix, switch_to_dynamic_naming]
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
