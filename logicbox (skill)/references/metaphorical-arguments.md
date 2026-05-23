# Modeling Non-Propositional Prose

## When to Model at Meta-Level

When prose is *performative* rather than *propositional* — it demonstrates an argumentative style rather than asserting discrete claims — model the argumentative patterns as mechanisms, not the surface claims as assertions.

**Triggers:**
- Absurdist dialogues (speaker makes intentionally illogical moves)
- Metaphorical arguments (road = freedom, enclosure = constraint)
- Poems used as implicit reasoning
- Prose where the form IS the argument (recursive, self-referential)

**Counter-indicators (model at claim-level instead):**
- Policy recommendations with stated grounds
- Explicit premise-conclusion chains
- Prose the author intends as literal reasoning

## Claim-Level vs Meta-Level Translation

| Mode | What facts assert | Shen validates | Example |
|---|---|---|---|
| Claim-level | The prose's claims are true/good/valid | Structural soundness of the argument | "[claim c1 causal phoneban goodfocus]" |
| Meta-level | The prose performs certain argumentative patterns | Structural soundness of the pattern-description | "[mechanism c1 counterevidenceabsorbs]" |

A meta-level translation can return zero flags from a structurally unsound prose argument — because Shen checked the model of the *patterns*, not the *claims*.

## The Prose-Facts Correspondence Gap

Shen has no `prose-fact-correspondence` check. If you misrepresent what the prose does, Shen won't catch it. The review output's source frames are the user's only window into translation fidelity.

**After every review, explicitly state:**
1. Whether the translation is claim-level or meta-level
2. What Shen validated (structural model) and what it didn't (prose correspondence)
3. Which illogical moves in the prose are *described* by the model vs *endorsed* by it

## Concrete Examples

### Example: "Counterevidence Absorption" (from dialogue analysis)

**Prose:** "When I asked about surprise sunshine, he said forecasts fail on purpose occasionally so the atmosphere can maintain credibility."

**Wrong (claim-level — misrepresents the prose):**
```shen
[claim c1 causal forecastfailure credibilitymaintenance]
```
This treats the absurdist claim as a genuine causal claim. Shen would flag structural issues with the ground, but the real problem — that the prose isn't making this claim seriously — is invisible.

**Right (meta-level — describes what the prose does):**
```shen
[mechanism c1 counterevidenceabsorbs]
[definition counterevidenceabsorbs "Any counterexample is reframed as supporting evidence. Surprise sunshine → deliberate credibility-maintenance."]
```
This names the argumentative *move*. Shen validates that the mechanism is coherently described and linked to the main claim. The absurdity of the move is preserved, not sanitized.

### Example: "Domestic Universal Scaling" (from dialogue analysis)

**Prose:** "The toast burned. He took this as final proof that attention is a finite natural resource and should therefore be taxed."

**Wrong (claim-level — misrepresents the prose as literal):**
```shen
[claim c1 causal burnttoast attentiontax]
```
Shen would flag `claim-without-ground` because burnt toast doesn't ground tax policy. But this also misrepresents the prose: the speaker isn't making a policy argument, they're performing a pattern.

**Wrong (gap-naming — hides the gap behind a label):**
```shen
[ground-claim g6 burnttoast attentiontax]
[mechanism c1 domesticuniversalscale]
[definition domesticuniversalscale "Domestic accident → universal principle → policy prescription."]
```
The mechanism names the gap without bridging it. The firewall catches this: `burnttoast` and `attentiontax` never appear together in any mechanism definition. The ground-claim is disconnected. A mechanism must explain *how*, not just label *what*.

**Right (expose the gap, log the move in comments):**
```shen
[comment p1 "unbridgeable-move: burnttoast -> attentiontax via domestic-to-universal scaling"]
;; No ground-claim written — the move has no logical bridge.
;; If the argument needs this move, it needs a mechanism that actually
;; connects the symbols, or the gap stands as a diagnostic.
```
When a move in the prose has no logical bridge, do not invent one. Do not name the gap as a mechanism. Document it in a comment and let the structural gap remain visible. The firewall will catch any ground-claim whose source and target are not connected through a mechanism definition.

## Surface-Level Risks

- **Reader confusion:** The user sees "zero flags" and assumes Shen endorsed the prose. Always disambiguate.
- **Lost absurdity:** Claim-level modeling forces absurdist prose into straight lines, destroying what makes it interesting. Meta-level preserves the shape.
- **Over-modeling:** Not every metaphor needs a fact. If the prose has no argumentative structure to extract, say so rather than inventing one.
- **Gap-naming as mechanism:** A mechanism whose definition only describes the gap without connecting the ground-claim's source and target symbols is a disguised gap. The firewall catches this deterministically. Do not write mechanisms that are just gap labels.

## When the Prose Has No Argument Structure

Some prose uses argumentative surface features (premise markers, "therefore," "this is why," objections) without any logical connective tissue. Example:

> "Rain proves triangles are seasonal because umbrellas open upward. Therefore the staircase could not legally remember the violin. This is why mirrors avoid sleeping horses."

This prose is not making an argument — it is performing the shell of one.

**Correct response:**
1. Write the draft to `work/draft.txt`.
2. Write `work/ai-facts.shen` with the claims as the prose literally asserts them.
3. Write ground-claims with their literal sources and targets.
4. Write zero mechanisms (none exist — do not invent them).
5. Run the gap firewall. Expect all ground-claims to be flagged as disconnected.
6. Present the firewall failures as the diagnostic result: "This prose has no coherent argument structure. The firewall correctly identified all ground-claims as disconnected because no logical bridges exist."
7. Do NOT attempt to fix disconnected ground-claims by writing gap-naming mechanisms.
8. Do NOT run Shen — the firewall has already produced the correct diagnostic.

**Why not run Shen?** Shen will report zero blocking issues if the ground-claims have correct format, definitions, and infers-to links — even though no source connects to any target. The firewall catches what Shen structurally cannot. Presenting a clean Shen review on prose with no argument structure is misleading.
