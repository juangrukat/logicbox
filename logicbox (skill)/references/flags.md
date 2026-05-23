# Shen-Derived Flag Reference

Explanations for every flag Shen may derive. Flags are output-only — never write them as input facts.

## Extraction & Translation

### `extraction-contract-violation X`
A hyphenated or compound-domain atom was packed into a position Shen inspects (claim source/target, ground-claim source/target, mechanism, outcome). Decompose into typed fields. This is a translation error — fix before judging the argument.

### `decomposition-needed X`
An action-like or condition-like atom should be represented as primitive predicates instead of a single term. Example: `overrideok` → decompose into `action`/`target`/`condition` fields.

### `definition-needed X`
A legitimate concept needs an operational definition. Unlike extraction-contract-violation, this means the writer's term genuinely needs defining — Shen is not objecting to the fact shape.

### `precomputed-flag FlagName ...`
A final Shen result (e.g. `missing-mechanism`, `definition-needed`) was placed in the AI fact input. Remove it from `ai-facts.shen`. Only Shen derives flags.

## Mechanism & Causation

### `missing-mechanism C`
A causal claim has no represented mechanism. Add `[mechanism C label]` or `[mechanism C unknown]`.

### `mechanism-needs-causal-path M`
A mechanism exists but lacks an explicit causal bridge. Add intermediate stages or a `stage-bridge` describing *how* the mechanism produces the effect.

### `mechanism-restates-source C Source Mechanism`
The mechanism label is too similar to the claim's source. Explanation may just restate the starting point. Add operational detail.

### `mechanism-restates-target C Target Mechanism`
The mechanism label is too similar to the claim's target. Explanation may just rename the desired result. Add a genuine bridge.

### `mechanism-too-abstract C Mechanism`
The mechanism label is so abstract it doesn't explain anything. Replace with concrete operational steps.

### `stage-chain-too-short C Count Minimum`
A causal claim has fewer mechanism stages than its `stage-chain-min`. Add intermediate stages.

### `stage-restates-claim C Stage Label Term`
A stage label is too close to the original claim's source or language. Stages should describe intermediate steps, not rephrase the claim.

### `mechanism-restates-stage C Stage Mechanism Label`
A stage's mechanism label is too close to the stage's own label. The mechanism should explain *how* the stage works, not rename it.

### `missing-stage-bridge C Stage1 Stage2`
Two adjacent stages have a `stage-next` link but no `stage-bridge` explaining how one leads to the next. Add `[stage-bridge S1 S2 label]`.

## Modality & Scope

### `unclear-modality C`
A claim has no modality or `unknown` modality. Add `[modality C possible|probable|certain|deontic-recommendation|...]`.

### `unclear-scope C`
A claim has no scope or `unknown` scope. Add typed scope fields (`location`, `population`, `timeframe`, `scope-status`) or `[scope C conditional|universal|...]`.

### `scope-missing F`
A plan fact or term fact has no `fact-scope` annotation. Add `[fact-scope F local|section|document|global]`.

### `scope-conflict F1 F2 Scope1 Scope2`
Two facts have conflicting scopes (e.g. one local, one global with the same term). Resolve the scope mismatch.

### `global-term-redefined-locally Term GlobalFact LocalFact`
A term defined at global scope is redefined differently at local scope. Unify or separate the term names.

## Grounds & Conclusions

### `claim-without-ground K`
A conclusion has no represented support. Add `[ground-claim G source target]` + `[infers-to G K]` or `[supports G K]`.

### `conclusion-stronger-than-premises Premise Conclusion OldModality NewModality`
A conclusion claims stronger modality (e.g. `certain`) than its supporting premise (e.g. `possible`). Weaken the conclusion or strengthen the premise.

### `conclusion-stronger-than-ground Ground Conclusion OldModality NewModality`
A conclusion claims stronger modality than the ground claim it infers from. Same fix as above.

### `overclaim necessity-counterfactual Conclusion Ground`
A necessity claim ("X is necessary," "cannot be solved any other way") relies on an unsupported counterfactual ground — no alternatives were considered. Lower modality, bracket the gap, or add grounds for why alternatives fail.

## Context & Tension

### `missing-context C Context`
A background assumption needed for the claim is `unknown`. Define the context or mark it as accepted.

### `tension benefit-undermined C Benefit Condition`
A condition or rule in the argument weakens a benefit the claim relies on. Resolve the tension or weaken the claim.

### `tension uniform-rule-vs-exception Rule Exception`
A uniform/no-exceptions policy conflicts with an exception. Resolve or acknowledge the tension.

### `tension subgroup-rule-conflicts-with-policy C Rule Group`
A subgroup rule conflicts with the main policy target. Resolve or restrict scope.

### `mitigation-needs-equivalence-check Mitigation Objection`
A fallback mitigation is traceable but may not preserve equivalent benefit. Add `[equivalence-status M shown]` or `unknown`.

### `mitigation-needs-sufficiency-check Mitigation Objection`
A mitigation exists but its sufficiency is unproven. Add `[sufficiency M shown]` or `unknown`.

## Value Conclusions

### `value-criteria-needed X V`
A value conclusion (fair, efficient, responsible) needs explicit criteria. Define what makes it fair/efficient/responsible.

### `value-criteria-stated X`
Criteria are stated in prose but not yet linked to grounds. Add ground-claims and infers-to links.

### `value-criteria-grounded X`
POSITIVE status. Criteria are stated and linked to supporting grounds. Not a problem.

## Plan Status

### `plan-incomplete P`
The plan has blocking structural flags. Fix the flags first.

### `clear-enough P`
POSITIVE status. No blocking structural flags remain. Not a truth verdict — only means structural diagnostics are clean.

### `needs-reconciliation P`
User-supplied facts passed provenance/mutation checks but introduced tensions that conflict with the argument's structure. Outranks `needs-user-input`. Mutation pass does not imply argument pass.

## Mutation (Rewrite Drift)

Rewrite meaning-drift flags:

- `modality-mutation C R Old New` — modality changed (e.g. possible → certain)
- `scope-mutation C R Old New` — scope changed (e.g. conditional → universal)
- `source-mutation C R Old New` — source term changed
- `target-mutation C R Old New` — target term changed

## Deletion (Rewrite Safety)

These fire when a protected structural element disappeared from the rewrite:

- `deleted-main-claim C` — main recommendation removed
- `deleted-condition C` — core/scope condition removed
- `deleted-objection O` — objection removed
- `deleted-concession X` — concession removed
- `deleted-rebuttal R` — rebuttal removed
- `deleted-safeguard S` — safeguard/exception/equity guardrail removed
- `deleted-mitigation M` — mitigation removed
- `deleted-value-conclusion K` — value conclusion removed

All are mutation failures. Fix the rewrite, not the facts.

## Counterexample Pressure Test

For structural weaknesses (missing-context, missing-mechanism, stage-chain-too-short, claim-without-ground, conclusion-stronger-than-premises), add one short counterexample: a concrete scenario where the missing element causes failure. AI explanation only — not Shen output.

```
Counterexample pressure test:
[One or two sentences showing a scenario where the missing element causes failure.]
```
