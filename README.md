# LogicBox

LogicBox is a tiny plain-text to Shen reasoning loop.

The human writes prose. The AI proposes symbolic facts. Shen derives structural flags. The AI explains those flags and asks for clarification.

It is for improving the structure of an argument, not proving that the argument is true.

## Quick Start

```sh
./logicbox check
```

The current draft is in `work/draft.txt`.

The AI-facing facts are in `work/ai-facts.shen`.

The derived Shen output is saved to `output/shen-output.txt`.

Run the rewrite mutation check with:

```sh
./logicbox mutation
```

Rewrite-derived facts live in `work/rewrite-facts.shen`, and mutation output is saved to `output/mutation-output.txt`.

Run the built-in rule fixtures with:

```sh
./logicbox test
```

`test` runs the ordinary fixtures, adversarial stress fixtures, exact gold models, and deterministic fuzz invariants.

Run only the adversarial fixtures with:

```sh
./logicbox stress
```

Run exact positive/negative gold models with:

```sh
./logicbox gold
```

Run the named edge-case suites with:

```sh
./logicbox edge
```

Run generated invariant checks with:

```sh
./logicbox fuzz
```

Run only the extraction preflight with:

```sh
./logicbox preflight
```

## How To Use It

The normal workflow is small and file-based:

1. Write or paste a paragraph into `work/draft.txt`.
2. Ask the AI to extract candidate facts into `work/ai-facts.shen`.
3. Run `./logicbox check`.
4. Read `output/shen-output.txt`.
5. Ask the AI to explain only those Shen-derived flags in `output/ai-feedback.md`.
6. Clarify the paragraph or the intended meaning.
7. Update `work/ai-facts.shen` and run `./logicbox check` again.

For a safe prose rewrite:

1. Put a machine-checkable rewrite patch in `work/rewrite-patch.json`.
2. Run `./logicbox rewrite-preflight`.
3. Run `./logicbox rewrite`.
4. Read `work/rewrite.md` and `output/rewrite-report.md`.
5. Keep unresolved facts visible as bracketed gaps instead of filling them.

For a symbolic meaning-drift check, put rewrite-derived facts in `work/rewrite-facts.shen` and run `./logicbox mutation`.

The human remains the authority on meaning. If Shen flags something because the AI encoded your meaning incorrectly, fix the facts rather than rewriting the prose.

## Start A New Claim

```sh
./logicbox new "Online learning is just as effective as in-person learning."
```

Then the AI edits `work/ai-facts.shen` with candidate facts and runs:

```sh
./logicbox check
```

## AI Workflow

For each draft, the AI should:

1. Read `work/draft.txt`.
2. Identify the likely argument in plain English.
3. Extract main terms, claims, mechanisms, modality, and scope.
4. Split grounds from conclusions when possible.
5. Add context obligations that the claim relies on.
6. Add staged mechanism steps for broad causal claims.
7. Add simple scopes for plan facts.
8. Mark unclear terms or context as `unknown` instead of guessing.
9. Add semantic helper facts when useful, such as `[similar A B]`, `[abstract M]`, or `[supports p1 k1]`.
10. Run `./logicbox check`.
11. Explain only the flags Shen actually derives.

The AI supplies semantic relationships. Shen derives the warnings.

## Compile-Check-Repair

Use LogicBox like a tiny compiler while translating prose:

1. Draft candidate facts in `work/ai-facts.shen`.
2. Run `./logicbox preflight`.
3. Repair compact atoms and obvious decomposition errors.
4. Run `./logicbox check`.
5. Repair translation errors such as `extraction-contract-violation`, `decomposition-needed`, malformed fact shape, and missing definitions already supplied by the prose.
6. Leave real argument diagnostics in place, including `value-criteria-needed`, `missing-context`, `mitigation-needs-sufficiency-check`, `mitigation-needs-equivalence-check`, `claim-without-ground`, `analogy-needs-comparability`, `unclear-scope`, reconciliation tensions, and evidence gaps.
7. Explain only the remaining Shen-derived flags.

Default mode is structure-only: no internet and no factual truth checking. Evidence suggestion and evidence augmentation can be added later as explicit modes, with external additions marked separately from the original argument.

## Rewrite Safety

LogicBox rewrites are patch-first. The AI should not jump from diagnostics to polished prose. The safe pipeline is:

```text
diagnose draft
-> produce rewrite patch
-> preflight rewrite patch
-> apply patch to prose
-> mutation check
-> structural Shen re-check when user facts fill gaps
-> consistency/tension check for user-supplied facts
-> final rewrite + gap list + flag delta
```

Rewrite patches have an explicit mode:

- `structure_only`: default. Clarify, split, reorder, preserve meaning, and expose missing information as bracketed placeholders.
- `rewrite_with_user_facts`: may fill placeholders only with facts the user explicitly supplied.
- `evidence_mode`: may add external facts only when they are marked as externally sourced.

In `structure_only`, allowed patch operations are `keep`, `split`, `move`, `rephrase`, `surface-implicit-criterion`, `insert-placeholder`, `label`, and `mark-unresolved`.

In `rewrite_with_user_facts`, allowed patch operations are `keep`, `rephrase`, `insert-user-fact`, `resolve-gap`, `mark-unresolved`, `surface-implicit-criterion`, `move`, and `split`. Every `insert-user-fact` must reference one existing gap and carry `USER_SUPPLIED` provenance.

User-supplied facts are allowed mutations, but they are not automatically compatible with the argument. After gap fills, LogicBox reruns Shen and can assign `[plan-status P needs-reconciliation]` when new user facts conflict with claimed benefits, uniformity rules, subgroup treatment, fallback equivalence, or necessity claims.

Do not bury consistency-relevant user answers only inside `[definition ... "..."]` strings. Extract structured facts such as:

```shen
[user-supplied G3 slackrule]
[benefit c1 deep-work]
[policy-condition c1 slackrule]
[undermines slackrule deep-work]
[policy-rule hrguides uniform-rules]
[policy-rule hrguides no-manager-exceptions]
[exception-rule newoffice]
[exception-to newoffice c1]
[group-rule newoffice new-employees]
[conflicts-with-target newoffice threeday]
[mitigation-type alternatives office-fallback]
[equivalence-status alternatives unknown]
[necessity-ground k3 quitrisk]
[evidence-status quitrisk unknown]
```

The rewrite preflight blocks new numbers, thresholds, percentages, deadlines, named programs, proper nouns, empirical claims, comparison claims, implementation procedures, groups, stronger modality, and uniqueness claims unless they are represented as placeholders.

Structure-only rewrites must also preserve protected claims. A rewrite may mark a protected claim unresolved, but it may not replace it with `[undefined: fill missing information]` or omit it. Protected roles include main recommendations, core/scope conditions, objections, concessions, rebuttals, safeguards, mitigations, exceptions, equity guardrails, and value conclusions.

Use protected-role facts in symbolic mutation checks:

```shen
[protected c1 main-claim]
[protected c2 core-condition]
[protected o1 objection]
[protected m1 mitigation]
[protected k1 value-conclusion]
```

Then the rewrite must show preservation with same-ID rewrite status, correspondence, or unresolved marking:

```shen
[rewrite-status c1 preserved]
[marked-unresolved c2 G1]
[corresponds o1 rw-o1]
[rewrite-status rw-o1 preserved]
```

If a protected role disappears, Shen derives deletion flags such as `[deleted-main-claim c1]`, `[deleted-condition c2]`, or `[deleted-value-conclusion k1]`. The text mutation report also includes deletion checks for main claims, core conditions, objections, safeguards, and conclusions.

Gap objects are first-class:

```json
{
  "id": "G1",
  "type": "threshold-needed",
  "subject": "large apartment buildings",
  "prompt": "define which buildings count as \"large\""
}
```

A structure-only rewrite should use the gap instead of inventing the missing fact:

```text
The city should require large apartment buildings — [G1: define which buildings count as "large"] — to install smart cooling systems.
```

Every changed sentence needs provenance such as `CLARIFIED`, `REORDERED`, `BRACKETED_GAP`, `SURFACED_CRITERIA`, `USER_SUPPLIED`, or `MARKED_UNRESOLVED`. Unlabeled additions are rejected.

Run the safe rewrite path with:

```sh
./logicbox rewrite-preflight
./logicbox rewrite
./logicbox rewrite-mutation
```

The final report contains:

1. Updated rewrite
2. Gap status
3. Mutation/provenance report
4. Consistency status
5. Structural re-check delta
6. Remaining flags grouped by gap
7. Next recommended action

Core rule: the rewrite may reduce confusion, but it may not reduce factual uncertainty.

Deletion rule: if inserting a placeholder would erase or mutate the main claim, preserve the original sentence and list the gap externally:

```text
The hospital should use an AI scheduling assistant to create nurse schedules, but only if patient coverage, nurse fairness, and emergency staffing do not suffer.

[Unresolved: G1 patient coverage, G2 nurse fairness, G3 emergency staffing.]
```

## Symbol Contract

The extraction layer should emit a typed argument graph, not compact labels that hide domain structure. Shen can inspect `(action c1 ban)`, `(target c1 private-car-use)`, and `(location c1 downtown)`; it cannot inspect the internal meaning of a single atom like `downtown-car-ban`.

Forbidden style:

```shen
[term downtown-car-ban known]
[term better-outcomes unknown]
```

Preferred style:

```shen
[term c1 claim]
[agent c1 city-government]
[action c1 ban]
[target c1 private-car-use]
[location c1 downtown]
[timeframe c1 five-years]
[modality c1 deontic-recommendation]
```

For policy-style arguments, use primitive facts such as `term`, `action`, `target`, `agent`, `location`, `timeframe`, `modality`, `reason-type`, `outcome`, `objects-to`, `mitigates`, `exempts`, `analogizes-from`, and `supports`. If a draft phrase cannot be mapped cleanly, represent it as unknown plus a definition instead of inventing a semantic-rich atom.

The command-line `check` and `mutation` paths run `scripts/preflight-facts.js` before Shen. That script appends marker facts for suspicious compact atoms, action-like atoms that should be decomposed, and value terms that need criteria. Shen then reports extraction and classification diagnostics in the same file-based workflow.

Typed claim nodes may carry scope directly:

```shen
[term c1 claim]
[location c1 admissions-office]
[population c1 undergraduate-applications]
[timeframe c1 next-cycle]
[scope-status c1 conditional]
```

Those fields count as scoped structure. Use `scope-status` values such as `unknown`, `underspecified`, or `unbounded` only when Shen should derive `unclear-scope`.

## Reading The Output

`[plan-status p1 argument-clear-enough]` means the current plan has no blocking structural flags. It does not mean the argument is true.

`[plan-status p1 needs-user-input]` means at least one blocking issue remains. `[plan-status p1 needs-evidence]` means a remaining issue needs outside support or a narrower claim.

`[plan-status p1 needs-reconciliation]` means translation and mutation provenance may be clean, but accepted facts introduce a tension with the argument's structure. This status outranks ordinary `needs-user-input`; mutation pass does not imply argument pass.

Common flags:

- `[extraction-contract-violation X]`: the extractor packed domain meaning into an opaque atom; decompose it into fields before judging the draft.
- `[definition-needed X]`: a legitimate concept needs an operational definition.
- `[decomposition-needed X]`: an action or condition should be represented as primitive predicates instead of a term.
- `[value-criteria-missing X]`: a value conclusion such as fairness, safety, or responsibility needs explicit criteria.
- `[value-criteria-stated X]`: criteria are stated in prose, but not yet linked to grounds.
- `[value-criteria-grounded X]`: criteria are stated and linked to supporting grounds.
- `[missing-mechanism C]`: a causal claim lacks a represented mechanism.
- `[mechanism-restates-source ...]`: the explanation may repeat the starting point.
- `[mechanism-restates-target ...]`: the explanation may repeat the desired result.
- `[missing-context C X]`: a background assumption is needed.
- `[tension benefit-undermined C Benefit Cond]`: a condition or rule weakens a benefit the claim relies on.
- `[tension uniform-rule-vs-exception R E]`: a uniform/no-exceptions policy conflicts with an exception.
- `[tension subgroup-rule-conflicts-with-policy C Rule Group]`: a subgroup rule conflicts with the main policy target.
- `[mitigation-needs-equivalence-check M O]`: a fallback mitigation is traceable but may not preserve equivalent benefit.
- `[overclaim necessity-counterfactual K Ground]`: a necessity claim relies on an unsupported counterfactual ground.
- `[deleted-main-claim C]`: the main recommendation disappeared from the rewrite.
- `[deleted-condition C]`: a core/scope condition disappeared from the rewrite.
- `[deleted-objection O]`: an objection disappeared from the rewrite.
- `[deleted-rebuttal R]`: a rebuttal disappeared from the rewrite.
- `[deleted-safeguard S]`: a safeguard, exception, or equity guardrail disappeared from the rewrite.
- `[deleted-mitigation M]`: a mitigation disappeared from the rewrite.
- `[deleted-value-conclusion K]`: a value conclusion disappeared from the rewrite.
- `[claim-without-ground K]`: a conclusion has no represented support.
- `[stage-chain-too-short C Count Minimum]`: a causal bridge needs more intermediate structure.
- `[scope-missing F]`: a plan fact needs a local, section, document, or global scope.
- `[precomputed-flag ...]`: a final Shen result was incorrectly placed in the AI fact input.

When a flag appears, the next move is usually one of three things: define a term, add the missing mechanism/context, or ask the human whether the AI misunderstood the intended meaning.

## What To Ask The AI

Useful prompts while working locally:

```text
Read work/draft.txt, extract a reasoning plan into work/ai-facts.shen, then run ./logicbox check and explain only Shen's output.
```

```text
Use Shen's flags to ask me one or two clarification questions. Do not rewrite yet.
```

```text
Update work/ai-facts.shen using my clarification and rerun the check.
```

```text
Propose a rewrite, extract rewrite facts, run ./logicbox mutation, and tell me whether Shen found meaning drift.
```

```text
Run ./logicbox stress and summarize which adversarial cases the kernel catches.
```

```text
Run ./logicbox gold and ./logicbox fuzz, then summarize whether the reusable regression checks passed.
```

```text
Run ./logicbox edge and summarize which edge-case families passed.
```

## Reasoning Plans

The AI should now group extracted facts into a lightweight reasoning plan. This is still plain Shen data, not a new app architecture.

```shen
[plan p1]
[plan-source p1 draft-1]
[plan-goal p1 clarify-argument]
[plan-fact p1 f-term-adjust]
[plan-fact p1 f-term-better]
[plan-fact p1 f1]
[plan-context p1 feedback-is-reliable-enough]
[plan-check p1 missing-context]
[comment p1 "The paragraph appears to rely on feedback as an adaptive mechanism."]
```

Comments are first-class notes, but they are not evidence. Shen ignores comments when deriving flags.

## Kernel Vocabulary

Use these fact families when useful:

```shen
[ground-claim g1 Source Target]
[conclusion k1 Target]
[infers-to g1 k1]

[context-required c1 feedback-is-reliable-enough]
[context-known feedback-is-reliable-enough unknown]

[stage s1 observe-results]
[stage-of s1 c1]
[stage-order s1 1]
[stage-next c1 s1 s2]
[stage-bridge s1 s2 causal-attribution]
[stage-chain-min c1 3]

[entity people]
[property people independent-judgment]
[relation accepts-without-evaluation people ai-output]

[fact-scope f1 local]
[fact-scope f2 section]
[fact-scope f3 document]
[fact-scope f4 global]
```

## Important Boundary

The AI may write facts like:

```shen
[term online-learning unknown]
[claim c1 equivalence online-learning in-person-learning]
[mechanism c1 unknown]
[modality c1 unknown]
[scope c1 unknown]

[fact-scope f-term-adjust local]
[similar source-symbol mechanism-symbol]
[abstract vague-mechanism]
[supports premise-claim conclusion-claim]
[context-required c1 actor-can-change-future-actions]
[context-known actor-can-change-future-actions unknown]
```

The AI must not write derived flags like:

```shen
[definition-needed online-learning]
[missing-mechanism c1]
[mechanism-restates-source c1 source mechanism]
[mechanism-restates-target c1 target mechanism]
[mechanism-too-abstract c1 mechanism]
[missing-context c1 actor-can-change-future-actions]
[plan-incomplete p1]
[clear-enough p1]
```

Those belong to Shen and appear only in `output/shen-output.txt`.

For rewrite checks, the AI appends only rewrite facts in `work/rewrite-facts.shen`:

```shen
(set *facts*
  (append (value *facts*)
    [
      [rewrite-claim r1 causal ai-use destroyed-intelligence]
      [rewrite-modality r1 certain]
      [rewrite-scope r1 universal]
      [broader-than ai-use passive-ai-dependence]
      [stronger-effect destroyed-intelligence weakened-independent-judgment]
      [stronger-than certain possible]
      [stronger-than universal conditional]
    ]))
```

Then run:

```sh
./logicbox mutation
```

## Fact Format

Facts are Shen data inside `work/ai-facts.shen`:

```shen
(set *facts*
  [
    [term some-symbol unknown]
    [term another-symbol known]
    [claim c1 causal some-symbol another-symbol]
    [mechanism c1 unknown]
    [modality c1 possible]
    [scope c1 conditional]
  ])
```

## Explanatory Distance

LogicBox can now detect when a mechanism exists syntactically but does not add much explanation.

Weak example:

```shen
[claim c1 causal adjust-based-on-results better-outcomes]
[mechanism c1 repeat-what-works]
[similar adjust-based-on-results repeat-what-works]
```

Shen derives:

```shen
[mechanism-restates-source c1 adjust-based-on-results repeat-what-works]
```

Meaning: the explanation may be too close to the original claim. It says adjustment works because adjustment repeats what works.

Stronger mechanisms usually describe a bridge such as:

```text
early problem detection
lower cost of correction
better allocation of effort
improved information for future choices
```

## Checks Implemented

Current Shen-derived flags:

- `[extraction-contract-violation X]`
- `[definition-needed X]`
- `[decomposition-needed X]`
- `[value-criteria-needed X V]`
- `[missing-mechanism C]`
- `[mechanism-needs-causal-path M]`
- `[unclear-modality C]`
- `[unclear-scope C]`
- `[mechanism-restates-source C Source Mechanism]`
- `[mechanism-restates-target C Target Mechanism]`
- `[mechanism-too-abstract C Mechanism]`
- `[missing-context C Context]`
- `[tension benefit-undermined C Benefit Condition]`
- `[tension uniform-rule-vs-exception Rule Exception]`
- `[tension subgroup-rule-conflicts-with-policy C Rule Group]`
- `[mitigation-needs-equivalence-check Mitigation Objection]`
- `[overclaim necessity-counterfactual Conclusion Ground]`
- `[deleted-main-claim Claim]`
- `[deleted-condition Claim]`
- `[deleted-objection Objection]`
- `[deleted-concession Concession]`
- `[deleted-rebuttal Rebuttal]`
- `[deleted-safeguard Safeguard]`
- `[deleted-mitigation Mitigation]`
- `[deleted-value-conclusion Conclusion]`
- `[conclusion-stronger-than-premises Premise Conclusion OldModality NewModality]`
- `[conclusion-stronger-than-ground Ground Conclusion OldModality NewModality]`
- `[claim-without-ground Conclusion]`
- `[stage-chain-too-short C Count Minimum]`
- `[stage-restates-claim C Stage Label Term]`
- `[mechanism-restates-stage C Stage Mechanism Label]`
- `[missing-stage-bridge C Stage1 Stage2]`
- `[scope-missing Fact]`
- `[scope-conflict Fact1 Fact2 Scope1 Scope2]`
- `[global-term-redefined-locally Term GlobalFact LocalFact]`
- `[precomputed-flag FlagName ...]`
- `[plan-incomplete P]`
- `[clear-enough P]`
- `[modality-mutation C R Old New]`
- `[scope-mutation C R Old New]`
- `[source-mutation C R Old New]`
- `[target-mutation C R Old New]`

`[clear-enough P]` is not a truth verdict. It only means this local plan has no blocking structural flags.

`[plan-status P needs-reconciliation]` is the post-gap-fill consistency status. It separates "this user fact was allowed by provenance" from "this user fact still fits the argument."

## Counterexample Feedback

When Shen derives a weakness such as `missing-context`, `missing-mechanism`, `stage-chain-too-short`, `claim-without-ground`, or `conclusion-stronger-than-premises`, the AI should add one short "Counterexample pressure test" in plain language.

Example:

```text
Someone may observe results but misread them, repeat the wrong action, or lack the ability to change behavior. In that case, feedback exists but improvement does not follow.
```

This counterexample is explanatory AI feedback, not a Shen-derived result.

## Worked Kernel Example

Draft:

```text
People who adjust based on results do better because adjusting based on results lets them repeat what works.
```

Candidate facts:

```shen
[plan p1]
[plan-source p1 draft-1]
[plan-goal p1 clarify-argument]

[term adjust-based-on-results known]
[term better-outcomes unknown]
[term repeat-what-works known]

[ground-claim g1 adjust-based-on-results repeat-what-works]
[conclusion k1 better-outcomes]
[infers-to g1 k1]

[claim c1 causal adjust-based-on-results better-outcomes]
[mechanism c1 repeat-what-works]
[similar adjust-based-on-results repeat-what-works]

[context-required c1 result-measure-is-reliable]
[context-known result-measure-is-reliable unknown]
[context-required c1 actor-can-change-future-actions]
[context-known actor-can-change-future-actions unknown]

[stage-chain-min c1 3]
[stage s1 repeat-what-works]
[stage-of s1 c1]
[stage-order s1 1]

[modality c1 unknown]
[scope c1 unknown]
```

Expected Shen output:

```shen
[extraction-contract-violation better-outcomes]
[unclear-modality c1]
[unclear-scope c1]
[mechanism-restates-source c1 adjust-based-on-results repeat-what-works]
[missing-context c1 result-measure-is-reliable]
[missing-context c1 actor-can-change-future-actions]
[stage-chain-too-short c1 1 3]
[stage-restates-claim c1 s1 repeat-what-works adjust-based-on-results]
[mechanism-restates-stage c1 s1 repeat-what-works repeat-what-works]
[scope-missing f-term-better]
[plan-incomplete p1]
```

Expected AI feedback:

```text
Shen did not say the claim is false. It found that the mechanism and stage structure are still too close to the original claim, and that two context assumptions are missing: the result measure must be reliable enough, and the actor must be able to change future actions.

Counterexample pressure test:
Someone may observe results but misread them, repeat the wrong action, or be unable to change behavior. In that case, feedback exists but improvement does not follow.

Clarifying question:
What changes after observing results: strategy, attention, effort allocation, or the person's model of the task?
```

## Stress Tests

The test suite includes ordinary fixtures, adversarial fixtures, gold models, and generated fuzz invariants:

```sh
./logicbox test
```

The stress-only command runs just the adversarial fixtures:

```sh
./logicbox stress
```

These try to sneak in fake support, circular stages, local/global scope leaks, comments as evidence, and precomputed final flags. Shen should derive flags instead of accepting those shortcuts.

Expected stress behavior:

- `stress-comment-as-evidence-model.shen`: comments do not satisfy missing context.
- `stress-fake-support-model.shen`: unknown ground claims do not support conclusions.
- `stress-precomputed-flag-model.shen`: final flags in input are reported as `precomputed-flag`.
- `stress-scope-leak-model.shen`: local/global definition drift is flagged.
- `stress-stage-circular-model.shen`: short or circular stage chains remain incomplete.

## Gold And Fuzz Tests

Gold tests live in `tests/gold/`. Each `.shen` model has a matching `.expected` file. These are minimal positive/negative examples for specific flags, such as missing context, stage-chain length, scope conflict, conclusion strength, and precomputed flags.

Run them with:

```sh
./logicbox gold
```

Edge-case suites live in `tests/edge/`. They are named fixtures for the five families most likely to break the kernel:

- scope pathologies
- stage/mechanism entanglement
- context obligations
- ground/conclusion/modality interactions
- plan meta-structure

Run them with:

```sh
./logicbox edge
```

Fuzz tests are generated temporarily by the `logicbox` script. They check invariants rather than exact stored models:

- no scope conflict when all scopes are identical
- stage-chain-too-short fires only below the requested minimum
- known context does not trigger missing-context
- stronger conclusions over weaker grounds are flagged
- modality and scope rewrite mutations are detected

Run them with:

```sh
./logicbox fuzz
```

## Troubleshooting

If `./logicbox check` returns `[]`, there may be no `[plan ...]` fact in the current model. Older fixtures without a plan can still produce ordinary flags, but only plans produce `[clear-enough ...]` or `[plan-incomplete ...]`.

If Shen reports a syntax error, inspect `work/ai-facts.shen` for mismatched brackets. Facts use Shen lists like `[claim c1 causal source target]`, not Lisp parentheses.

If a flag seems wrong, first check whether the AI encoded the prose correctly. The system checks the facts it was given; it does not read the draft directly.

If `[precomputed-flag ...]` appears, remove the derived flag from `work/ai-facts.shen`. The AI may submit helper facts, but Shen must derive final flags.

## Upload Checklist

Before uploading or sharing the folder:

1. Run `./logicbox check`.
2. Run `./logicbox mutation`.
3. Run `./logicbox stress`.
4. Run `./logicbox gold`.
5. Run `./logicbox edge`.
6. Run `./logicbox fuzz`.
7. Run `./logicbox test`.
8. Confirm no hidden Shen raw outputs are present in `output/`.
9. Confirm `README.md` and `skill.md` are the only authoritative docs.
10. Confirm the sample files in `work/` are safe to share.

The upload-ready surface is:

```text
.gitignore
README.md
skill.md
logicbox
shen/
tests/
work/
output/
```

Generated raw Shen logs are ignored by `.gitignore`; the useful human-readable outputs are kept in `output/shen-output.txt`, `output/mutation-output.txt`, and `output/ai-feedback.md`.

## Files

```text
.gitignore
logicbox
README.md
skill.md
work/
  draft.txt
  ai-facts.shen
  rewrite.md
  rewrite-facts.shen
shen/
  rules.shen
  run.shen
  run-mutation.shen
output/
  shen-output.txt
  ai-feedback.md
  mutation-output.txt
```
