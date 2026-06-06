from __future__ import annotations

import hashlib
import os
import stat
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path
from types import MappingProxyType

import pytest

from logicbox_cli.hashing import sha256_file
from logicbox_cli.stages import (
    RollbackConflictError,
    StageRequest,
    StageResult,
    execute_stage,
    resolve_engine_root,
)


OPAQUE_BYTES = b'(set *logicbox-artifact* ["quoted \\"bytes\\""  \xff])\n'


def test_engine_root_contains_authoritative_schema():
    assert (resolve_engine_root() / "fact-schema.shen").is_file()


def make_script(path: Path, body: str) -> Path:
    path.write_text("#!/bin/sh\nset -eu\n" + body, encoding="utf-8")
    path.chmod(0o755)
    return path


def request_for(
    tmp_path: Path,
    runtime: Path,
    output: Path,
    *,
    timeout: float = 5,
    load_paths: tuple[Path, ...] | None = None,
    outputs: dict[str, Path] | None = None,
    replace: bool = False,
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
        replace=replace,
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

    result = execute_stage(request_for(tmp_path, runtime, output))

    assert result.exit_code == 7
    assert result.stdout == b"failure"
    assert result.stderr == b"detail"
    assert not output.exists()
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


def test_existing_destination_is_rejected_before_runtime_starts(tmp_path):
    marker = tmp_path / "runtime-started"
    runtime = make_script(
        tmp_path / "shen",
        f"touch '{marker}'\nprintf updated > accepted.shen\n",
    )
    output = tmp_path / "result.shen"
    output.write_bytes(b"existing")

    with pytest.raises(FileExistsError, match="destination already exists"):
        execute_stage(request_for(tmp_path, runtime, output))

    assert output.read_bytes() == b"existing"
    assert not marker.exists()


def test_destination_created_during_stage_is_not_overwritten(tmp_path):
    output = tmp_path / "result.shen"
    runtime = make_script(
        tmp_path / "shen",
        f"printf concurrent > '{output}'\n"
        "printf generated > accepted.shen\n",
    )

    with pytest.raises(FileExistsError):
        execute_stage(request_for(tmp_path, runtime, output))

    assert output.read_bytes() == b"concurrent"


def test_replace_true_replaces_existing_destination(tmp_path):
    runtime = make_script(
        tmp_path / "shen",
        "printf updated > accepted.shen\n",
    )
    output = tmp_path / "result.shen"
    output.write_bytes(b"existing")

    result = execute_stage(
        request_for(tmp_path, runtime, output, replace=True)
    )

    assert result.exit_code == 0
    assert output.read_bytes() == b"updated"
    assert result.output_sizes == {"accepted.shen": 7}


def test_destination_aliasing_input_is_rejected_before_runtime_starts(tmp_path):
    marker = tmp_path / "runtime-started"
    runtime = make_script(
        tmp_path / "shen",
        f"touch '{marker}'\nprintf updated > accepted.shen\n",
    )
    source = tmp_path / "source.shen"
    source.write_bytes(OPAQUE_BYTES)
    alias = tmp_path / "source-alias.shen"
    alias.symlink_to(source)
    request = StageRequest(
        name="probe",
        runtime=runtime,
        inputs={"input.shen": source},
        load_paths=(Path("/engine/emit-accepted.shen"),),
        outputs={"accepted.shen": alias},
        timeout_seconds=1,
        replace=True,
    )

    with pytest.raises(ValueError, match="aliases input"):
        execute_stage(request)

    assert source.read_bytes() == OPAQUE_BYTES
    assert alias.is_symlink()
    assert not marker.exists()


def test_predictable_symlink_cannot_capture_promoted_bytes(tmp_path):
    runtime = make_script(
        tmp_path / "shen",
        "printf secure > accepted.shen\n",
    )
    output = tmp_path / "result.shen"
    victim = tmp_path / "victim"
    victim.write_bytes(b"untouched")
    predictable = output.with_name(".result.shen.tmp")
    predictable.symlink_to(victim)

    execute_stage(request_for(tmp_path, runtime, output))

    assert output.read_bytes() == b"secure"
    assert victim.read_bytes() == b"untouched"
    assert predictable.is_symlink()


def test_request_and_result_mappings_are_defensive_and_immutable(tmp_path):
    source = tmp_path / "source.shen"
    output = tmp_path / "output.shen"
    inputs = {"input.shen": source}
    outputs = {"accepted.shen": output}
    request = StageRequest(
        "probe",
        tmp_path / "shen",
        inputs,
        (),
        outputs,
        1,
    )
    inputs["other.shen"] = source
    outputs["other.shen"] = output

    assert isinstance(request.inputs, MappingProxyType)
    assert isinstance(request.outputs, MappingProxyType)
    assert tuple(request.inputs) == ("input.shen",)
    assert tuple(request.outputs) == ("accepted.shen",)
    with pytest.raises(TypeError):
        request.inputs["new.shen"] = source

    hashes = {"accepted.shen": "abc"}
    sizes = {"accepted.shen": 3}
    result = StageResult(
        "probe",
        0,
        0.1,
        "2026-06-06T00:00:00+00:00",
        "2026-06-06T00:00:01+00:00",
        (),
        "exited",
        b"",
        b"",
        hashes,
        sizes,
    )
    hashes["other.shen"] = "def"
    sizes["other.shen"] = 4

    assert isinstance(result.output_hashes, MappingProxyType)
    assert isinstance(result.output_sizes, MappingProxyType)
    assert dict(result.output_hashes) == {"accepted.shen": "abc"}
    assert dict(result.output_sizes) == {"accepted.shen": 3}
    with pytest.raises(TypeError):
        result.output_hashes["new.shen"] = "ghi"


def test_multi_output_replace_rolls_back_after_second_replace_fails(
    tmp_path, monkeypatch
):
    runtime = make_script(
        tmp_path / "shen",
        "printf new-accepted > accepted.shen\n"
        "printf new-diagnostics > diagnostics.shen\n",
    )
    accepted = tmp_path / "accepted-result.shen"
    diagnostics = tmp_path / "diagnostics-result.shen"
    accepted.write_bytes(b"old-accepted")
    diagnostics.write_bytes(b"old-diagnostics")
    outputs = {
        "accepted.shen": accepted,
        "diagnostics.shen": diagnostics,
    }
    real_replace = os.replace
    promotion_count = 0

    def fail_second_promotion(source, destination):
        nonlocal promotion_count
        if str(source).endswith(".tmp"):
            promotion_count += 1
            if promotion_count == 2:
                raise OSError("injected second promotion failure")
        return real_replace(source, destination)

    monkeypatch.setattr("logicbox_cli.stages.os.replace", fail_second_promotion)

    with pytest.raises(OSError, match="injected second promotion failure"):
        execute_stage(
            request_for(
                tmp_path,
                runtime,
                accepted,
                outputs=outputs,
                replace=True,
            )
        )

    assert accepted.read_bytes() == b"old-accepted"
    assert diagnostics.read_bytes() == b"old-diagnostics"
    assert not list(tmp_path.glob(".*.tmp"))
    assert not list(tmp_path.glob(".*.bak"))


def test_rollback_preserves_destination_replaced_by_another_writer(
    tmp_path, monkeypatch
):
    runtime = make_script(
        tmp_path / "shen",
        "printf new-accepted > accepted.shen\n"
        "printf new-diagnostics > diagnostics.shen\n",
    )
    accepted = tmp_path / "accepted-result.shen"
    diagnostics = tmp_path / "diagnostics-result.shen"
    accepted.write_bytes(b"old-accepted")
    diagnostics.write_bytes(b"old-diagnostics")
    foreign = tmp_path / "foreign-result.shen"
    foreign.write_bytes(b"foreign-accepted")
    outputs = {
        "accepted.shen": accepted,
        "diagnostics.shen": diagnostics,
    }
    real_replace = os.replace
    promotion_count = 0

    def replace_first_output_then_fail(source, destination):
        nonlocal promotion_count
        if str(source).endswith(".tmp"):
            promotion_count += 1
            if promotion_count == 1:
                result = real_replace(source, destination)
                real_replace(foreign, accepted)
                return result
            if promotion_count == 2:
                raise OSError("injected second promotion failure")
        return real_replace(source, destination)

    monkeypatch.setattr(
        "logicbox_cli.stages.os.replace",
        replace_first_output_then_fail,
    )

    with pytest.raises(RollbackConflictError, match="rollback conflict"):
        execute_stage(
            request_for(
                tmp_path,
                runtime,
                accepted,
                outputs=outputs,
                replace=True,
            )
        )

    assert accepted.read_bytes() == b"foreign-accepted"
    assert diagnostics.read_bytes() == b"old-diagnostics"
    retained_backups = list(tmp_path.glob(".accepted-result.shen.*.bak"))
    assert len(retained_backups) == 1
    assert retained_backups[0].read_bytes() == b"old-accepted"
    assert not list(tmp_path.glob(".*.tmp"))


def test_promotion_fsyncs_files_and_destination_directory(tmp_path, monkeypatch):
    runtime = make_script(
        tmp_path / "shen",
        "printf durable > accepted.shen\n",
    )
    output = tmp_path / "destination" / "result.shen"
    fsynced_modes: list[int] = []
    real_fsync = os.fsync

    def record_fsync(fd):
        fsynced_modes.append(os.fstat(fd).st_mode)
        real_fsync(fd)

    monkeypatch.setattr("logicbox_cli.stages.os.fsync", record_fsync)

    execute_stage(request_for(tmp_path, runtime, output))

    assert any(stat.S_ISREG(mode) for mode in fsynced_modes)
    assert any(stat.S_ISDIR(mode) for mode in fsynced_modes)


@pytest.mark.skipif(os.name != "posix", reason="process groups require POSIX")
def test_timeout_kills_descendant_process_and_captures_output(tmp_path):
    child_pid_file = tmp_path / "child.pid"
    runtime = make_script(
        tmp_path / "shen",
        "printf 'before-timeout\\n'\n"
        "printf 'timeout-detail\\n' >&2\n"
        "sleep 30 &\n"
        "child=$!\n"
        f"printf '%s' \"$child\" > '{child_pid_file}'\n"
        "wait \"$child\"\n",
    )
    output = tmp_path / "result.shen"

    with pytest.raises(subprocess.TimeoutExpired) as raised:
        execute_stage(request_for(tmp_path, runtime, output, timeout=0.5))

    child_pid = int(child_pid_file.read_text(encoding="ascii"))
    deadline = time.monotonic() + 3
    while time.monotonic() < deadline:
        try:
            os.kill(child_pid, 0)
        except ProcessLookupError:
            break
        time.sleep(0.05)
    else:
        pytest.fail(f"descendant process {child_pid} survived timeout")

    assert raised.value.output == b"before-timeout\n"
    assert raised.value.stderr == b"timeout-detail\n"
    assert not output.exists()
