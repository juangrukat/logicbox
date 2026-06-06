# Shen-Native LogicBox Rearchitecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the patchwork shell/JavaScript workspace with a Python CLI that coordinates immutable Shen-native artifacts without interpreting their logical payloads.

**Architecture:** Existing Shen schema and reasoning files remain authoritative. New Shen stage runners load and emit complete `.shen` artifact envelopes; a standard-library Python package discovers the runtime, prepares isolated stage directories, invokes Shen, preserves exact files and process traces, and exposes composable Unix-style commands. Legacy orchestration is deleted only after artifact-chain, parity, and cleanup-gate tests pass.

**Tech Stack:** Shen/SBCL, Python 3.11+, standard-library `argparse`, `subprocess`, `pathlib`, `hashlib`, `json`, `tempfile`, and `pytest` for coordinator tests.

---

## Scope And File Map

### Preserve As The Engine Baseline

These files remain in place and are not rewritten during the architecture migration:

```text
shen/fact-schema.shen
shen/fact-normalize.shen
shen/fact-provenance.shen
shen/fact-typecheck.shen
shen/rules.shen
shen/fact-regression.shen
tests/**/*.shen
tests/**/*.expected
```

### Create

```text
pyproject.toml
src/logicbox_cli/__init__.py
src/logicbox_cli/__main__.py
src/logicbox_cli/cli.py
src/logicbox_cli/errors.py
src/logicbox_cli/runtime.py
src/logicbox_cli/stages.py
src/logicbox_cli/runs.py
src/logicbox_cli/manifest.py
src/logicbox_cli/hashing.py

shen/artifact-protocol.shen
shen/stages/emit-accepted.shen
shen/stages/emit-diagnostics.shen
shen/stages/emit-findings.shen
shen/stages/emit-mutation.shen
shen/stages/emit-contract.shen
shen/stages/capture-source.shen
shen/stages/capture-candidate.shen

tests/artifacts/source-valid.shen
tests/artifacts/source-invalid.shen
tests/artifacts/candidate-valid.shen
tests/python/conftest.py
tests/python/test_cli.py
tests/python/test_runtime.py
tests/python/test_stages.py
tests/python/test_runs.py
tests/python/test_manifest.py
tests/python/test_cleanup_gate.py
tests/shen/test-artifact-protocol.shen
tests/shen/wrap-current-facts.shen
tests/shen/emit-findings-lines.shen
```

### Replace Or Remove After Parity

```text
logicbox
scripts/
work/
output/
logicbox (skill)/
shen/run.shen
shen/run-mutation.shen
shen/run-preflight.shen
shen/run-prompt-contract.shen
shen/run-rewrite-safety.shen
shen/run-fact-regression.shen
```

`README.md`, `.gitignore`, `docs/fact-schema.md`, and
`docs/prompt-contract.md` are rewritten to describe the new commands and
artifact protocol. The design and implementation-plan documents remain.

---

### Task 1: Establish Python Packaging And Stable Exit Codes

**Files:**
- Create: `pyproject.toml`
- Create: `src/logicbox_cli/__init__.py`
- Create: `src/logicbox_cli/__main__.py`
- Create: `src/logicbox_cli/errors.py`
- Create: `src/logicbox_cli/cli.py`
- Create: `tests/python/test_cli.py`

- [ ] **Step 1: Write the failing CLI tests**

```python
# tests/python/test_cli.py
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
```

- [ ] **Step 2: Run the tests and verify import failure**

Run:

```bash
python3 -m pytest tests/python/test_cli.py -q
```

Expected: collection fails with `ModuleNotFoundError: No module named 'logicbox_cli'`.

- [ ] **Step 3: Add packaging and the minimal CLI**

```toml
# pyproject.toml
[build-system]
requires = ["setuptools>=69"]
build-backend = "setuptools.build_meta"

[project]
name = "logicbox"
version = "3.0.0"
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
test = ["pytest>=8.0"]

[project.scripts]
logicbox = "logicbox_cli.cli:entrypoint"

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests/python"]
```

```python
# src/logicbox_cli/__init__.py
__version__ = "3.0.0"
```

```python
# src/logicbox_cli/errors.py
from enum import IntEnum


class ExitCode(IntEnum):
    OK = 0
    USAGE = 2
    FILESYSTEM = 3
    RUNTIME = 4
    STAGE = 5
    PROTOCOL = 6
    LOCKED = 7
    INTERNAL = 8
```

```python
# src/logicbox_cli/cli.py
from __future__ import annotations

import argparse
from collections.abc import Sequence

from logicbox_cli import __version__
from logicbox_cli.errors import ExitCode


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="logicbox")
    parser.add_argument("--version", action="version", version=f"logicbox {__version__}")
    parser.add_subparsers(dest="command")
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.command is None:
        parser.print_usage()
        return int(ExitCode.USAGE)
    return int(ExitCode.OK)


def entrypoint() -> None:
    raise SystemExit(main())
```

```python
# src/logicbox_cli/__main__.py
from logicbox_cli.cli import entrypoint

entrypoint()
```

- [ ] **Step 4: Install editable package and run tests**

Run:

```bash
python3 -m pip install -e '.[test]'
python3 -m pytest tests/python/test_cli.py -q
```

Expected: `2 passed`.

- [ ] **Step 5: Commit**

```bash
git add pyproject.toml src/logicbox_cli tests/python/test_cli.py
git commit -m "build: add Python LogicBox CLI package"
```

---

### Task 2: Add Runtime Discovery And `doctor`

**Files:**
- Create: `src/logicbox_cli/runtime.py`
- Create: `tests/python/test_runtime.py`
- Modify: `src/logicbox_cli/cli.py`

- [ ] **Step 1: Write failing discovery tests**

```python
# tests/python/test_runtime.py
from pathlib import Path

from logicbox_cli.runtime import discover_shen


def test_explicit_runtime_wins(tmp_path, monkeypatch):
    executable = tmp_path / "shen-sbcl"
    executable.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    executable.chmod(0o755)
    monkeypatch.setenv("SHEN_SBCL", "/ignored")
    assert discover_shen(executable) == executable.resolve()


def test_environment_runtime_is_used(tmp_path, monkeypatch):
    executable = tmp_path / "shen-sbcl"
    executable.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    executable.chmod(0o755)
    monkeypatch.setenv("SHEN_SBCL", str(executable))
    assert discover_shen(None) == executable.resolve()


def test_missing_runtime_returns_none(monkeypatch):
    monkeypatch.delenv("SHEN_SBCL", raising=False)
    monkeypatch.setenv("PATH", "")
    assert discover_shen(None) is None
```

- [ ] **Step 2: Verify tests fail**

Run:

```bash
python3 -m pytest tests/python/test_runtime.py -q
```

Expected: import fails because `logicbox_cli.runtime` does not exist.

- [ ] **Step 3: Implement runtime discovery and health results**

```python
# src/logicbox_cli/runtime.py
from __future__ import annotations

import os
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class DoctorCheck:
    check_id: str
    ok: bool
    detail: str
    remediation: str = ""


def _usable(path: Path) -> bool:
    return path.is_file() and os.access(path, os.X_OK)


def discover_shen(explicit: Path | None) -> Path | None:
    candidates: list[Path] = []
    if explicit is not None:
        candidates.append(explicit)
    configured = os.environ.get("SHEN_SBCL")
    if configured:
        candidates.append(Path(configured))
    located = shutil.which("shen-sbcl")
    if located:
        candidates.append(Path(located))
    for candidate in candidates:
        resolved = candidate.expanduser().resolve()
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
    result = subprocess.run(
        [str(runtime), "--help"],
        capture_output=True,
        text=True,
        timeout=10,
        check=False,
    )
    return DoctorCheck(
        "shen.runtime",
        result.returncode == 0,
        str(runtime),
        "" if result.returncode == 0 else "Verify that the configured executable starts.",
    )
```

- [ ] **Step 4: Add clean `doctor` output**

Replace `build_parser()` with:

```python
def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="logicbox")
    parser.add_argument("--version", action="version", version=f"logicbox {__version__}")
    subcommands = parser.add_subparsers(dest="command")
    doctor = subcommands.add_parser("doctor")
    doctor.add_argument("--shen", type=Path)
    return parser
```

Add this dispatch to `main()`:

```python
if args.command == "doctor":
    runtime = discover_shen(args.shen)
    check = check_runtime(runtime)
    stream = sys.stdout if check.ok else sys.stderr
    state = "ok" if check.ok else "fail"
    print(f"{check.check_id}\t{state}\t{check.detail}", file=stream)
    if check.remediation:
        print(check.remediation, file=sys.stderr)
    return int(ExitCode.OK if check.ok else ExitCode.RUNTIME)
```

Import `sys`, `Path`, `check_runtime`, and `discover_shen`.

- [ ] **Step 5: Run tests and command**

Run:

```bash
python3 -m pytest tests/python/test_runtime.py tests/python/test_cli.py -q
logicbox doctor
```

Expected: tests pass. On the current machine, `doctor` exits `4` and prints the
missing-runtime remediation to stderr without a traceback.

- [ ] **Step 6: Commit**

```bash
git add src/logicbox_cli tests/python
git commit -m "feat: add Shen runtime discovery and doctor"
```

---

### Task 3: Define The Shen Artifact Protocol

**Files:**
- Create: `shen/artifact-protocol.shen`
- Create: `tests/shen/test-artifact-protocol.shen`
- Create: `tests/artifacts/source-valid.shen`
- Create: `tests/artifacts/source-invalid.shen`
- Create: `tests/artifacts/candidate-valid.shen`

- [ ] **Step 1: Add source artifact fixtures**

```shen
\\ tests/artifacts/source-valid.shen
(set *logicbox-artifact*
  [logicbox-artifact
    [kind source]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [plan p1]
        [term source known]
        [term target known]
        [claim c1 causal source target]
        [mechanism c1 bridge]
        [modality c1 possible]
        [scope c1 conditional]
      ]]])
```

```shen
\\ tests/artifacts/source-invalid.shen
(set *logicbox-artifact*
  [logicbox-artifact
    [kind source]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [plan p1]
        [scope p1 impossible-scope]
      ]]])
```

```shen
\\ tests/artifacts/candidate-valid.shen
(set *logicbox-artifact*
  [logicbox-artifact
    [kind accepted]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [term source known]
        [term target known]
        [rewrite-claim r1 causal source target]
        [rewrite-modality r1 certain]
        [rewrite-scope r1 conditional]
        [stronger-than certain possible]
      ]]])
```

- [ ] **Step 2: Add a failing Shen protocol test**

```shen
\\ tests/shen/test-artifact-protocol.shen
(define assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label -> (simple-error (make-string "~A expected ~A got ~A" Label Expected Actual)))

(assert-equal source
  (logicbox-artifact-kind (value *logicbox-artifact*))
  artifact-kind)
(assert-equal logicbox-artifact-v1
  (logicbox-artifact-protocol (value *logicbox-artifact*))
  artifact-protocol)
(assert-equal schema-v1
  (logicbox-artifact-schema (value *logicbox-artifact*))
  artifact-schema)
(assert-equal 7
  (lb-length (logicbox-artifact-payload (value *logicbox-artifact*)))
  artifact-payload)
```

- [ ] **Step 3: Run with a configured Shen runtime and verify failure**

Run:

```bash
"${SHEN_SBCL:?Set SHEN_SBCL}" \
  -l tests/artifacts/source-valid.shen \
  -l shen/fact-schema.shen \
  -l shen/artifact-protocol.shen \
  -l tests/shen/test-artifact-protocol.shen
```

Expected: failure because the artifact accessor functions are undefined.

- [ ] **Step 4: Implement Shen-only envelope access and emission**

```shen
\\ shen/artifact-protocol.shen
(define logicbox-field
  Key [[Key Value] | _] -> Value
  Key [_ | Rest] -> (logicbox-field Key Rest)
  Key [] -> (simple-error (make-string "missing LogicBox artifact field: ~A" Key)))

(define logicbox-artifact-fields
  [logicbox-artifact | Fields] -> Fields
  Other -> (simple-error (make-string "invalid LogicBox artifact: ~A" Other)))

(define logicbox-artifact-kind
  Artifact -> (logicbox-field kind (logicbox-artifact-fields Artifact)))

(define logicbox-artifact-protocol
  Artifact -> (logicbox-field protocol (logicbox-artifact-fields Artifact)))

(define logicbox-artifact-schema
  Artifact -> (logicbox-field schema (logicbox-artifact-fields Artifact)))

(define logicbox-artifact-payload
  Artifact -> (logicbox-field payload (logicbox-artifact-fields Artifact)))

(define make-logicbox-artifact
  Kind Schema Payload ->
    [logicbox-artifact
      [kind Kind]
      [protocol logicbox-artifact-v1]
      [schema Schema]
      [payload Payload]])

(define write-logicbox-artifact
  Path Kind Schema Payload ->
    (write-to-file Path
      (make-string "(set *logicbox-artifact*~%  ~S)~%"
        (make-logicbox-artifact Kind Schema Payload))))
```

- [ ] **Step 5: Run the protocol test**

Run the Step 3 command again.

Expected: four lines ending in `ok`, with exit code `0`.

- [ ] **Step 6: Commit**

```bash
git add shen/artifact-protocol.shen tests/artifacts tests/shen
git commit -m "feat: define Shen-native artifact protocol"
```

---

### Task 4: Add Shen Schema And Analysis Emitters

**Files:**
- Create: `shen/stages/emit-accepted.shen`
- Create: `shen/stages/emit-diagnostics.shen`
- Create: `shen/stages/emit-findings.shen`
- Create: `shen/stages/emit-contract.shen`

- [ ] **Step 1: Add accepted and diagnostic emitters**

```shen
\\ shen/stages/emit-accepted.shen
(set *facts* (logicbox-artifact-payload (value *logicbox-artifact*)))
(write-logicbox-artifact
  "accepted.shen"
  accepted
  (logicbox-artifact-schema (value *logicbox-artifact*))
  (if (schema-valid? (value *facts*))
      (schema-accepted-core-facts (value *facts*))
      []))
```

```shen
\\ shen/stages/emit-diagnostics.shen
(set *facts* (logicbox-artifact-payload (value *logicbox-artifact*)))
(write-logicbox-artifact
  "diagnostics.shen"
  diagnostics
  (logicbox-artifact-schema (value *logicbox-artifact*))
  (schema-diagnostics (value *facts*)))
```

- [ ] **Step 2: Add the Shen-gated findings emitter**

```shen
\\ shen/stages/emit-findings.shen
(set *facts* (logicbox-artifact-payload (value *logicbox-artifact*)))
(define logicbox-pipeline-findings
  Facts -> (let Errors (schema-type-errors Facts)
           (let Diagnostics (schema-diagnostics Facts)
           (if (= Errors [])
               (append Diagnostics
                 (derived-flags
                   (preflight-enriched-facts
                     (schema-accepted-core-facts Facts))))
               (append Diagnostics (schema-error-plan-statuses Facts))))))
(write-logicbox-artifact
  "findings.shen"
  findings
  (logicbox-artifact-schema (value *logicbox-artifact*))
  (logicbox-pipeline-findings (value *facts*)))
```

- [ ] **Step 3: Add the schema contract emitter**

```shen
\\ shen/stages/emit-contract.shen
(write-logicbox-artifact
  "contract.shen"
  contract
  schema-v1
  (schema-prompt-contract))
```

- [ ] **Step 4: Run emitters in a temporary directory**

Run:

```bash
tmp="$(mktemp -d)"
cp tests/artifacts/source-valid.shen "$tmp/input.shen"
(
  cd "$tmp"
  "$SHEN_SBCL" \
    -l input.shen \
    -l "$OLDPWD/shen/fact-schema.shen" \
    -l "$OLDPWD/shen/fact-normalize.shen" \
    -l "$OLDPWD/shen/fact-provenance.shen" \
    -l "$OLDPWD/shen/fact-typecheck.shen" \
    -l "$OLDPWD/shen/rules.shen" \
    -l "$OLDPWD/shen/artifact-protocol.shen" \
    -l "$OLDPWD/shen/stages/emit-accepted.shen" \
    -l "$OLDPWD/shen/stages/emit-diagnostics.shen" \
    -l "$OLDPWD/shen/stages/emit-findings.shen"
)
test -s "$tmp/accepted.shen"
test -s "$tmp/diagnostics.shen"
test -s "$tmp/findings.shen"
```

Expected: all three files exist and begin with `(set *logicbox-artifact*`.

- [ ] **Step 5: Verify invalid source produces empty accepted facts and findings**

Repeat Step 4 with `source-invalid.shen`, then load `accepted.shen` and
`findings.shen` with Shen and assert:

```shen
(assert-equal [] (logicbox-artifact-payload (value *logicbox-artifact*)) invalid-accepted-empty)
```

The findings payload must contain a `fact-type-error` and
`[plan-status p1 translation-error]`, proving Shen performed the gate.

- [ ] **Step 6: Commit**

```bash
git add shen/stages
git commit -m "feat: emit schema and analysis artifacts from Shen"
```

---

### Task 5: Add Shen Mutation Emitter

**Files:**
- Create: `shen/stages/emit-mutation.shen`
- Create: `shen/stages/capture-source.shen`
- Create: `shen/stages/capture-candidate.shen`
- Create: `tests/artifacts/source-accepted.shen`

- [ ] **Step 1: Create an accepted source fixture**

```shen
\\ tests/artifacts/source-accepted.shen
(set *logicbox-artifact*
  [logicbox-artifact
    [kind accepted]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [plan p1]
        [term source known]
        [term target known]
        [claim c1 causal source target]
        [mechanism c1 bridge]
        [modality c1 possible]
        [scope c1 conditional]
      ]]])
```

- [ ] **Step 2: Add the mutation emitter**

```shen
\\ shen/stages/emit-mutation.shen
(set *source-facts*
  (logicbox-artifact-payload (value *logicbox-source-artifact*)))
(set *candidate-facts*
  (logicbox-artifact-payload (value *logicbox-candidate-artifact*)))
(set *facts* (append (value *source-facts*) (value *candidate-facts*)))
(define logicbox-mutation-findings
  Facts -> (let Errors (schema-type-errors Facts)
           (if (= Errors [])
               (mutation-flags-on
                 (preflight-enriched-facts
                   (schema-accepted-core-facts Facts)))
               (schema-diagnostics Facts))))
(write-logicbox-artifact
  "mutation.shen"
  mutation
  schema-v1
  (logicbox-mutation-findings (value *facts*)))
```

- [ ] **Step 3: Add fixed capture stages that preserve both loaded artifacts**

```shen
\\ shen/stages/capture-source.shen
(set *logicbox-source-artifact* (value *logicbox-artifact*))
```

```shen
\\ shen/stages/capture-candidate.shen
(set *logicbox-candidate-artifact* (value *logicbox-artifact*))
```

The Python coordinator loads source, `capture-source.shen`, candidate,
`capture-candidate.shen`, and the emitter in that exact order. It generates no
logical facts or Shen source.

- [ ] **Step 4: Execute and inspect the artifact through Shen**

Run:

```bash
tmp="$(mktemp -d)"
(
  cd /Users/kat/Documents/MISC/DESK/logicbox
  "$SHEN_SBCL" \
    -l tests/artifacts/source-accepted.shen \
    -l shen/artifact-protocol.shen \
    -l shen/stages/capture-source.shen \
    -l tests/artifacts/candidate-valid.shen \
    -l shen/stages/capture-candidate.shen \
    -l shen/fact-schema.shen \
    -l shen/fact-normalize.shen \
    -l shen/fact-provenance.shen \
    -l shen/fact-typecheck.shen \
    -l shen/rules.shen \
    -l shen/stages/emit-mutation.shen
)
```

Expected: `mutation.shen` is loadable and its payload contains a modality
mutation for `c1`.

- [ ] **Step 5: Commit**

```bash
git add shen/stages/emit-mutation.shen tests/artifacts tests/shen
git commit -m "feat: emit Shen-native mutation artifacts"
```

---

### Task 6: Implement Opaque Stage Execution

**Files:**
- Create: `src/logicbox_cli/hashing.py`
- Create: `src/logicbox_cli/stages.py`
- Create: `tests/python/conftest.py`
- Create: `tests/python/test_stages.py`

- [ ] **Step 1: Write a fake Shen executable fixture**

```python
# tests/python/conftest.py
from pathlib import Path

import pytest


@pytest.fixture
def fake_shen(tmp_path: Path) -> Path:
    executable = tmp_path / "shen-sbcl"
    executable.write_text(
        "#!/bin/sh\n"
        "set -eu\n"
        "printf '%s\\n' \"$@\" > engine-args.txt\n"
        "case \"$*\" in\n"
        "  *emit-accepted.shen*) output=accepted.shen; kind=accepted ;;\n"
        "  *emit-diagnostics.shen*) output=diagnostics.shen; kind=diagnostics ;;\n"
        "  *emit-findings.shen*) output=findings.shen; kind=findings ;;\n"
        "  *emit-mutation.shen*) output=mutation.shen; kind=mutation ;;\n"
        "  *emit-contract.shen*) output=contract.shen; kind=contract ;;\n"
        "  *) exit 9 ;;\n"
        "esac\n"
        "printf '(set *logicbox-artifact*\\n  [logicbox-artifact [kind %s] [protocol logicbox-artifact-v1] [schema schema-v1] [payload []]])\\n' \"$kind\" > \"$output\"\n",
        encoding="utf-8",
    )
    executable.chmod(0o755)
    return executable
```

- [ ] **Step 2: Write failing opaque-execution tests**

```python
# tests/python/test_stages.py
from pathlib import Path

from logicbox_cli.stages import StageRequest, execute_stage


def test_stage_copies_input_and_promotes_opaque_output(tmp_path, fake_shen):
    source = tmp_path / "source.shen"
    source.write_bytes(b"(set *logicbox-artifact* [opaque bytes])\n")
    output = tmp_path / "result.shen"
    request = StageRequest(
        name="schema-accepted",
        runtime=fake_shen,
        inputs={"input.shen": source},
        load_paths=(Path("/engine/artifact-protocol.shen"),),
        outputs={"accepted.shen": output},
        timeout_seconds=10,
    )
    result = execute_stage(request)
    assert result.exit_code == 0
    assert output.read_bytes().startswith(b"(set *logicbox-artifact*")
    assert source.read_bytes() == b"(set *logicbox-artifact* [opaque bytes])\n"
```

- [ ] **Step 3: Verify failure**

Run:

```bash
python3 -m pytest tests/python/test_stages.py -q
```

Expected: import fails because `logicbox_cli.stages` does not exist.

- [ ] **Step 4: Implement hashing and stage execution**

```python
# src/logicbox_cli/hashing.py
from hashlib import sha256
from pathlib import Path


def sha256_file(path: Path) -> str:
    digest = sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()
```

```python
# src/logicbox_cli/stages.py
from __future__ import annotations

import shutil
import subprocess
import tempfile
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

from logicbox_cli.hashing import sha256_file


@dataclass(frozen=True)
class StageRequest:
    name: str
    runtime: Path
    inputs: dict[str, Path]
    load_paths: tuple[Path, ...]
    outputs: dict[str, Path]
    timeout_seconds: float


@dataclass(frozen=True)
class StageResult:
    name: str
    exit_code: int
    elapsed_seconds: float
    started_at: str
    finished_at: str
    load_paths: tuple[str, ...]
    termination_reason: str
    stdout: bytes
    stderr: bytes
    output_hashes: dict[str, str]
    output_sizes: dict[str, int]


def execute_stage(request: StageRequest) -> StageResult:
    started_at = datetime.now(timezone.utc).isoformat()
    started = time.monotonic()
    with tempfile.TemporaryDirectory(prefix=f"logicbox-{request.name}-") as raw:
        stage_dir = Path(raw)
        for target_name, source in request.inputs.items():
            shutil.copyfile(source, stage_dir / target_name)
        command = [str(request.runtime)]
        for load_path in request.load_paths:
            command.extend(["-l", str(load_path)])
        completed = subprocess.run(
            command,
            cwd=stage_dir,
            capture_output=True,
            timeout=request.timeout_seconds,
            check=False,
        )
        if completed.returncode == 0:
            for stage_name, destination in request.outputs.items():
                produced = stage_dir / stage_name
                if not produced.is_file():
                    raise RuntimeError(f"{request.name} did not produce {stage_name}")
                destination.parent.mkdir(parents=True, exist_ok=True)
                temporary = destination.with_name(f".{destination.name}.tmp")
                shutil.copyfile(produced, temporary)
                temporary.replace(destination)
        hashes = {
            name: sha256_file(path)
            for name, path in request.outputs.items()
            if path.is_file()
        }
        sizes = {
            name: path.stat().st_size
            for name, path in request.outputs.items()
            if path.is_file()
        }
    finished_at = datetime.now(timezone.utc).isoformat()
    return StageResult(
        request.name,
        completed.returncode,
        time.monotonic() - started,
        started_at,
        finished_at,
        tuple(str(path) for path in request.load_paths),
        "exited",
        completed.stdout,
        completed.stderr,
        hashes,
        sizes,
    )
```

- [ ] **Step 5: Add timeout, nonzero-exit, missing-output, and path-with-spaces tests**

```python
def make_script(path: Path, body: str) -> Path:
    path.write_text("#!/bin/sh\nset -eu\n" + body, encoding="utf-8")
    path.chmod(0o755)
    return path


def request_for(tmp_path: Path, runtime: Path, output: Path, timeout: float = 1) -> StageRequest:
    source = tmp_path / "source with spaces.shen"
    source.write_bytes(b"(set *logicbox-artifact* [opaque bytes])\n")
    return StageRequest(
        "probe",
        runtime,
        {"input.shen": source},
        (Path("input.shen"), Path("/engine/emit-accepted.shen")),
        {"accepted.shen": output},
        timeout,
    )


def test_nonzero_exit_does_not_promote_output(tmp_path):
    runtime = make_script(tmp_path / "shen", "printf partial > accepted.shen\nexit 7\n")
    output = tmp_path / "result.shen"
    result = execute_stage(request_for(tmp_path, runtime, output))
    assert result.exit_code == 7
    assert not output.exists()


def test_missing_output_raises(tmp_path):
    runtime = make_script(tmp_path / "shen", "exit 0\n")
    output = tmp_path / "result.shen"
    with pytest.raises(RuntimeError, match="did not produce accepted.shen"):
        execute_stage(request_for(tmp_path, runtime, output))
    assert not output.exists()


def test_timeout_does_not_promote_output(tmp_path):
    runtime = make_script(tmp_path / "shen", "sleep 2\n")
    output = tmp_path / "result.shen"
    with pytest.raises(subprocess.TimeoutExpired):
        execute_stage(request_for(tmp_path, runtime, output, timeout=0.01))
    assert not output.exists()
```

Import `subprocess` and `pytest`. The existing success test already uses an
input path containing spaces and asserts exact source bytes remain unchanged.
The CLI layer maps `TimeoutExpired` to exit code `5`.

- [ ] **Step 6: Run tests**

Run:

```bash
python3 -m pytest tests/python/test_stages.py -q
```

Expected: all stage tests pass.

- [ ] **Step 7: Commit**

```bash
git add src/logicbox_cli tests/python
git commit -m "feat: execute Shen stages with opaque artifacts"
```

---

### Task 7: Add `schema`, `analyze`, `compare`, And `contract` Commands

**Files:**
- Modify: `src/logicbox_cli/cli.py`
- Modify: `src/logicbox_cli/stages.py`
- Modify: `tests/python/test_cli.py`

- [ ] **Step 1: Add failing parser and dispatch tests**

```python
def test_schema_command_writes_both_artifacts(tmp_path, fake_shen):
    source = tmp_path / "source.shen"
    source.write_text("(set *logicbox-artifact* [source])\n", encoding="utf-8")
    accepted = tmp_path / "accepted.shen"
    diagnostics = tmp_path / "diagnostics.shen"
    assert main([
        "schema", "--shen", str(fake_shen), "--input", str(source),
        "--accepted", str(accepted), "--diagnostics", str(diagnostics),
    ]) == 0
    assert accepted.is_file()
    assert diagnostics.is_file()


def test_analyze_compare_and_contract_commands(tmp_path, fake_shen):
    source = tmp_path / "source.shen"
    candidate = tmp_path / "candidate.shen"
    source.write_text("(set *logicbox-artifact* [source])\n", encoding="utf-8")
    candidate.write_text("(set *logicbox-artifact* [candidate])\n", encoding="utf-8")
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
    assert mutation.is_file()
    assert contract.is_file()


def test_existing_output_requires_replace(tmp_path, fake_shen):
    source = tmp_path / "source.shen"
    output = tmp_path / "findings.shen"
    source.write_text("(set *logicbox-artifact* [source])\n", encoding="utf-8")
    output.write_text("keep\n", encoding="utf-8")
    args = [
        "analyze", "--shen", str(fake_shen), "--input", str(source),
        "--output", str(output),
    ]
    assert main(args) == 3
    assert output.read_text(encoding="utf-8") == "keep\n"
    assert main([*args, "--replace"]) == 0
    assert output.read_text(encoding="utf-8").startswith("(set *logicbox-artifact*")
```

- [ ] **Step 2: Add a repository-root resolver and load orders**

```python
# append to src/logicbox_cli/stages.py
ENGINE_ROOT = Path(__file__).resolve().parents[2] / "shen"
SCHEMA_LOADS = (
    ENGINE_ROOT / "fact-schema.shen",
    ENGINE_ROOT / "fact-normalize.shen",
    ENGINE_ROOT / "fact-provenance.shen",
    ENGINE_ROOT / "fact-typecheck.shen",
)
ANALYSIS_LOADS = SCHEMA_LOADS + (
    ENGINE_ROOT / "rules.shen",
    ENGINE_ROOT / "artifact-protocol.shen",
)
```

Define request builders:

```python
def schema_requests(runtime: Path, source: Path, accepted: Path, diagnostics: Path, timeout: float) -> tuple[StageRequest, StageRequest]:
    common = {"input.shen": source}
    return (
        StageRequest(
            "schema-accepted",
            runtime,
            common,
            (Path("input.shen"), *SCHEMA_LOADS, ENGINE_ROOT / "artifact-protocol.shen", ENGINE_ROOT / "stages/emit-accepted.shen"),
            {"accepted.shen": accepted},
            timeout,
        ),
        StageRequest(
            "schema-diagnostics",
            runtime,
            common,
            (Path("input.shen"), *SCHEMA_LOADS, ENGINE_ROOT / "artifact-protocol.shen", ENGINE_ROOT / "stages/emit-diagnostics.shen"),
            {"diagnostics.shen": diagnostics},
            timeout,
        ),
    )


def analyze_request(runtime: Path, accepted: Path, findings: Path, timeout: float) -> StageRequest:
    return StageRequest(
        "analyze",
        runtime,
        {"input.shen": accepted},
        (
            Path("input.shen"),
            *SCHEMA_LOADS,
            ENGINE_ROOT / "rules.shen",
            ENGINE_ROOT / "artifact-protocol.shen",
            ENGINE_ROOT / "stages/emit-findings.shen",
        ),
        {"findings.shen": findings},
        timeout,
    )


def pipeline_findings_request(runtime: Path, source: Path, findings: Path, timeout: float) -> StageRequest:
    return StageRequest(
        "pipeline-findings",
        runtime,
        {"input.shen": source},
        (
            Path("input.shen"),
            *SCHEMA_LOADS,
            ENGINE_ROOT / "rules.shen",
            ENGINE_ROOT / "artifact-protocol.shen",
            ENGINE_ROOT / "stages/emit-findings.shen",
        ),
        {"findings.shen": findings},
        timeout,
    )


def compare_request(runtime: Path, source: Path, candidate: Path, mutation: Path, timeout: float) -> StageRequest:
    return StageRequest(
        "compare",
        runtime,
        {"source.shen": source, "candidate.shen": candidate},
        (
            Path("source.shen"),
            ENGINE_ROOT / "artifact-protocol.shen",
            ENGINE_ROOT / "stages/capture-source.shen",
            Path("candidate.shen"),
            ENGINE_ROOT / "stages/capture-candidate.shen",
            *SCHEMA_LOADS,
            ENGINE_ROOT / "rules.shen",
            ENGINE_ROOT / "stages/emit-mutation.shen",
        ),
        {"mutation.shen": mutation},
        timeout,
    )


def contract_request(runtime: Path, contract: Path, timeout: float) -> StageRequest:
    return StageRequest(
        "contract",
        runtime,
        {},
        (
            *SCHEMA_LOADS,
            ENGINE_ROOT / "artifact-protocol.shen",
            ENGINE_ROOT / "stages/emit-contract.shen",
        ),
        {"contract.shen": contract},
        timeout,
    )
```

Use the staged copy `input.shen` in the load order rather than the original
source path. Update `execute_stage()` so relative load paths are resolved inside
the stage directory and engine paths remain absolute.

- [ ] **Step 3: Implement CLI command arguments**

Every stage command accepts:

```text
--shen PATH
--timeout SECONDS
--replace
--trace
```

Artifact arguments are:

```text
schema:   --input --accepted --diagnostics
analyze:  --input --output
compare:  --source --candidate --output
contract: --output
```

Before execution, reject missing input files with exit `3`, missing runtimes with
exit `4`, existing outputs without `--replace` with exit `3`, and stage failures
with exit `5`. Successful commands print nothing unless `--trace` is enabled;
trace lines go to stderr.

- [ ] **Step 4: Run fake-runtime tests**

Run:

```bash
python3 -m pytest tests/python/test_cli.py tests/python/test_stages.py -q
```

Expected: all tests pass without a real Shen installation.

- [ ] **Step 5: Run real-runtime integration commands**

Run:

```bash
tmp="$(mktemp -d)"
logicbox schema \
  --shen "$SHEN_SBCL" \
  --input tests/artifacts/source-valid.shen \
  --accepted "$tmp/accepted.shen" \
  --diagnostics "$tmp/diagnostics.shen"
logicbox analyze \
  --shen "$SHEN_SBCL" \
  --input "$tmp/accepted.shen" \
  --output "$tmp/findings.shen"
```

Expected: exit `0`; all outputs load in Shen without preprocessing.

- [ ] **Step 6: Commit**

```bash
git add src/logicbox_cli tests/python
git commit -m "feat: add composable Shen artifact commands"
```

---

### Task 8: Add Immutable Runs And Operational Manifests

**Files:**
- Create: `src/logicbox_cli/manifest.py`
- Create: `src/logicbox_cli/runs.py`
- Create: `tests/python/test_manifest.py`
- Create: `tests/python/test_runs.py`
- Modify: `src/logicbox_cli/cli.py`

- [ ] **Step 1: Write failing manifest tests**

```python
# tests/python/test_manifest.py
import json

from logicbox_cli.manifest import write_manifest


def test_manifest_contains_only_operational_metadata(tmp_path):
    path = tmp_path / "manifest.json"
    write_manifest(
        path,
        {
            "run_id": "20260606T000000Z-abcd1234",
            "status": "completed",
            "artifacts": [{"path": "schema/accepted.shen", "sha256": "a" * 64, "bytes": 42}],
        },
    )
    data = json.loads(path.read_text(encoding="utf-8"))
    assert data["run_id"] == "20260606T000000Z-abcd1234"
    serialized = json.dumps(data)
    assert "[plan " not in serialized
    assert "payload" not in serialized
```

- [ ] **Step 2: Implement atomic manifest writing**

```python
# src/logicbox_cli/manifest.py
from __future__ import annotations

import json
from pathlib import Path
from typing import Any


def write_manifest(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(
        json.dumps(data, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    temporary.replace(path)
```

- [ ] **Step 3: Write failing run-layout tests**

Assert that `create_run()` produces:

```text
input/source.shen
schema/accepted.shen
schema/diagnostics.shen
analysis/findings.shen
schema/engine.stdout
schema/engine.stderr
analysis/engine.stdout
analysis/engine.stderr
manifest.json
```

Also assert exact source bytes and SHA-256 are preserved.

- [ ] **Step 4: Implement run coordination**

```python
# src/logicbox_cli/runs.py
from __future__ import annotations

import secrets
import shutil
from datetime import datetime, timezone
from pathlib import Path

from logicbox_cli.hashing import sha256_file
from logicbox_cli.manifest import write_manifest
from logicbox_cli.stages import (
    StageResult,
    execute_stage,
    pipeline_findings_request,
    schema_requests,
)


def new_run_id() -> str:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    return f"{stamp}-{secrets.token_hex(4)}"


def copy_exact(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)


def save_trace(stage_dir: Path, result: StageResult) -> None:
    stage_dir.mkdir(parents=True, exist_ok=True)
    (stage_dir / "engine.stdout").write_bytes(result.stdout)
    (stage_dir / "engine.stderr").write_bytes(result.stderr)


def create_run(source: Path, run_root: Path, runtime: Path, timeout: float) -> Path:
    run_id = new_run_id()
    temporary = run_root / f".{run_id}.tmp"
    final = run_root / run_id
    temporary.mkdir(parents=True, exist_ok=False)
    copied_source = temporary / "input/source.shen"
    copy_exact(source, copied_source)
    accepted = temporary / "schema/accepted.shen"
    diagnostics = temporary / "schema/diagnostics.shen"
    findings = temporary / "analysis/findings.shen"
    results: list[StageResult] = []
    try:
        schema_results = [
            execute_stage(request)
            for request in schema_requests(runtime, copied_source, accepted, diagnostics, timeout)
        ]
        results.extend(schema_results)
        save_trace(temporary / "schema", StageResult(
            "schema",
            max(result.exit_code for result in schema_results),
            sum(result.elapsed_seconds for result in schema_results),
            schema_results[0].started_at,
            schema_results[-1].finished_at,
            tuple(
                path
                for result in schema_results
                for path in result.load_paths
            ),
            "exited",
            b"".join(result.stdout for result in schema_results),
            b"".join(result.stderr for result in schema_results),
            {
                key: value
                for result in schema_results
                for key, value in result.output_hashes.items()
            },
            {
                key: value
                for result in schema_results
                for key, value in result.output_sizes.items()
            },
        ))
        analysis_result = execute_stage(
            pipeline_findings_request(runtime, copied_source, findings, timeout)
        )
        results.append(analysis_result)
        save_trace(temporary / "analysis", analysis_result)
        manifest = {
            "run_id": run_id,
            "status": "completed",
            "runtime": str(runtime),
            "input": {
                "path": "input/source.shen",
                "sha256": sha256_file(copied_source),
                "bytes": copied_source.stat().st_size,
            },
            "stages": [
                {
                    "name": result.name,
                    "exit_code": result.exit_code,
                    "elapsed_seconds": result.elapsed_seconds,
                    "started_at": result.started_at,
                    "finished_at": result.finished_at,
                    "load_paths": result.load_paths,
                    "termination_reason": result.termination_reason,
                    "output_hashes": result.output_hashes,
                    "output_sizes": result.output_sizes,
                }
                for result in results
            ],
        }
        write_manifest(temporary / "manifest.json", manifest)
        final.parent.mkdir(parents=True, exist_ok=True)
        temporary.replace(final)
        return final
    except Exception:
        failed = run_root / f".failed-{run_id}"
        if temporary.exists():
            temporary.replace(failed)
        raise
```

These fields are operational metadata produced by Python; no `.shen` artifact is
opened to derive them.

- [ ] **Step 5: Add `run` and `inspect` commands**

```text
logicbox run --input FILE --run-dir DIR [--shen PATH] [--timeout N]
logicbox inspect --run-dir DIR
```

`inspect` prints only manifest fields and artifact paths. It never parses `.shen`
payloads.

- [ ] **Step 6: Run tests**

Run:

```bash
python3 -m pytest tests/python/test_manifest.py tests/python/test_runs.py tests/python/test_cli.py -q
```

Expected: all tests pass.

- [ ] **Step 7: Commit**

```bash
git add src/logicbox_cli tests/python
git commit -m "feat: add immutable traceable LogicBox runs"
```

---

### Task 9: Build The Shen Behavioral Parity Gate

**Files:**
- Create: `tests/python/test_cleanup_gate.py`
- Create: `tests/python/test_shen_integration.py`
- Create: `tests/shen/wrap-current-facts.shen`
- Create: `tests/shen/emit-findings-lines.shen`
- Modify: `pyproject.toml`

- [ ] **Step 1: Mark real-runtime tests**

Add:

```toml
[tool.pytest.ini_options]
testpaths = ["tests/python"]
markers = [
  "shen: requires a real SHEN_SBCL runtime",
]
```

- [ ] **Step 2: Add integration helpers that skip only when runtime is absent**

```python
# tests/python/test_shen_integration.py
import os
from pathlib import Path

import pytest

from logicbox_cli.runtime import discover_shen


def real_shen() -> Path:
    runtime = discover_shen(Path(os.environ["SHEN_SBCL"]) if "SHEN_SBCL" in os.environ else None)
    if runtime is None:
        pytest.skip("real shen-sbcl runtime is not configured")
    return runtime
```

- [ ] **Step 3: Add artifact-chain assertions**

```python
@pytest.mark.shen
@pytest.mark.parametrize("fixture", ["source-valid.shen", "source-invalid.shen"])
def test_artifact_chain_is_loadable_and_source_is_unchanged(tmp_path, fixture):
    runtime = real_shen()
    source = Path("tests/artifacts") / fixture
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
        result = subprocess.run(
            [str(runtime), "-l", str(artifact.resolve())],
            capture_output=True,
            check=False,
        )
        assert result.returncode == 0, result.stderr.decode()
    assert source.read_bytes() == original
    for manifest in tmp_path.rglob("*.json"):
        serialized = manifest.read_text(encoding="utf-8")
        for forbidden in ("[plan ", "[claim ", "[fact-type-error", '"payload"'):
            assert forbidden not in serialized
```

Import `subprocess` and `main`.

- [ ] **Step 4: Re-run every preserved Shen fixture through the new findings emitter**

```shen
\\ tests/shen/wrap-current-facts.shen
(set *logicbox-artifact*
  (make-logicbox-artifact source schema-v1 (value *facts*)))
```

```shen
\\ tests/shen/emit-findings-lines.shen
(define write-finding-lines-h
  [] Stream -> (close Stream)
  [Finding | Rest] Stream ->
    (do
      (pr (make-string "~S~%" Finding) Stream)
      (write-finding-lines-h Rest Stream)))

(define write-finding-lines
  Path Findings -> (write-finding-lines-h Findings (open Path out)))

(write-finding-lines
  "actual.expected"
  (logicbox-artifact-payload (value *logicbox-artifact*)))
```

```python
@pytest.mark.shen
@pytest.mark.parametrize(
    "model",
    sorted(Path("tests/gold").glob("*.shen"))
    + sorted(Path("tests/edge").glob("*.shen")),
    ids=lambda path: str(path),
)
def test_preserved_fixture_output_matches(model, tmp_path):
    runtime = real_shen()
    root = Path.cwd().resolve()
    command = [
        str(runtime),
        "-l", str(model.resolve()),
        "-l", str(root / "shen/fact-schema.shen"),
        "-l", str(root / "shen/fact-normalize.shen"),
        "-l", str(root / "shen/fact-provenance.shen"),
        "-l", str(root / "shen/fact-typecheck.shen"),
        "-l", str(root / "shen/rules.shen"),
        "-l", str(root / "shen/artifact-protocol.shen"),
        "-l", str(root / "tests/shen/wrap-current-facts.shen"),
        "-l", str(root / "shen/stages/emit-findings.shen"),
        "-l", "findings.shen",
        "-l", str(root / "tests/shen/emit-findings-lines.shen"),
    ]
    completed = subprocess.run(command, cwd=tmp_path, capture_output=True, check=False)
    assert completed.returncode == 0, completed.stderr.decode()
    expected = model.with_suffix(".expected").read_bytes()
    assert (tmp_path / "actual.expected").read_bytes() == expected
```

Python compares bytes only; Shen constructs the artifact and serializes its
payload into the legacy expected-line format.

- [ ] **Step 5: Add the cleanup gate**

```python
# tests/python/test_cleanup_gate.py
from pathlib import Path


PRESERVED = (
    "shen/fact-schema.shen",
    "shen/fact-normalize.shen",
    "shen/fact-provenance.shen",
    "shen/fact-typecheck.shen",
    "shen/fact-regression.shen",
    "shen/rules.shen",
)


def test_preserved_engine_files_exist():
    for name in PRESERVED:
        assert Path(name).is_file(), name


def test_legacy_orchestration_is_absent_after_cleanup():
    for name in ("scripts", "work", "output", "logicbox (skill)"):
        assert not Path(name).exists(), name
```

Mark the second test `xfail(strict=True, reason="enabled in cleanup task")`
until Task 11, then remove the marker.

- [ ] **Step 6: Run all gates with the real runtime**

Run:

```bash
SHEN_SBCL="$SHEN_SBCL" python3 -m pytest -q
```

Expected: all tests pass, with only the cleanup-absence test reported as the
single expected failure.

- [ ] **Step 7: Commit**

```bash
git add pyproject.toml tests/python
git commit -m "test: gate rearchitecture on Shen behavioral parity"
```

---

### Task 10: Rewrite Documentation For The New Toolchain

**Files:**
- Modify: `README.md`
- Modify: `docs/fact-schema.md`
- Modify: `docs/prompt-contract.md`
- Modify: `.gitignore`

- [ ] **Step 1: Replace README workflow**

Document only:

```text
python3 -m pip install -e '.[test]'
logicbox doctor
logicbox schema --input source.shen --accepted accepted.shen --diagnostics diagnostics.shen
logicbox analyze --input accepted.shen --output findings.shen
logicbox compare --source accepted.shen --candidate candidate.shen --output mutation.shen
logicbox run --input source.shen --run-dir ./runs
logicbox inspect --run-dir ./runs/<run-id>
```

State prominently that `.shen` files are the sole logical interchange format
and JSON manifests contain operational metadata only.

- [ ] **Step 2: Update schema documentation**

Add the exact artifact envelope and explain `source`, `accepted`,
`diagnostics`, `findings`, `mutation`, and `contract` kinds. Preserve the
predicate registry documentation that still matches `fact-schema.shen`.

- [ ] **Step 3: Replace prompt-contract instructions**

Explain that an AI must emit a complete `source` artifact and that malformed
output is sent unchanged to Shen's schema stage. Remove all directions that ask
Python, JavaScript, AWK, or a report renderer to repair facts.

- [ ] **Step 4: Update ignored operational files**

```gitignore
.DS_Store
.clj-kondo/
.lsp/
.superpowers/
.pytest_cache/
__pycache__/
*.py[cod]
*.tmp
*~
runs/
dist/
build/
*.egg-info/
```

- [ ] **Step 5: Verify documented commands**

Run every README command against `tests/artifacts/source-valid.shen` in a
temporary directory. Expected: all complete with exit `0`, and `git status
--short` shows no generated artifacts.

- [ ] **Step 6: Commit**

```bash
git add README.md docs/fact-schema.md docs/prompt-contract.md .gitignore
git commit -m "docs: describe Shen-native LogicBox workflow"
```

---

### Task 11: Remove The Patchwork Architecture

**Files:**
- Delete: `logicbox`
- Delete: `scripts/preflight-facts.js`
- Delete: `scripts/rewrite-safety.js`
- Delete: `work/*`
- Delete: `output/*`
- Delete: `logicbox (skill)/**`
- Delete: superseded `shen/run*.shen`
- Modify: `tests/python/test_cleanup_gate.py`

- [ ] **Step 1: Run the complete pre-cleanup gate**

Run:

```bash
SHEN_SBCL="$SHEN_SBCL" python3 -m pytest -q
git status --short
```

Expected: all tests pass except the single strict expected cleanup failure.

- [ ] **Step 2: Record the retained Shen inventory**

Run:

```bash
git ls-files 'shen/*.shen' 'tests/**/*.shen' 'tests/**/*.expected' | sort > /tmp/logicbox-retained-before.txt
```

Review the list and confirm it includes the six preserved engine files and all
gold/edge fixtures.

- [ ] **Step 3: Delete superseded tracked architecture**

Run:

```bash
git rm logicbox
git rm -r scripts work output 'logicbox (skill)'
git rm \
  shen/run.shen \
  shen/run-mutation.shen \
  shen/run-preflight.shen \
  shen/run-prompt-contract.shen \
  shen/run-rewrite-safety.shen \
  shen/run-fact-regression.shen
```

- [ ] **Step 4: Remove generated editor and brainstorming state**

Run:

```bash
rm -rf .clj-kondo .lsp .superpowers .pytest_cache
find . -name __pycache__ -type d -prune -exec rm -rf {} +
```

These paths are generated and ignored; they contain no Shen engine artifacts.

- [ ] **Step 5: Enable the cleanup test**

Remove the `xfail` marker from
`test_legacy_orchestration_is_absent_after_cleanup`.

- [ ] **Step 6: Verify preserved engine files and fixtures**

Run:

```bash
for file in \
  shen/fact-schema.shen \
  shen/fact-normalize.shen \
  shen/fact-provenance.shen \
  shen/fact-typecheck.shen \
  shen/fact-regression.shen \
  shen/rules.shen
do
  test -f "$file"
done
find tests -name '*.shen' -o -name '*.expected' | sort > /tmp/logicbox-retained-after.txt
test -s /tmp/logicbox-retained-after.txt
```

Expected: every preserved engine file exists and the fixture inventory is
nonempty.

- [ ] **Step 7: Run the complete post-cleanup gate**

Run:

```bash
SHEN_SBCL="$SHEN_SBCL" python3 -m pytest -q
git diff --check
git status --short
```

Expected: all tests pass; no legacy orchestration or generated work/output
directories remain.

- [ ] **Step 8: Commit cleanup**

```bash
git add -A
git commit -m "refactor: remove legacy LogicBox orchestration"
```

---

### Task 12: Final Installation And Replay Verification

**Files:**
- Modify only if verification exposes a defect.

- [ ] **Step 1: Test a clean installation**

Run:

```bash
python3 -m venv /tmp/logicbox-venv
/tmp/logicbox-venv/bin/pip install '.[test]'
/tmp/logicbox-venv/bin/logicbox --version
```

Expected: `logicbox 3.0.0`.

- [ ] **Step 2: Run doctor**

Run:

```bash
SHEN_SBCL="$SHEN_SBCL" /tmp/logicbox-venv/bin/logicbox doctor
```

Expected: `shen.runtime	ok	<resolved path>` on stdout and exit `0`.

- [ ] **Step 3: Produce and replay an immutable run**

Run:

```bash
tmp="$(mktemp -d)"
SHEN_SBCL="$SHEN_SBCL" /tmp/logicbox-venv/bin/logicbox run \
  --input tests/artifacts/source-valid.shen \
  --run-dir "$tmp/runs"
run_dir="$(find "$tmp/runs" -mindepth 1 -maxdepth 1 -type d | head -1)"
/tmp/logicbox-venv/bin/logicbox inspect --run-dir "$run_dir"
```

Expected: the run contains exact source, accepted, diagnostics, findings,
stdout/stderr traces, and `manifest.json`.

- [ ] **Step 4: Verify repository cleanliness**

Run:

```bash
git status --short
find . -maxdepth 2 \( -name work -o -name output -o -name scripts -o -name '.superpowers' \)
```

Expected: no output from either command.

- [ ] **Step 5: Tag the architectural checkpoint**

Run:

```bash
git tag -a v3.0.0-alpha.1 -m "Shen-native LogicBox architecture"
```

Expected: annotated local tag created after all tests and cleanup pass.
