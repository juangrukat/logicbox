from __future__ import annotations

import os
import shutil
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path

_PROBE_SENTINEL = "LOGICBOX-SHEN-RUNTIME-OK"
_RUNTIME_REMEDIATION = "Verify that the configured Shen executable starts."


@dataclass(frozen=True)
class DoctorCheck:
    check_id: str
    ok: bool
    detail: str
    remediation: str = ""


def _usable(path: Path) -> bool:
    try:
        return path.is_file() and os.access(path, os.X_OK)
    except OSError:
        return False


def discover_shen(explicit: Path | None) -> Path | None:
    if explicit is not None:
        try:
            resolved = explicit.expanduser().resolve()
        except OSError:
            return None
        return resolved if _usable(resolved) else None

    candidates: list[Path] = []
    configured = os.environ.get("SHEN_SBCL")
    if configured:
        candidates.append(Path(configured))

    located = shutil.which("shen-sbcl")
    if located:
        candidates.append(Path(located))

    for candidate in candidates:
        try:
            resolved = candidate.expanduser().resolve()
        except OSError:
            continue
        if _usable(resolved):
            return resolved
    return None


def check_runtime(runtime: Path | None) -> DoctorCheck:
    if runtime is None:
        return DoctorCheck(
            "shen.runtime",
            False,
            "shen-sbcl was not found",
            "Pass --shen PATH, set SHEN_SBCL, or install shen-sbcl on PATH.",
        )

    try:
        with tempfile.TemporaryDirectory(prefix="logicbox-doctor-") as temp_dir:
            probe = Path(temp_dir) / "probe.shen"
            probe.write_text(
                f'(output "{_PROBE_SENTINEL}~%")\n',
                encoding="utf-8",
            )
            result = subprocess.run(
                [str(runtime), "-l", str(probe)],
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )
    except subprocess.TimeoutExpired:
        return DoctorCheck(
            "shen.runtime",
            False,
            f"runtime probe timed out: {runtime}",
            _RUNTIME_REMEDIATION,
        )
    except OSError as error:
        return DoctorCheck(
            "shen.runtime",
            False,
            f"runtime probe could not start: {runtime}: {error}",
            _RUNTIME_REMEDIATION,
        )

    if result.returncode != 0:
        return DoctorCheck(
            "shen.runtime",
            False,
            f"runtime probe exited with exit {result.returncode}: {runtime}",
            _RUNTIME_REMEDIATION,
        )
    if not any(
        line.strip() == _PROBE_SENTINEL for line in result.stdout.splitlines()
    ):
        return DoctorCheck(
            "shen.runtime",
            False,
            f"runtime probe produced no sentinel: {runtime}",
            _RUNTIME_REMEDIATION,
        )

    return DoctorCheck("shen.runtime", True, str(runtime))
