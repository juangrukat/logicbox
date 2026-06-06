from __future__ import annotations

from pathlib import Path

import pytest


@pytest.fixture
def fake_shen(tmp_path: Path) -> Path:
    executable = tmp_path / "fake shen"
    executable.write_text(
        "#!/bin/sh\n"
        "set -eu\n"
        "printf '%s\\n' \"$@\" > engine-args.txt\n"
        "case \"$*\" in\n"
        "  *emit-accepted.shen*) output=accepted.shen ;;\n"
        "  *emit-diagnostics.shen*) output=diagnostics.shen ;;\n"
        "  *emit-findings.shen*) output=findings.shen ;;\n"
        "  *emit-mutation.shen*) output=mutation.shen ;;\n"
        "  *emit-contract.shen*) output=contract.shen ;;\n"
        "  *) exit 9 ;;\n"
        "esac\n"
        "if test -f input.shen; then input=input.shen\n"
        "elif test -f candidate.shen; then input=candidate.shen\n"
        "else printf '(set *logicbox-artifact* [fake])\\n' > \"$output\"; input=\n"
        "fi\n"
        "test -z \"$input\" || cp \"$input\" \"$output\"\n"
        "printf 'engine stdout\\n'\n"
        "printf 'engine stderr\\n' >&2\n",
        encoding="utf-8",
    )
    executable.chmod(0o755)
    return executable
