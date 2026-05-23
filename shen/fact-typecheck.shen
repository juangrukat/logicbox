\\ Registry-driven schema gate for LogicBox facts.

(define env-class
  Atom [] -> unknown
  Atom [[id-class Atom Class] | _] -> Class
  Atom [_ | Rest] -> (env-class Atom Rest))

(define env-has?
  Atom Env -> (if (= (env-class Atom Env) unknown) false true))

(define env-add
  Atom Class Env -> (if (= Class unknown)
                     Env
                     (if (env-has? Atom Env)
                      Env
                      [[id-class Atom Class] | Env])))

(define seed-id-env-h
  [] Env -> Env
  [[term Id Kind] | Rest] Env -> (seed-id-env-h Rest (env-add Id (term-kind-id-class Kind) Env))
  [[current-schema Version] | Rest] Env -> (seed-id-env-h Rest (env-add Version schema-version-id Env))
  [[plan Id] | Rest] Env -> (seed-id-env-h Rest (env-add Id plan-id Env))
  [[plan Id _] | Rest] Env -> (seed-id-env-h Rest (env-add Id plan-id Env))
  [[claim Id _ _ _] | Rest] Env -> (seed-id-env-h Rest (env-add Id claim-id Env))
  [[conclusion Id _] | Rest] Env -> (seed-id-env-h Rest (env-add Id claim-id Env))
  [[ground-claim Id _ _] | Rest] Env -> (seed-id-env-h Rest (env-add Id ground-id Env))
  [[rewrite Id _ _] | Rest] Env -> (seed-id-env-h Rest (env-add Id rewrite-id Env))
  [[rewrite-claim Id _ _ _] | Rest] Env -> (seed-id-env-h Rest (env-add Id rewrite-id Env))
  [[adapter-fact Id] | Rest] Env -> (seed-id-env-h Rest (env-add Id adapter-id Env))
  [[adapter-span Id _] | Rest] Env -> (seed-id-env-h Rest (env-add Id adapter-id Env))
  [[report-line Id _ _] | Rest] Env -> (seed-id-env-h Rest (env-add Id report-id Env))
  [[fact-run _ Run] | Rest] Env -> (seed-id-env-h Rest (env-add Run run-id Env))
  [[fact-source _ Source] | Rest] Env -> (seed-id-env-h Rest (env-add Source source-id Env))
  [[fact-schema-version _ Version] | Rest] Env -> (seed-id-env-h Rest (env-add Version schema-version-id Env))
  [_ | Rest] Env -> (seed-id-env-h Rest Env))

(define seed-id-env
  Facts -> (seed-id-env-h Facts []))

(define id-compatible?
  any-id Actual -> true
  core-id adapter-id -> false
  core-id report-id -> false
  core-id unknown -> true
  core-id _ -> true
  Expected unknown -> true
  Expected Expected -> true
  _ _ -> false)

(define atom-class-valid?
  symbol X -> (if (cons? X) false (if (string? X) false true))
  text-atom X -> (string? X)
  bool-atom true -> true
  bool-atom false -> true
  bool-atom _ -> false
  integer-atom X -> (integer? X)
  timestamp-atom X -> (if (string? X) true (if (cons? X) false true))
  external-ref X -> (if (cons? X) false true)
  _ X -> true)

(define type-compatible?
  Type Atom Env -> (if (id-class? Type)
                    (id-compatible? Type (env-class Atom Env))
                    (if (enum-type? Type)
                     (enum-member? Type Atom)
                     (atom-class-valid? Type Atom))))

(define type-error-kind
  Type Atom Env -> (if (id-class? Type)
                    id-class
                    (if (enum-type? Type)
                     enum
                     atom-class)))

(define expected-values-for
  Type -> (if (enum-type? Type) (enum-values Type) Type))

(define slot-type-errors-h
  Pred Pos [] [] Env -> []
  Pred Pos [Type | Types] [Arg | Args] Env -> (if (type-compatible? Type Arg Env)
                                                (slot-type-errors-h Pred (+ Pos 1) Types Args Env)
                                                (let Kind (type-error-kind Type Arg Env)
                                                (let Got (if (id-class? Type) (env-class Arg Env) Arg)
                                                [[fact-type-error e-slot Kind predicate Pred slot Pos expected (expected-values-for Type) got Got atom Arg]
                                                 | (slot-type-errors-h Pred (+ Pos 1) Types Args Env)])))
  Pred Pos _ _ Env -> [])

(define slot-type-errors
  Pred Args Spec Env -> (slot-type-errors-h Pred 1 (fact-spec-slots Spec) Args Env))

(define predicate-arity-error
  Pred Args Spec Fact -> [fact-type-error e-arity arity predicate Pred expected (fact-spec-arity Spec) got (lb-length Args) fact Fact])

(define unknown-predicate-error
  Pred Fact -> [fact-type-error e-unknown-predicate unknown-predicate predicate Pred fact Fact])

(define malformed-fact-error
  Fact -> [fact-type-error e-shape shape expected shen-list fact Fact])

(define schema-version-errors-h
  [] Target -> []
  [[current-schema Version] | Rest] Target -> (if (schema-known-version? Version)
                                               (schema-version-errors-h Rest Version)
                                               [[fact-type-error e-schema-version schema-version unknown Version fact [current-schema Version]]
                                                | (schema-version-errors-h Rest Target)])
  [[fact-schema-version Subject Version] | Rest] Target -> (if (schema-known-version? Version)
                                                            (if (= Version Target)
                                                             (schema-version-errors-h Rest Target)
                                                             [[fact-type-error e-schema-version schema-version incompatible fact Subject expected Target got Version]
                                                              | (schema-version-errors-h Rest Target)])
                                                            [[fact-type-error e-schema-version schema-version unknown Version fact [fact-schema-version Subject Version]]
                                                             | (schema-version-errors-h Rest Target)])
  [_ | Rest] Target -> (schema-version-errors-h Rest Target))

(define schema-version-errors
  Facts -> (schema-version-errors-h Facts (current-schema-version Facts)))

(define declaration-required-errors-h
  Pred Pos [] [] Env -> []
  Pred Pos [Type | Types] [Arg | Args] Env -> (if (id-class? Type)
                                                (if (env-has? Arg Env)
                                                 (declaration-required-errors-h Pred (+ Pos 1) Types Args Env)
                                                 [[fact-type-error e-undeclared-id undeclared-id predicate Pred slot Pos expected Type atom Arg]
                                                  | (declaration-required-errors-h Pred (+ Pos 1) Types Args Env)])
                                                (declaration-required-errors-h Pred (+ Pos 1) Types Args Env))
  Pred Pos _ _ Env -> [])

(define declaration-required-errors
  Pred Args Spec Env -> (if (fact-spec-requires-declaration? Spec)
                         (declaration-required-errors-h Pred 1 (fact-spec-slots Spec) Args Env)
                         []))

(define namespace-policy-errors
  report-line Args Spec Env Fact -> []
  fact-type-error Args Spec Env Fact -> []
  fact-warning Args Spec Env Fact -> []
  fact-suggestion Args Spec Env Fact -> []
  fact-normalization Args Spec Env Fact -> []
  mutation-status Args Spec Env Fact -> []
  Pred Args Spec Env Fact -> (if (report-namespace? (fact-spec-namespace Spec))
                              [[fact-type-error e-report-only report-only predicate Pred namespace report fact Fact]]
                              []))

(define validate-fact-errors
  [Pred | Args] Env -> (let Spec (find-fact-spec Pred (lb-length Args))
                       (if (= Spec [])
                        (let AnySpec (find-fact-spec-by-predicate Pred)
                        (if (= AnySpec [])
                         [(unknown-predicate-error Pred [Pred | Args])]
                         [(predicate-arity-error Pred Args AnySpec [Pred | Args])]))
                        (append (slot-type-errors Pred Args Spec Env)
                         (append (declaration-required-errors Pred Args Spec Env)
                                 (namespace-policy-errors Pred Args Spec Env [Pred | Args])))))
  Fact Env -> [(malformed-fact-error Fact)])

(define validate-facts-errors-h
  [] Env -> []
  [Fact | Rest] Env -> (append (validate-fact-errors Fact Env)
                       (validate-facts-errors-h Rest Env)))

(define schema-type-errors-on
  Facts -> (let Norm (normalize-facts Facts)
           (let NormFacts (normalization-result-facts Norm)
           (let Env (seed-id-env NormFacts)
           (append (schema-version-errors NormFacts)
                   (validate-facts-errors-h NormFacts Env))))))

(define schema-type-errors
  Facts -> (schema-type-errors-on Facts))

(define generic-placeholder?
  thing -> true
  stuff -> true
  something -> true
  anything -> true
  everything -> true
  object -> true
  entity -> true
  _ -> false)

(define opaque-atom?
  Atom -> (let S (lb-atom-string Atom)
          (if (lb-string-prefix? "opaque-" S)
           true
           (if (lb-string-contains? "superlongopaque" S)
            true
            false))))

(define compact-atom?
  Atom -> (let S (lb-atom-string Atom)
          (if (= S "unknown")
           false
           (if (lb-string-contains? "-" S)
            (if (lb-string-contains? "policy" S) true
             (if (lb-string-contains? "outcome" S) true
              (if (lb-string-contains? "does-not" S) true
               false)))
            false))))

(define suspicious-atom-warnings-h
  Pred [] -> []
  Pred [Arg | Args] -> (append
                        (if (generic-placeholder? Arg)
                         [[fact-warning w-suspicious suspicious-atom predicate Pred atom Arg reason generic-placeholder]]
                         [])
                        (append
                         (if (opaque-atom? Arg)
                          [[fact-warning w-opaque opaque-atom predicate Pred atom Arg reason compact-opaque-boundary]]
                          [])
                         (suspicious-atom-warnings-h Pred Args))))

(define text-length-warnings-h
  Pred Pos [] [] -> []
  Pred Pos [text-atom | Types] [Arg | Args] -> (if (string? Arg)
                                               (if (> (lb-string-length Arg) 280)
                                                [[fact-warning w-long-text long-text predicate Pred slot Pos length (lb-string-length Arg)]
                                                 | (text-length-warnings-h Pred (+ Pos 1) Types Args)]
                                                (text-length-warnings-h Pred (+ Pos 1) Types Args))
                                               (text-length-warnings-h Pred (+ Pos 1) Types Args))
  Pred Pos [_ | Types] [_ | Args] -> (text-length-warnings-h Pred (+ Pos 1) Types Args)
  Pred Pos _ _ -> [])

(define fact-soft-warnings
  [rewrite R C C] -> [[fact-warning w-rewrite-identity rewrite-identity predicate rewrite source C target C]]
  [claim C Kind Source Target] -> (append (if (generic-placeholder? Source)
                                           [[fact-warning w-claim-generic claim-generic predicate claim atom Source reason generic-source]]
                                           [])
                                   (append (if (generic-placeholder? Target)
                                            [[fact-warning w-claim-generic claim-generic predicate claim atom Target reason generic-target]]
                                            [])
                                           (suspicious-atom-warnings-h claim [C Kind Source Target])))
  [Pred | Args] -> (let Spec (find-fact-spec Pred (lb-length Args))
                    (append (suspicious-atom-warnings-h Pred Args)
                            (if (= Spec []) [] (text-length-warnings-h Pred 1 (fact-spec-slots Spec) Args))))
  _ -> [])

(define schema-warnings-on-h
  [] -> []
  [Fact | Rest] -> (append (fact-soft-warnings Fact)
                   (schema-warnings-on-h Rest)))

(define schema-warnings-on
  Facts -> (let Norm (normalize-facts Facts)
           (schema-warnings-on-h (normalization-result-facts Norm))))

(define schema-warnings
  Facts -> (schema-warnings-on Facts))

(define enum-near-miss
  scope maybe-globalish -> global
  scope globalish -> global
  scope locally -> local
  modality probabl -> probable
  modality probably -> probable
  knowledge-state unkown -> unknown
  adapter-status-type temp -> ephemeral
  _ _ -> none)

(define predicate-near-miss
  modaliy -> modality
  modaility -> modality
  scrope -> scope
  groundclaim -> ground-claim
  factsource -> fact-source
  mystical-link -> similar
  _ -> none)

(define enum-suggestions-h
  Pred Pos [] [] -> []
  Pred Pos [Type | Types] [Arg | Args] -> (if (enum-type? Type)
                                            (let Suggest (enum-near-miss Type Arg)
                                            (if (= Suggest none)
                                             (enum-suggestions-h Pred (+ Pos 1) Types Args)
                                             [[fact-suggestion s-enum-near-miss enum-near-miss predicate Pred slot Pos got Arg suggest Suggest]
                                              | (enum-suggestions-h Pred (+ Pos 1) Types Args)]))
                                            (enum-suggestions-h Pred (+ Pos 1) Types Args))
  Pred Pos _ _ -> [])

(define fact-suggestions
  [Pred | Args] -> (let Canonical (predicate-alias Pred)
                    (let Spec (find-fact-spec Canonical (lb-length Args))
                    (append (let Suggest (predicate-near-miss Pred)
                             (if (= Suggest none) [] [[fact-suggestion s-predicate-near-miss predicate-near-miss got Pred suggest Suggest]]))
                            (if (= Spec []) [] (enum-suggestions-h Canonical 1 (fact-spec-slots Spec) Args)))))
  _ -> [])

(define schema-suggestions-on-h
  [] -> []
  [Fact | Rest] -> (append (fact-suggestions Fact)
                   (schema-suggestions-on-h Rest)))

(define schema-suggestions
  Facts -> (schema-suggestions-on-h Facts))

(define hard-error?
  [fact-type-error | _] -> true
  _ -> false)

(define no-hard-errors?
  [] -> true
  [Error | _] -> false)

(define fact-has-errors?
  Fact Env -> (if (= (validate-fact-errors Fact Env) []) false true))

(define accepted-core-facts-h
  [] Env Acc -> Acc
  [Fact | Rest] Env Acc -> (accepted-core-facts-h Rest Env
                            (if (fact-has-errors? Fact Env)
                             Acc
                             (let Spec (if (cons? Fact)
                                        (find-fact-spec (hd Fact) (lb-length (tl Fact)))
                                        [])
                             (if (= Spec [])
                              Acc
                              (if (core-namespace? (fact-spec-namespace Spec))
                               (if (fact-spec-report-only? Spec)
                                Acc
                                (lb-snoc Acc Fact))
                               Acc))))))

(define schema-accepted-core-facts
  Facts -> (let Norm (normalize-facts Facts)
           (let NormFacts (normalization-result-facts Norm)
           (accepted-core-facts-h NormFacts (seed-id-env NormFacts) []))))

(define schema-normalizations
  Facts -> (let Norm (normalize-facts Facts)
           (normalization-result-records Norm)))

(define schema-diagnostics
  Facts -> (append (schema-type-errors Facts)
           (append (schema-warnings Facts)
           (append (schema-suggestions Facts)
                   (schema-normalizations Facts)))))

(define schema-plan-status-h
  [] Status -> []
  [[plan P] | Rest] Status -> [[plan-status P Status] | (schema-plan-status-h Rest Status)]
  [[plan P _] | Rest] Status -> [[plan-status P Status] | (schema-plan-status-h Rest Status)]
  [_ | Rest] Status -> (schema-plan-status-h Rest Status))

(define schema-error-plan-statuses
  Facts -> (schema-plan-status-h Facts translation-error))

(define schema-valid?
  Facts -> (= (schema-type-errors Facts) []))
