# Session-Derived Pitfall Patterns

## Compound Atom Avoidance
**Trigger:** Hyphenated atoms in claim source/target, ground-claim source/target, mechanism, or outcome positions.  
**Fix:** Use non-hyphenated concatenated names. `phoneban` not `phone-ban`, `poorfocus` not `poor-focus`.

## Mechanism Restatement
**Trigger:** Mechanism label too similar to claim's source or target. `[similar reduces-waiting-times automated-urgency-sorting]`.  
**Fix:** Use operational descriptions that explain *how*: `parallel-case-processing`, `clerical-automation`, not synonyms.

## Ground-Claim Format Error
**Trigger:** `[ground-claim g7 patients-told-when-ai-used]` — only 3 elements, missing target.  
**Fix:** Exactly 4 elements: `[ground-claim g8 appeal-mechanism provides-error-remedy]`.

## claim-without-ground from Exemption Links
**Trigger:** `[infers-to e1 k1]` where `e1` is `[exempts e1 ...]`, not a ground-claim.  
**Fix:** Create a proper ground-claim: `[ground-claim g11 exemptions-exist protected-access]` → `[infers-to g11 k1]`.

## Stale rewrite-facts.shen
**Trigger:** `./logicbox mutation` returns `[]` but rewrite dropped sentences.  
**Fix:** Always write fresh `rewrite-facts.shen` before running mutation. Old facts from a different draft produce meaningless output.

## rewrite_with_user_facts: `resolved` Not `user_fact`
**Trigger:** `rewrite-preflight` blocks all scope changes as "no user source" despite filled gaps.  
**Fix:** `rewrite-safety.js` reads `gap.resolved`, never `gap.user_fact`. Use `"resolved": "..."` in gap objects.

## rewrite_with_user_facts: Rephrase Must Match `resolved` Text
**Trigger:** `findUserSource` does canonical substring matching. Paraphrased rephrase text doesn't match.  
**Fix:** Embed the exact `resolved` text verbatim in the rephrase operation.

## rewrite_with_user_facts: Preserve Conditional Language
**Trigger:** Rephrased s1 drops "but only if X and Y" → `deleted-condition`.  
**Fix:** Keep conditional structure in rephrased text even while incorporating user definitions.

## Protected Role Coverage in rewrite-facts.shen
**Trigger:** `./logicbox mutation` returns `[deleted-condition c1a]` but the rewrite preserved s1.  
**Fix:** Every `[protected X role]` in `ai-facts.shen` needs a corresponding `[rewrite-status X preserved]` and `[corresponds X rw-X]` in `rewrite-facts.shen`.

## mark-unresolved vs Sentence Deletion
**Trigger:** `mark-unresolved` replaced a protected sentence with `[undefined: ...]`.  
**Fix:** Preserve the original sentence text verbatim. Append `[Unresolved: G1 ...]` externally. Use `mark-unresolved` (not `rephrase`) when the sentence contains scope conditions.

## Post-Resolution: ai-facts.shen Must Be Updated
**Trigger:** Pipeline re-check shows zero delta even though user provided tension-creating facts.  
**Fix:** The pipeline re-checks against OLD `ai-facts.shen`. After pipeline runs, manually update `ai-facts.shen` with resolved terms, definitions, provenance, and tension facts. Rerun `./logicbox check`.

## Shen `;;` Comments in Facts Form
**Trigger:** `./logicbox preflight` crashes with `SIMPLE-ERROR: read error here` at a `;;` comment inside `(set *facts* ...)`.  
**Fix:** Strip all `;;` from inside the facts form. Use `[comment p1 "..."]` facts for annotations.

## stage-next Without stage-bridge
**Trigger:** `[missing-stage-bridge c2 s1 s2]` for every adjacent stage pair.  
**Fix:** Every `[stage-next C S1 S2]` needs a matching `[stage-bridge S1 S2 label]`. Use gerund labels: `enrollmentenableschoice`.

## resolve-gap Requires Exactly One Gap
**Trigger:** `rewrite-preflight` rejects `resolve-gap` with multiple gaps: "must reference exactly one gap."  
**Fix:** Use `rephrase` with `USER_SUPPLIED` provenance for multi-gap resolutions.

## needs-reconciliation Priority
**Trigger:** User-supplied facts create tensions but status shows `needs-user-input`.  
**Fix:** When adapter facts like `[undermines X Y]` are present, Shen should derive `needs-reconciliation`. Do not collapse into `needs-user-input`. Mutation pass does not imply argument pass.

## Necessity Overclaim Weakening
**Trigger:** Shen derives `[overclaim necessity-counterfactual K G]` when a conclusion claims something is "necessary" or "cannot be addressed any other way" without considering alternatives.  
**Fix:** Lower modality from `certain` to `probable`, remove absolute language ("cannot be addressed any other way") from the definition, and bracket the necessity gap: `[G1: specify alternatives considered or weaken 'necessary']`. In the prose rewrite, frame as "a structured, scalable intervention" rather than "the only possible solution." In `ai-facts.shen`, add a proper `[ground-claim G source target]` for the necessity reasoning and avoid linking necessity to ungrounded terms.

## Decomposition-Candidate on Concatenated Atoms
**Trigger:** An atom like `overrideok` or `studentoverride` is flagged as `decomposition-candidate` despite having no hyphens. The preflight tokenizer treats some concatenated words as "packed" ideas.  
**Fix:** Try a different single-word alternative: `overrideok` → `modifyfree`. No hyphen, no compound. Keep names under 30 chars and prefer gerunds or abstract nouns: `planmodification`, `optoutallowed`.

## infers-to From Non-Ground-Claim Entities
**Trigger:** `[infers-to s4 k1]` where s4 is a safeguard, restriction, or equity-guardrail — not a ground-claim. Shen won't recognize it as supporting evidence.  
**Fix:** Create a proper `[ground-claim G ...]` that captures what the safeguard achieves, then link: `[infers-to G k1]`. This applies to safeguards, restrictions, exemptions, and equity-guardrails — none are valid `infers-to` targets.

## scope-missing on plan-fact Entries
**Trigger:** Every `[plan-fact p1 f-...]` entry produces `[scope-missing f-...]` if no corresponding `[fact-scope f-... local]` exists.  
**Fix:** Add `[fact-scope f-... local]` for every plan-fact entry immediately after the plan block.
