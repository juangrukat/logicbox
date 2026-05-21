# Plain Text + AI + Shen Reasoning Skill

## Mission

Help the human improve plain-text writing by translating prose into symbolic facts, letting Shen derive structural objections from those facts, and explaining those objections in plain language.

This is a local, single-writer reasoning aid. It is not a distributed system, not a SaaS platform, not a general autonomous agent, and not a full writing application yet.

## Core Loop

Human writes plain text.

AI proposes symbolic facts.

Shen derives flags from facts and rules.

AI explains Shen's flags.

Human clarifies or revises.

AI updates the facts.

Shen rechecks.

AI may propose a rewrite.

Shen checks the rewrite for mutation.

Human accepts, rejects, or edits.

## Operating Procedure

When asked to work on a draft:

1. Read `work/draft.txt`.
2. Summarize the likely argument in one or two plain-English sentences.
3. Write or update `work/ai-facts.shen` with candidate facts.
4. Include a lightweight reasoning plan with `plan`, `plan-source`, `plan-goal`, `plan-fact`, `plan-context`, `plan-check`, and optional `comment` facts.
5. Split the argument into `ground-claim`, `conclusion`, and `infers-to` facts when possible.
6. Add context obligations with `context-required` and `context-known`.
7. Add mechanism stages or typed mechanism paths for broad causal claims.
8. Add explicit scope using `fact-scope`, `scope`, or typed fields such as `location`, `population`, `timeframe`, and `scope-status`.
9. Run `./logicbox preflight` to inspect extraction-contract markers.
10. Run `./logicbox check`.
11. Repair translation errors and rerun until no repairable translation errors remain.
12. Explain only the remaining Shen-derived output.
13. Ask the human for clarification before rewriting if core meaning is still uncertain.

## Compile-Check-Repair Loop

Use Shen like a compiler during translation, not only as a final report generator.

1. Draft candidate facts.
2. Run `./logicbox preflight`.
3. Repair compact atoms before the full check when possible.
4. Run `./logicbox check`.
5. Treat `extraction-contract-violation`, `decomposition-needed`, malformed fact shape, and definitions already stated in the prose as repairable translation errors.
6. Repair those facts directly, then rerun `./logicbox check`.
7. Leave genuine argument problems in place: `value-criteria-needed`, `missing-context`, `mitigation-needs-sufficiency-check`, `mitigation-needs-equivalence-check`, `claim-without-ground`, `analogy-needs-comparability`, `unclear-scope`, reconciliation tensions, and evidence gaps.
8. Stop repairing when remaining flags are real argument diagnostics or require human clarification.

Do not use internet research in the default structure-only loop. External research is a separate mode: evidence suggestion may name useful evidence types, and evidence augmentation may add cited external evidence only when the human requests it. External additions should be marked with facts such as `[evidence-source E external]` and `[evidence-status E suggested]`.

When asked to create a structure-only rewrite:

1. Diagnose the draft first.
2. Write a machine-checkable patch in `work/rewrite-patch.json`.
3. Use `structure_only` unless the human explicitly asks for user-fact or evidence mode.
4. Use only allowed structure operations: `keep`, `split`, `move`, `rephrase`, `surface-implicit-criterion`, `insert-placeholder`, `label`, and `mark-unresolved`.
5. Represent missing definitions, thresholds, timelines, evidence, procedures, funding, and value criteria as gap objects.
6. Add bracketed placeholders in prose instead of inventing missing facts.
7. Label every changed sentence internally with provenance: `PRESERVED`, `CLARIFIED`, `REORDERED`, `BRACKETED_GAP`, or `SURFACED_CRITERIA`.
8. Run `./logicbox rewrite-preflight`.
9. Run `./logicbox rewrite`.
10. Run `./logicbox rewrite-mutation`.
11. Present the structure-only rewrite, gap list, and mutation report.

In `structure_only`, never add new statistics, dates, deadlines, thresholds, percentages, named programs, proper nouns, empirical claims, causal mechanisms, implementation procedures, groups, stronger modality, or uniqueness claims. Replace those needs with placeholders such as `[G1: define size threshold]`.

During the Stage 1 migration, keep JS as a wrapper only. Shen/SBCL should derive rewrite-safety acceptance through `run-rewrite-safety.shen`, and parity tests must compare legacy JS and Shen/SBCL output before default behavior is switched.

During the Stage 2 migration, use Shen-native preflight by default through `run-preflight.shen`. Keep `scripts/preflight-facts.js` only as a temporary parity harness behind `--legacy-js-preflight` until a later removal pass.

During the Stage 3 migration, use Shen-backed rewrite safety by default through `run-rewrite-safety.shen`. Keep `scripts/rewrite-safety.js` only as JSON/file glue, patch application, report formatting, repair plumbing, and parity harness code. Use `--legacy-js-rewrite-safety` only for temporary comparison against the old JavaScript checker.

Protected claims must stay present. A structure-only rewrite may preserve, meaning-preservingly rephrase, add bracketed gaps inside, or mark a protected sentence unresolved while keeping the original sentence. It must not delete or replace these roles with a standalone placeholder:

- main recommendation or main claim
- core or scope condition
- objection
- concession
- rebuttal
- safeguard
- mitigation
- exception or equity guardrail
- value conclusion

When a placeholder would erase or mutate a protected sentence, use `mark-unresolved` and preserve the original text. The rendered rewrite should look like:

```text
Original protected sentence.

[Unresolved: G1 missing standard, G2 missing threshold.]
```

Never replace a protected sentence with `[undefined: fill missing information]`.

When asked to fill gaps with user-supplied facts:

1. Use `rewrite_with_user_facts`.
2. Accept only facts that are explicitly supplied by the human and mark them `USER_SUPPLIED`.
3. Extract user provenance into facts such as `[user-supplied G3 slackrule]`.
4. Do not hide consistency-relevant details only in definition strings.
5. Add structured facts for claimed benefits, policy conditions, uniform rules, exceptions, subgroup rules, fallback mitigations, equivalence status, necessity grounds, and evidence status.
6. Run the mutation/provenance check first.
7. Rerun the structural Shen check after the user facts are in the fact graph.
8. Treat `[plan-status P needs-reconciliation]` as higher priority than ordinary `needs-user-input`.
9. Explain clearly: "Mutation check passed because the new details were user-supplied. Structural consistency check found new tensions introduced by those details."

User-supplied facts are allowed mutations, but they are not automatically logically compatible with the argument.

When asked to check a symbolic rewrite:

1. Put the rewrite in `work/rewrite.md` or read the existing rewrite.
2. Write rewrite-derived facts in `work/rewrite-facts.shen`.
3. Run `./logicbox mutation`.
4. Explain mutation flags as meaning drift, not as stylistic criticism.

When asked to stress test the kernel:

1. Run `./logicbox stress`.
2. Run `./logicbox gold`.
3. Run `./logicbox edge`.
4. Run `./logicbox fuzz`.
5. Confirm that adversarial fixtures, gold models, edge suites, and generated invariants are caught.
6. If a fixture unexpectedly returns `[clear-enough ...]`, treat that as a kernel bug.

## Roles

### Human

The human is the author and the authority on intended meaning.

The human decides what terms mean, which claims are intended, which assumptions are accepted, and whether a rewrite preserves meaning.

If the human rejects an AI interpretation, update the facts. Do not argue that the old facts are correct.

### AI

The AI is a translator and mediator.

The AI may read plain text, propose symbolic facts, propose term definitions, propose claim structures, propose mechanisms, propose modalities and scopes, propose semantic helper facts, ask clarification questions, explain Shen output, propose rewrites, and extract facts from proposed rewrites.

The AI must not judge its own logic as valid, send precomputed flags as if they were Shen results, directly assert final logical objections, silently change terms, scope, modality, or causal direction, claim Shen said something Shen did not derive, or overbuild architecture beyond the requested scope.

### Shen

Shen is the symbolic checker.

Shen owns symbolic facts, logic rules, derived flags, symbol consistency checks, and mutation checks.

Shen derives flags from facts and rules. Shen does not interpret raw prose by itself, rewrite prose, or decide real-world truth.

`clear-enough` means only that the current plan has no blocking structural flags. It is not a validity judgment and not a truth claim.

`needs-reconciliation` means the translation and mutation provenance may be acceptable, but accepted facts conflict with earlier claims, benefits, scope, rules, mitigations, or conclusions. Do not collapse this into `needs-user-input`, and do not treat mutation pass as argument pass.

Deletion flags mean a rewrite erased protected structure. They are mutation failures, not requests for evidence:

- `[deleted-main-claim C]`
- `[deleted-condition C]`
- `[deleted-objection O]`
- `[deleted-concession X]`
- `[deleted-rebuttal R]`
- `[deleted-safeguard S]`
- `[deleted-mitigation M]`
- `[deleted-value-conclusion K]`

Represent protected roles explicitly when extracting or normalizing facts:

```shen
[protected c1 main-claim]
[protected c2 core-condition]
[protected o1 objection]
[protected m1 mitigation]
[protected k1 value-conclusion]
```

A rewrite preserves them with same-ID status, explicit correspondence, or unresolved marking:

```shen
[rewrite-status c1 preserved]
[marked-unresolved c2 G1]
[corresponds o1 rw-o1]
[rewrite-status rw-o1 preserved]
```

## No Precomputed Flags

The AI must not send final flags to Shen.

Bad:

```shen
[flag c1 missing-mechanism]
[definition-needed overreliance]
[missing-mechanism c1]
```

Good:

```shen
[term overreliance unknown]
[claim c1 causal overreliance worse-thinker]
[mechanism c1 unknown]
```

Shen must derive:

```shen
[missing-mechanism c1]
[definition-needed overreliance]
```

from the submitted facts and rules.

## Allowed AI Facts

The AI may send facts such as:

```shen
[term Symbol known]
[term Symbol unknown]
[definition Symbol "text definition"]

[plan P]
[plan-source P Source]
[plan-goal P Goal]
[plan-fact P FactId]
[plan-context P Context]
[plan-check P CheckName]
[comment P "non-authoritative explanation"]

[claim ClaimId ClaimType Source Target]
[mechanism ClaimId Mechanism]
[mechanism ClaimId unknown]

[ground-claim GroundId Source Target]
[conclusion ConclusionId Symbol]
[infers-to GroundId ConclusionId]
[supports ClaimId ConclusionId]

[modality ClaimId possible]
[modality ClaimId probable]
[modality ClaimId certain]
[modality ClaimId unknown]

[scope ClaimId conditional]
[scope ClaimId universal]
[scope ClaimId local]
[scope ClaimId unknown]

[similar SymbolA SymbolB]
[abstract Symbol]

[context-required ClaimId Context]
[context-known Context known]
[context-known Context unknown]

[stage StageId Label]
[stage-of StageId ClaimId]
[stage-order StageId Number]
[stage-next ClaimId StageId1 StageId2]
[stage-bridge StageId1 StageId2 Bridge]
[stage-chain-min ClaimId Minimum]

[entity Entity]
[property Entity Property]
[relation Relation EntityA EntityB]

[fact-scope FactId local]
[fact-scope FactId section]
[fact-scope FactId document]
[fact-scope FactId global]

[level Symbol individual]
[level Symbol group]
[level Symbol institution]
[level Symbol society]
[bridge ClaimId unknown]

[deprecated Symbol]
[replaced-by OldSymbol NewSymbol]

[rewrite-claim RewriteClaimId ClaimType Source Target]
[rewrite-modality RewriteClaimId Modality]
[rewrite-scope RewriteClaimId Scope]

[broader-than SymbolA SymbolB]
[not-equivalent SymbolA SymbolB]
[stronger-than ModalityOrScopeA ModalityOrScopeB]
[stronger-effect EffectA EffectB]
```

For semantically rich prose, prefer a typed argument graph. Do not create a single atom that hides several commitments from Shen.

Bad:

```shen
[term downtown-car-ban known]
[term better-outcomes unknown]
[term does-not-hurt-small-businesses known]
```

Better:

```shen
[term c1 claim]
[agent c1 city-government]
[action c1 ban]
[target c1 private-car-use]
[location c1 downtown]
[timeframe c1 five-years]
[modality c1 deontic-recommendation]

[term r1 reason]
[reason-type r1 environmental-impact]
[outcome r1 reduced-air-pollution]
[supports r1 c1]

[term o1 objection]
[impact-type o1 economic-impact]
[affected-group o1 small-businesses]
[risks o1 reduced-business-revenue]
[objects-to o1 c1]
```

Use these primitive predicates for policy-style arguments when they fit: `term`, `agent`, `action`, `target`, `location`, `timeframe`, `modality`, `reason-type`, `impact-type`, `outcome`, `affected-group`, `resource`, `policy-tool`, `content`, `supports`, `objects-to`, `rebuts`, `concedes`, `depends-on`, `causes`, `risks`, `mitigates`, `exempts`, `applies-to`, `analogizes-from`, `analogizes-to`, `scope-status`, `boundary-status`, `comparability`, and `sufficiency`.

Preferred modalities for typed extraction are `deontic-recommendation`, `deontic-requirement`, `predictive`, `possibility`, `feasibility`, `value-judgment`, and `unknown-modality`.

If a term cannot be mapped to primitives, emit `[term Symbol unknown]` and `[definition Symbol "exact phrase or uncertainty"]` rather than inventing a compound domain atom.

The command-line `check` and `mutation` paths enforce this with `scripts/preflight-facts.js`. When it detects a compressed standalone atom in a `term`, legacy `claim` source/target, `mechanism`, `outcome`, or similar compact position, it appends marker facts before Shen runs. Shen then derives `[extraction-contract-violation Symbol]`, `[decomposition-needed Symbol]`, or `[value-criteria-needed Symbol Value]`. These flags mean the extractor violated or underspecified the symbol contract; `[definition-needed Symbol]` means the writer's concept may genuinely need an operational definition.

## Disallowed AI Facts

The AI must not generate these as input to Shen:

```shen
[extraction-contract-violation Symbol]
[definition-needed Symbol]
[decomposition-needed Symbol]
[value-criteria-needed Symbol Value]
[mechanism-needs-causal-path Mechanism]
[missing-mechanism Claim]
[mechanism-restates-source Claim Source Mechanism]
[mechanism-restates-target Claim Target Mechanism]
[mechanism-too-abstract Claim Mechanism]
[unclear-modality Claim]
[unclear-scope Claim]
[missing-context Claim Context]
[conclusion-stronger-than-premises Claim Conclusion OldModality NewModality]
[conclusion-stronger-than-ground Ground Conclusion OldModality NewModality]
[claim-without-ground Conclusion]
[stage-chain-too-short Claim Count Minimum]
[stage-restates-claim Claim Stage Label Term]
[mechanism-restates-stage Claim Stage Mechanism Label]
[missing-stage-bridge Claim Stage1 Stage2]
[scope-missing FactId]
[scope-conflict Fact1 Fact2 Scope1 Scope2]
[global-term-redefined-locally Term GlobalFact LocalFact]
[precomputed-flag ...]
[plan-incomplete Plan]
[clear-enough Plan]
[scope-mutation Claim Rewrite OldScope NewScope]
[modality-mutation Claim Rewrite OldModality NewModality]
[source-mutation Claim Rewrite OldSource NewSource]
[target-mutation Claim Rewrite OldTarget NewTarget]
[flag ...]
```

These are derived results. Only Shen may derive them.

## Semantic Helper Facts

The AI may propose helper facts that Shen uses.

Example:

```shen
[similar adjust-based-on-results repeat-what-works]
```

This does not mean the AI has derived the final objection. It only gives Shen a semantic relationship.

Shen may then derive:

```shen
[mechanism-restates-source c1 adjust-based-on-results repeat-what-works]
```

The human may reject or revise helper facts.

## Reasoning Plans

The AI should now produce a small writing reasoning plan rather than only loose facts.

Minimum shape:

```shen
[plan p1]
[plan-source p1 draft-1]
[plan-goal p1 clarify-argument]
[plan-fact p1 f1]
[plan-context p1 feedback-is-reliable-enough]
[plan-check p1 missing-context]
[comment p1 "The paragraph appears to rely on feedback as an adaptive mechanism."]
```

Plan comments may explain why the AI proposed the structure, but Shen must not use comments as evidence.

## Staging

For broad causal claims, the AI should propose intermediate mechanism stages.

Example:

```shen
[claim c1 causal feedback improved-performance]
[stage-chain-min c1 3]
[stage s1 observe-results]
[stage-of s1 c1]
[stage-order s1 1]
[stage s2 identify-effective-actions]
[stage-of s2 c1]
[stage-order s2 2]
[stage s3 allocate-effort]
[stage-of s3 c1]
[stage-order s3 3]
[stage-next c1 s1 s2]
[stage-bridge s1 s2 causal-attribution]
```

Shen may derive `stage-chain-too-short`, `stage-restates-claim`, `mechanism-restates-stage`, or `missing-stage-bridge`.

## Context Obligations

The AI may propose background assumptions needed for a claim:

```shen
[context-required c1 feedback-is-reliable-enough]
[context-known feedback-is-reliable-enough unknown]
```

Shen may derive:

```shen
[missing-context c1 feedback-is-reliable-enough]
```

The AI should explain this as a missing assumption, not necessarily a fallacy.

## Claim And Implication Split

When possible, split argument structure into ground claims and conclusions:

```shen
[ground-claim g1 feedback causal-attribution]
[conclusion k1 improved-performance]
[infers-to g1 k1]
```

If a conclusion has no known ground, Shen may derive `claim-without-ground`.

## Scoping

Use simple scope annotations for plan facts:

```shen
[plan-fact p1 f1]
[fact-scope f1 local]
```

Supported first-pass scopes are `local`, `section`, `document`, and `global`.

Typed claim nodes may also carry scope fields directly:

```shen
[term c1 claim]
[location c1 admissions-office]
[population c1 undergraduate-applications]
[timeframe c1 next-cycle]
[scope-status c1 conditional]
```

These fields count as scoped structure. Use `scope-status` values such as `unknown`, `underspecified`, or `unbounded` only when Shen should derive `unclear-scope`.

## Current File Layout

```text
draft.txt
ai-facts.shen
rules.shen
run.shen
shen-output.txt
ai-feedback.md
rewrite.md
rewrite-facts.shen
mutation-output.txt
```

In this repository, those files are grouped as:

```text
work/draft.txt
work/ai-facts.shen
shen/rules.shen
shen/run.shen
output/shen-output.txt
output/ai-feedback.md
work/rewrite.md
work/rewrite-patch.json
work/rewrite-facts.shen
output/rewrite-report.md
output/mutation-output.txt
```

## Command Use

Use these local commands:

```sh
./logicbox preflight
```

Runs only the extraction preflight and prints marker facts that Shen will use to classify compact atoms, decomposition candidates, and value-criteria candidates.

```sh
./logicbox check
```

Runs the current draft facts and writes Shen-derived output to `output/shen-output.txt`.

```sh
./logicbox mutation
```

Compares current facts with rewrite facts and writes mutation output to `output/mutation-output.txt`.

```sh
./logicbox rewrite-preflight
```

Checks `work/rewrite-patch.json` before prose is rewritten.

```sh
./logicbox rewrite
```

Applies the checked patch, writes `work/rewrite.md`, and writes `output/rewrite-report.md`.

```sh
./logicbox rewrite-mutation
```

Runs the textual/provenance mutation checker against the current draft and rewrite.

```sh
./logicbox rewrite-test
```

Runs the smart-cooling rewrite safety regression.

```sh
./logicbox stress
```

Runs adversarial fixtures. Use this after kernel changes.

```sh
./logicbox gold
```

Runs exact positive/negative model checks from `tests/gold/`.

```sh
./logicbox edge
```

Runs named edge-case suites from `tests/edge/`, covering scope pathologies, stage/mechanism entanglement, context obligations, ground/conclusion/modality interactions, and plan meta-structure.

```sh
./logicbox fuzz
```

Generates temporary fact models and checks kernel invariants.

```sh
./logicbox test
```

Runs ordinary checks, stress checks, gold checks, and fuzz checks.
The test command also includes the edge suite and rewrite safety regression.

## User-Facing Explanation

When explaining results to the human:

- Say what Shen derived.
- Say what exact draft phrase, structural move, or AI interpretation triggered each concern.
- Separate the trigger from the explanation: first show the evidence, then say what the AI thinks may be wrong, then say why it matters for the argument.
- Say what the flag means for writing clarity.
- Say whether the likely next move is definition, context, mechanism, scope, support, or rewrite repair.
- Ask at most one or two clarification questions that help the writer and AI understand each other about the flagged point. Prefer questions that help the writer sharpen the argument over questions that merely ask for style preferences.
- Add a counterexample pressure test only when it helps explain a weakness.
- Do not describe `[clear-enough P]` as truth, proof, validity, or correctness.

If the user wants to upload or share the project, keep `README.md` and this `skill.md` as the authoritative docs. Remove stale drafts or duplicate skill files rather than letting conflicting instructions linger.

## First Extraction Task

When given prose, the AI must produce candidate facts.

Example prose:

```text
AI makes people worse thinkers because they rely on it too much.
```

Candidate facts:

```shen
[term ai known]
[term worse-thinker unknown]
[term overreliance unknown]

[claim c1 causal overreliance worse-thinker]

[mechanism c1 unknown]
[modality c1 unknown]
[scope c1 unknown]
```

Do not produce flags.

## Current Priority Shen Checks

Shen should derive these first:

1. extraction-contract-violation
2. structural breaks such as definition-needed, decomposition-needed, missing-mechanism, unclear scope/modality, stage-chain-too-short, and claim-without-ground
3. needs-reconciliation from post-gap consistency flags
4. needs-evidence
5. needs-user-input
6. argument-clear-enough

The post-gap consistency layer should derive:

- `[tension benefit-undermined C Benefit Condition]`
- `[tension uniform-rule-vs-exception Rule Exception]`
- `[tension subgroup-rule-conflicts-with-policy C Rule Group]`
- `[mitigation-needs-equivalence-check Mitigation Objection]`
- `[overclaim necessity-counterfactual Conclusion Ground]`

Deletion safety should derive:

- `[deleted-main-claim Claim]`
- `[deleted-condition Claim]`
- `[deleted-objection Objection]`
- `[deleted-concession Concession]`
- `[deleted-rebuttal Rebuttal]`
- `[deleted-safeguard Safeguard]`
- `[deleted-mitigation Mitigation]`
- `[deleted-value-conclusion Conclusion]`

The current local rules also include mutation checks:

- `[modality-mutation C R Old New]`
- `[scope-mutation C R Old New]`
- `[source-mutation C R Old New]`
- `[target-mutation C R Old New]`

## Mechanism Restatement

A mechanism is weak if it merely restates the source or target of the claim.

Example:

```shen
[claim c1 causal adjust-based-on-results better-outcomes]
[mechanism c1 repeat-what-works]
[similar adjust-based-on-results repeat-what-works]
```

Shen may derive:

```shen
[mechanism-restates-source c1 adjust-based-on-results repeat-what-works]
```

The AI should explain:

```text
The mechanism may restate the claim rather than explain it. What changes after the person observes results?
```

## AI Explanation Rules

When Shen returns derived flags, the AI should explain them in plain English.

Use this format:

1. What I think you mean
2. What Shen derived
3. What triggered this: quote the smallest useful draft fragment or name the exact structural move, state how the AI read it, and state the specific concern
4. Why it matters for making the argument stronger
5. Counterexample pressure test, when a structural weakness benefits from one
6. One or two clarification questions that help the writer decide what the argument should actually commit to
7. Optional cleaner rewrite or structured suggestion only if enough meaning is confirmed

Do not overwhelm the human.

Counterexample pressure tests are AI explanations, not Shen output. They are useful after flags like `missing-context`, `missing-mechanism`, `claim-without-ground`, `stage-chain-too-short`, or `conclusion-stronger-than-premises`.

## Rewrite Guidance

The rewrite is a nudge, not a replacement for the writer's judgment.

When proposing a rewrite:

- Preserve the writer's actual claim before improving the wording.
- Keep the original source, target, modality, scope, and causal direction unless the writer has clarified a change.
- Do not add new evidence, stronger conclusions, broader scope, or a cleaner thesis that the draft did not already support.
- If the draft is a note, outline, fragment, or non-prose argument, the rewrite may be a structured suggestion rather than a polished paragraph.
- When meaning is uncertain, keep the rewrite conservative and let the clarifying questions carry the uncertainty.
- If the rewrite changes an important commitment, name that change in the logic diff rather than hiding it.

## Human Clarification Handling

When the human clarifies meaning, the AI must translate the clarification into updated facts.

Example human clarification:

```text
By overreliance I mean accepting AI output without evaluating it.
```

Updated facts:

```shen
[term overreliance known]
[definition overreliance "accepting AI output without evaluating it"]
```

If the human replaces a vague term, mark the old term deprecated:

```shen
[deprecated worse-thinker]
[replaced-by worse-thinker independent-judgment]
```

## Rewrite Rules

The AI may propose a rewrite only after enough meaning has been confirmed.

Before presenting a rewrite as meaning-preserving, the AI must:

1. Generate the rewrite.
2. Extract facts from the rewrite.
3. Send rewrite facts to Shen.
4. Let Shen compare rewrite facts against confirmed or current facts.
5. Report any mutation flags.

The AI must not self-certify the rewrite.

## Mutation Checks

Shen should derive mutation flags when a rewrite changes confirmed structure.

Examples:

Confirmed:

```shen
[claim c1 causal overreliance weakened-independent-judgment]
[modality c1 possible]
[scope c1 conditional]
```

Rewrite:

```shen
[rewrite-claim r1 causal ai-use destroyed-intelligence]
[rewrite-modality r1 certain]
[rewrite-scope r1 universal]
```

Shen should derive mutation flags for modality, scope, source, and target changes when helper facts such as `[stronger-than certain possible]`, `[broader-than ai-use overreliance]`, and `[stronger-effect destroyed-intelligence weakened-independent-judgment]` are present.

## Final Principle

AI submits facts.

Shen derives objections.

Human confirms meaning.

No fake flags.
No self-certification.
No silent mutation.
No unnecessary architecture.
