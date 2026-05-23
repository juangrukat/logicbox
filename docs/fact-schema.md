# LogicBox Fact Schema

LogicBox facts remain Shen lists. The schema gate adds a typed boundary around
that syntax before the semantic kernel sees it.

```shen
[claim c1 causal source target]
[modality c1 probable]
[context-known x unknown]
```

The gate does not decide whether the source was interpreted correctly. It only
checks that emitted facts are well shaped, typed, namespaced, versioned, and
auditable enough for the existing rules to consume.

## Pipeline

```text
raw facts
-> normalization pass
-> schema gate / typechecker
-> accepted normalized core facts
-> existing Shen semantic kernel
-> report facts and source-facing diagnostics
```

If hard schema errors exist, the kernel is not run for that input. This keeps
malformed, report-only, or adapter-only facts from satisfying core inference
rules by accident.

## Namespaces

Every predicate belongs to one namespace:

- `core`: permanent semantic facts that may be consumed by inference.
- `adapter`: temporary extraction or translation facts for the current run.
- `report`: diagnostics and presentation facts only.

Adapter facts do not satisfy core rules. Report facts are never consumed by
inference. Moving an adapter fact into the core language requires an explicit
promotion fact.

```shen
[promote adapter-f42 claim c7]
[promotion-justification adapter-f42 c7 extractor-review]
```

The source must be an `AdapterId`; the target must be a non-adapter, non-report
core ID appropriate for the destination.

## Registry Format

Predicate definitions live in `shen/fact-schema.shen` as data:

```shen
[fact-spec predicate namespace family arity slots
  persistent inferable report-only user-visible
  requires-provenance requires-declaration]
```

`arity` counts arguments after the predicate atom. Slot entries are type names
such as `ClaimId`, `EntityId`, `Modality`, or `TextAtom`. Enum constraints are
attached by slot type, so changing an enum updates validation and prompt
documentation together.

## Type Universe

ID classes:

- `ClaimId`
- `PlanId`
- `GroundId`
- `ContextId`
- `RewriteId`
- `AdapterId`
- `ReportId`
- `EvidenceId`
- `EntityId`
- `SourceId`
- `RunId`
- `SchemaVersionId`

Atom classes:

- `Symbol`
- `TextAtom`
- `EnumAtom`
- `BoolAtom`
- `IntegerAtom`
- `TimestampAtom`
- `ExternalRef`

Declarations seed the ID environment:

```shen
[term c1 claim]
[term p1 plan]
[term g1 ground]
[term r1 rewrite]
[term run-2026-05-23 run]
[term schema-v1 schema-version]
```

Some IDs can also be safely inferred from structural facts such as `[claim c1
...]`, `[plan p1]`, `[ground-claim g1 ...]`, and `[rewrite r1 ...]`.

## Controlled Enums

The schema defines these controlled vocabularies at minimum:

- `Modality`: `asserted`, `probable`, `possible`, `hypothetical`, `contested`
- `Scope`: `local`, `global`, `bounded`, `comparative`
- `PlanStatus`: `proposed`, `active`, `blocked`, `complete`, `abandoned`
- `RewriteStatus`: `proposed`, `accepted`, `rejected`, `drifted`
- `AdapterStatus`: `ephemeral`, `staged`, `dropped`
- `Severity`: `info`, `warning`, `error`
- `KnowledgeState`: `known`, `unknown`, `mixed`
- `LifecycleState`: `proposed`, `accepted`, `superseded`, `withdrawn`
- `ProtectedRole`: `source`, `target`, `actor`, `mechanism`, `context`, `evidence`

LogicBox also registers legacy values already used by the current kernel, such
as `certain`, `conditional`, `document`, `temporary`, and rewrite preservation
states. They are still enum values, not free text.

## Normalization

Normalization runs before typechecking and is visible in diagnostics.

It may:

- canonicalize known predicate aliases, such as `modaliy` to `modality`.
- lowercase known enum spellings, such as `Probable` to `probable`.
- canonicalize simple booleans, such as `yes` to `true`.

It does not invent facts or rewrite semantic content. Every normalization emits
a record like:

```shen
[fact-normalization n-enum-case predicate modality slot 2 original Probable normalized probable]
```

Long natural-language content should be quoted as a Shen string and validated as
`TextAtom`. Compact opaque atoms at entity boundaries are flagged so the
extractor can split them into inspectable facts.

## Provenance

Accepted facts are auditable through the schema gate. The stable provenance
predicates are:

```shen
[fact-source c1 src-12]
[fact-span c1 span-44]
[fact-run c1 run-2026-05-23]
[fact-extractor c1 llm-extractor-v3]
[fact-confidence c1 82]
[fact-schema-version c1 schema-v1]
```

If explicit provenance is absent, the gate can still produce accepted-fact audit
records linked to the current run and schema version. Missing explicit
provenance can be tightened later per predicate through the `requires-provenance`
capability flag.

## Lifecycle

Lifecycle facts preserve audit history:

```shen
[fact-lifecycle c1 proposed]
[fact-lifecycle c1 accepted]
[fact-lifecycle c1 superseded]
[fact-lifecycle c1 withdrawn]
```

Superseded or withdrawn facts are not deleted. They remain available to source
review and history.

## Schema Versioning

Every run targets a named schema version. If no explicit fact is present, the
gate targets `schema-v1`.

```shen
[current-schema schema-v1]
[fact-schema-version c1 schema-v1]
```

The gate emits a hard type error for unknown schema versions and incompatible
per-fact schema version references.

## Diagnostics

Diagnostics are Shen facts:

```shen
[fact-type-error e-arity arity predicate ground-claim expected 3 got 2 fact [ground-claim g1 source]]
[fact-type-error e-enum enum predicate scope slot 2 expected [local global bounded comparative] got maybe-globalish]
[fact-type-error e-id-class id-class predicate mechanism slot 1 expected ClaimId got PlanId atom p1]
[fact-type-error e-unknown-predicate unknown-predicate predicate mystical-link fact [mystical-link c1 c2]]
[fact-warning w-suspicious suspicious-atom predicate claim atom thing reason generic-placeholder]
[fact-warning w-rewrite-identity rewrite-identity predicate rewrite source c1 target c1]
[fact-suggestion s-enum-near-miss enum-near-miss predicate scope got maybe-globalish suggest global]
```

Errors block the semantic kernel. Warnings and suggestions do not.

## Valid Examples

```shen
[current-schema schema-v1]
[term c1 claim]
[term g1 ground]
[term p1 plan]
[claim c1 causal source target]
[modality c1 probable]
[scope c1 local]
[ground-claim g1 source target]
[infers-to g1 c1]
[plan p1]
[plan-claim p1 c1]
[fact-run c1 run-2026-05-23]
[fact-schema-version c1 schema-v1]
[fact-lifecycle c1 accepted]
```

Adapter facts stay outside inference:

```shen
[term a1 adapter]
[adapter-span a1 "source words from the extractor"]
[adapter-status a1 staged]
[promote a1 claim c1]
[promotion-justification a1 c1 extractor-review]
```

Report facts are presentation-only:

```shen
[term rep1 report]
[report-line rep1 schema-gate warning]
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

Unknown predicate:

```shen
[mystical-link c1 c2]
```

Report fact consumed by inference:

```shen
[term rep1 report]
[supports rep1 c1]
```

Adapter leakage:

```shen
[term a1 adapter]
[supports a1 c1]
```

Invalid schema version:

```shen
[current-schema schema-v404]
```
