\\ LogicBox fact schema registry and helpers.
\\ Arity counts arguments after the predicate atom.

(define lb-snoc
  [] X -> [X]
  [Y | Ys] X -> [Y | (lb-snoc Ys X)])

(define lb-member?
  X [] -> false
  X [X | _] -> true
  X [_ | Rest] -> (lb-member? X Rest))

(define lb-length
  [] -> 0
  [_ | Rest] -> (+ 1 (lb-length Rest))
  _ -> 0)

(define lb-empty-string?
  "" -> true
  _ -> false)

(define lb-string-prefix?
  "" S -> true
  Prefix "" -> false
  Prefix S -> (if (= (hdstr Prefix) (hdstr S))
               (lb-string-prefix? (tlstr Prefix) (tlstr S))
               false))

(define lb-string-contains?
  Needle S -> (if (lb-string-prefix? Needle S)
               true
               (if (lb-empty-string? S)
                false
                (lb-string-contains? Needle (tlstr S)))))

(define lb-string-length
  "" -> 0
  S -> (+ 1 (lb-string-length (tlstr S))))

(define lb-atom-string
  X -> (str X))

(define id-class?
  claim-id -> true
  plan-id -> true
  ground-id -> true
  context-id -> true
  rewrite-id -> true
  adapter-id -> true
  report-id -> true
  evidence-id -> true
  entity-id -> true
  source-id -> true
  run-id -> true
  schema-version-id -> true
  any-id -> true
  core-id -> true
  _ -> false)

(define enum-type?
  relation-kind -> true
  modality -> true
  scope -> true
  scope-status-type -> true
  plan-status-type -> true
  rewrite-status-type -> true
  adapter-status-type -> true
  severity -> true
  knowledge-state -> true
  lifecycle-state -> true
  protected-role -> true
  term-kind -> true
  criteria-status-type -> true
  evidence-status-type -> true
  value-kind -> true
  patch-op-type -> true
  mutation-status-type -> true
  _ -> false)

(define enum-values
  relation-kind -> [assertion descriptive causal produces enables prevents practical-outperformance comparison value]
  modality -> [asserted probable possible hypothetical contested certain unknown descriptive recommendation requirement deontic-recommendation feasibility]
  scope -> [local global bounded comparative section document conditional universal unknown underspecified unbounded unclear]
  scope-status-type -> [known unknown underspecified unbounded unclear local global bounded comparative conditional universal]
  plan-status-type -> [proposed active blocked complete abandoned translation-error needs-user-input needs-evidence needs-reconciliation structurally-clear awaiting-value-confirmation ready-for-final-rewrite]
  rewrite-status-type -> [proposed accepted rejected drifted preserved unresolved marked-unresolved]
  adapter-status-type -> [ephemeral staged dropped temporary]
  severity -> [info warning error]
  knowledge-state -> [known unknown mixed shown provided present]
  lifecycle-state -> [proposed accepted superseded withdrawn]
  protected-role -> [source target actor mechanism context evidence main-claim main-recommendation core-condition scope-condition objection concession rebuttal safeguard mitigation exception equity-guardrail value-conclusion]
  term-kind -> [claim value-conclusion plan ground ground-claim context rewrite adapter adapter-fact report evidence entity source run schema-version known unknown reason objection mitigation safeguard exception analogy popularity-claim mechanism]
  criteria-status-type -> [specified defined shown stated grounded unknown unspecified]
  evidence-status-type -> [shown provided present unknown]
  value-kind -> [fair fairness safety necessity efficiency responsibility practicality environmental-impact feasibility equity-impact]
  patch-op-type -> [delete omit insert-placeholder replace preserve]
  mutation-status-type -> [accepted rejected]
  _ -> [])

(define enum-member?
  Type Value -> (lb-member? Value (enum-values Type)))

(define schema-known-version?
  schema-v1 -> true
  _ -> false)

(define schema-default-version
  -> schema-v1)

(define term-kind-id-class
  claim -> claim-id
  value-conclusion -> claim-id
  plan -> plan-id
  ground -> ground-id
  ground-claim -> ground-id
  context -> context-id
  rewrite -> rewrite-id
  adapter -> adapter-id
  adapter-fact -> adapter-id
  report -> report-id
  evidence -> evidence-id
  source -> source-id
  run -> run-id
  schema-version -> schema-version-id
  entity -> entity-id
  known -> entity-id
  unknown -> entity-id
  reason -> entity-id
  objection -> entity-id
  mitigation -> entity-id
  safeguard -> entity-id
  exception -> entity-id
  analogy -> entity-id
  popularity-claim -> entity-id
  mechanism -> entity-id
  _ -> entity-id)

(define fact-registry
  -> [
    [fact-spec term core schema-meta-fact 2 [symbol term-kind] true true false false false false]
    [fact-spec current-schema core schema-meta-fact 1 [schema-version-id] true false false false false false]
    [fact-spec schema-compatible core schema-meta-fact 2 [schema-version-id schema-version-id] true false false false false false]

    [fact-spec plan core plan-fact-family 1 [plan-id] true true false true false false]
    [fact-spec plan core plan-fact-family 2 [plan-id plan-status-type] true true false true false false]
    [fact-spec plan-source core plan-fact-family 2 [plan-id external-ref] true true false true false false]
    [fact-spec plan-goal core plan-fact-family 2 [plan-id symbol] true true false true false false]
    [fact-spec plan-check core plan-fact-family 2 [plan-id symbol] true true false true false false]
    [fact-spec plan-claim core plan-fact-family 2 [plan-id claim-id] true true false true false false]
    [fact-spec plan-conclusion core plan-fact-family 2 [plan-id claim-id] true true false true false false]
    [fact-spec plan-ground core plan-fact-family 2 [plan-id ground-id] true true false true false false]
    [fact-spec plan-context core plan-fact-family 2 [plan-id context-id] true true false true false false]
    [fact-spec plan-fact core plan-fact-family 2 [plan-id any-id] true true false true false false]

    [fact-spec claim core claim-fact 4 [claim-id relation-kind entity-id entity-id] true true false true true false]
    [fact-spec claim-content core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec conclusion core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec target core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec agent core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec action core claim-fact 2 [claim-id symbol] true true false true false false]
    [fact-spec modality core claim-fact 2 [any-id modality] true true false true false false]
    [fact-spec protected core claim-fact 2 [any-id protected-role] true true false true false false]

    [fact-spec ground-claim core ground-fact 3 [ground-id entity-id entity-id] true true false true true false]
    [fact-spec infers-to core ground-fact 2 [ground-id claim-id] true true false true false false]
    [fact-spec supports core ground-fact 2 [any-id claim-id] true true false true false false]
    [fact-spec reason-type core ground-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec reason-domain core ground-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec ground-uses-definition core ground-fact 2 [ground-id any-id] true true false true false false]

    [fact-spec scope core scope-fact 2 [any-id scope] true true false true false false]
    [fact-spec fact-scope core scope-fact 2 [any-id scope] true true false true false false]
    [fact-spec scope-status core scope-fact 2 [any-id scope-status-type] true true false true false false]
    [fact-spec scope-conflict-candidate core scope-fact 2 [any-id any-id] true true false false false false]
    [fact-spec scope-incompatible core scope-fact 2 [scope scope] true true false false false false]
    [fact-spec scope-transition core scope-fact 3 [any-id scope scope] true true false false false false]
    [fact-spec scope-transition-invalid core scope-fact 2 [scope scope] true true false false false false]
    [fact-spec location core scope-fact 2 [any-id entity-id] true true false true false false]
    [fact-spec setting core scope-fact 2 [any-id entity-id] true true false true false false]
    [fact-spec population core scope-fact 2 [any-id entity-id] true true false true false false]
    [fact-spec timeframe core scope-fact 2 [any-id entity-id] true true false true false false]

    [fact-spec context-known core context-fact 2 [entity-id knowledge-state] true true false true false false]
    [fact-spec context-required core context-fact 2 [claim-id context-id] true true false true false false]
    [fact-spec context-required-scope core context-fact 3 [claim-id context-id scope] true true false true false false]
    [fact-spec context-scope core context-fact 2 [context-id scope] true true false true false false]
    [fact-spec context-incompatible core context-fact 2 [context-id context-id] true true false false false false]

    [fact-spec rewrite core rewrite-fact 3 [rewrite-id claim-id claim-id] true true false true true false]
    [fact-spec rewrite-claim core rewrite-fact 4 [rewrite-id relation-kind entity-id entity-id] true true false true true false]
    [fact-spec rewrite-conclusion core rewrite-fact 2 [rewrite-id entity-id] true true false true false false]
    [fact-spec rewrite-modality core rewrite-fact 2 [rewrite-id modality] true true false true false false]
    [fact-spec rewrite-scope core rewrite-fact 2 [rewrite-id scope] true true false true false false]
    [fact-spec rewrite-status core rewrite-fact 2 [any-id rewrite-status-type] true true false true false false]
    [fact-spec rewrite-corresponds core rewrite-fact 2 [any-id any-id] true true false true false false]
    [fact-spec corresponds core rewrite-fact 2 [any-id any-id] true true false true false false]
    [fact-spec preserved core rewrite-fact 1 [any-id] true true false true false false]
    [fact-spec marked-unresolved core rewrite-fact 2 [any-id symbol] true true false true false false]

    [fact-spec adapter-fact adapter adapter-fact-family 1 [adapter-id] false false false false false false]
    [fact-spec adapter-span adapter adapter-fact-family 2 [adapter-id text-atom] false false false false false false]
    [fact-spec adapter-source adapter adapter-fact-family 2 [adapter-id external-ref] false false false false false false]
    [fact-spec adapter-scope adapter adapter-fact-family 2 [adapter-id symbol] false false false false false false]
    [fact-spec adapter-status adapter adapter-fact-family 2 [adapter-id adapter-status-type] false false false false false false]

    [fact-spec report-line report report-fact 3 [report-id symbol severity] false false true true false false]
    [fact-spec fact-type-error report report-fact 999 [symbol] false false true true false false]
    [fact-spec fact-warning report report-fact 999 [symbol] false false true true false false]
    [fact-spec fact-suggestion report report-fact 999 [symbol] false false true true false false]
    [fact-spec fact-normalization report report-fact 999 [symbol] false false true true false false]

    [fact-spec fact-source core provenance-fact 2 [any-id source-id] true false false true false true]
    [fact-spec fact-span core provenance-fact 2 [any-id external-ref] true false false true false true]
    [fact-spec fact-run core provenance-fact 2 [any-id run-id] true false false true false true]
    [fact-spec fact-extractor core provenance-fact 2 [any-id external-ref] true false false true false true]
    [fact-spec fact-confidence core provenance-fact 2 [any-id integer-atom] true false false true false true]
    [fact-spec fact-schema-version core provenance-fact 2 [any-id schema-version-id] true false false true false true]
    [fact-spec fact-lifecycle core lifecycle-fact 2 [any-id lifecycle-state] true false false true false true]
    [fact-spec promote core lifecycle-fact 3 [adapter-id symbol core-id] true false false true false true]
    [fact-spec promotion-justification core lifecycle-fact 3 [adapter-id core-id external-ref] true false false true false true]

    [fact-spec definition core claim-fact 2 [any-id text-atom] true true false true false false]
    [fact-spec source-text core provenance-fact 2 [any-id text-atom] true false false true false false]
    [fact-spec source-span core provenance-fact 4 [any-id external-ref integer-atom integer-atom] true false false true false false]
    [fact-spec comment core report-fact 2 [any-id text-atom] false false true true false false]
    [fact-spec translator-added core provenance-fact 2 [any-id symbol] true false false false false false]
    [fact-spec user-supplied core provenance-fact 2 [any-id symbol] true false false true false false]

    [fact-spec mechanism core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec outcome core claim-fact 2 [any-id entity-id] true true false true false false]
    [fact-spec risk core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec similar core claim-fact 2 [symbol symbol] true true false false false false]
    [fact-spec abstract core claim-fact 1 [entity-id] true true false false false false]
    [fact-spec not-equivalent core claim-fact 2 [symbol symbol] true true false false false false]
    [fact-spec stronger-than core claim-fact 2 [symbol symbol] true true false false false false]
    [fact-spec broader-than core claim-fact 2 [symbol symbol] true true false false false false]
    [fact-spec stronger-effect core claim-fact 2 [symbol symbol] true true false false false false]
    [fact-spec term-definition core claim-fact 2 [any-id entity-id] true true false true false false]
    [fact-spec local-definition-overrides core claim-fact 2 [any-id any-id] true true false false false false]

    [fact-spec stage core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec stage-of core claim-fact 2 [entity-id claim-id] true true false true false false]
    [fact-spec stage-order core claim-fact 2 [entity-id integer-atom] true true false true false false]
    [fact-spec stage-chain-min core claim-fact 2 [claim-id integer-atom] true true false true false false]
    [fact-spec stage-next core claim-fact 3 [claim-id entity-id entity-id] true true false true false false]
    [fact-spec stage-bridge core claim-fact 3 [entity-id entity-id symbol] true true false true false false]

    [fact-spec criteria-status core claim-fact 2 [any-id criteria-status-type] true true false true false false]
    [fact-spec value-type core claim-fact 2 [any-id value-kind] true true false true false false]
    [fact-spec value-definition core claim-fact 2 [value-kind any-id] true true false true false false]
    [fact-spec value-criteria-candidate core claim-fact 2 [any-id value-kind] true true false false false false]
    [fact-spec evidence-status core ground-fact 2 [any-id evidence-status-type] true true false true false false]
    [fact-spec evidence core ground-fact 2 [any-id evidence-status-type] true true false true false false]
    [fact-spec metric core ground-fact 2 [any-id symbol] true true false true false false]
    [fact-spec necessity-ground core ground-fact 2 [claim-id any-id] true true false true false false]

    [fact-spec source-condition core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec process core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec intermediate-effect core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec final-outcome core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec sufficiency core claim-fact 2 [entity-id knowledge-state] true true false true false false]
    [fact-spec sufficiency-status core claim-fact 2 [entity-id knowledge-state] true true false true false false]
    [fact-spec comparability core claim-fact 2 [entity-id knowledge-state] true true false true false false]
    [fact-spec boundary-status core claim-fact 2 [entity-id knowledge-state] true true false true false false]
    [fact-spec equivalence-status core claim-fact 2 [entity-id knowledge-state] true true false true false false]
    [fact-spec needs-equivalence-check core claim-fact 1 [entity-id] true true false true false false]
    [fact-spec mitigation-requires core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec mitigation-type core claim-fact 2 [entity-id symbol] true true false true false false]

    [fact-spec requires core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec prohibits core claim-fact 2 [any-id entity-id] true true false true false false]
    [fact-spec denies core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec implies core claim-fact 2 [entity-id entity-id] true true false false false false]
    [fact-spec conflicts core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec conflicts-with-target core claim-fact 2 [entity-id entity-id] true true false false false false]
    [fact-spec requires-equitable-treatment core claim-fact 1 [entity-id] true true false true false false]
    [fact-spec benefit core claim-fact 2 [claim-id entity-id] true true false true false false]
    [fact-spec safeguard core claim-fact 1 [entity-id] true true false true false false]
    [fact-spec identical-treatment core claim-fact 1 [entity-id] true true false true false false]
    [fact-spec policy-rule core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec policy-tool core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec group-rule core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec exception-rule core claim-fact 1 [entity-id] true true false true false false]
    [fact-spec exception-to core claim-fact 2 [entity-id claim-id] true true false true false false]
    [fact-spec exception-group core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec exempts core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec applies-to core claim-fact 2 [any-id any-id] true true false true false false]
    [fact-spec objects-to core claim-fact 2 [entity-id claim-id] true true false true false false]
    [fact-spec mitigates core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec rebuts core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec concedes core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec undermines core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec affected-group core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec impact-type core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec analogizes-from core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec analogizes-to core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec content core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec resource core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec property core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec entity core claim-fact 1 [entity-id] true true false true false false]
    [fact-spec entity core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec rule-type core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec direction core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec duration core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec availability-window core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec remote-days core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec required-office-days core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec required-location core claim-fact 2 [entity-id entity-id] true true false true false false]
    [fact-spec response-time core claim-fact 2 [entity-id symbol] true true false true false false]
    [fact-spec policy-condition core claim-fact 2 [any-id entity-id] true true false true false false]
    [fact-spec counterfactual core claim-fact 1 [entity-id] true true false true false false]
    [fact-spec counterfactual core claim-fact 2 [claim-id entity-id] true true false true false false]

    [fact-spec candidate-addition core rewrite-fact 2 [symbol any-id] true true false true false false]
    [fact-spec addition-source core rewrite-fact 2 [any-id symbol] true true false true false false]
    [fact-spec protected-sentence core rewrite-fact 1 [any-id] true true false true false false]
    [fact-spec patch-op core rewrite-fact 3 [any-id patch-op-type any-id] true true false true false false]
    [fact-spec patch-placeholder-only core rewrite-fact 1 [any-id] true true false true false false]
    [fact-spec mutation-status report report-fact 1 [mutation-status-type] false false true true false false]

    [fact-spec clear-enough report report-fact 1 [plan-id] false false true true false false]
    [fact-spec plan-incomplete report report-fact 1 [plan-id] false false true true false false]
    [fact-spec plan-status report report-fact 2 [plan-id plan-status-type] false false true true false false]
    [fact-spec missing-context report report-fact 2 [claim-id context-id] false false true true false false]
    [fact-spec compound-domain-atom core claim-fact 1 [entity-id] true true false false false false]
    [fact-spec decomposition-candidate core claim-fact 1 [entity-id] true true false false false false]
  ])

(define fact-spec-matches?
  P Arity [fact-spec P _ _ Arity _ _ _ _ _ _ _] -> true
  _ _ _ -> false)

(define fact-spec-predicate-matches?
  P [fact-spec P _ _ _ _ _ _ _ _ _ _] -> true
  _ _ -> false)

(define find-fact-spec
  P Arity -> (find-fact-spec-h P Arity (fact-registry)))

(define find-fact-spec-h
  P Arity [] -> []
  P Arity [Spec | Rest] -> (if (fact-spec-matches? P Arity Spec)
                             Spec
                             (find-fact-spec-h P Arity Rest)))

(define find-fact-spec-by-predicate
  P -> (find-fact-spec-by-predicate-h P (fact-registry)))

(define find-fact-spec-by-predicate-h
  P [] -> []
  P [Spec | Rest] -> (if (fact-spec-predicate-matches? P Spec)
                       Spec
                       (find-fact-spec-by-predicate-h P Rest)))

(define fact-spec-known-predicate?
  P -> (if (= (find-fact-spec-by-predicate P) []) false true))

(define fact-spec-namespace
  [fact-spec _ Namespace _ _ _ _ _ _ _ _ _] -> Namespace
  _ -> unknown)

(define fact-spec-family
  [fact-spec _ _ Family _ _ _ _ _ _ _ _] -> Family
  _ -> unknown-fact)

(define fact-spec-arity
  [fact-spec _ _ _ Arity _ _ _ _ _ _ _] -> Arity
  _ -> 0)

(define fact-spec-slots
  [fact-spec _ _ _ _ Slots _ _ _ _ _ _] -> Slots
  _ -> [])

(define fact-spec-persistent?
  [fact-spec _ _ _ _ _ Persistent _ _ _ _ _] -> Persistent
  _ -> false)

(define fact-spec-inferable?
  [fact-spec _ _ _ _ _ _ Inferable _ _ _ _] -> Inferable
  _ -> false)

(define fact-spec-report-only?
  [fact-spec _ _ _ _ _ _ _ ReportOnly _ _ _] -> ReportOnly
  _ -> false)

(define fact-spec-user-visible?
  [fact-spec _ _ _ _ _ _ _ _ UserVisible _ _] -> UserVisible
  _ -> false)

(define fact-spec-requires-provenance?
  [fact-spec _ _ _ _ _ _ _ _ _ RequiresProvenance _] -> RequiresProvenance
  _ -> false)

(define fact-spec-requires-declaration?
  [fact-spec _ _ _ _ _ _ _ _ _ _ RequiresDeclaration] -> RequiresDeclaration
  _ -> false)

(define core-namespace?
  core -> true
  _ -> false)

(define adapter-namespace?
  adapter -> true
  _ -> false)

(define report-namespace?
  report -> true
  _ -> false)

(define schema-slot-enums-h
  Pos [] -> []
  Pos [Type | Rest] -> (if (enum-type? Type)
                        [[slot Pos enum Type values (enum-values Type)]
                         | (schema-slot-enums-h (+ Pos 1) Rest)]
                        (schema-slot-enums-h (+ Pos 1) Rest)))

(define schema-slot-enums
  Slots -> (schema-slot-enums-h 1 Slots))

(define schema-prompt-contract-entry
  [fact-spec Predicate Namespace Family Arity Slots Persistent Inferable ReportOnly UserVisible RequiresProvenance RequiresDeclaration]
  -> [prompt-fact predicate Predicate namespace Namespace family Family arity Arity slots Slots enums (schema-slot-enums Slots) persistent Persistent inferable Inferable report-only ReportOnly user-visible UserVisible requires-provenance RequiresProvenance requires-declaration RequiresDeclaration])

(define schema-prompt-contract-h
  [] -> []
  [Spec | Rest] -> [(schema-prompt-contract-entry Spec) | (schema-prompt-contract-h Rest)])

(define schema-prompt-contract
  -> (schema-prompt-contract-h (fact-registry)))
