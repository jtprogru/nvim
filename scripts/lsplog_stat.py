#!/usr/bin/env python3
"""Offline analysis of Neovim's LSP log (~/.local/state/nvim/lsp.log).

Everything a language server writes to stderr lands there, tagged with the
client name and a timestamp. That makes the log a free, always-on record of what
the servers were doing — including the days you were not profiling.

    scripts/lsplog_stat.py                    # whole log
    scripts/lsplog_stat.py --since 7d         # last week
    scripts/lsplog_stat.py --client ltex-ls-plus --top 20

Timestamps in the log have 1-second resolution, so latencies are lower bounds:
"0s" means "under a second", not "instant".
"""

from __future__ import annotations

import argparse
import collections
import datetime as dt
import os
import re
import statistics
import sys

LOG_DEFAULT = os.path.expanduser("~/.local/state/nvim/lsp.log")

LINE = re.compile(
    r"^\[(?P<level>\w+)\]\[(?P<ts>\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)\]"
    r".*?\"rpc\"\s+\"(?P<client>[^\"]+)\"\s+\"(?P<stream>\w+)\"\s+\"(?P<body>.*)\"\s*$"
)
START = re.compile(r"^\[START\]\[(?P<ts>\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)\]")
# ltex-ls / any java.util.logging server: "<class> <method>\nLEVEL: message"
JUL = re.compile(r"([\w.$]+) (\w+)\\n(SEVERE|WARNING|INFO|CONFIG|FINE|FINER|FINEST): ")


UNITS = {"s": "seconds", "m": "minutes", "h": "hours", "d": "days", "w": "weeks"}


def parse_since(s: str) -> dt.timedelta:
    m = re.fullmatch(r"(\d+)([smhdw])", s)
    if not m:
        raise argparse.ArgumentTypeError("use e.g. 30m, 12h, 7d, 2w")
    return dt.timedelta(**{UNITS[m.group(2)]: int(m.group(1))})


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("log", nargs="?", default=LOG_DEFAULT)
    ap.add_argument("--since", type=parse_since, help="only lines newer than e.g. 7d")
    ap.add_argument("--client", help="restrict to one client name")
    ap.add_argument("--top", type=int, default=10)
    args = ap.parse_args()

    if not os.path.exists(args.log):
        print(f"no such log: {args.log}", file=sys.stderr)
        return 1

    cutoff = dt.datetime.now() - args.since if args.since else None
    size = os.path.getsize(args.log)

    sessions = 0
    by_client: dict[str, list[tuple[dt.datetime, str]]] = collections.defaultdict(list)
    bytes_by_client: collections.Counter[str] = collections.Counter()

    with open(args.log, encoding="utf-8", errors="replace") as fh:
        for raw in fh:
            if START.match(raw):
                sessions += 1
                continue
            m = LINE.match(raw.rstrip("\n"))
            if not m:
                continue
            ts = dt.datetime.strptime(m.group("ts"), "%Y-%m-%d %H:%M:%S")
            if cutoff and ts < cutoff:
                continue
            client = m.group("client")
            if args.client and client != args.client:
                continue
            by_client[client].append((ts, m.group("body")))
            bytes_by_client[client] += len(raw)

    print(f"log: {args.log}  ({size / 1e6:.1f} MB, {sessions} nvim sessions)")
    if cutoff:
        print(f"window: since {cutoff:%Y-%m-%d %H:%M}")
    if not by_client:
        print("\nnothing matched — servers only appear here when they write to stderr.")
        return 0

    print("\nSTDERR VOLUME PER CLIENT")
    print(f"  {'lines':>8} {'KiB':>9}  client")
    for client, n in sorted(bytes_by_client.items(), key=lambda kv: -kv[1]):
        print(f"  {len(by_client[client]):8d} {n / 1024:9.0f}  {client}")

    for client, events in sorted(by_client.items(), key=lambda kv: -len(kv[1])):
        print(f"\n{'=' * 60}\n{client}  ({len(events)} stderr lines)")
        report_client(events, args.top)

    return 0


def report_client(events: list[tuple[dt.datetime, str]], top: int) -> None:
    kinds: collections.Counter[str] = collections.Counter()
    levels: collections.Counter[str] = collections.Counter()
    for _, body in events:
        m = JUL.search(body)
        if m:
            kinds[f"{m.group(1).rsplit('.', 1)[-1]}.{m.group(2)}"] += 1
            levels[m.group(3)] += 1
        else:
            kinds[body[:48]] += 1

    print("\n  message kinds")
    for k, v in kinds.most_common(top):
        print(f"    {v:7d}  {k}")
    if levels:
        print("  log levels: " + ", ".join(f"{k}={v}" for k, v in levels.most_common()))

    # ltex-ls in particular: a check starts with logTextToBeChecked and ends
    # with checkAnnotatedTextFragment*. Pair them up to get a check duration.
    pending = None
    durations: list[float] = []
    langs: collections.Counter[str] = collections.Counter()
    for ts, body in events:
        if "logTextToBeChecked" in body:
            pending = ts
            lm = re.search(r"language '([\w-]+)'", body)
            langs[lm.group(1) if lm else "?"] += 1
        elif "checkAnnotatedTextFragment" in body and pending is not None:
            durations.append((ts - pending).total_seconds())
            pending = None

    if durations:
        s = sorted(durations)
        print(f"\n  full-document checks: {len(s)}  languages: {dict(langs)}")
        print(f"    p50={statistics.median(s):.0f}s  "
              f"p90={s[int(0.9 * len(s))]:.0f}s  max={max(s):.0f}s  "
              f"total={sum(s):.0f}s of server CPU")

    # Lifecycle accounting: a clean exit is initialize -> shutdown -> exit.
    life = collections.Counter()
    for _, body in events:
        for word in ("initialize", "shutdown", "exit"):
            if re.search(rf"\.\w+ {word}\\n", body):
                life[word] += 1
    if life:
        print(f"\n  lifecycle: initialize={life['initialize']} "
              f"shutdown={life['shutdown']} exit={life['exit']}")
        leaked = life["shutdown"] - life["exit"]
        if leaked > 0:
            print(f"    !! {leaked} shutdown(s) never reached exit — "
                  f"server process outlived nvim or was killed")

    # Storms: how many server-side checks happened in the busiest minutes.
    per_min: collections.Counter[dt.datetime] = collections.Counter()
    for ts, body in events:
        if "logTextToBeChecked" in body or "didChange" in body:
            per_min[ts.replace(second=0)] += 1
    if per_min:
        print("\n  busiest minutes (checks/min)")
        for minute, n in per_min.most_common(min(top, 5)):
            print(f"    {minute:%Y-%m-%d %H:%M}  {n}")


if __name__ == "__main__":
    raise SystemExit(main())
