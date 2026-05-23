# LogicBox

LogicBox helps people turn messy prose into clearer arguments without pretending to decide whether the argument is factually true.

It is a small file-based reasoning loop:

1. A human writes a draft in plain language.
2. An AI translates the draft into symbolic facts.
3. Shen derives structural flags from those facts.
4. The AI explains only those derived flags and asks for clarification.
5. The human decides what they meant.

Use LogicBox when you want an AI assistant to help clarify an argument, proposal, policy, essay, memo, or rewrite while keeping uncertainty visible instead of smoothing it away.

## What Can I Do With This?

LogicBox answers practical questions like:

- Did this paragraph make a claim without enough support?
- Did my rewrite accidentally make the claim stronger than the original?
- Did an AI fill in a missing fact that the human never supplied?
- Are the scope, mechanism, criteria, or assumptions unclear?
- Did the final rewrite preserve the important claim, objection, safeguard, or condition?
- Are there still gaps the user needs to answer before a clean rewrite is safe?

It is especially useful when an argument feels plausible but slippery. LogicBox gives the AI a disciplined way to say, “This part needs a definition,” “This causal step is missing,” or “This rewrite changed the meaning,” instead of jumping straight to polished prose.

## Example Uses

### Example 1: Improve a policy argument

Draft:

```text
The city should require large apartment buildings to install smart cooling systems because this will protect vulnerable residents during heat waves.
```

LogicBox can help surface questions such as:

- What counts as a “large” apartment building?
- Which residents are considered vulnerable?
- What mechanism connects smart cooling systems to protection?
- Is the claim about all heat waves, extreme heat events, or a specific city program?
- Does the argument need evidence, a narrower claim, or a safeguard?

A safe rewrite might keep unresolved facts visible:

```text
The city should require large apartment buildings — [G1: define which buildings count as "large"] — to install smart cooling systems, because these systems may help protect vulnerable residents — [G2: define the protected resident group] — during heat waves.
```

The point is not to make the paragraph sound better at any cost. The point is to make it clearer without inventing missing information.

### Example 2: Keep an AI rewrite from drifting

Original:

```text
Students may benefit from AI tutoring when the tutor gives feedback that the student can evaluate and apply.
```

Unsafe rewrite:

```text
AI tutoring will improve student outcomes for everyone.
```

LogicBox can flag that the rewrite strengthened the modality, broadened the scope, and removed the condition that students must be able to evaluate and apply the feedback.

### Example 3: Clarify a causal explanation

Draft:

```text
People who adjust based on results do better because adjusting based on results lets them repeat what works.
```

LogicBox can flag that the explanation may be circular or too close to the original claim. A better next step is not necessarily a rewrite; it may be a question:

```text
What changes after observing results: strategy, attention, effort allocation, or the person's model of the task?
```

## Who Is This For?

LogicBox is for people who work with claims that need careful structure:

- writers revising essays, memos, policy arguments, or grant proposals
- researchers or students checking whether a claim has enough support
- product and policy teams trying to preserve constraints during rewrites
- AI-tool builders who want a small reasoning kernel around LLM-generated prose
- anyone who wants AI feedback to separate “this is unclear” from “this is false”

It is also for developers experimenting with a hybrid AI + symbolic-checking workflow. The project keeps the AI responsible for interpretation and explanation, while Shen is responsible for deriving structural warnings from explicit facts.

## What LogicBox Is Not

LogicBox does not prove that a claim is true.

By default, it does not browse the internet, verify evidence, or decide whether a policy is good. It checks the structure of the argument represented in the facts it was given.

If Shen flags something because the AI encoded the human’s meaning incorrectly, the right fix is to repair the facts, not to rewrite the prose around the mistake.

Core boundary:

```text
LogicBox can reduce confusion.
LogicBox should not reduce factual uncertainty.
```

## How It Works

The normal loop is intentionally small:

```text
plain-text draft
-> AI-extracted Shen facts
-> Shen-derived structural flags
-> AI explanation and clarification questions
-> human correction or approval
-> optional safe rewrite
-> mutation and consistency checks
```

The architecture is file-based. The shell script orchestrates commands, Shen derives logical flags, and JavaScript still handles JSON/text glue for rewrite patching and reporting.

Important files:

```text
work/draft.txt              user draft
work/ai-facts.shen          AI-extracted source facts
work/adapter-facts.shen     temporary semantic bridge facts
work/rewrite-patch.json     machine-checkable rewrite patch
work/rewrite.md             applied rewrite
work/rewrite-facts.shen     rewrite-derived symbolic facts
output/check-report.md      source-facing report to read first
output/shen-output.txt      expert/audit raw Shen flags
output/rewrite-report.md    safe rewrite report
output/mutation-output.txt  rewrite mutation output
```

## Quick Start

Put a draft in `work/draft.txt`, extract candidate facts into `work/ai-facts.shen`, then run the streamlined review:

```sh
./logicbox review
```

Read this first:

```text
output/check-report.md
```

Use the raw Shen output only when you need machine-oriented audit detail:

```text
output/shen-output.txt
```

Start a new claim from the command line:

```sh
./logicbox new "Online learning is just as effective as in-person learning."
```

Then have the AI edit `work/ai-facts.shen` and run:

```sh
./logicbox review
```

## Command Overview

### Review the current argument

```sh
./logicbox review
```

Runs the current Shen check and shows the source-facing report. This is the default human workflow: diagnostics, next action, source frames, file map, and expert appendices live together in `output/check-report.md`.

### Check the current argument, expert mode

```sh
./logicbox check
```

Uses `work/draft.txt`, `work/ai-facts.shen`, and `work/adapter-facts.shen` to derive structural flags.

Outputs:

```text
output/shen-output.txt
output/check-report.md
```

### Run only extraction preflight

```sh
./logicbox preflight
```

Use this when you want to inspect marker facts before a full check. Preflight helps catch opaque symbols, decomposition problems, and value terms that may need criteria.

### Check symbolic rewrite mutation

```sh
./logicbox mutation
```

Uses rewrite-derived facts in `work/rewrite-facts.shen` and saves output to:

```text
output/mutation-output.txt
```

### Run the safe rewrite path

```sh
./logicbox rewrite-preflight
./logicbox rewrite
./logicbox rewrite-mutation
```

Uses `work/rewrite-patch.json` to validate and apply a rewrite without silently inventing missing facts.

### Run tests

```sh
./logicbox test
```

Runs ordinary fixtures, adversarial stress fixtures, exact gold models, edge suites, and generated fuzz invariants.

Run subsets:

```sh
./logicbox stress
./logicbox gold
./logicbox edge
./logicbox fuzz
```

## Schema Gate & Pipeline

Since v2.3.0, LogicBox validates facts through a typed schema gate before the kernel runs.

**Pipeline:**
```
raw facts → normalization → schema typecheck → accepted core facts → kernel → report
```

Hard schema errors (wrong arity, bad enum, unknown predicate, ID-class mismatch, precomputed flags, namespace leakage) block the kernel with `translation-error`.

**New commands:**

```sh
./logicbox schema-test        # regression suite for norm, typecheck, provenance
./logicbox schema-contract    # machine-readable prompt contract from schema registry
```

**New files:**

```text
shen/fact-schema.shen         schema registry (predicates, types, enums)
shen/fact-normalize.shen      normalization pass
shen/fact-typecheck.shen      type checker
shen/fact-provenance.shen     provenance tracking
docs/fact-schema.md           schema gate documentation
docs/prompt-contract.md       LLM extraction prompt contract
```

Only registered predicates pass the gate. Common errors caught:

- `[condition c2 ...]` → not a predicate (use `[claim c2 ...]`)
- `[value-conclusion v1 ...]` → not a predicate
- `[term o1 objection]` → not a valid TermKind (use `entity`)
- `[term r1 rebuttal]` → not a valid TermKind (use `reason`)
- `[sufficiency r1 stated]` → not a valid KnowledgeState (use `shown`)
- `[protected r1 rebuttal]` → not a valid ProtectedRole (use `safeguard`)

## Normal User Workflow

1. Write or paste a paragraph into `work/draft.txt`.
2. Ask the AI to extract candidate facts into `work/ai-facts.shen`.
3. Put temporary bridge facts in `work/adapter-facts.shen` only when the current check needs them.
4. Run `./logicbox review`.
5. Read `output/check-report.md` before reading the raw Shen output.
6. Ask the AI to explain only the diagnostics Shen actually derived.
7. Clarify the paragraph or the intended meaning.
8. Update `work/ai-facts.shen` and `work/adapter-facts.shen`.
9. Run `./logicbox review` again.

The human remains the authority on meaning.

## What To Ask The AI

Useful prompts while working locally:

```text
Read work/draft.txt, extract a reasoning plan into work/ai-facts.shen, then run ./logicbox review and explain the source-facing diagnostics.
```

```text
Use Shen's flags to ask me one or two clarification questions. Do not rewrite yet.
```

```text
Update work/ai-facts.shen using my clarification and rerun ./logicbox review.
```

```text
Propose a rewrite patch that preserves meaning, marks unresolved gaps, and does not add external facts.
```

```text
Run ./logicbox rewrite-preflight, ./logicbox rewrite, and ./logicbox rewrite-mutation. Tell me whether Shen found meaning drift.
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
10. Run `./logicbox review`.
11. Explain only the source-facing diagnostics Shen actually derives.

The AI supplies semantic relationships. Shen derives the warnings.

## Compile, Check, Repair

Use LogicBox like a tiny compiler while translating prose:

1. Draft candidate facts in `work/ai-facts.shen`.
2. Run `./logicbox preflight`.
3. Repair compact atoms and obvious decomposition errors.
4. Run `./logicbox review`.
5. Repair translation errors such as `extraction-contract-violation`, `decomposition-needed`, malformed fact shape, and missing definitions already supplied by the prose.
6. Leave real argument diagnostics in place, including `value-criteria-needed`, `missing-context`, `mitigation-needs-sufficiency-check`, `mitigation-needs-equivalence-check`, `claim-without-ground`, `analogy-needs-comparability`, `unclear-scope`, reconciliation tensions, and evidence gaps.
7. Explain only the remaining Shen-derived flags.

Default mode is structure-only: no internet and no factual truth checking. Evidence suggestion and evidence augmentation can be added later as explicit modes, with external additions marked separately from the original argument.

## Reading The Output

Read `output/check-report.md` first. It separates:

```text
Read first:
- Blocking issues
- Reconciliation tensions
- Mutation/deletion failures

Next action:
- the likely next move

Diagnostics:
- source-facing explanation of derived flags

Open user tasks:
- evidence still needed
- optional definitions
- value confirmation

Positive statuses:
- value criteria already grounded

Plan status:
- the current next-state label

Source frames:
- source-facing labels and definitions

Expert appendices:
- raw Shen flags
- raw source facts
- temporary adapter facts
```

Do not treat positive status flags as blocking problems. `value-criteria-grounded` is a positive status. A plan can have no blocking issues, no remaining reconciliation tensions, and still be `needs-user-input` because evidence or optional clarification remains.

Common plan statuses:

- `[plan-status p1 ready-for-final-rewrite]`: the current plan has no blocking structural flags. It does not mean the argument is true.
- `[plan-status p1 translation-error]`: the symbolic extraction itself needs repair before the argument should be judged.
- `[plan-status p1 needs-user-input]`: definitions, context, mechanisms, scope, or similar structural information is missing.
- `[plan-status p1 awaiting-value-confirmation]`: only value criteria need confirmation.
- `[plan-status p1 needs-evidence]`: a remaining issue needs outside support or a narrower claim.
- `[plan-status p1 needs-reconciliation]`: translation and mutation provenance may be clean, but accepted facts introduce a tension with the argument's structure.

`needs-reconciliation` outranks ordinary `needs-user-input`. A mutation pass does not imply an argument pass.

## Common Flags

- `[extraction-contract-violation X]`: the extractor packed domain meaning into an opaque atom; decompose it before judging the draft.
- `[definition-needed X]`: a legitimate concept needs an operational definition.
- `[decomposition-needed X]`: an action or condition should be represented as primitive predicates instead of a compact term.
- `[value-criteria-missing X]`: a value conclusion such as fairness, safety, privacy, or responsibility needs explicit criteria.
- `[value-criteria-stated X]`: criteria are stated in prose, but not yet linked to grounds.
- `[value-criteria-grounded X]`: criteria are stated and linked to supporting grounds.
- `[missing-mechanism C]`: a causal claim lacks a represented mechanism.
- `[mechanism-needs-causal-path M]`: a mechanism is present but lacks a causal bridge.
- `[mechanism-restates-source C Source Mechanism]`: the explanation may repeat the starting point.
- `[mechanism-restates-target C Target Mechanism]`: the explanation may repeat the desired result.
- `[mechanism-too-abstract C Mechanism]`: the mechanism is too abstract to explain the claim.
- `[missing-context C X]`: a background assumption is needed.
- `[claim-without-ground K]`: a conclusion has no represented support.
- `[conclusion-stronger-than-premises Premise Conclusion OldModality NewModality]`: the conclusion is stronger than its premise.
- `[conclusion-stronger-than-ground Ground Conclusion OldModality NewModality]`: the conclusion is stronger than its ground.
- `[stage-chain-too-short C Count Minimum]`: a causal bridge needs more intermediate structure.
- `[missing-stage-bridge C Stage1 Stage2]`: two causal stages need a represented bridge.
- `[scope-missing F]`: a plan fact needs a local, section, document, or global scope.
- `[scope-conflict Fact1 Fact2 Scope1 Scope2]`: two facts use conflicting scopes.
- `[global-term-redefined-locally Term GlobalFact LocalFact]`: a local definition conflicts with a global term.
- `[tension benefit-undermined C Benefit Condition]`: a condition or rule weakens a benefit the claim relies on.
- `[tension uniform-rule-vs-exception Rule Exception]`: a uniform/no-exceptions policy conflicts with an exception.
- `[tension subgroup-rule-conflicts-with-policy C Rule Group]`: a subgroup rule conflicts with the main policy target.
- `[mitigation-needs-equivalence-check M O]`: a fallback mitigation is traceable but may not preserve equivalent benefit.
- `[overclaim necessity-counterfactual K Ground]`: a necessity claim relies on an unsupported counterfactual ground.
- `[deleted-main-claim C]`: the main recommendation disappeared from the rewrite.
- `[deleted-condition C]`: a core or scope condition disappeared from the rewrite.
- `[deleted-objection O]`: an objection disappeared from the rewrite.
- `[deleted-rebuttal R]`: a rebuttal disappeared from the rewrite.
- `[deleted-safeguard S]`: a safeguard, exception, or equity guardrail disappeared from the rewrite.
- `[deleted-mitigation M]`: a mitigation disappeared from the rewrite.
- `[deleted-value-conclusion K]`: a value conclusion disappeared from the rewrite.
- `[modality-mutation C R Old New]`: the rewrite changed the strength of the claim.
- `[scope-mutation C R Old New]`: the rewrite changed the scope of the claim.
- `[source-mutation C R Old New]`: the rewrite changed the source side of the claim.
- `[target-mutation C R Old New]`: the rewrite changed the target side of the claim.
- `[precomputed-flag ...]`: a final Shen result was incorrectly placed in the AI fact input.

When a flag appears, the next move is usually one of three things: define a term, add the missing mechanism/context, or ask whether the AI misunderstood the intended meaning.

## Counterexample Feedback

When Shen derives a weakness such as `missing-context`, `missing-mechanism`, `stage-chain-too-short`, `claim-without-ground`, or `conclusion-stronger-than-premises`, the AI should add one short counterexample pressure test in plain language.

Example:

```text
Someone may observe results but misread them, repeat the wrong action, or lack the ability to change behavior. In that case, feedback exists but improvement does not follow.
```

This counterexample is explanatory AI feedback, not a Shen-derived result.

## Rewrite Safety

LogicBox rewrites are patch-first. The AI should not jump from diagnostics to polished prose.

Safe pipeline:

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

In `structure_only`, allowed patch operations are:

```text
keep
split
move
rephrase
surface-implicit-criterion
insert-placeholder
label
mark-unresolved
```

In `rewrite_with_user_facts`, allowed patch operations are:

```text
keep
rephrase
insert-user-fact
resolve-gap
mark-unresolved
surface-implicit-criterion
move
split
```

Every `insert-user-fact` must reference one existing gap and carry `USER_SUPPLIED` provenance.

User-supplied facts are allowed mutations, but they are not automatically compatible with the argument. After gap fills, LogicBox reruns Shen and can assign `[plan-status P needs-reconciliation]` when new user facts conflict with claimed benefits, uniformity rules, subgroup treatment, fallback equivalence, or necessity claims.

Gap fills are reported as:

- `resolved-clean`
- `answered-conflicting`
- `still-open`

A user answer can be accepted for provenance while still being `answered-conflicting` if Shen derives a contradiction or tension from the structured facts it introduces.

### Gap objects

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

Every changed sentence needs provenance such as:

```text
CLARIFIED
REORDERED
BRACKETED_GAP
SURFACED_CRITERIA
USER_SUPPLIED
MARKED_UNRESOLVED
```

Unlabeled additions are rejected.

### Protected claims

Structure-only rewrites must preserve protected claims. A rewrite may mark a protected claim unresolved, but it may not replace it with a generic placeholder or omit it.

Protected roles include:

- main recommendations
- core or scope conditions
- objections
- concessions
- rebuttals
- safeguards
- mitigations
- exceptions
- equity guardrails
- value conclusions

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

If a protected role disappears, Shen derives deletion flags such as:

```shen
[deleted-main-claim c1]
[deleted-condition c2]
[deleted-value-conclusion k1]
```

Deletion rule: if inserting a placeholder would erase or mutate the main claim, preserve the original sentence and list the gap externally:

```text
The hospital should use an AI scheduling assistant to create nurse schedules, but only if patient coverage, nurse fairness, and emergency staffing do not suffer.

[Unresolved: G1 patient coverage, G2 nurse fairness, G3 emergency staffing.]
```

### Safe rewrite output

The final rewrite report contains:

1. Updated rewrite
2. Gap status
3. Mutation/provenance report
4. Consistency status
5. Structural re-check delta
6. Remaining flags grouped by gap
7. Next recommended action

## Temporary Adapter Facts

Use `work/adapter-facts.shen` for per-run semantic bridge facts that help Shen connect the user's wording to general structural rules.

Typical adapter facts are generic relationships:

```shen
[adapter-fact a1]
[adapter-source a1 ai-semantic-bridge]
[adapter-scope a1 current-run]
[adapter-status a1 temporary]
[implies nightlystudylogs privatestudymonitoring]
```

Adapter facts are loaded into the current Shen check and reported separately in `output/check-report.md`. They should stay out of `shen/rules.shen` unless deliberately promoted after neutral wording and regression coverage.

Do not bury consistency-relevant user answers only inside `[definition ... "..."]` strings. Extract structured facts such as:

```shen
[user-supplied G3 slackrule]
[benefit c1 deep-work]
[policy-condition c1 slackrule]
[undermines slackrule deep-work]
[policy-rule hrguides uniform-rules]
[prohibits hrguides exceptions]
[exception-rule newoffice]
[exception-to newoffice c1]
[group-rule newoffice new-employees]
[conflicts-with-target newoffice threeday]
[needs-equivalence-check alternatives]
[equivalence-status alternatives unknown]
[necessity-ground k3 quitrisk]
[evidence-status quitrisk unknown]
```

Structured consistency helper facts are not manual notes. Shen consumes generic bridge facts such as `[requires C X]`, `[denies Y X]`, `[prohibits C X]`, `[implies Y X]`, `[conflicts Y X]`, and `[undermines Y X]` to derive contradiction or tension flags. These bridge facts usually belong in `work/adapter-facts.shen`, not in the permanent rule kernel.

## Symbol Contract

The extraction layer should emit a typed argument graph, not compact labels that hide domain structure.

Shen can inspect this:

```shen
[action c1 ban]
[target c1 private-car-use]
[location c1 downtown]
```

Shen cannot inspect the internal meaning of one opaque atom:

```shen
[term downtown-car-ban known]
```

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

For policy-style arguments, use primitive facts such as:

```text
term
action
target
agent
location
timeframe
modality
reason-type
outcome
objects-to
mitigates
exempts
analogizes-from
supports
```

If a draft phrase cannot be mapped cleanly, represent it as unknown plus a definition instead of inventing a semantic-rich atom.

Typed claim nodes may carry scope directly:

```shen
[term c1 claim]
[location c1 admissions-office]
[population c1 undergraduate-applications]
[timeframe c1 next-cycle]
[scope-status c1 conditional]
```

Those fields count as scoped structure. Use `scope-status` values such as `unknown`, `underspecified`, or `unbounded` only when Shen should derive `unclear-scope`.

The command-line `check` and `mutation` paths let Shen append marker facts for suspicious compact atoms, action-like atoms that should be decomposed, and value terms that need criteria inside the same default Shen run. `scripts/preflight-facts.js` is only a temporary parity path behind the legacy flag.

## Reasoning Plans

The AI should group extracted facts into a lightweight reasoning plan. This is still plain Shen data, not a new app architecture.

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

## Important Boundary For AI Facts

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

## Explanatory Distance

LogicBox can detect when a mechanism exists syntactically but does not add much explanation.

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

## Checks Implemented

Current Shen-derived flags include:

```text
[extraction-contract-violation X]
[definition-needed X]
[decomposition-needed X]
[value-criteria-needed X V]
[missing-mechanism C]
[mechanism-needs-causal-path M]
[unclear-modality C]
[unclear-scope C]
[mechanism-restates-source C Source Mechanism]
[mechanism-restates-target C Target Mechanism]
[mechanism-too-abstract C Mechanism]
[missing-context C Context]
[tension benefit-undermined C Benefit Condition]
[tension uniform-rule-vs-exception Rule Exception]
[tension subgroup-rule-conflicts-with-policy C Rule Group]
[mitigation-needs-equivalence-check Mitigation Objection]
[overclaim necessity-counterfactual Conclusion Ground]
[deleted-main-claim Claim]
[deleted-condition Claim]
[deleted-objection Objection]
[deleted-concession Concession]
[deleted-rebuttal Rebuttal]
[deleted-safeguard Safeguard]
[deleted-mitigation Mitigation]
[deleted-value-conclusion Conclusion]
[conclusion-stronger-than-premises Premise Conclusion OldModality NewModality]
[conclusion-stronger-than-ground Ground Conclusion OldModality NewModality]
[claim-without-ground Conclusion]
[stage-chain-too-short C Count Minimum]
[stage-restates-claim C Stage Label Term]
[mechanism-restates-stage C Stage Mechanism Label]
[missing-stage-bridge C Stage1 Stage2]
[scope-missing Fact]
[scope-conflict Fact1 Fact2 Scope1 Scope2]
[global-term-redefined-locally Term GlobalFact LocalFact]
[precomputed-flag FlagName ...]
[plan-incomplete P]
[clear-enough P]
[modality-mutation C R Old New]
[scope-mutation C R Old New]
[source-mutation C R Old New]
[target-mutation C R Old New]
```

`[clear-enough P]` is not a truth verdict. It only means this local plan has no blocking structural flags.

`[plan-status P needs-reconciliation]` is the post-gap-fill consistency status. It separates “this user fact was allowed by provenance” from “this user fact still fits the argument.”

## Test Suites

The test suite includes ordinary fixtures, adversarial fixtures, gold models, edge cases, and generated fuzz invariants.

Run all tests:

```sh
./logicbox test
```

### Stress tests

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

### Gold tests

```sh
./logicbox gold
```

Gold tests live in `tests/gold/`. Each `.shen` model has a matching `.expected` file. These are minimal positive/negative examples for specific flags, such as missing context, stage-chain length, scope conflict, conclusion strength, and precomputed flags.

### Edge tests

```sh
./logicbox edge
```

Edge-case suites live in `tests/edge/`. They are named fixtures for the families most likely to break the kernel:

- scope pathologies
- stage/mechanism entanglement
- context obligations
- ground/conclusion/modality interactions
- plan meta-structure

### Fuzz tests

```sh
./logicbox fuzz
```

Fuzz tests are generated temporarily by the `logicbox` script. They check invariants rather than exact stored models:

- no scope conflict when all scopes are identical
- `stage-chain-too-short` fires only below the requested minimum
- known context does not trigger `missing-context`
- stronger conclusions over weaker grounds are flagged
- modality and scope rewrite mutations are detected

## Implementation Notes

The current architecture intentionally separates roles:

- Shell orchestrates commands.
- Shen/SBCL derives structural flags and plan statuses.
- JavaScript handles JSON/file glue, patch application, report formatting, and some remaining text heuristics.
- AI interprets prose, proposes facts, explains Shen output, and asks human-facing questions.
- The human remains the authority on intended meaning.

The long-term direction is to keep migrating actual decision logic into Shen while leaving JavaScript as glue. In particular, protected-role inference, rewrite safety observations, and domain-specific heuristics should continue moving toward generic facts that Shen can inspect.

Preferred core rule set:

- extraction contract: facts must be decomposed enough for Shen to inspect
- claim/support structure: conclusions need grounds and must not outrun support
- scope/modality: unknown scope, invalid scope, scope conflict, and modality strengthening
- definitions and criteria: unknown terms and value conclusions need criteria
- missing context: explicit assumptions must be known or marked unknown
- objection/mitigation sufficiency: objections must be answered; mitigations need sufficiency status
- contradiction/tension: represented commitments such as `requires`, `denies`, `undermines`, and `conflicts-with-target`
- rewrite mutation/deletion safety: protected commitments must be preserved
- gap-fill recheck: user-supplied facts are allowed, then checked for contradiction
- plan status: clear, user-input, evidence, or reconciliation

Avoid rule creep. Domain-specific examples are useful as tests, but the reusable kernel should prefer generic predicates over noun-specific rules.

## Known Limitations

- Hidden conflicts inside `[definition X "..."]` strings are invisible unless extracted as structured facts.
- User-supplied facts can be accepted for provenance while still too unstructured for Shen to evaluate.
- Reconciliation can leave stale original facts unless the AI updates `ai-facts.shen` carefully.
- Value-term preflight can over-flag broad words like fairness, privacy, or necessity.
- Domain-specific contradictions are under-flagged unless the AI supplies explicit `requires`, `denies`, `undermines`, or `conflicts-with-target` facts.
- JavaScript text heuristics can both over-block and under-block rewrites.
- The biggest architectural risk is infinite rule creep: every new scenario tempts a new noun-specific rule.

## Troubleshooting

If `./logicbox review` shows only raw `[]` output, there may be no `[plan ...]` fact in the current model. Older fixtures without a plan can still produce ordinary flags, but only plans produce plan statuses.

If Shen reports a syntax error, inspect `work/ai-facts.shen` for mismatched brackets. Facts use Shen lists like `[claim c1 causal source target]`, not Lisp parentheses.

If a flag seems wrong, first check whether the AI encoded the prose correctly. The system checks the facts it was given; it does not read the draft directly.

If `[precomputed-flag ...]` appears, remove the derived flag from `work/ai-facts.shen`. The AI may submit helper facts, but Shen must derive final flags.

If a rewrite is rejected, check for unlabeled additions, invented numbers, invented thresholds, deleted protected claims, changed modality, changed scope, or placeholders that erased the main claim.

## Upload Checklist

Before uploading or sharing the folder:

1. Run `./logicbox review`.
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

Generated raw Shen logs are ignored by `.gitignore`; the useful outputs are:

```text
output/check-report.md
output/shen-output.txt
output/mutation-output.txt
output/rewrite-report.md
```

## Files

```text
.gitignore
logicbox
README.md
skill.md
work/
  draft.txt
  ai-facts.shen
  adapter-facts.shen
  rewrite-patch.json
  rewrite.md
  rewrite-facts.shen
shen/
  rules.shen
  run.shen
  run-preflight.shen
  run-mutation.shen
  run-rewrite-safety.shen
scripts/
  preflight-facts.js
  rewrite-safety.js
tests/
  gold/
  edge/
output/
  shen-output.txt
  check-report.md
  mutation-output.txt
  rewrite-report.md
```
