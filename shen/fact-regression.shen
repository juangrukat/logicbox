\\ Regression fixtures for the schema gate.

(define schema-fixture-valid
  -> [
    [current-schema schema-v1]
    [term p1 plan]
    [term c1 claim]
    [term g1 ground]
    [term a1 adapter]
    [term rep1 report]
    [term run-2026-05-23 run]
    [term schema-v1 schema-version]
    [plan p1]
    [plan-claim p1 c1]
    [claim c1 causal source target]
    [modality c1 probable]
    [scope c1 local]
    [ground-claim g1 source target]
    [infers-to g1 c1]
    [adapter-span a1 "source words"]
    [adapter-status a1 staged]
    [report-line rep1 schema-gate warning]
    [fact-run c1 run-2026-05-23]
    [fact-schema-version c1 schema-v1]
    [fact-lifecycle c1 accepted]
    [promote a1 claim c1]
    [promotion-justification a1 c1 extractor-review]
  ])

(define schema-fixture-invalid
  -> [
    not-a-list
    [current-schema schema-v404]
    [term p1 plan]
    [term a1 adapter]
    [term rep1 report]
    [ground-claim g1 source]
    [scope c1 maybe-globalish]
    [mechanism p1 m1]
    [mystical-link c1 c2]
    [supports a1 c1]
    [supports rep1 c1]
    [fact-source orphan src-1]
    [fact-schema-version c1 schema-v0]
    [promote c1 claim c2]
    [claim c2 causal opaque-source target]
  ])

(define schema-fixture-warning
  -> [
    [term c1 claim]
    [term c2 claim]
    [claim c1 causal thing something]
    [rewrite r1 c1 c1]
    [scope c1 maybe-globalish]
    [modaliy c1 probable]
    [definition c1 "This is a deliberately long text atom used to prove that the schema warning layer can detect source fragments that are probably too long for compact predicate slots and should be reviewed for whether they belong in a source span or in the permanent fact language boundary instead."]
  ])

(define contains-diagnostic-kind?
  Kind [] -> false
  Kind [[fact-type-error _ Kind | _] | _] -> true
  Kind [[fact-warning _ Kind | _] | _] -> true
  Kind [[fact-suggestion _ Kind | _] | _] -> true
  Kind [[fact-normalization _ Kind | _] | _] -> true
  Kind [_ | Rest] -> (contains-diagnostic-kind? Kind Rest))

(define schema-regression-results
  -> [
    [valid-fixture-has-no-errors (= (schema-type-errors (schema-fixture-valid)) [])]
    [valid-fixture-keeps-core-claim (lb-member? [claim c1 causal source target] (schema-accepted-core-facts (schema-fixture-valid)))]
    [valid-fixture-drops-adapter (if (lb-member? [adapter-span a1 "source words"] (schema-accepted-core-facts (schema-fixture-valid))) false true)]
    [invalid-catches-arity (contains-diagnostic-kind? arity (schema-type-errors (schema-fixture-invalid)))]
    [invalid-catches-enum (contains-diagnostic-kind? enum (schema-type-errors (schema-fixture-invalid)))]
    [invalid-catches-id-class (contains-diagnostic-kind? id-class (schema-type-errors (schema-fixture-invalid)))]
    [invalid-catches-unknown-predicate (contains-diagnostic-kind? unknown-predicate (schema-type-errors (schema-fixture-invalid)))]
    [invalid-catches-malformed (contains-diagnostic-kind? shape (schema-type-errors (schema-fixture-invalid)))]
    [invalid-catches-schema-version (contains-diagnostic-kind? schema-version (schema-type-errors (schema-fixture-invalid)))]
    [invalid-catches-undeclared (contains-diagnostic-kind? undeclared-id (schema-type-errors (schema-fixture-invalid)))]
    [warning-catches-generic (contains-diagnostic-kind? suspicious-atom (schema-warnings (schema-fixture-warning)))]
    [warning-catches-identity-rewrite (contains-diagnostic-kind? rewrite-identity (schema-warnings (schema-fixture-warning)))]
    [suggests-enum (contains-diagnostic-kind? enum-near-miss (schema-suggestions (schema-fixture-warning)))]
    [normalizes-predicate (contains-diagnostic-kind? predicate-alias (schema-normalizations (schema-fixture-warning)))]
  ])
