from __future__ import annotations

import os
import secrets
import shutil
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from logicbox_cli.hashing import sha256_file
from logicbox_cli.manifest import write_manifest
from logicbox_cli.stages import (
    StageResult,
    execute_stage,
    pipeline_findings_request,
    schema_requests,
)


def new_run_id() -> str:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    return f"{stamp}-{secrets.token_hex(4)}"


def copy_exact(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with source.open("rb") as input_stream, destination.open("xb") as output:
        shutil.copyfileobj(input_stream, output)
        output.flush()
        os.fsync(output.fileno())


def save_trace(stage_dir: Path, stdout: bytes, stderr: bytes) -> None:
    stage_dir.mkdir(parents=True, exist_ok=True)
    for name, content in (
        ("engine.stdout", stdout),
        ("engine.stderr", stderr),
    ):
        path = stage_dir / name
        with path.open("xb") as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())


def _stage_metadata(result: StageResult) -> dict[str, Any]:
    return {
        "name": result.name,
        "exit_code": result.exit_code,
        "elapsed_seconds": result.elapsed_seconds,
        "started_at": result.started_at,
        "finished_at": result.finished_at,
        "load_paths": list(result.load_paths),
        "termination_reason": result.termination_reason,
        "outputs": [
            {
                "path": name,
                "sha256": result.output_hashes[name],
                "bytes": result.output_sizes[name],
            }
            for name in result.output_hashes
        ],
    }


def _artifact_metadata(run_dir: Path, relative: str) -> dict[str, Any]:
    path = run_dir / relative
    return {
        "path": relative,
        "sha256": sha256_file(path),
        "bytes": path.stat().st_size,
    }


def create_run(
    source: Path,
    run_root: Path,
    runtime: Path,
    timeout: float,
) -> Path:
    run_root.mkdir(parents=True, exist_ok=True)
    run_id = new_run_id()
    temporary = run_root / f".{run_id}.tmp"
    final = run_root / run_id
    failed = run_root / f".failed-{run_id}"
    temporary.mkdir(exist_ok=False)
    copied_source = temporary / "input/source.shen"
    accepted = temporary / "schema/accepted.shen"
    diagnostics = temporary / "schema/diagnostics.shen"
    findings = temporary / "analysis/findings.shen"
    results: list[StageResult] = []
    try:
        copy_exact(source, copied_source)
        schema_results: list[StageResult] = []
        for request in schema_requests(
            runtime,
            copied_source,
            accepted,
            diagnostics,
            timeout,
        ):
            result = execute_stage(request)
            schema_results.append(result)
            results.append(result)
            if result.exit_code != 0:
                save_trace(
                    temporary / "schema",
                    b"".join(item.stdout for item in schema_results),
                    b"".join(item.stderr for item in schema_results),
                )
                raise RuntimeError(
                    f"{result.name}: Shen exited with {result.exit_code}"
                )
        save_trace(
            temporary / "schema",
            b"".join(result.stdout for result in schema_results),
            b"".join(result.stderr for result in schema_results),
        )

        analysis_result = execute_stage(
            pipeline_findings_request(
                runtime,
                copied_source,
                findings,
                timeout,
            )
        )
        results.append(analysis_result)
        save_trace(
            temporary / "analysis",
            analysis_result.stdout,
            analysis_result.stderr,
        )
        if analysis_result.exit_code != 0:
            raise RuntimeError(
                f"{analysis_result.name}: Shen exited with "
                f"{analysis_result.exit_code}"
            )

        manifest = {
            "format": "logicbox-run-v1",
            "run_id": run_id,
            "status": "completed",
            "runtime": str(runtime),
            "input": _artifact_metadata(temporary, "input/source.shen"),
            "artifacts": [
                _artifact_metadata(temporary, relative)
                for relative in (
                    "schema/accepted.shen",
                    "schema/diagnostics.shen",
                    "analysis/findings.shen",
                )
            ],
            "stages": [_stage_metadata(result) for result in results],
        }
        write_manifest(temporary / "manifest.json", manifest)
        os.rename(temporary, final)
        return final
    except BaseException:
        if temporary.exists():
            os.rename(temporary, failed)
        raise
