# Detailed Workflows

## Compile-Check-Repair Loop

Use Shen like a compiler during translation, not only as a final report generator.

1. Draft candidate facts in `work/ai-facts.shen`.
2. Run `./logicbox preflight` — inspect extraction-contract markers.
3. Repair compact atoms, decomposition candidates, and malformed fact shapes.
4. Run `./logicbox check`.
5. Repairable translation errors: `extraction-contract-violation`, `decomposition-needed`, malformed ground-claim shape, definitions already stated in prose.
6. Genuine diagnostics to leave: `value-criteria-needed`, `missing-context`, `mitigation-needs-sufficiency-check`, `mitigation-needs-equivalence-check`, `claim-without-ground`, `analogy-needs-comparability`, `unclear-scope`, reconciliation tensions, evidence gaps.
7. Stop when remaining flags are real diagnostics or need human clarification.
8. Explain only the remaining Shen-derived flags.

Do not use internet research in the default structure-only loop.

## Structure-Only Rewrite (Patch Pipeline)

1. Diagnose draft via compile-check-repair.
2. Write a machine-checkable patch in `work/rewrite-patch.json`:
```json
{"mode": "structure_only", "gaps": [{"id": "G1", "type": "threshold-needed", "prompt": "..."}],
 "operations": [
   {"op": "keep", "sentenceId": "s1"},
   {"op": "rephrase", "sentenceId": "s2", "provenance": ["CLARIFIED", "BRACKETED_GAP"], "gaps": ["G1"], "text": "..."},
   {"op": "mark-unresolved", "sentenceId": "s1", "gaps": ["G1"], "note": "..."}
 ]}
```
3. Allowed operations: `keep`, `split`, `move`, `rephrase`, `surface-implicit-criterion`, `insert-placeholder`, `label`, `mark-unresolved`.
4. Never add: statistics, dates, deadlines, thresholds, percentages, named programs, proper nouns, empirical claims, causal mechanisms, implementation procedures, groups, stronger modality, uniqueness claims.
5. Replace missing evidence with bracketed placeholders: `[G1: define threshold]`.
6. Provenance labels: `PRESERVED`, `CLARIFIED`, `REORDERED`, `BRACKETED_GAP`, `SURFACED_CRITERIA`.
7. Run `./logicbox rewrite-preflight` → `./logicbox rewrite` → `./logicbox rewrite-mutation`.
8. Write `work/rewrite-facts.shen` — only structural claims, no scaffolding, no claims from marked-unresolved sentences. Every `[protected X role]` needs `[rewrite-status X preserved]` + `[corresponds X rw-X]`.
9. Run `./logicbox mutation` — Shen-level drift detection. Always write fresh `rewrite-facts.shen` first.
10. Present rewrite, gap list, mutation reports.

### mark-unresolved for Protected Sentences

Preserve the original sentence verbatim and append gaps externally:
```text
Original protected sentence text unchanged.

[Unresolved: G1 missing standard, G2 missing threshold.]
```
Never replace with `[undefined: fill missing information]` — triggers deletion flags.

## Post-Resolution: Two Paths

### Path A: Manual
1. `cp work/rewrite.md work/draft.txt`
2. Regenerate `work/ai-facts.shen` with fresh facts
3. `./logicbox preflight` → `./logicbox check`
4. Report delta

### Path B: Pipeline (rewrite_with_user_facts)
1. Write patch with `"mode": "rewrite_with_user_facts"`
2. `./logicbox rewrite-preflight` → `./logicbox rewrite` → `./logicbox rewrite-mutation`
3. **Update `work/ai-facts.shen`** — re-check runs against OLD facts. Change `unknown` to `known`, add definitions, `[user-supplied G X]` provenance, tension facts.
4. `./logicbox preflight` → `./logicbox check`
5. Report delta + consistency status

### rewrite_with_user_facts Rules
- Use `resolved` not `user_fact` in gap objects.
- Embed exact `resolved` text in rephrase; do not paraphrase (substring match).
- Preserve conditional language ("but only if...") in s1 or triggers `deleted-condition`.
- `USER_SUPPLIED` provenance is valid in this mode.
- `needs reconciliation` outranks `needs-user-input`. Explain: "Mutation check passed because new details were user-supplied. Structural consistency check found new tensions."
- Tension facts: `[undermines X Y]`, `[conflicts-with-target X Y]`.

## Explanation Format

1. What I think you mean (1-2 sentence summary)
2. What Shen derived (grouped by flag category)
3. What triggered each flag (draft fragment or structural move)
4. Why it matters
5. Counterexample pressure test (only for structural weaknesses)
6. One or two clarification questions
7. Next move: definition, context, mechanism, scope, support, or rewrite repair

`[clear-enough P]` = no blocking structural flags, not truth or validity.
