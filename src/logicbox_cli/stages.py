from __future__ import annotations

import shutil
import stat
import subprocess
import tempfile
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from logicbox_cli.hashing import sha256_file


@dataclass(frozen=True)
class StageRequest:
    name: str
    runtime: Path
    inputs: dict[str, Path]
    load_paths: tuple[Path, ...]
    outputs: dict[str, Path]
    timeout_seconds: float


@dataclass(frozen=True)
class StageResult:
    name: str
    exit_code: int
    elapsed_seconds: float
    started_at: str
    finished_at: str
    load_paths: tuple[str, ...]
    termination_reason: str
    stdout: bytes
    stderr: bytes
    output_hashes: dict[str, str]
    output_sizes: dict[str, int]


def _stage_path(stage_dir: Path, name: str) -> Path:
    relative = Path(name)
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError(f"stage artifact name must be relative: {name}")
    return stage_dir / relative


def _is_regular_file(path: Path) -> bool:
    try:
        return stat.S_ISREG(path.lstat().st_mode)
    except OSError:
        return False


def _promote(produced: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary = destination.with_name(f".{destination.name}.tmp")
    try:
        shutil.copyfile(produced, temporary)
        temporary.replace(destination)
    finally:
        temporary.unlink(missing_ok=True)


def execute_stage(request: StageRequest) -> StageResult:
    started_at = datetime.now(timezone.utc).isoformat()
    started = time.monotonic()
    output_hashes: dict[str, str] = {}
    output_sizes: dict[str, int] = {}

    with tempfile.TemporaryDirectory(prefix=f"logicbox-{request.name}-") as raw:
        stage_dir = Path(raw)
        for target_name, source in request.inputs.items():
            target = _stage_path(stage_dir, target_name)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)

        resolved_load_paths = tuple(
            str(path if path.is_absolute() else stage_dir / path)
            for path in request.load_paths
        )
        command = [str(request.runtime)]
        for load_path in resolved_load_paths:
            command.extend(["-l", load_path])

        completed = subprocess.run(
            command,
            cwd=stage_dir,
            capture_output=True,
            timeout=request.timeout_seconds,
            check=False,
        )

        if completed.returncode == 0:
            produced_outputs = {
                stage_name: _stage_path(stage_dir, stage_name)
                for stage_name in request.outputs
            }
            for stage_name, produced in produced_outputs.items():
                if not _is_regular_file(produced):
                    raise RuntimeError(
                        f"{request.name} did not produce {stage_name}"
                    )

            for stage_name, destination in request.outputs.items():
                _promote(produced_outputs[stage_name], destination)
                output_hashes[stage_name] = sha256_file(destination)
                output_sizes[stage_name] = destination.stat().st_size

    finished_at = datetime.now(timezone.utc).isoformat()
    return StageResult(
        name=request.name,
        exit_code=completed.returncode,
        elapsed_seconds=time.monotonic() - started,
        started_at=started_at,
        finished_at=finished_at,
        load_paths=resolved_load_paths,
        termination_reason="exited",
        stdout=completed.stdout,
        stderr=completed.stderr,
        output_hashes=output_hashes,
        output_sizes=output_sizes,
    )
