from __future__ import annotations

import argparse
import sys
from collections.abc import Sequence
from pathlib import Path

from logicbox_cli import __version__
from logicbox_cli.errors import ExitCode
from logicbox_cli.runtime import check_runtime, discover_shen


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="logicbox")
    parser.add_argument("--version", action="version", version=f"logicbox {__version__}")
    subcommands = parser.add_subparsers(dest="command")
    doctor = subcommands.add_parser("doctor")
    doctor.add_argument("--shen", type=Path)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    try:
        args = parser.parse_args(argv)
    except SystemExit as error:
        return int(error.code)

    if args.command is None:
        parser.print_usage(sys.stderr)
        return int(ExitCode.USAGE)
    if args.command == "doctor":
        check = check_runtime(discover_shen(args.shen))
        stream = sys.stdout if check.ok else sys.stderr
        state = "ok" if check.ok else "fail"
        print(f"{check.check_id}\t{state}\t{check.detail}", file=stream)
        if check.remediation:
            print(check.remediation, file=sys.stderr)
        return int(ExitCode.OK if check.ok else ExitCode.RUNTIME)
    return int(ExitCode.OK)


def entrypoint() -> None:
    raise SystemExit(main())
