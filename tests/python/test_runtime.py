from __future__ import annotations

from pathlib import Path

from logicbox_cli.runtime import check_runtime, discover_shen


def _write_executable(path: Path, body: str) -> Path:
    path.write_text(body, encoding="utf-8")
    path.chmod(0o755)
    return path


def test_explicit_runtime_wins(tmp_path, monkeypatch):
    explicit = _write_executable(tmp_path / "explicit-shen", "#!/bin/sh\nexit 0\n")
    configured = _write_executable(tmp_path / "configured-shen", "#!/bin/sh\nexit 0\n")
    monkeypatch.setenv("SHEN_SBCL", str(configured))

    assert discover_shen(explicit) == explicit.resolve()


def test_environment_runtime_is_used(tmp_path, monkeypatch):
    executable = _write_executable(tmp_path / "shen-sbcl", "#!/bin/sh\nexit 0\n")
    monkeypatch.setenv("SHEN_SBCL", str(executable))
    monkeypatch.setenv("PATH", "")

    assert discover_shen(None) == executable.resolve()


def test_path_runtime_is_used_after_invalid_environment(tmp_path, monkeypatch):
    executable = _write_executable(tmp_path / "shen-sbcl", "#!/bin/sh\nexit 0\n")
    monkeypatch.setenv("SHEN_SBCL", str(tmp_path / "missing"))
    monkeypatch.setenv("PATH", str(tmp_path))

    assert discover_shen(None) == executable.resolve()


def test_missing_runtime_returns_none(monkeypatch):
    monkeypatch.delenv("SHEN_SBCL", raising=False)
    monkeypatch.setenv("PATH", "")

    assert discover_shen(None) is None


def test_non_executable_or_non_file_runtime_is_ignored(tmp_path, monkeypatch):
    non_executable = tmp_path / "not-executable"
    non_executable.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    directory = tmp_path / "runtime-directory"
    directory.mkdir()
    monkeypatch.setenv("SHEN_SBCL", str(directory))
    monkeypatch.setenv("PATH", "")

    assert discover_shen(non_executable) is None


def test_missing_runtime_check_has_remediation():
    check = check_runtime(None)

    assert check.check_id == "shen.runtime"
    assert check.ok is False
    assert check.detail == "shen-sbcl was not found"
    assert check.remediation


def test_healthy_runtime_loads_probe_and_requires_sentinel(tmp_path):
    executable = _write_executable(
        tmp_path / "shen-sbcl",
        "#!/bin/sh\n"
        'test "$1" = "-l" || exit 20\n'
        'test "$#" = "2" || exit 21\n'
        'grep -q "LOGICBOX-SHEN-RUNTIME-OK" "$2" || exit 22\n'
        'printf "LOGICBOX-SHEN-RUNTIME-OK\\n"\n',
    )

    check = check_runtime(executable)

    assert check.ok is True
    assert check.detail == str(executable)
    assert check.remediation == ""


def test_zero_exit_without_sentinel_is_unhealthy(tmp_path):
    executable = _write_executable(
        tmp_path / "shen-sbcl",
        "#!/bin/sh\n"
        'test "$1" = "-l" || exit 20\n'
        "exit 0\n",
    )

    check = check_runtime(executable)

    assert check.ok is False
    assert "sentinel" in check.detail
    assert check.remediation


def test_nonzero_runtime_is_unhealthy(tmp_path):
    executable = _write_executable(
        tmp_path / "shen-sbcl",
        "#!/bin/sh\n"
        'test "$1" = "-l" || exit 20\n'
        'printf "failed to start\\n" >&2\n'
        "exit 9\n",
    )

    check = check_runtime(executable)

    assert check.ok is False
    assert "exit 9" in check.detail
    assert check.remediation
