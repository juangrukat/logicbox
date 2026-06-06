from logicbox_cli.cli import main


def test_no_command_returns_usage_error(capsys):
    assert main([]) == 2
    captured = capsys.readouterr()
    assert captured.out == ""
    assert "usage:" in captured.err


def test_version_is_clean_stdout(capsys):
    assert main(["--version"]) == 0
    captured = capsys.readouterr()
    assert captured.out == "logicbox 3.0.0\n"
    assert captured.err == ""


def test_doctor_success_has_clean_tab_separated_stdout(tmp_path, capsys):
    executable = tmp_path / "shen-sbcl"
    executable.write_text(
        "#!/bin/sh\n"
        'test "$1" = "-l" || exit 20\n'
        'grep -q "LOGICBOX-SHEN-RUNTIME-OK" "$2" || exit 21\n'
        'printf "LOGICBOX-SHEN-RUNTIME-OK\\n"\n',
        encoding="utf-8",
    )
    executable.chmod(0o755)

    assert main(["doctor", "--shen", str(executable)]) == 0
    captured = capsys.readouterr()
    assert captured.out == f"shen.runtime\tok\t{executable.resolve()}\n"
    assert captured.err == ""


def test_doctor_failure_uses_stderr_without_traceback(monkeypatch, capsys):
    monkeypatch.delenv("SHEN_SBCL", raising=False)
    monkeypatch.setenv("PATH", "")

    assert main(["doctor"]) == 4
    captured = capsys.readouterr()
    assert captured.out == ""
    assert captured.err.startswith("shen.runtime\tfail\tshen-sbcl was not found\n")
    assert "Pass --shen PATH" in captured.err
    assert "Traceback" not in captured.err


def test_schema_command_writes_both_artifacts(tmp_path, fake_shen, capsys):
    source = tmp_path / "source.shen"
    source.write_bytes(b"(set *logicbox-artifact* [source])\n")
    accepted = tmp_path / "accepted.shen"
    diagnostics = tmp_path / "diagnostics.shen"

    assert main([
        "schema", "--shen", str(fake_shen), "--input", str(source),
        "--accepted", str(accepted), "--diagnostics", str(diagnostics),
    ]) == 0

    assert accepted.read_bytes() == source.read_bytes()
    assert diagnostics.read_bytes() == source.read_bytes()
    captured = capsys.readouterr()
    assert captured.out == ""
    assert captured.err == ""


def test_analyze_compare_and_contract_commands(tmp_path, fake_shen):
    source = tmp_path / "source.shen"
    candidate = tmp_path / "candidate.shen"
    source.write_bytes(b"(set *logicbox-artifact* [source])\n")
    candidate.write_bytes(b"(set *logicbox-artifact* [candidate])\n")
    findings = tmp_path / "findings.shen"
    mutation = tmp_path / "mutation.shen"
    contract = tmp_path / "contract.shen"

    assert main([
        "analyze", "--shen", str(fake_shen), "--input", str(source),
        "--output", str(findings),
    ]) == 0
    assert main([
        "compare", "--shen", str(fake_shen), "--source", str(source),
        "--candidate", str(candidate), "--output", str(mutation),
    ]) == 0
    assert main([
        "contract", "--shen", str(fake_shen), "--output", str(contract),
    ]) == 0

    assert findings.is_file()
    assert mutation.read_bytes() == candidate.read_bytes()
    assert contract.is_file()


def test_existing_output_requires_replace(tmp_path, fake_shen, capsys):
    source = tmp_path / "source.shen"
    output = tmp_path / "findings.shen"
    source.write_bytes(b"(set *logicbox-artifact* [source])\n")
    output.write_bytes(b"keep\n")
    args = [
        "analyze", "--shen", str(fake_shen), "--input", str(source),
        "--output", str(output),
    ]

    assert main(args) == 3
    assert output.read_bytes() == b"keep\n"
    assert "destination already exists" in capsys.readouterr().err
    assert main([*args, "--replace"]) == 0
    assert output.read_bytes() == source.read_bytes()


def test_missing_input_is_filesystem_error(tmp_path, fake_shen, capsys):
    assert main([
        "analyze", "--shen", str(fake_shen),
        "--input", str(tmp_path / "missing.shen"),
        "--output", str(tmp_path / "findings.shen"),
    ]) == 3
    assert "No such file" in capsys.readouterr().err


def test_trace_goes_only_to_stderr(tmp_path, fake_shen, capsys):
    source = tmp_path / "source.shen"
    source.write_bytes(b"(set *logicbox-artifact* [source])\n")

    assert main([
        "analyze", "--shen", str(fake_shen), "--input", str(source),
        "--output", str(tmp_path / "findings.shen"), "--trace",
    ]) == 0
    captured = capsys.readouterr()
    assert captured.out == ""
    assert "analyze\texit=0" in captured.err
    assert "engine stdout" in captured.err


def test_run_and_inspect_use_operational_manifest(
    tmp_path, fake_shen, capsys
):
    source = tmp_path / "source.shen"
    source.write_bytes(b"(set *logicbox-artifact* [source])\n")
    root = tmp_path / "runs"

    assert main([
        "run", "--shen", str(fake_shen), "--input", str(source),
        "--run-dir", str(root),
    ]) == 0
    run_output = capsys.readouterr()
    run_dir = root / run_output.out.strip().split("/")[-1]
    assert run_dir.is_dir()
    assert run_output.err == ""

    assert main(["inspect", "--run-dir", str(run_dir)]) == 0
    inspect_output = capsys.readouterr()
    assert '"format": "logicbox-run-v1"' in inspect_output.out
    assert "payload" not in inspect_output.out
    assert inspect_output.err == ""
