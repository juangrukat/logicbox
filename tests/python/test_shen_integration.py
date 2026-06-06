from __future__ import annotations

import os
import subprocess
from pathlib import Path

import pytest

from logicbox_cli.cli import main
from logicbox_cli.runtime import discover_shen

ROOT = Path(__file__).resolve().parents[2]


def real_shen() -> Path:
    configured = Path(os.environ["SHEN_SBCL"]) if "SHEN_SBCL" in os.environ else None
    runtime = discover_shen(configured)
    if runtime is None:
        pytest.skip("real shen-sbcl runtime is not configured")
    return runtime


@pytest.mark.shen
@pytest.mark.parametrize(
    "fixture",
    ["source-valid.shen", "source-invalid.shen"],
)
def test_artifact_chain_is_loadable_and_source_is_unchanged(
    tmp_path, fixture
):
    runtime = real_shen()
    source = ROOT / "tests/artifacts" / fixture
    original = source.read_bytes()
    accepted = tmp_path / "accepted.shen"
    diagnostics = tmp_path / "diagnostics.shen"
    findings = tmp_path / "findings.shen"

    assert main([
        "schema", "--shen", str(runtime), "--input", str(source),
        "--accepted", str(accepted), "--diagnostics", str(diagnostics),
    ]) == 0
    assert main([
        "analyze", "--shen", str(runtime), "--input", str(accepted),
        "--output", str(findings),
    ]) == 0

    for artifact in (accepted, diagnostics, findings):
        completed = subprocess.run(
            [str(runtime), "-l", str(artifact)],
            capture_output=True,
            check=False,
        )
        assert completed.returncode == 0, completed.stderr.decode()
    assert source.read_bytes() == original


MODELS = (
    sorted((ROOT / "tests/gold").glob("*.shen"))
    + sorted((ROOT / "tests/edge").glob("*.shen"))
    + sorted((ROOT / "tests").glob("stress-*-model.shen"))
)


@pytest.mark.shen
@pytest.mark.parametrize("model", MODELS, ids=lambda path: str(path.relative_to(ROOT)))
def test_preserved_fixture_output_matches(model, tmp_path):
    runtime = real_shen()
    command = [
        str(runtime),
        "-l", str(model),
        "-l", str(ROOT / "shen/fact-schema.shen"),
        "-l", str(ROOT / "shen/fact-normalize.shen"),
        "-l", str(ROOT / "shen/fact-provenance.shen"),
        "-l", str(ROOT / "shen/fact-typecheck.shen"),
        "-l", str(ROOT / "shen/rules.shen"),
        "-l", str(ROOT / "shen/artifact-protocol.shen"),
        "-l", str(ROOT / "tests/shen/wrap-current-facts.shen"),
        "-l", str(ROOT / "shen/stages/emit-findings.shen"),
        "-l", str(tmp_path / "findings.shen"),
        "-l", str(ROOT / "tests/shen/emit-findings-lines.shen"),
    ]
    completed = subprocess.run(
        command,
        cwd=tmp_path,
        capture_output=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr.decode()
    expected = model.with_suffix(".expected").read_bytes()
    assert (tmp_path / "actual.expected").read_bytes() == expected


@pytest.mark.shen
@pytest.mark.parametrize(
    ("fixture", "case"),
    [
        ("stress-policy-graph.shen", "policy"),
        ("stress-context-stage.shen", "context-stage"),
    ],
)
def test_stress_artifacts_exercise_distinct_rule_families(
    tmp_path, fixture, case
):
    runtime = real_shen()
    source = ROOT / "tests/artifacts" / fixture
    first = tmp_path / "first-findings.shen"
    second = tmp_path / "second-findings.shen"

    for destination in (first, second):
        assert main([
            "analyze", "--shen", str(runtime), "--input", str(source),
            "--output", str(destination),
        ]) == 0
    assert first.read_bytes() == second.read_bytes()

    case_file = tmp_path / "stress-case.shen"
    case_file.write_text(
        f"(set *stress-case* {case})\n",
        encoding="ascii",
    )
    completed = subprocess.run(
        [
            str(runtime),
            "-l", str(ROOT / "shen/fact-schema.shen"),
            "-l", str(ROOT / "shen/artifact-protocol.shen"),
            "-l", str(first),
            "-l", str(case_file),
            "-l", str(ROOT / "tests/shen/assert-stress-findings.shen"),
        ],
        capture_output=True,
        check=False,
    )
    assert completed.returncode == 0, completed.stderr.decode()
