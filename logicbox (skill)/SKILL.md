---
name: logicbox-argument-checking
description: Translate argument prose into Shen symbolic facts, run LogicBox compile-check-repair loop, explain structural flags, and produce structure-only rewrites through the patch pipeline.
version: 2.3.0
author: Hermes Agent
license: MIT
platforms:
  - macos
metadata:
  agent:
    tags:
      - reasoning
      - shen
      - argument-checking
      - rewrite-safety
      - structural-diagnostics
    category: code
    related_skills: []
    requires_toolsets:
      - terminal
      - files
    required_environment_variables: []
config: {}
---

## When to Use
- Use when translating policy, argument, or claim prose into Shen symbolic facts for structural checking.
- Use when running `./logicbox review` (primary) or `./logicbox check` (expert audit) and explaining derived flags.
- Use when producing structure-only rewrites via the patch pipeline.
- Use when the human asks to check a draft, find structural gaps, or surface implicit criteria.
- Do NOT write precomputed flags (`[missing-mechanism ...]`, `[definition-needed ...]`, `[plan-status ...]`) or report-only facts (`[report-line ...]`) into `ai-facts.shen`. The schema gate now rejects these as hard `translation-error` — the kernel is not run.
- When prose is metaphorical, performative, or absurdist, model argumentative patterns (not surface claims). Classify the translation mode and surface the prose-facts correspondence gap — see Pitfalls.

---

## Quick Reference

| Command | What it does |
|---|---|
| `./logicbox review` | **Primary human-facing command.** Schema gate → normalization → typecheck → kernel → human-readable report |
| `./logicbox check` | Raw/expert audit path. Schema gate → Shen output → `output/shen-output.txt` |
| `./logicbox schema-test` | Regression suite for the schema gate (normalization, typecheck, provenance) |
| `./logicbox schema-contract` | Emit the machine-readable prompt contract from the schema registry |
| `./logicbox preflight` | Shen-native extraction markers (compound atoms, decomposition, value-criteria) |
| `./logicbox mutation` | Shen rewrite drift check: `ai-facts.shen` vs `rewrite-facts.shen` |
| `./logicbox rewrite-preflight` | Validate `work/rewrite-patch.json` before applying |
| `./logicbox rewrite` | Apply patch → `work/rewrite.md` + `output/rewrite-report.md` |
| `./logicbox rewrite-mutation` | JS-level textual/provenance mutation check |
| `./logicbox recheck-report` | Delta report: before/after Shen output + consistency status |
| `./logicbox new "claim"` | Scaffold `draft.txt`, starter `ai-facts.shen`, empty `adapter-facts.shen` |
| `./logicbox show` | Display current draft, facts, adapter, and last outputs |
| `./logicbox test` | Full suite: fixtures + stress + gold + edge + fuzz + rewrite-test + report-smoke |
| `./logicbox report-smoke` | Regression check for the new report rendering |
| `./logicbox stress` / `gold` / `edge` / `fuzz` | Individual test suites |

Key files:
```
work/draft.txt             — input prose
work/ai-facts.shen         — AI-written candidate facts
work/adapter-facts.shen    — per-run semantic bridge facts (temporary)
work/rewrite-patch.json    — machine-checkable rewrite patch
work/rewrite.md            — generated rewrite
work/rewrite-facts.shen    — facts extracted from rewrite (for mutation check)
scripts/gap-firewall.py    — deterministic pre-Shen check: every ground-claim's source/target connected?
scripts/provenance-firewall.py — deterministic pre-Shen check: every argumentative fact tagged with provenance
shen/rules.shen            — kernel (do not edit)
shen/run.shen              — check runner
shen/run-mutation.shen     — mutation runner
shen/run-preflight.shen    — Shen-native preflight (Stage 2)
shen/run-rewrite-safety.shen — Shen-native rewrite safety (Stage 3)
shen/fact-schema.shen      — schema registry: predicate definitions, types, enums
shen/fact-normalize.shen   — normalization pass: canonicalize aliases, enums, booleans
shen/fact-typecheck.shen   — type checker: arity, enum, ID-class, unknown-predicate
shen/fact-provenance.shen  — provenance tracking: source, span, run, extractor, confidence
docs/fact-schema.md        — schema gate documentation: pipeline, namespaces, types, enums
docs/prompt-contract.md    — LLM extraction prompt contract: valid predicates, enums, examples
output/shen-output.txt     — raw derived flags (expert audit)
output/check-report.md     — human-readable report: next action, source-facing diagnostics, source frames, file map, expert appendices (read this first)
output/mutation-output.txt — mutation flags
output/rewrite-report.md   — rewrite gap list + mutation + consistency
```

---

## Routing
- For full command reference and legacy JS flags, read `references/commands.md`.
- For fact construction rules (plans, compound atoms, claims, ground-claims, mechanisms, objections, mitigations, protected roles), read `references/facts.md`.
- For typed extraction, staging, context obligations, adapter facts, and value conclusions, read `references/facts-advanced.md`.
- For detailed compile-check-repair loop, rewrite pipeline, post-resolution paths, and `rewrite_with_user_facts` mode, read `references/workflows.md`.
- For session-derived pitfall patterns with triggers and fixes, read `references/pitfalls.md`.
- For a glossary of every Shen-derived flag with explanations and counterexample guidance, read `references/flags.md`.
- For techniques on modeling non-propositional prose (dialogues, poems, absurdist arguments) and the prose-facts correspondence gap, read `references/metaphorical-arguments.md`.
- For the deterministic gap firewall (pre-Shen ground-claim connectivity check), see `scripts/gap-firewall.py`.
- For the deterministic provenance firewall (pre-Shen tagging requirement), see `scripts/provenance-firewall.py`.
- For the schema gate (type system, namespaces, controlled enums, normalization), read `docs/fact-schema.md` in the logicbox repo.
- For the LLM extraction prompt contract (valid predicates, forbidden predicates, enum values), read `docs/prompt-contract.md` in the logicbox repo.

---

## Procedure

### Core Loop
Human writes prose → AI proposes symbolic facts → Shen derives flags → AI explains flags → human clarifies → AI updates facts → Shen rechecks.

### Compile-Check-Repair
1. Write/read draft to `work/draft.txt`.
2. Summarize the argument in 1-2 sentences.
3. Write candidate facts to `work/ai-facts.shen` with a reasoning plan. For each ground-claim, verify the mechanism bridges source to target, not just renames the leap. If it only renames, omit it — let Shen flag the gap.
4. Classify every fact by provenance using `[translator-added ID <extracted|inferred|added>]` tags. EXTRACTED: from the prose. INFERRED: logically required, not stated. ADDED: translator-supplied illustration or bridging — especially examples, percentages, named entities.
5. Run the provenance firewall: `python3 scripts/provenance-firewall.py work/ai-facts.shen`. Deterministic check that every claim, condition, ground-claim, mechanism, definition, objection, rebuttal, and value-conclusion has a `[translator-added ID <extracted|inferred|added>]` tag. If the firewall fails, tag every untagged fact before proceeding.
6. Run the gap firewall: `python3 scripts/gap-firewall.py work/ai-facts.shen`. If it fails, remove the disconnected ground-claim — don't invent a bridge. The original prose supplied no connection; that is the diagnostic.
7. Run `./logicbox preflight` — inspect extraction-contract markers.
8. Repair compact atoms, decomposition candidates, malformed shapes.
9. Run `./logicbox review` (preferred) or `./logicbox check` (expert audit). Both run the schema gate first: normalization → typecheck → accepted core facts → kernel. Hard schema errors block the kernel with `translation-error`. Fix schema errors before interpreting kernel flags.
   - **After review, present: (a) source frames, (b) translation mode (claim-level or meta-level), (c) provenance table (extracted/inferred/added per fact), (d) firewall-vs-Shen summary when they disagree.**
10. Treat these as repairable: `extraction-contract-violation`, `decomposition-needed`, malformed fact shape, definitions already in prose.
11. Leave genuine diagnostics in place: `value-criteria-needed`, `missing-context`, `mitigation-needs-sufficiency-check`, `claim-without-ground`, `unclear-scope`, reconciliation tensions, evidence gaps.
12. Stop when remaining flags are real diagnostics or need human clarification.
13. Explain only Shen-derived flags via the standard format (what I think you mean → what Shen derived → trigger → why it matters → counterexample pressure test → clarification questions → next move).

### Structure-Only Rewrite (Patch Pipeline)
1. Diagnose draft via compile-check-repair.
2. Write `work/rewrite-patch.json` in `structure_only` mode.
3. Allowed operations: `keep`, `split`, `move`, `rephrase`, `surface-implicit-criterion`, `insert-placeholder`, `label`, `mark-unresolved`.
4. Never add: statistics, dates, deadlines, thresholds, percentages, named programs, proper nouns, empirical claims, implementation procedures, groups, stronger modality, uniqueness claims.
5. Replace missing evidence with `[G#: prompt]` placeholders.
6. Provenance labels: `PRESERVED`, `CLARIFIED`, `REORDERED`, `BRACKETED_GAP`, `SURFACED_CRITERIA`.
7. Run `./logicbox rewrite-preflight` → `./logicbox rewrite` → `./logicbox rewrite-mutation`.
8. Write `work/rewrite-facts.shen` (only structural claims, no scaffolding, no claims from marked-unresolved sentences).
9. Run `./logicbox mutation` for Shen-level drift detection.
10. Present rewrite + gap list + mutation reports.

### Protected Claims
Mark elements that must survive rewrites. Use only schema-registered ProtectedRole values:
```shen
[protected c1 main-claim]
[protected c2 core-condition]
[protected c3 core-condition]
[protected o1 core-condition]    ;; objections are entities, protected as core-condition
[protected r1 safeguard]          ;; rebuttals are reasons, protected as safeguard
```
Valid: `main-claim`, `core-condition`, `safeguard`, `source`, `target`, `actor`, `mechanism`, `context`, `evidence`. NOT valid: `objection`, `rebuttal`, `concession`, `mitigation`, `value-conclusion`.

### Adapter Facts
Use `work/adapter-facts.shen` for per-run semantic bridges (`[implies Y X]`, `[denies Y X]`, `[conflicts Y X]`, `[undermines Y X]`). Reported separately in `check-report.md`. Do not put in `shen/rules.shen` unless deliberately promoted after neutral wording and regression coverage.

---

## Schema Gate Vocabulary

Only these predicates, TermKinds, and enums are valid in `ai-facts.shen`. Everything else is a hard `translation-error`.

### Registered Predicates
`[plan ...]` `[plan-source ...]` `[plan-goal ...]` `[plan-check ...]` `[comment ...]`
`[term Symbol TermKind]` — where TermKind is: `claim` `plan` `ground-claim` `ground` `entity` `reason` `evidence` `context` `adapter` `report` `run` `schema-version`
`[claim ClaimId RelationKind EntityId EntityId]` — RelationKind: `assertion` `descriptive` `causal` `produces` `enables` `prevents` `practical-outperformance` `comparison` `value`
`[ground-claim GroundId EntityId EntityId]`
`[mechanism ClaimId EntityId]`
`[infers-to GroundId ClaimId]`
`[supports EntityId ClaimId]`
`[rebuts ReasonId EntityId]` — slot 2 expects entity-id
`[reason-type ReasonId Symbol]`
`[sufficiency ReasonId KnowledgeState]` — KnowledgeState: `known` `unknown` `mixed` `shown` `provided` `present`
`[definition Symbol TextAtom]`
`[modality AnyId Modality]` — Modality: `asserted` `probable` `possible` `hypothetical` `contested` `certain` `unknown`
`[scope AnyId Scope]` — Scope: `local` `global` `bounded` `comparative` `conditional` `unknown`
`[protected AnyId ProtectedRole]` — ProtectedRole: `main-claim` `core-condition` `safeguard` `source` `target` `actor` `mechanism` `context` `evidence`
`[translator-added Symbol Atom]` — provenance tag (EXTRACTED/INFERRED/ADDED in comment convention)

### NOT Registered (hard errors)
`condition` `value-conclusion` `risks` `rebuttal` `concession` `mitigation` `objection` (as predicate or TermKind)
`[term o1 objection]` → use `[term o1 entity]`
`[term r1 rebuttal]` → use `[term r1 reason]`
`[protected r1 rebuttal]` → use `[protected r1 safeguard]`
`[sufficiency r1 stated]` → use `[sufficiency r1 shown]`

## Pitfalls
- **Precomputed flags (hard schema error):** Writing `[missing-mechanism c1]`, `[definition-needed X]`, `[plan-status ...]`, or any report-only fact into `ai-facts.shen` is rejected as `translation-error`.
- **Wrong enum values:** Use only registered enums from the Schema Gate Vocabulary above.
- **ID-class mismatch:** `[mechanism p1 m1]` where p1 is PlanId → error. Declare IDs with `[term ...]` before use.
- **Namespace leakage:** Adapter and report facts excluded from core. `[supports a1 c1]` where a1 is adapter → error.
- **Compound atoms:** Hyphenated atoms in claim source/target, ground-claim source/target, mechanism, or outcome positions trigger `extraction-contract-violation`. Use non-hyphenated concatenated names: `poorfocus` not `poor-focus`.
- **Ground-claim format:** Requires exactly 4 elements `[ground-claim ID source target]`. Missing target causes `claim-without-ground`.
- **Stale rewrite-facts.shen:** Mutation check loads from disk — stale facts from a previous draft produce meaningless `[]`. Always write fresh before `./logicbox mutation`.
- **Protected deletion:** A `mark-unresolved` that replaces a protected sentence with `[undefined: ...]` triggers deletion flags. Preserve the original sentence text and append `[Unresolved: ...]`.
- **Adapter fact promotion:** Adapter facts are temporary per-run bridges. Do not move them into `shen/rules.shen` without deliberate promotion.
- **`;;` comments in facts form:** Shen's parser rejects `;;` inside `(set *facts* ...)`. Use `[comment p1 "..."]` facts instead.
- **Meta-description gap:** Shen validates the structural model, not prose-to-facts correspondence. A clean review does not mean the prose is logically sound.
---

## Verification
- [ ] Draft is in `work/draft.txt` and candidate facts in `work/ai-facts.shen` with a `[plan p1]` fact.
- [ ] Provenance firewall passed: `python3 scripts/provenance-firewall.py work/ai-facts.shen` exited 0. Every argumentative fact tagged as extracted, inferred, or added.
- [ ] Gap firewall passed: `python3 scripts/gap-firewall.py work/ai-facts.shen` exited 0.
- [ ] `./logicbox preflight` ran and compound atoms / decomposition candidates were repaired.
- [ ] `./logicbox review` ran (or `./logicbox check` for expert audit) and only genuine diagnostics remain.
- [ ] For rewrites: `rewrite-patch.json` uses only allowed operations in `structure_only` mode.
- [ ] For rewrites: `./logicbox rewrite-preflight` passed before `./logicbox rewrite`.
- [ ] For rewrites: fresh `rewrite-facts.shen` written before `./logicbox mutation`.
- [ ] All protected roles in `ai-facts.shen` have corresponding entries in `rewrite-facts.shen`.
- [ ] No precomputed flags, report-only facts, or adapter facts in `ai-facts.shen` — these are hard schema errors.
- [ ] Enum values and ID classes conform to the schema gate registry (`docs/prompt-contract.md`).
- [ ] `./logicbox schema-test` passes (regression suite for the schema gate).
- [ ] Adapter facts are in `work/adapter-facts.shen`, not in `shen/rules.shen`.
