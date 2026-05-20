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
7. Add mechanism stages for broad causal claims.
8. Add `fact-scope` facts for plan facts.
9. Run `./logicbox check`.
10. Explain only Shen-derived output.
11. Ask the human for clarification before rewriting if core meaning is still uncertain.

When asked to check a rewrite:

1. Put the rewrite in `work/rewrite.md` or read the existing rewrite.
2. Write rewrite-derived facts in `work/rewrite-facts.shen`.
3. Run `./logicbox mutation`.
4. Explain mutation flags as meaning drift, not as stylistic criticism.

When asked to stress test the kernel:

1. Run `./logicbox stress`.
2. Confirm that adversarial fixtures are caught.
3. If a fixture unexpectedly returns `[clear-enough ...]`, treat that as a kernel bug.

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

## No Precomputed Flags

The AI must not send final flags to Shen.

Bad:

```shen
[flag c1 missing-mechanism]
[undefined-term overreliance]
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
[undefined-term overreliance]
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

## Disallowed AI Facts

The AI must not generate these as input to Shen:

```shen
[undefined-term Symbol]
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
work/rewrite-facts.shen
output/mutation-output.txt
```

## Command Use

Use these local commands:

```sh
./logicbox check
```

Runs the current draft facts and writes Shen-derived output to `output/shen-output.txt`.

```sh
./logicbox mutation
```

Compares current facts with rewrite facts and writes mutation output to `output/mutation-output.txt`.

```sh
./logicbox stress
```

Runs adversarial fixtures. Use this after kernel changes.

```sh
./logicbox test
```

Runs all fixtures, including ordinary checks and stress checks.

## User-Facing Explanation

When explaining results to the human:

- Say what Shen derived.
- Say what the flag means for writing clarity.
- Say whether the likely next move is definition, context, mechanism, scope, support, or rewrite repair.
- Ask at most one or two clarification questions.
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

1. undefined-term
2. missing-mechanism
3. mechanism-restates-source
4. mechanism-restates-target
5. mechanism-too-abstract
6. unclear-modality
7. unclear-scope
8. conclusion-stronger-than-premises
9. missing-context
10. claim-without-ground
11. stage-chain-too-short
12. plan-incomplete or clear-enough
13. modality-mutation
14. scope-mutation

The current local rules also include source and target mutation checks because they are useful for rewrite drift.

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
3. Why it matters
4. Counterexample pressure test, when Shen derived a structural weakness
5. One or two clarification questions
6. Optional cleaner rewrite only if enough meaning is confirmed

Do not overwhelm the human.

Counterexample pressure tests are AI explanations, not Shen output. They are useful after flags like `missing-context`, `missing-mechanism`, `claim-without-ground`, `stage-chain-too-short`, or `conclusion-stronger-than-premises`.

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
