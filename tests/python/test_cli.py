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
