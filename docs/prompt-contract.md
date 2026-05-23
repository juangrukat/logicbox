# LogicBox Prompt Contract

This prompt contract is generated from the schema registry in
`shen/fact-schema.shen`. Run `./logicbox schema-contract` for the full
machine-readable registry-derived contract. This document is the concise
human-curated form to paste into an LLM extraction prompt.

## Output Syntax

Emit Shen facts only:

```shen
[predicate arg1 arg2 ...]
```

Do not emit JSON. Do not emit derived report facts as source facts. Preserve
uncertainty with enum values such as `unknown`, `possible`, and `contested`
rather than guessing.

## Permanent Output Namespace

Permanent extraction output may use `core` predicates. Do not emit `adapter`
or `report` predicates into permanent facts unless the task explicitly asks for
temporary adapter facts or source-facing diagnostics.

Forbidden for permanent output:

- `adapter-*`
- `report-line`
- `fact-type-error`
- `fact-warning`
- `fact-suggestion`
- `fact-normalization`
- derived kernel flags such as `clear-enough`, `missing-context`, or
  `plan-status`

## Core Predicate Contracts

Common stable contracts:

```text
[term Symbol TermKind]
[current-schema SchemaVersionId]
[plan PlanId]
[plan PlanId PlanStatus]
[plan-claim PlanId ClaimId]
[plan-ground PlanId GroundId]
[plan-conclusion PlanId ClaimId]
[plan-fact PlanId AnyId]

[claim ClaimId RelationKind EntityId EntityId]
[modality AnyId Modality]
[scope AnyId Scope]
[context-known EntityId KnowledgeState]
[ground-claim GroundId EntityId EntityId]
[infers-to GroundId ClaimId]
[supports EntityId ClaimId]
[mechanism ClaimId EntityId]

[rewrite RewriteId ClaimId ClaimId]
[rewrite-claim RewriteId RelationKind EntityId EntityId]
[rewrite-status AnyId RewriteStatus]

[fact-source AnyId SourceId]
[fact-span AnyId ExternalRef]
[fact-run AnyId RunId]
[fact-extractor AnyId ExternalRef]
[fact-confidence AnyId IntegerAtom]
[fact-schema-version AnyId SchemaVersionId]
[fact-lifecycle AnyId LifecycleState]

[promote AdapterId Symbol CoreId]
[promotion-justification AdapterId CoreId ExternalRef]
```

## Adapter Predicate Contracts

Adapter facts are temporary and do not feed inference:

```text
[adapter-fact AdapterId]
[adapter-span AdapterId TextAtom]
[adapter-source AdapterId ExternalRef]
[adapter-scope AdapterId Symbol]
[adapter-status AdapterId AdapterStatus]
```

Promotion is explicit:

```shen
[term a1 adapter]
[adapter-span a1 "phrase from source"]
[adapter-status a1 staged]
[promote a1 claim c1]
[promotion-justification a1 c1 extractor-review]
```

## Report Predicate Contracts

Report facts are output only:

```text
[report-line ReportId Symbol Severity]
```

Do not use report IDs in core predicates such as `supports`, `mechanism`, or
`infers-to`.

## Enums

Use these controlled values:

```text
Modality: asserted, probable, possible, hypothetical, contested, certain, unknown
Scope: local, global, bounded, comparative, section, document, conditional, universal, unknown
PlanStatus: proposed, active, blocked, complete, abandoned
RewriteStatus: proposed, accepted, rejected, drifted, preserved, unresolved, marked-unresolved
AdapterStatus: ephemeral, staged, dropped, temporary
Severity: info, warning, error
KnowledgeState: known, unknown, mixed, shown, provided, present
LifecycleState: proposed, accepted, superseded, withdrawn
ProtectedRole: source, target, actor, mechanism, context, evidence, main-claim, core-condition, safeguard
```

## Valid Examples

```shen
[current-schema schema-v1]
[term p1 plan]
[term c1 claim]
[term g1 ground]
[plan p1]
[plan-claim p1 c1]
[claim c1 causal source target]
[modality c1 probable]
[scope c1 local]
[ground-claim g1 source target]
[infers-to g1 c1]
[fact-lifecycle c1 accepted]
```

```shen
[term a1 adapter]
[adapter-span a1 "because public spaces have become transactional"]
[adapter-status a1 staged]
[promote a1 claim c1]
[promotion-justification a1 c1 extractor-review]
```

## Invalid Examples

Wrong arity:

```shen
[ground-claim g1 source]
```

Bad enum:

```shen
[scope c1 maybe-globalish]
```

Wrong ID class:

```shen
[term p1 plan]
[mechanism p1 m1]
```

Unsupported predicate:

```shen
[mystical-link c1 c2]
```

Adapter leakage:

```shen
[term a1 adapter]
[supports a1 c1]
```

Report leakage:

```shen
[term rep1 report]
[supports rep1 c1]
```
