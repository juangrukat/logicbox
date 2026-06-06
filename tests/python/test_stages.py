from __future__ import annotations

import hashlib
import subprocess
from datetime import datetime, timezone
from pathlib import Path

import pytest

from logicbox_cli.hashing import sha256_file
from logicbox_cli.stages import StageRequest, execute_stage


OPAQUE_BYTES = b'(set *logicbox-artifact* ["quoted \\"bytes\\""  \xff])\n'


def make_script(path: Path, body: str) -> Path:
    path.write_text("#!/bin/sh\nset -eu\n" + body, encoding="utf-8")
    path.chmod(0o755)
    return path


def request_for(
    tmp_path: Path,
    runtime: Path,
    output: Path,
    *,
    timeout: float = 1,
    load_paths: tuple[Path, ...] | None = None,
    outputs: dict[str, Path] | None = None,
) -> StageRequest:
    source = tmp_path / "source with spaces.shen"
    source.write_bytes(OPAQUE_BYTES)
    return StageRequest(
        name="probe",
        runtime=runtime,
        inputs={"input.shen": source},
        load_paths=load_paths
        or (Path("input.shen"), Path("/engine/emit-accepted.shen")),
        outputs=outputs or {"accepted.shen": output},
        timeout_seconds=timeout,
    )


def test_sha256_file_hashes_binary_file(tmp_path):
    artifact = tmp_path / "opaque.shen"
    payload = OPAQUE_BYTES * 100_000
    artifact.write_bytes(payload)

    assert sha256_file(artifact) == hashlib.sha256(payload).hexdigest()


def test_stage_copies_input_and_promotes_opaque_output(tmp_path, fake_shen):
    source = tmp_path / "source with spaces.shen"
    source.write_bytes(OPAQUE_BYTES)
    output = tmp_path / "output directory" / "result.shen"
    absolute_emitter = Path("/engine path/emit-accepted.shen")
    request = StageRequest(
        name="schema-accepted",
        runtime=fake_shen,
        inputs={"input.shen": source},
        load_paths=(Path("input.shen"), absolute_emitter),
        outputs={"accepted.shen": output},
        timeout_seconds=10,
    )

    result = execute_stage(request)

    assert result.name == "schema-accepted"
    assert result.exit_code == 0
    assert result.termination_reason == "exited"
    assert result.stdout == b"engine stdout\n"
    assert result.stderr == b"engine stderr\n"
    assert output.read_bytes() == OPAQUE_BYTES
    assert source.read_bytes() == OPAQUE_BYTES
    assert result.output_hashes == {
        "accepted.shen": hashlib.sha256(OPAQUE_BYTES).hexdigest()
    }
    assert result.output_sizes == {"accepted.shen": len(OPAQUE_BYTES)}
    assert result.load_paths[0].endswith("/input.shen")
    assert Path(result.load_paths[0]).is_absolute()
    assert result.load_paths[1] == str(absolute_emitter)
    assert datetime.fromisoformat(result.started_at).tzinfo == timezone.utc
    assert datetime.fromisoformat(result.finished_at).tzinfo == timezone.utc
    assert datetime.fromisoformat(result.started_at) <= datetime.fromisoformat(
        result.finished_at
    )
    assert result.elapsed_seconds >= 0
    assert not output.with_name(".result.shen.tmp").exists()


def test_load_paths_are_passed_in_order_and_relative_paths_resolve_in_stage_dir(
    tmp_path,
):
    runtime = make_script(
        tmp_path / "runtime with spaces",
        "printf '%s\\n' \"$@\" > accepted.shen\n",
    )
    output = tmp_path / "result.shen"
    load_paths = (
        Path("first input.shen"),
        Path("/absolute engine/artifact protocol.shen"),
        Path("emit-accepted.shen"),
    )
    request = request_for(
        tmp_path,
        runtime,
        output,
        load_paths=load_paths,
    )

    result = execute_stage(request)
    arguments = output.read_text(encoding="utf-8").splitlines()

    assert arguments[::2] == ["-l", "-l", "-l"]
    assert arguments[1] == result.load_paths[0]
    assert arguments[3] == str(load_paths[1])
    assert arguments[5] == result.load_paths[2]
    assert Path(arguments[1]).is_absolute()
    assert arguments[1].endswith("/first input.shen")
    assert arguments[5].endswith("/emit-accepted.shen")


def test_nonzero_exit_does_not_promote_output(tmp_path):
    runtime = make_script(
        tmp_path / "shen",
        "printf partial > accepted.shen\n"
        "printf failure\n"
        "printf detail >&2\n"
        "exit 7\n",
    )
    output = tmp_path / "result.shen"
    output.write_bytes(b"existing")

    result = execute_stage(request_for(tmp_path, runtime, output))

    assert result.exit_code == 7
    assert result.stdout == b"failure"
    assert result.stderr == b"detail"
    assert output.read_bytes() == b"existing"
    assert result.output_hashes == {}
    assert result.output_sizes == {}


def test_missing_output_raises_without_promoting_any_output(tmp_path):
    runtime = make_script(
        tmp_path / "shen",
        "printf complete > accepted.shen\n",
    )
    accepted = tmp_path / "accepted-result.shen"
    diagnostics = tmp_path / "diagnostics-result.shen"
    outputs = {
        "accepted.shen": accepted,
        "diagnostics.shen": diagnostics,
    }

    with pytest.raises(RuntimeError, match="did not produce diagnostics.shen"):
        execute_stage(
            request_for(
                tmp_path,
                runtime,
                accepted,
                outputs=outputs,
            )
        )

    assert not accepted.exists()
    assert not diagnostics.exists()


def test_output_must_be_a_regular_file(tmp_path):
    runtime = make_script(
        tmp_path / "shen",
        "mkdir accepted.shen\n",
    )
    output = tmp_path / "result.shen"

    with pytest.raises(RuntimeError, match="did not produce accepted.shen"):
        execute_stage(request_for(tmp_path, runtime, output))

    assert not output.exists()


def test_timeout_propagates_and_does_not_promote_output(tmp_path):
    runtime = make_script(
        tmp_path / "shen",
        "printf partial > accepted.shen\n"
        "sleep 2\n",
    )
    output = tmp_path / "result.shen"

    with pytest.raises(subprocess.TimeoutExpired):
        execute_stage(request_for(tmp_path, runtime, output, timeout=0.05))

    assert not output.exists()
