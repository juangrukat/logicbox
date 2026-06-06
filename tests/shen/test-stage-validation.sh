#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
SHEN=${SHEN_SBCL:-$(command -v shen-sbcl || true)}

if [ -z "$SHEN" ] || [ ! -x "$SHEN" ]; then
  echo "Shen runtime not found or not executable; set SHEN_SBCL or install shen-sbcl on PATH" >&2
  exit 1
fi

run_rejected() {
  name=$1
  fixture=$2
  stage=$3
  output=$4
  work=$(mktemp -d)

  cp "$fixture" "$work/input.shen"
  if (
    cd "$work"
    "$SHEN" \
      -l input.shen \
      -l "$ROOT/shen/fact-schema.shen" \
      -l "$ROOT/shen/fact-normalize.shen" \
      -l "$ROOT/shen/fact-provenance.shen" \
      -l "$ROOT/shen/fact-typecheck.shen" \
      -l "$ROOT/shen/rules.shen" \
      -l "$ROOT/shen/artifact-protocol.shen" \
      -l "$stage"
  ) >"$work/stdout" 2>"$work/stderr"; then
    echo "$name: expected Shen runtime failure" >&2
    rm -rf "$work"
    exit 1
  fi

  if [ -e "$work/$output" ]; then
    echo "$name: rejected artifact produced $output" >&2
    rm -rf "$work"
    exit 1
  fi

  echo "$name ok"
  rm -rf "$work"
}

INVALID="$ROOT/tests/shen/invalid-artifacts"
ACCEPTED="$ROOT/shen/stages/emit-accepted.shen"
DIAGNOSTICS="$ROOT/shen/stages/emit-diagnostics.shen"
FINDINGS="$ROOT/shen/stages/emit-findings.shen"

run_rejected wrong-kind-accepted "$INVALID/wrong-kind.shen" "$ACCEPTED" accepted.shen
run_rejected wrong-kind-diagnostics "$INVALID/wrong-kind.shen" "$DIAGNOSTICS" diagnostics.shen
run_rejected wrong-kind-findings "$INVALID/wrong-kind.shen" "$FINDINGS" findings.shen
run_rejected unknown-protocol "$INVALID/unknown-protocol.shen" "$ACCEPTED" accepted.shen
run_rejected unknown-schema "$INVALID/unknown-schema.shen" "$ACCEPTED" accepted.shen
run_rejected unknown-field "$INVALID/unknown-field.shen" "$ACCEPTED" accepted.shen
run_rejected missing-payload "$INVALID/missing-payload.shen" "$ACCEPTED" accepted.shen
run_rejected duplicate-kind "$INVALID/duplicate-kind.shen" "$ACCEPTED" accepted.shen
run_rejected malformed-field "$INVALID/malformed-field.shen" "$ACCEPTED" accepted.shen
