# LogicBox Shen-Native Architecture Design

Date: 2026-06-06

## Purpose

Rebuild LogicBox as a traceable Unix-style toolchain around the existing Shen
reasoning engine. The redesign may replace the current Zsh, AWK, JavaScript,
mutable workspace, and report orchestration. The Shen kernel, schema logic, and
behavioral tests are the valuable core and remain authoritative.

The first milestone is a clean command-line architecture. A local web UI may be
added later as a client of the same commands and artifacts.

## Primary Invariant

Only Shen may read, interpret, normalize, validate, transform, compare, or emit
logical artifacts.

Python may treat a Shen artifact as an opaque file. It may copy it, hash it,
select it as process input, capture it as process output, and record its path.
Python must not translate logical data between Shen and another representation.

In particular, Python must not:

- convert Shen facts or findings to JSON;
- parse Shen expressions with regular expressions or partial tokenization;
- reconstruct Shen expressions from Python values;
- normalize, reorder, filter, or classify Shen facts;
- generate logical Shen facts from Python objects;
- feed rendered reports back into a Shen stage.

Operational metadata may use JSON because it is not part of the logic protocol.

## Architectural Principles

1. **Shen artifacts are authoritative.** Reports and future UI views are
   projections, never sources of logical truth.
2. **Every stage has explicit inputs and outputs.** No command depends on a
   process-wide `work/` or `output/` directory.
3. **Standard output is clean.** A command writes either its requested artifact
   or a concise operational result to stdout, never both.
4. **Diagnostics use stderr.** Human logs, trace messages, and runtime failures
   do not contaminate logical output.
5. **Runs are immutable and replayable.** Exact inputs, outputs, load order,
   hashes, runtime versions, exit status, and stderr are retained.
6. **Files are written atomically.** A failed process cannot leave an artifact
   that appears complete.
7. **The pipeline is composable.** Individual stages run independently, while a
   higher-level command can coordinate a complete run.
8. **No language unification for its own sake.** Shen performs logic; Python
   performs process and artifact management. Additional runtimes require a
   concrete capability that neither provides safely.

## Components

### Shen Kernel

The existing rule, schema, normalization, provenance, typecheck, preflight, and
mutation definitions remain Shen code. Existing regression, gold, edge, stress,
and fuzz tests establish the behavioral baseline.

Kernel files do not perform project discovery, directory management, API calls,
or presentation rendering.

### Shen Stage Runners

Small Shen programs provide stable stage boundaries. Each runner loads complete
Shen artifacts and writes complete Shen artifacts to destinations supplied by
the coordinator. Artifact selection and serialization happen inside Shen.

Initial runners:

- `schema`: normalize and typecheck source facts;
- `analyze`: derive structural findings from accepted facts;
- `compare`: derive mutation findings from source and candidate facts;
- `pipeline`: run schema gating and conditionally run analysis entirely in Shen;
- `contract`: emit the schema/prompt contract as a Shen artifact.

Preflight enrichment belongs inside a Shen stage. It must not be recreated in
Python or JavaScript.

### Python CLI

A single Python executable named `logicbox` owns:

- argument parsing;
- runtime discovery and health checks;
- explicit path validation;
- isolated run-directory creation;
- deterministic Shen load-order construction;
- subprocess execution, timeout, cancellation, and locking;
- byte-for-byte capture of Shen stdout and stderr;
- hashing and operational manifests;
- atomic promotion of completed artifacts;
- orchestration of multi-stage runs;
- optional report rendering from separately produced presentation data;
- future AI provider and UI integration at non-logical boundaries.

The Python CLI does not contain inference rules or logical artifact conversion.

## Shen Artifact Contract

Every logical artifact is a UTF-8 `.shen` file that can be loaded by the
supported Shen runtime without preprocessing.

Each artifact defines one documented global value:

```shen
(set *logicbox-artifact*
  [logicbox-artifact
    [kind source]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [plan p1]
      ]]])
```

The envelope itself is Shen data. A stage reads and emits it using Shen code.
Python treats the complete file as opaque bytes.

Required envelope fields:

- `kind`: `source`, `accepted`, `diagnostics`, `findings`, or `mutation`;
- `protocol`: initially `logicbox-artifact-v1`;
- `schema`: the fact schema version;
- `payload`: a Shen list appropriate to the artifact kind.

Optional logical metadata, including fact provenance, belongs in the Shen
payload. Operational metadata, such as wall-clock duration or process ID,
belongs only in `manifest.json`.

### Source Artifact

Contains the exact candidate facts supplied for a run. The original source
artifact is preserved byte-for-byte.

### Accepted Artifact

Contains the normalized core facts accepted by the Shen schema gate. It is
emitted by Shen, even when it is logically equivalent to the source.

### Diagnostics Artifact

Contains normalization records, type errors, warnings, and suggestions emitted
by the schema gate. It is produced alongside the accepted artifact.

If hard schema errors occur, `accepted.shen` remains a valid artifact with an
empty accepted payload. The diagnostics artifact explains the rejection.

### Findings Artifact

Contains only Shen-derived structural findings and statuses for accepted facts.
It is not mixed with logs, headings, Markdown, or runtime startup text.

### Mutation Artifact

Contains only Shen-derived comparison and mutation findings for source and
candidate fact artifacts.

## Stage Boundaries

### Schema

```text
source.shen
  -> accepted.shen
  -> diagnostics.shen
```

The stage preserves the exact source and asks Shen to emit separate accepted and
diagnostic artifacts. A hard schema error is a completed logical result, not a
process crash.

### Analyze

```text
accepted.shen
  -> findings.shen
```

Analysis refuses artifacts with an unsupported protocol, schema, or kind. Such
refusal is emitted as a Shen diagnostic when the runtime can load the input.

### Compare

```text
accepted-source.shen + accepted-candidate.shen
  -> mutation.shen
```

Both sides are accepted Shen artifacts. Textual comparison or AI-generated prose
does not enter this stage directly.

### Full Run

```text
source.shen
  -> Shen pipeline runner
      -> schema
      -> analyze when schema permits
  -> immutable run directory
```

The Shen pipeline runner, not Python, decides whether hard schema errors prevent
analysis. Python invokes the runner and captures every artifact it emits without
inspecting diagnostic contents. A schema rejection remains a completed logical
run with diagnostics and no findings artifact.

## Command-Line Interface

Initial commands:

```text
logicbox doctor
logicbox schema --input FILE --accepted FILE --diagnostics FILE
logicbox analyze --input FILE --output FILE
logicbox compare --source FILE --candidate FILE --output FILE
logicbox run --input FILE --run-dir DIR
logicbox inspect --run-dir DIR
```

Common behavior:

- `-` may represent stdin or stdout only for a single artifact stream.
- Output paths are explicit.
- Existing files are not overwritten unless `--replace` is supplied.
- `--trace` writes operational details to stderr and the run manifest.
- `--quiet` suppresses non-error stderr output.
- `--timeout` limits the Shen subprocess.
- `--shen PATH` overrides configured runtime discovery.

Commands that create multiple artifacts require file paths or a run directory;
they do not multiplex multiple logical artifacts onto stdout.

When a file path is requested, the Shen stage writes the logical artifact to a
temporary destination supplied by Python. Python may atomically rename the
completed opaque file but does not serialize its contents. When stdout is
requested, Shen emits exactly one complete artifact and Python forwards the
captured bytes unchanged.

## Exit Codes

- `0`: command and requested Shen stage completed;
- `2`: invalid CLI usage or invalid operational configuration;
- `3`: input/output filesystem failure;
- `4`: Shen runtime missing or unhealthy;
- `5`: Shen process failed, timed out, or emitted no valid stage artifact;
- `6`: unsupported artifact protocol, schema, or stage kind;
- `7`: lock or concurrent-run conflict;
- `8`: internal coordinator failure.

A schema rejection or mutation finding is logical output and normally exits
`0`. Consumers inspect the emitted Shen artifact rather than conflating a
finding with process failure.

## Run Directory

```text
runs/<run-id>/
  input/
    source.shen
  schema/
    accepted.shen
    diagnostics.shen
    engine.stdout
    engine.stderr
  analysis/
    findings.shen
    engine.stdout
    engine.stderr
  manifest.json
```

Comparison runs additionally contain:

```text
  input/
    source-accepted.shen
    candidate-accepted.shen
  compare/
    mutation.shen
    engine.stdout
    engine.stderr
```

Artifacts are first written under a temporary directory on the same filesystem.
The run directory becomes visible at its final path only after the manifest and
all completed artifacts have been flushed and atomically renamed.

Run IDs are sortable UTC timestamps plus a random suffix. Project identity is
not encoded into logical artifacts unless Shen provenance explicitly requires
it.

## Operational Manifest

`manifest.json` records no logical facts or findings. It contains:

- run ID and stage names;
- start and finish timestamps;
- command-line arguments after secret redaction;
- executable paths and versions;
- exact Shen load order;
- input and output paths;
- SHA-256 hashes and byte sizes;
- process exit codes and termination reason;
- elapsed time;
- completion state.

Hashes cover exact file bytes. The manifest may point to `.shen` artifacts but
must not embed their payload.

## Runtime Discovery And Doctor

The runtime path must not be hard-coded.

Discovery order:

1. `--shen PATH`;
2. project or user configuration;
3. `SHEN_SBCL`;
4. executable lookup on `PATH`.

`logicbox doctor` verifies:

- Python version;
- configured Shen executable presence and executability;
- Shen startup;
- loading of the LogicBox kernel;
- a minimal schema artifact round trip;
- write and atomic-rename support in the target run location.

Each check reports a stable identifier, status, and remediation. Doctor performs
no project mutation.

## Output And Traceability

When stdout is the artifact destination, Shen stage stdout must contain only the
requested Shen artifact. When all artifacts have file destinations, stage
stdout must be empty. Runners must not use marker-delimited extraction such as
`LOGICBOX-BEGIN`.

Raw stdout is preserved even when the coordinator also promotes it as the stage
artifact. Runtime startup messages or unexpected text make the stage fail rather
than being filtered heuristically.

Human reports are derived views. During the first migration, existing Markdown
reports may be retained for comparison, but they are never consumed by another
logical stage.

## AI And Revision Boundary

AI integration is deferred until the Shen-native CLI is stable.

When added:

- AI may produce prose or propose a complete source `.shen` artifact;
- an AI-produced `.shen` file is untrusted source input;
- the schema stage must accept or reject it;
- Python must not repair AI-produced Shen syntax by translating its semantics;
- revised prose must receive fresh Shen facts before structural comparison;
- guarded and free revision modes remain presentation/workflow concepts, not
  changes to Shen artifact integrity.

Credentials and provider responses are operational artifacts. Secrets are never
stored in run manifests.

## Migration Strategy

### Phase 1: Characterize The Kernel

- Freeze the current Shen files and test fixtures as the behavioral baseline.
- Add tests that capture accepted facts, diagnostics, findings, and mutation
  results independently.
- Document supported Shen/SBCL versions.

### Phase 2: Introduce Shen Artifact Envelopes

- Implement envelope constructors and accessors in Shen.
- Add Shen-native schema, analysis, and comparison runners.
- Prove that each emitted artifact can be loaded by the next Shen stage without
  translation.
- Prove byte preservation of source artifacts.

### Phase 3: Build The Python Coordinator

- Implement runtime discovery, `doctor`, subprocess execution, atomic artifacts,
  manifests, exit codes, and immutable run directories.
- Keep logical payloads opaque.
- Add integration tests using temporary directories and a real Shen runtime.

### Phase 4: Replace Presentation Plumbing

- Remove AWK parsing and marker extraction.
- Render optional human reports from a dedicated Shen-produced presentation
  artifact or through a future complete Shen parser. Do not parse partial Shen
  syntax with regular expressions.
- Retire global `work/` and `output/` state.

### Phase 5: Rebuild Revision Support

- Reassess the JavaScript patch system against the Shen-only logical boundary.
- Keep text manipulation outside Shen only when it operates strictly on prose.
- Require all logical rewrite judgments and generated logical artifacts to pass
  through Shen-native stages.

### Phase 6: Add AI And UI Clients

- Add optional OpenAI/OpenRouter adapters.
- Add a local web application that invokes the same Python CLI/application
  service and reads immutable run artifacts.

## Testing Requirements

- Existing Shen regression, gold, edge, stress, and fuzz behavior remains green.
- Every stage output is a complete loadable Shen file.
- Source bytes and hashes remain unchanged through coordination.
- `accepted.shen` and `diagnostics.shen` are both preserved.
- Analysis never runs after a hard schema rejection.
- Logical rejection exits `0`; runtime failure uses the documented nonzero code.
- Unexpected stdout contamination fails the stage.
- Interrupted writes leave no final artifact or apparently complete run.
- Replaying a manifest load order with the same artifacts reproduces exact Shen
  output under the same runtime version.
- Python tests assert that no logical payload appears in JSON manifests.
- Tests cover paths containing spaces and macOS/Linux runtime discovery.

## Out Of Scope

- Backward compatibility with the current shell command implementation;
- a browser UI;
- accounts, collaboration, or public hosting;
- a database;
- porting Shen rules to Python or another language;
- a JSON representation of facts or findings;
- automatic semantic repair of malformed Shen artifacts;
- editing the Shen kernel through an application UI.

## Success Criteria

The architecture is unified when:

1. all logical stages exchange only complete Shen artifacts;
2. Python coordinates those stages without interpreting their payloads;
3. every run is isolated, immutable, traceable, and replayable;
4. stdout, stderr, artifacts, and exit codes have documented meanings;
5. no stage relies on mutable global workspace files or report parsing;
6. the existing Shen engine behavior is preserved by automated tests;
7. future AI and UI clients can use the toolchain without creating a second
   implementation of LogicBox.
