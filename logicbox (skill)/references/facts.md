# Fact Construction Rules

- [Plans](#plans)
- [Compound Atom Avoidance](#compound-atom-avoidance)
- [Claims and Ground-Claims](#claims-and-ground-claims)
- [Mechanisms](#mechanisms)
- [Objections, Mitigations, Rebuttals](#objections-mitigations-rebuttals)
- [Protected Claims](#protected-claims)
- [Advanced patterns](#advanced-patterns): typed extraction, staging, context, adapter facts, value conclusions → `references/facts-advanced.md`

## Plans

Every facts file needs a plan. Minimum shape:

```shen
[plan p1]
[plan-source p1 draft-1]
[plan-goal p1 clarify-argument]
[plan-fact p1 f-section-id]
[plan-context p1 assumption-name]
[plan-check p1 flag-type-to-watch]
[comment p1 "one-sentence summary of the argument"]
```

Include `plan-check` entries for expected flag types. Shen ignores `comment` when deriving flags.

## Compound Atom Avoidance

The preflight flags hyphenated atoms in compact positions (claim source/target, ground-claim source/target, mechanism, outcome). Use non-hyphenated concatenated names:

Bad (flagged as compound-domain-atom):
```shen
[claim c-g4 causal smartphone-ban improved-attention]
[mechanism c-g6 unavailability-by-policy]
```

Good:
```shen
[claim c-g4 causal phoneban goodfocus]
[mechanism c-g6 structural-break]
```

Even short pairs like `phone-ban` or `less-focus` get flagged. Use single-word concatenations: `phoneban`, `poorfocus`, `goodfocus`.

## Claims and Ground-Claims

Claims require exactly 5 elements. Ground-claims require exactly 4:

```shen
[claim c1 causal source-symbol target-symbol]
[ground-claim g1 source-symbol target-symbol]
```

A ground-claim missing its target argument will cause `claim-without-ground`. Exemptions (`[exempts e1 ...]`) are not ground-claims — Shen won't recognize them as supporting evidence. Create a proper ground-claim for what the exemption provides:

```shen
;; Wrong — exemption can't ground a conclusion:
[infers-to e1 k1]

;; Right — create a ground-claim:
[ground-claim g11 exemptions-exist protected-access]
[infers-to g11 k1]
```

## Mechanisms

Shen checks whether a mechanism label is similar to the claim's target. Use operational descriptions that explain *how*:

Bad (restates target): `[mechanism c1 automated-urgency-sorting]` when target is `reduces-waiting-times`.

Good: `[mechanism c1 parallel-case-processing]`

Working patterns: `checklist-matching`, `threshold-comparison`, `clerical-automation`, `clear-case-routing`, `task-switching-cost`, `removal-of-interruption-source`.

## Objections, Mitigations, Rebuttals

```shen
[term o1 objection]
[impact-type o1 risk-type]
[affected-group o1 group-name]
[risks o1 outcome]
[objects-to o1 claim-id]

[term m1 mitigation]
[mitigates m1 o1]
[sufficiency m1 shown]

[term m2 rebuttal]
[rebuts m2 o1]
[reason-type m2 empirical-counterargument]
[sufficiency m2 shown]
```

Add `[sufficiency M shown]` on adequate mitigations. Without it: `mitigation-needs-sufficiency-check`.

For detailed typed extraction, staging, context obligations, adapter facts, and value conclusions, see `references/facts-advanced.md`.

## Protected Claims

Mark every structural element that must survive rewrites:

```shen
[protected c1 main-claim]
[protected c2 core-condition]
[protected o1 objection]
[protected m1 rebuttal]
[protected k1 value-conclusion]
```

Protected roles: main-claim, core-condition, objection, concession, rebuttal, safeguard, mitigation, exception/equity-guardrail, value-conclusion. Deletion triggers Shen flags.
