#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
SHEN=${SHEN_SBCL:-$(command -v shen-sbcl || true)}

if [ -z "$SHEN" ] || [ ! -x "$SHEN" ]; then
  echo "Shen runtime not found or not executable; set SHEN_SBCL or install shen-sbcl on PATH" >&2
  exit 1
fi

SOURCE="$ROOT/tests/artifacts/source-accepted.shen"
CANDIDATE="$ROOT/tests/artifacts/candidate-valid.shen"
PROTOCOL="$ROOT/shen/artifact-protocol.shen"
CAPTURE_SOURCE="$ROOT/shen/stages/capture-source.shen"
CAPTURE_CANDIDATE="$ROOT/shen/stages/capture-candidate.shen"
EMITTER="$ROOT/shen/stages/emit-mutation.shen"
ASSERT_MUTATION="$ROOT/tests/shen/assert-mutation-artifact.shen"
ASSERT_STATE="$ROOT/tests/shen/assert-mutation-stage-state.shen"
ASSERT_DIAGNOSTICS="$ROOT/tests/shen/assert-mutation-diagnostics.shen"
INVALID_CANDIDATE="$ROOT/tests/shen/mutation-invalid-candidate.shen"
INVALID="$ROOT/tests/shen/invalid-artifacts"

run_engine() {
  source_fixture=$1
  candidate_fixture=$2
  work=$3

  (
    cd "$work"
    "$SHEN" \
      -l "$source_fixture" \
      -l "$PROTOCOL" \
      -l "$CAPTURE_SOURCE" \
      -l "$candidate_fixture" \
      -l "$CAPTURE_CANDIDATE" \
      -l "$ROOT/shen/fact-schema.shen" \
      -l "$ROOT/shen/fact-normalize.shen" \
      -l "$ROOT/shen/fact-provenance.shen" \
      -l "$ROOT/shen/fact-typecheck.shen" \
      -l "$ROOT/shen/rules.shen" \
      -l "$EMITTER"
  )
}

run_valid() {
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT HUP INT TERM

  (
    cd "$work"
    "$SHEN" \
      -l "$SOURCE" \
      -l "$PROTOCOL" \
      -l "$CAPTURE_SOURCE" \
      -l "$CANDIDATE" \
      -l "$CAPTURE_CANDIDATE" \
      -l "$ROOT/shen/fact-schema.shen" \
      -l "$ROOT/shen/fact-normalize.shen" \
      -l "$ROOT/shen/fact-provenance.shen" \
      -l "$ROOT/shen/fact-typecheck.shen" \
      -l "$ROOT/shen/rules.shen" \
      -l "$EMITTER" \
      -l "$ASSERT_STATE"
  ) >"$work/stdout" 2>"$work/stderr"

  (
    cd "$work"
    "$SHEN" \
      -l "$ROOT/shen/fact-schema.shen" \
      -l "$PROTOCOL" \
      -l "$ASSERT_MUTATION"
  ) >"$work/assert.stdout" 2>"$work/assert.stderr"

  echo "mutation-valid ok"
  rm -rf "$work"
  trap - EXIT HUP INT TERM
}

run_schema_invalid() {
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT HUP INT TERM

  run_engine "$SOURCE" "$INVALID_CANDIDATE" "$work" \
    >"$work/stdout" 2>"$work/stderr"

  (
    cd "$work"
    "$SHEN" \
      -l "$ROOT/shen/fact-schema.shen" \
      -l "$PROTOCOL" \
      -l "$ASSERT_DIAGNOSTICS"
  ) >"$work/assert.stdout" 2>"$work/assert.stderr"

  echo "mutation-schema-diagnostics ok"
  rm -rf "$work"
  trap - EXIT HUP INT TERM
}

run_rejected() {
  name=$1
  source_fixture=$2
  candidate_fixture=$3
  work=$(mktemp -d)
  trap 'rm -rf "$work"' EXIT HUP INT TERM

  if run_engine "$source_fixture" "$candidate_fixture" "$work" \
      >"$work/stdout" 2>"$work/stderr"; then
    echo "$name: expected Shen runtime failure" >&2
    exit 1
  fi

  if [ -e "$work/mutation.shen" ]; then
    echo "$name: rejected artifacts produced mutation.shen" >&2
    exit 1
  fi

  echo "$name ok"
  rm -rf "$work"
  trap - EXIT HUP INT TERM
}

run_valid
run_schema_invalid

run_rejected source-wrong-kind "$INVALID/wrong-kind.shen" "$CANDIDATE"
run_rejected candidate-wrong-kind "$SOURCE" "$INVALID/wrong-kind.shen"
run_rejected source-unknown-protocol "$INVALID/unknown-protocol.shen" "$CANDIDATE"
run_rejected candidate-unknown-protocol "$SOURCE" "$INVALID/unknown-protocol.shen"
run_rejected source-unknown-schema "$INVALID/unknown-schema.shen" "$CANDIDATE"
run_rejected candidate-unknown-schema "$SOURCE" "$INVALID/unknown-schema.shen"
run_rejected schema-mismatch "$SOURCE" "$INVALID/unknown-schema.shen"
run_rejected source-malformed "$INVALID/malformed-field.shen" "$CANDIDATE"
run_rejected candidate-malformed "$SOURCE" "$INVALID/malformed-field.shen"
run_rejected source-duplicate-field "$INVALID/duplicate-kind.shen" "$CANDIDATE"
run_rejected candidate-duplicate-field "$SOURCE" "$INVALID/duplicate-kind.shen"
run_rejected source-missing-payload "$INVALID/missing-payload.shen" "$CANDIDATE"
run_rejected candidate-missing-payload "$SOURCE" "$INVALID/missing-payload.shen"
