from __future__ import annotations

import argparse
import json
import subprocess
import sys
from collections.abc import Sequence
from pathlib import Path

from logicbox_cli import __version__
from logicbox_cli.errors import ExitCode
from logicbox_cli.manifest import read_manifest
from logicbox_cli.runtime import check_runtime, discover_shen
from logicbox_cli.runs import create_run
from logicbox_cli.stages import (
    StageRequest,
    analyze_request,
    compare_request,
    contract_request,
    execute_stage,
    schema_requests,
)

DEFAULT_TIMEOUT = 30.0


def _add_stage_options(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--shen", type=Path)
    parser.add_argument("--timeout", type=float, default=DEFAULT_TIMEOUT)
    parser.add_argument("--replace", action="store_true")
    parser.add_argument("--trace", action="store_true")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="logicbox")
    parser.add_argument("--version", action="version", version=f"logicbox {__version__}")
    subcommands = parser.add_subparsers(dest="command")
    doctor = subcommands.add_parser("doctor")
    doctor.add_argument("--shen", type=Path)
    schema = subcommands.add_parser("schema")
    _add_stage_options(schema)
    schema.add_argument("--input", type=Path, required=True)
    schema.add_argument("--accepted", type=Path, required=True)
    schema.add_argument("--diagnostics", type=Path, required=True)
    analyze = subcommands.add_parser("analyze")
    _add_stage_options(analyze)
    analyze.add_argument("--input", type=Path, required=True)
    analyze.add_argument("--output", type=Path, required=True)
    compare = subcommands.add_parser("compare")
    _add_stage_options(compare)
    compare.add_argument("--source", type=Path, required=True)
    compare.add_argument("--candidate", type=Path, required=True)
    compare.add_argument("--output", type=Path, required=True)
    contract = subcommands.add_parser("contract")
    _add_stage_options(contract)
    contract.add_argument("--output", type=Path, required=True)
    run = subcommands.add_parser("run")
    run.add_argument("--shen", type=Path)
    run.add_argument("--timeout", type=float, default=DEFAULT_TIMEOUT)
    run.add_argument("--input", type=Path, required=True)
    run.add_argument("--run-dir", type=Path, required=True)
    inspect = subcommands.add_parser("inspect")
    inspect.add_argument("--run-dir", type=Path, required=True)
    return parser


def _trace(result) -> None:
    print(
        f"{result.name}\texit={result.exit_code}"
        f"\telapsed={result.elapsed_seconds:.6f}s",
        file=sys.stderr,
    )
    if result.stdout:
        sys.stderr.buffer.write(result.stdout)
    if result.stderr:
        sys.stderr.buffer.write(result.stderr)


def _run_stages(
    requests: Sequence[StageRequest],
    *,
    trace: bool,
) -> int:
    try:
        for request in requests:
            result = execute_stage(request)
            if trace:
                _trace(result)
            if result.exit_code != 0:
                print(
                    f"{request.name}: Shen exited with {result.exit_code}",
                    file=sys.stderr,
                )
                return int(ExitCode.STAGE)
    except (FileNotFoundError, FileExistsError, IsADirectoryError, PermissionError, ValueError) as error:
        print(str(error), file=sys.stderr)
        return int(ExitCode.FILESYSTEM)
    except (subprocess.TimeoutExpired, RuntimeError, OSError) as error:
        print(str(error), file=sys.stderr)
        return int(ExitCode.STAGE)
    return int(ExitCode.OK)


def _stage_runtime(path: Path | None) -> Path | None:
    runtime = discover_shen(path)
    if runtime is None:
        print(
            "shen-sbcl was not found; pass --shen PATH, set SHEN_SBCL, "
            "or install shen-sbcl on PATH.",
            file=sys.stderr,
        )
    return runtime


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
    if args.command == "inspect":
        try:
            manifest = read_manifest(args.run_dir / "manifest.json")
        except (OSError, ValueError, json.JSONDecodeError) as error:
            print(str(error), file=sys.stderr)
            return int(ExitCode.FILESYSTEM)
        print(json.dumps(manifest, indent=2, sort_keys=True))
        return int(ExitCode.OK)
    runtime = _stage_runtime(args.shen)
    if runtime is None:
        return int(ExitCode.RUNTIME)
    if args.timeout <= 0:
        print("--timeout must be greater than zero", file=sys.stderr)
        return int(ExitCode.USAGE)
    if args.command == "run":
        try:
            run_dir = create_run(
                args.input,
                args.run_dir,
                runtime,
                args.timeout,
            )
        except (FileNotFoundError, FileExistsError, IsADirectoryError, PermissionError, ValueError) as error:
            print(str(error), file=sys.stderr)
            return int(ExitCode.FILESYSTEM)
        except (subprocess.TimeoutExpired, RuntimeError, OSError) as error:
            print(str(error), file=sys.stderr)
            return int(ExitCode.STAGE)
        print(run_dir)
        return int(ExitCode.OK)
    if args.command == "schema":
        requests = schema_requests(
            runtime,
            args.input,
            args.accepted,
            args.diagnostics,
            args.timeout,
            replace=args.replace,
        )
    elif args.command == "analyze":
        requests = (
            analyze_request(
                runtime,
                args.input,
                args.output,
                args.timeout,
                replace=args.replace,
            ),
        )
    elif args.command == "compare":
        requests = (
            compare_request(
                runtime,
                args.source,
                args.candidate,
                args.output,
                args.timeout,
                replace=args.replace,
            ),
        )
    elif args.command == "contract":
        requests = (
            contract_request(
                runtime,
                args.output,
                args.timeout,
                replace=args.replace,
            ),
        )
    else:
        return int(ExitCode.INTERNAL)
    return _run_stages(requests, trace=args.trace)


def entrypoint() -> None:
    raise SystemExit(main())
