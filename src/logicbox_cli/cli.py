from __future__ import annotations

import argparse
import sys
from collections.abc import Sequence

from logicbox_cli import __version__
from logicbox_cli.errors import ExitCode


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="logicbox")
    parser.add_argument("--version", action="version", version=f"logicbox {__version__}")
    parser.add_subparsers(dest="command")
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
    return int(ExitCode.OK)


def entrypoint() -> None:
    raise SystemExit(main())
