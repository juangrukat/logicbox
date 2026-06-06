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
