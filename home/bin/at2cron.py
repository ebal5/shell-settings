#!/usr/bin/env python3

"""crontab を1日分のatコマンドリストへと変換する

最後に翌日の朝このスクリプトを実行するコマンドも記述?
"""


import re
import sys
import argparse
import os.path
import datetime
import itertools


compress_space = re.compile(r"[\s\t]+")


class UnitParser():
    def __init__(self, max=60, *, min=0, debug=False):
        self.debug = debug
        self.min = min
        self.max = max

    def parse(self, target: str):
        units = target.split(",")
        if self.debug:
            print(f"parsed units: {units}")
        dists = [self.parse_dist(unit) for unit in units]
        if self.debug:
            print(f"parsed dists: {dists}")
        extracted = [self.extract_range(pair) for pair in dists]
        if self.debug:
            print(f"extracted range: {extracted}")
        filterd = sum([self.filter_pair(pair) for pair in extracted], [])
        if self.debug:
            print(f"filterd: {filterd}")
        return filterd

    def parse_dist(self, unit: str):
        if not self.is_dist(unit):
            return (unit, 1)
        idx = unit.index("/")
        dist = unit[idx+1:]
        if not dist.isdigit():
            raise ValueError(f"{dist} is not consist of digit")
        return (unit[:idx], int(dist))

    def extract_range(self, pair):
        (maybe, dist) = pair
        if not self.is_range(maybe):
            if not maybe.isdigit():
                return (list(range(self.min, self.max)), dist)
            else:
                return ([int(maybe)], dist)
        idx = maybe.index("-")
        start = int(maybe[:idx])
        end = self.max if maybe.endswith("-") else int(maybe[idx+1:])+1
        return (list(range(start, end)), dist)

    def filter_pair(self, pair):
        (lst, dist) = pair
        return [x for x in range(lst[0], lst[-1]+1, dist)]

    def is_range(self, maybe: str):
        return "-" in maybe

    def is_dist(self, maybe: str):
        return "/" in maybe


class CrontabParser():
    def __init__(self, *, debug=False):
        self.debug = debug
        self.min_psr = UnitParser(60, debug=self.debug)
        self.hur_psr = UnitParser(24, debug=self.debug)
        self.dat_psr = UnitParser(min=1, max=32, debug=self.debug)
        self.mth_psr = UnitParser(min=1, max=13, debug=self.debug)
        self.dow_psr = UnitParser(min=0, max=7, debug=self.debug)
        # TODO: 曜日だけ特別なパーサ作成するべき？(Sunなどの表記に対応するため)

    def parse(self, stream, filename=None):
        cmdls = []
        for line in stream.readlines():
            cline = compress_space.sub(" ", line)
            if cline[0] == " ":
                cline = cline[1:]
            if len(cline) > 0 and (cline[0].isdigit() or cline[0] == "*"):
                obj = self.parse_line(cline)
                cmds = self.make_cmdls(obj)
                cmdls.extend(cmds)
                if self.debug:
                    print()
        if filename:
            myself = os.path.abspath(__file__)
            cmdls.append(["echo", "python3", myself, filename, "|",
                          "at", "0:00 +1 days"])
        if self.debug:
            for cmd in cmdls:
                print(cmd)
        return cmdls

    def parse_line(self, line: str):
        seps = line.split(" ")
        obj = {
            "minute": self.min_psr.parse(seps[0]),
            "hour": self.hur_psr.parse(seps[1]),
            "day": self.dat_psr.parse(seps[2]),
            "month": self.mth_psr.parse(seps[3]),
            "dOw": self.dow_psr.parse(seps[4]),
            "cmd": " ".join(seps[5:])
        }
        if self.debug:
            print(line)
            for (key, val) in obj.items():
                print(f"{key} = '{val}'")
            pass
        return obj

    def make_cmdls(self, obj):
        today = datetime.date.today()
        day = today.day
        month = today.month
        wday = today.weekday()
        wday = 0 if wday == 6 else wday+1
        if not (wday in obj["dOw"] or
                (day in obj["day"] and month in obj["month"])):
            return []
        if self.debug:
            print(f"this command is target")
            pass
        hmps = itertools.product(obj["hour"], obj["minute"])
        cmdls = [["echo", obj['cmd'], "|", "at", f"{h}:{m:02}"]
                 for (h, m) in hmps]
        return cmdls


def exec_cmds(cmdls):
    import subprocess
    with open(os.path.expanduser('~/at2cron.log'), "a") as logf:
        for cmd in cmdls:
            res = subprocess.Popen(" ".join(cmd),
                                   shell=True,
                                   stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE)
            try:
                res.wait(1)
            except subprocess.TimeoutExpired as e:
                print(f"Error: timed out {res.args}", file=logf)
            if res.returncode != 0:
                print(f"Error: $? = {res.returncode}", file=logf)
                print(f"Error: {res.args}", file=logf)
                print(f"Error: {res.stdout}", file=logf)
                print(f"Error: {res.stderr}", file=logf)
            else:
                print(f"log: {res.args}", file=logf)
                print(f"log: {res.stdout}", file=logf)
                print(f"log: {res.stderr}", file=logf)


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
                              ' will print at commands to STDOUT [False]'))
    args = parser.parse_args()
    crontab = args.crontab
    if not (os.path.exists(crontab) and os.path.isfile(crontab)):
        parser.print_help()
        exit(1)
        pass
    cron_parser = CrontabParser(debug=args.debug)
    with open(crontab) as cf:
        cmdls = cron_parser.parse(cf, crontab)
        exec_cmds(cmdls)


if __name__ == "__main__":
    main()


def test():
    import io
    testtab = """
    5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1
    # 毎月初日の 2:15pm に実行する -- 出力は paul にメールされる
    15 14 1 * *     $HOME/bin/monthly
    # 平日の午後 10 時に実行してジョーを心配させる
    0 22 * * 1-5    mail -s "午後10時だ" joe%ジョー、%%お前の子どもはどこだい?%
    23 0-23/2 * * * echo "毎日 0,2,4..時 23 分に実行する"
    5 4 * * sun     echo "日曜 4 時 5 分に実行する"
    # 日月の10時，22時から24時10分15分に
    10,15 10,22-24 * * sun,mon	echo "some command"
    """
    print(testtab)
    stream = io.StringIO(testtab)
    parser = CrontabParser(debug=True)
    cmdls = parser.parse(stream, "filename")
    for cmd in cmdls:
        print(cmd)
