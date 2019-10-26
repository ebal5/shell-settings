#!/usr/bin/env python3


import re
import sys
import argparse
import os.path


class NumParser():
    def __init__(self, *, debug=False):
        self.debug = debug

    def parse(target: str, max=60):
        units = [target] if not self.is_list(target) else target.split(",")

    def parse_dist(unit: str):
        pass

    def is_list(maybe: str):
        return maybe.find(",") != -1

    def is_range(maybe: str):
        return maybe.find("-") != -1

    def is_dist(maybe: str):
        return maybe.find("/") != -1


def parse_line(line: str):
    seps = line.split(" ")
    minute = seps[0]
    hour = seps[1]
    day = seps[2]
    month = seps[3]
    dOw = seps[4]
    cmd = "".join(seps[5:])
    pass


def main():
    parser = argparse.ArgumentParser(
        description="Translate crontab to at commands")
    parser.add_argument('crontab',
                        action='store',
                        nargs=None,
                        const=None,
                        default='~/crontab',
                        type=str,
                        choices=None,
                        help='Crontab file.',
                        metavar=None)
    parser.add_argument('--debug',
                        action='store_true',
                        default=False,
                        help=('debug mode.'
                              ' This will print at commands to STDOUT [False]'))
    args = parser.parse_args()
    crontab = args.crontab
    if not (os.path.exists(crontab) and os.path.isfile(crontab)):
        parser.print_help()
        exit(1)
        pass
    with open(crontab) as cf:
        for line in cf.readlines():
            parse_line(line)


if __name__ == "__main__":
    main()
