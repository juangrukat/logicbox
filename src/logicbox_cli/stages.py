from __future__ import annotations

import os
import signal
import shutil
import stat
import subprocess
import tempfile
import time
from collections.abc import Mapping
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from types import MappingProxyType

from logicbox_cli.hashing import sha256_file


@dataclass(frozen=True)
class StageRequest:
    name: str
    runtime: Path
    inputs: Mapping[str, Path]
    load_paths: tuple[Path, ...]
    outputs: Mapping[str, Path]
    timeout_seconds: float
    replace: bool = False

    def __post_init__(self) -> None:
        object.__setattr__(self, "inputs", MappingProxyType(dict(self.inputs)))
        object.__setattr__(self, "outputs", MappingProxyType(dict(self.outputs)))


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
    output_hashes: Mapping[str, str]
    output_sizes: Mapping[str, int]

    def __post_init__(self) -> None:
        object.__setattr__(
            self,
            "output_hashes",
            MappingProxyType(dict(self.output_hashes)),
        )
        object.__setattr__(
            self,
            "output_sizes",
            MappingProxyType(dict(self.output_sizes)),
        )


@dataclass
class _Promotion:
    produced: Path
    destination: Path
    temporary: Path | None = None
    backup: Path | None = None
    existed: bool = False
    promoted_identity: tuple[int, int] | None = None


class RollbackConflictError(RuntimeError):
    """Raised when another writer replaces an output during rollback."""


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


def _exists(path: Path) -> bool:
    return path.exists() or path.is_symlink()


def _same_file(left: Path, right: Path) -> bool:
    try:
        if left.resolve(strict=False) == right.resolve(strict=False):
            return True
    except OSError:
        pass
    try:
        return left.samefile(right)
    except OSError:
        return False


def _validate_destinations(request: StageRequest) -> None:
    input_paths = tuple(request.inputs.values())
    destinations = tuple(request.outputs.values())
    for destination in destinations:
        for source in input_paths:
            if _same_file(destination, source):
                raise ValueError(
                    f"output destination aliases input: {destination}"
                )
        if _exists(destination) and not request.replace:
            raise FileExistsError(
                f"destination already exists: {destination}"
            )
        if _exists(destination) and not _is_regular_file(destination):
            raise ValueError(
                f"existing destination is not a regular file: {destination}"
            )

    for index, destination in enumerate(destinations):
        for other in destinations[index + 1 :]:
            if _same_file(destination, other):
                raise ValueError(
                    f"output destinations alias each other: {destination}"
                )


def _secure_copy(
    source: Path,
    destination: Path,
    *,
    suffix: str,
) -> Path:
    destination.parent.mkdir(parents=True, exist_ok=True)
    descriptor, raw_path = tempfile.mkstemp(
        prefix=f".{destination.name}.",
        suffix=suffix,
        dir=destination.parent,
    )
    temporary = Path(raw_path)
    try:
        with source.open("rb") as input_stream:
            with os.fdopen(descriptor, "wb") as output_stream:
                descriptor = -1
                shutil.copyfileobj(input_stream, output_stream)
                output_stream.flush()
                os.fsync(output_stream.fileno())
        return temporary
    except BaseException:
        if descriptor >= 0:
            os.close(descriptor)
        temporary.unlink(missing_ok=True)
        raise


def _fsync_directories(paths: set[Path]) -> None:
    flags = os.O_RDONLY | getattr(os, "O_DIRECTORY", 0)
    for path in sorted(paths, key=str):
        descriptor = os.open(path, flags)
        try:
            os.fsync(descriptor)
        finally:
            os.close(descriptor)


def _cleanup(paths: list[Path]) -> None:
    for path in paths:
        path.unlink(missing_ok=True)


def _file_identity(path: Path) -> tuple[int, int] | None:
    try:
        metadata = path.lstat()
    except FileNotFoundError:
        return None
    return metadata.st_dev, metadata.st_ino


def _promote_outputs(promotions: list[_Promotion], replace: bool) -> None:
    parents = {item.destination.parent for item in promotions}
    promoted: list[_Promotion] = []
    rollback_failed: list[Path] = []
    rollback_conflicts: list[_Promotion] = []
    committed = False

    try:
        for item in promotions:
            item.temporary = _secure_copy(
                item.produced,
                item.destination,
                suffix=".tmp",
            )

        if replace:
            for item in promotions:
                item.existed = _exists(item.destination)
                if item.existed:
                    item.backup = _secure_copy(
                        item.destination,
                        item.destination,
                        suffix=".bak",
                    )

        for item in promotions:
            assert item.temporary is not None
            item.promoted_identity = _file_identity(item.temporary)
            if replace:
                os.replace(item.temporary, item.destination)
                item.temporary = None
                promoted.append(item)
            else:
                os.link(
                    item.temporary,
                    item.destination,
                    follow_symlinks=False,
                )
                promoted.append(item)
                item.temporary.unlink()
                item.temporary = None

        _fsync_directories(parents)
        committed = True
    except BaseException as error:
        for item in reversed(promoted):
            if _file_identity(item.destination) != item.promoted_identity:
                rollback_conflicts.append(item)
                if item.backup is not None:
                    rollback_failed.append(item.backup)
                continue
            try:
                if item.existed:
                    assert item.backup is not None
                    os.replace(item.backup, item.destination)
                    item.backup = None
                else:
                    item.destination.unlink(missing_ok=True)
            except OSError:
                if item.backup is not None:
                    rollback_failed.append(item.backup)
        _fsync_directories(parents)
        if rollback_conflicts:
            details = ", ".join(
                (
                    f"{item.destination}"
                    + (
                        f" (original retained at {item.backup})"
                        if item.backup is not None
                        else ""
                    )
                )
                for item in rollback_conflicts
            )
            raise RollbackConflictError(
                f"rollback conflict: destination changed by another writer: {details}"
            ) from error
        raise
    finally:
        temporary_paths = [
            item.temporary
            for item in promotions
            if item.temporary is not None
        ]
        backup_paths = [
            item.backup
            for item in promotions
            if item.backup is not None
            and (committed or item.backup not in rollback_failed)
        ]
        _cleanup(temporary_paths)
        _cleanup(backup_paths)
        if parents:
            _fsync_directories(parents)


def _communicate(
    command: list[str],
    *,
    cwd: Path,
    timeout: float,
) -> tuple[int, bytes, bytes]:
    process = subprocess.Popen(
        command,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=os.name == "posix",
    )
    try:
        stdout, stderr = process.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        if os.name == "posix":
            try:
                os.killpg(process.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        else:
            process.kill()
        stdout, stderr = process.communicate()
        raise subprocess.TimeoutExpired(
            command,
            timeout,
            output=stdout,
            stderr=stderr,
        )
    return process.returncode, stdout, stderr


def execute_stage(request: StageRequest) -> StageResult:
    _validate_destinations(request)
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

        returncode, stdout, stderr = _communicate(
            command,
            cwd=stage_dir,
            timeout=request.timeout_seconds,
        )

        if returncode == 0:
            produced_outputs = {
                stage_name: _stage_path(stage_dir, stage_name)
                for stage_name in request.outputs
            }
            for stage_name, produced in produced_outputs.items():
                if not _is_regular_file(produced):
                    raise RuntimeError(
                        f"{request.name} did not produce {stage_name}"
                    )

            promotions = [
                _Promotion(produced_outputs[stage_name], destination)
                for stage_name, destination in request.outputs.items()
            ]
            _promote_outputs(promotions, request.replace)
            for stage_name, destination in request.outputs.items():
                output_hashes[stage_name] = sha256_file(destination)
                output_sizes[stage_name] = destination.stat().st_size

    finished_at = datetime.now(timezone.utc).isoformat()
    return StageResult(
        name=request.name,
        exit_code=returncode,
        elapsed_seconds=time.monotonic() - started,
        started_at=started_at,
        finished_at=finished_at,
        load_paths=resolved_load_paths,
        termination_reason="exited",
        stdout=stdout,
        stderr=stderr,
        output_hashes=output_hashes,
        output_sizes=output_sizes,
    )
