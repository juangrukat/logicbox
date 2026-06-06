import json

import pytest

from logicbox_cli.hashing import sha256_file
from logicbox_cli.runs import create_run


def test_create_run_preserves_source_and_writes_traceable_layout(
    tmp_path, fake_shen
):
    source = tmp_path / "source.shen"
    source_bytes = b'(set *logicbox-artifact* ["opaque"  \xff])\n'
    source.write_bytes(source_bytes)

    run_dir = create_run(source, tmp_path / "runs", fake_shen, 5)

    expected = {
        "input/source.shen",
        "schema/accepted.shen",
        "schema/diagnostics.shen",
        "analysis/findings.shen",
        "schema/engine.stdout",
        "schema/engine.stderr",
        "analysis/engine.stdout",
        "analysis/engine.stderr",
        "manifest.json",
    }
    assert {
        str(path.relative_to(run_dir))
        for path in run_dir.rglob("*")
        if path.is_file()
    } == expected
    copied = run_dir / "input/source.shen"
    assert copied.read_bytes() == source_bytes
    manifest = json.loads((run_dir / "manifest.json").read_text())
    assert manifest["status"] == "completed"
    assert manifest["input"]["sha256"] == sha256_file(copied)
    assert manifest["input"]["bytes"] == len(source_bytes)
    assert "payload" not in json.dumps(manifest)
    assert not list((tmp_path / "runs").glob(".*.tmp"))


def test_failed_run_is_retained_for_diagnosis(tmp_path):
    runtime = tmp_path / "shen"
    runtime.write_text(
        "#!/bin/sh\nset -eu\nprintf failed >&2\nexit 7\n",
        encoding="utf-8",
    )
    runtime.chmod(0o755)
    source = tmp_path / "source.shen"
    source.write_bytes(b"(set *logicbox-artifact* [opaque])\n")
    run_root = tmp_path / "runs"

    with pytest.raises(RuntimeError, match="Shen exited with 7"):
        create_run(source, run_root, runtime, 5)

    failed = list(run_root.glob(".failed-*"))
    assert len(failed) == 1
    assert (failed[0] / "input/source.shen").read_bytes() == source.read_bytes()
    assert not list(run_root.glob(".*.tmp"))
