# LogicBox Command Reference

## Check-and-Repair Commands

### `./logicbox preflight`
## Check-and-Repair Commands

### `./logicbox review`
**Primary human-facing command.** Runs the full Shen check and produces a human-readable report at `output/check-report.md`. The report is structured as: next action, source-facing diagnostics, source frames (draft + facts), file map, and expert appendices (raw Shen flags, raw facts). Read this first — it's designed to answer "what do I do next?" before diving into raw flags.

### `./logicbox check`
Raw/expert audit path. Runs `ai-facts.shen` + `adapter-facts.shen` (if present) through Shen with `rules.shen` and `run.shen`. Produces bare Shen flags at `output/shen-output.txt` and a legacy report at `output/check-report.md`. Use when you need undecorated flags without the review report's formatting and next-action layer.

### `./logicbox mutation`
Loads `ai-facts.shen` + `rewrite-facts.shen` through Shen's `run-mutation.shen`. Detects modality, scope, source, and target drift between original and rewrite facts. Output to `output/mutation-output.txt`.

## Rewrite Pipeline Commands

### `./logicbox rewrite-preflight`
Validates `work/rewrite-patch.json` via `scripts/rewrite-safety.js validate-patch`. Accepts `--legacy-js-rewrite-safety` for parity comparison. Blocks invented thresholds, named programs, scope changes, modality strengthening, and deleted protected claims.

### `./logicbox rewrite`
Applies validated patch, writes `work/rewrite.md` and `output/rewrite-report.md`. In `structure_only` mode: applies operations directly. In `rewrite_with_user_facts` mode: also runs Shen structural re-check and consistency report.

### `./logicbox rewrite-mutation`
JS-level textual/provenance mutation check via `scripts/rewrite-safety.js mutation`. Checks draft text against rewrite for scope changes, modality drift, and deleted conditions.

### `./logicbox recheck-report`
Generates delta report comparing before/after Shen output for `rewrite_with_user_facts` mode. Reports consistency status and flag changes.

### `./logicbox rewrite-test`
Runs the smart-cooling rewrite safety regression suite.

## Test Commands

### `./logicbox test`
Runs all suites: ordinary fixtures, stress (adversarial), gold (exact models), edge (named suites), fuzz (generated invariants), rewrite-test, and report-smoke.

### `./logicbox report-smoke`
Regression check for the new report rendering. Ensures `./logicbox review` output is well-formed with all expected sections present.

### `./logicbox stress`
Runs adversarial fixtures from `tests/stress-*-model.shen`. Tries to sneak in fake support, circular stages, scope leaks, comments as evidence, and precomputed flags.

### `./logicbox gold`
Runs exact positive/negative model checks from `tests/gold/`. Each `.shen` model has a matching `.expected` file. Fails on diff.

### `./logicbox edge`
Runs named edge-case suites from `tests/edge/` covering five families: scope pathologies, stage/mechanism entanglement, context obligations, ground/conclusion/modality interactions, plan meta-structure.

### `./logicbox fuzz`
Generates temporary fact models and checks kernel invariants: identical scopes produce no conflict, stage-chain-too-short fires only below minimum, known context blocks missing-context, stronger conclusions over weaker grounds flagged, modality and scope mutations detected.

## Utility Commands

### `./logicbox new "claim text"`
Creates `work/draft.txt` with the claim, a starter `work/ai-facts.shen` with a placeholder plan, and an empty `work/adapter-facts.shen`.

### `./logicbox show`
Displays current draft (first 120 lines), AI facts, adapter facts, last Shen output, last check report, last mutation output, and last rewrite report.

## Migration Flags

Three stages are complete. Legacy JS paths remain behind feature flags:

- `--legacy-js-preflight` — use `scripts/preflight-facts.js` instead of Shen-native `run-preflight.shen`
- `--legacy-js-rewrite-safety` — use JS rewrite-safety checker instead of `run-rewrite-safety.shen`

Default behavior uses Shen/SBCL for all core checking. `scripts/rewrite-safety.js` remains as JSON/file glue, patch application, report formatting, repair plumbing, and parity harness.
