# LogicBox

LogicBox is a self-hosted, file-oriented reasoning tool. Shen owns the logical
engine and every logical artifact. Python provides a small Unix-style
coordinator for runtime discovery, isolated process execution, exact byte
preservation, hashes, traces, and immutable run directories.

LogicBox checks the structure represented by supplied facts. It does not prove
that claims are true, browse for evidence, or silently fill gaps.

## Architectural Boundary

`.shen` files are the sole logical interchange format. Only Shen may read,
validate, normalize, transform, or emit their logical payloads.

Python treats `.shen` files as opaque bytes. `manifest.json` contains
operational metadata only: paths, hashes, byte sizes, runtime details, stage
status, and timing. It never contains facts, findings, or translated payloads.

## Install

Python 3.11+ and a Shen/SBCL batch executable are required.

```sh
python3 -m pip install -e '.[test]'
export SHEN_SBCL=/path/to/shen-sbcl
logicbox doctor
```

The Shen executable must accept ordered `-l FILE` arguments and terminate after
loading them.

## Artifact Commands

Validate a complete source artifact:

```sh
logicbox schema \
  --input source.shen \
  --accepted accepted.shen \
  --diagnostics diagnostics.shen
```

Analyze accepted facts:

```sh
logicbox analyze --input accepted.shen --output findings.shen
```

Compare accepted source and candidate artifacts:

```sh
logicbox compare \
  --source accepted.shen \
  --candidate candidate.shen \
  --output mutation.shen
```

Emit the registry-derived schema contract:

```sh
logicbox contract --output contract.shen
```

Commands refuse to overwrite outputs unless `--replace` is supplied. Add
`--trace` to send stage timing and exact Shen stdout/stderr to stderr.

## Immutable Runs

Create a traceable run:

```sh
logicbox run --input source.shen --run-dir ./runs
```

The command prints the new run path. A completed run contains:

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

Inspect operational metadata without parsing artifacts:

```sh
logicbox inspect --run-dir ./runs/<run-id>
```

Runs are assembled in private temporary directories and atomically finalized.
Failed runs are retained with a `.failed-` prefix for diagnosis.

## AI Integration

An AI extractor must emit one complete `source` artifact as documented in
[`docs/prompt-contract.md`](docs/prompt-contract.md). Its output is passed
unchanged to Shen. A later text editor or AI revision interface can consume
Shen-produced findings, but it must never rewrite the logical artifacts itself.

## Tests

```sh
SHEN_SBCL="$SHEN_SBCL" python3 -m pytest -q
```

The suite includes exact behavioral parity checks for the preserved gold and
edge Shen fixtures.
