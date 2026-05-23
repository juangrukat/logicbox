# Advanced Fact Patterns

## Typed Extraction with Scope Fields

For policy arguments, use typed primitives. Scope fields now work correctly:

```shen
[term c1 claim]
[agent c1 organization]
[action c1 deploy]
[target c1 tool-name]
[location c1 department-name]
[population c1 group-name]
[timeframe c1 next-cycle]
[modality c1 deontic-recommendation]
[scope-status c1 conditional]
```

When all of `location`, `population`, `timeframe`, `scope-status` are present, Shen treats it as scoped — no `unclear-scope`. Modalities: `deontic-recommendation`, `deontic-requirement`, `predictive`, `possibility`, `feasibility`, `value-judgment`, `unknown-modality`.

## Staging

For broad causal claims, propose intermediate stages:
```shen
[claim c1 causal feedback improved-performance]
[stage-chain-min c1 3]
[stage s1 observe-results]
[stage-of s1 c1]
[stage-order s1 1]
[stage-next c1 s1 s2]
[stage-bridge s1 s2 causal-attribution]
```
Every `stage-next` needs a `stage-bridge`.

## Context Obligations

```shen
[context-required claim-id assumption-name]
[context-known assumption-name unknown]
```
`unknown` → `missing-context`. `known` → check passes.

## Adapter Facts

Per-run semantic bridges in `work/adapter-facts.shen`:
```shen
[adapter-fact a1]
[adapter-source a1 ai-semantic-bridge]
[adapter-scope a1 current-run]
[adapter-status a1 temporary]
[implies nightlystudylogs privatestudymonitoring]
```
Bridge types: `[requires C X]`, `[denies Y X]`, `[prohibits C X]`, `[implies Y X]`, `[conflicts Y X]`, `[undermines Y X]`. Reported separately in `check-report.md`.

## Value Conclusions

Normative conclusions (`fair`, `efficient`, `responsible`) trigger `value-criteria-needed`. Surface criteria in definitions or accept the flag. `value-criteria-grounded` = criteria in definitions. `value-criteria-stated` = explicit in prose.

## Necessity Claims

Necessity claims ("X is necessary," "cannot be solved any other way") trigger `overclaim necessity-counterfactual` when no alternatives are considered. Pattern:

Before (triggers overclaim):
```shen
[conclusion k3 necessary]
[modality k3 certain]
[necessity-ground k3 someproblem]
```

After (weakened, gap acknowledged):
```shen
[conclusion k3 necessary]
[modality k3 probable]
[ground-claim g11 problem evidence]
[infers-to g11 k3]
[necessity-ground k3 g11]
```
Remove absolute language from the definition. In prose rewrites, bracket the necessity gap: `[G1: specify alternatives considered or weaken 'necessary']`.
