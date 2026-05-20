\\ LogicBox Shen checker.
\\ The AI writes candidate facts into work/ai-facts.shen as data in *facts*.
\\ This file owns the derived flags.

(define unknown-mechanism?
  C [] -> false
  C [[mechanism C unknown] | _] -> true
  C [_ | Rest] -> (unknown-mechanism? C Rest))

(define stronger-than?
  New Old [] -> false
  New Old [[stronger-than New Old] | _] -> true
  New Old [_ | Rest] -> (stronger-than? New Old Rest))

(define broader-than?
  New Old [] -> false
  New Old [[broader-than New Old] | _] -> true
  New Old [_ | Rest] -> (broader-than? New Old Rest))

(define stronger-effect?
  New Old [] -> false
  New Old [[stronger-effect New Old] | _] -> true
  New Old [_ | Rest] -> (stronger-effect? New Old Rest))

(define similar?
  A A _ -> true
  A B [] -> false
  A B [[similar A B] | _] -> true
  A B [[similar B A] | _] -> true
  A B [_ | Rest] -> (similar? A B Rest))

(define abstract?
  X [] -> false
  X [[abstract X] | _] -> true
  X [_ | Rest] -> (abstract? X Rest))

(define not-equivalent?
  A B [] -> false
  A B [[not-equivalent A B] | _] -> true
  A B [[not-equivalent B A] | _] -> true
  A B [_ | Rest] -> (not-equivalent? A B Rest))

(define context-known-positive?
  Ctx [] -> false
  Ctx [[context-known Ctx known] | _] -> true
  Ctx [_ | Rest] -> (context-known-positive? Ctx Rest))

(define context-missing?
  Ctx Facts -> (if (context-known-positive? Ctx Facts) false true))

(define fact-scope-known?
  F [] -> false
  F [[fact-scope F _] | _] -> true
  F [_ | Rest] -> (fact-scope-known? F Rest))

(define fact-has-scope?
  F Scope [] -> false
  F Scope [[fact-scope F Scope] | _] -> true
  F Scope [_ | Rest] -> (fact-has-scope? F Scope Rest))

(define scope-incompatible?
  S1 S2 [] -> false
  S1 S2 [[scope-incompatible S1 S2] | _] -> true
  S1 S2 [[scope-incompatible S2 S1] | _] -> true
  S1 S2 [_ | Rest] -> (scope-incompatible? S1 S2 Rest))

(define ground-known?
  G [] -> false
  G [[ground-claim G unknown unknown] | _] -> false
  G [[ground-claim G unknown] | _] -> false
  G [[ground-claim G _ _] | _] -> true
  G [_ | Rest] -> (ground-known? G Rest))

(define conclusion-supported?
  K [] Facts -> false
  K [[infers-to G K] | _] Facts -> (if (ground-known? G Facts) true false)
  K [_ | Rest] Facts -> (conclusion-supported? K Rest Facts))

(define count-stages-of
  C [] -> 0
  C [[stage-of _ C] | Rest] -> (+ 1 (count-stages-of C Rest))
  C [_ | Rest] -> (count-stages-of C Rest))

(define stage-bridge-known?
  S1 S2 [] -> false
  S1 S2 [[stage-bridge S1 S2 _] | _] -> true
  S1 S2 [_ | Rest] -> (stage-bridge-known? S1 S2 Rest))

(define no-flags?
  [] -> true
  _ -> false)

(define mechanism-required?
  causal -> true
  produces -> true
  enables -> true
  prevents -> true
  practical-outperformance -> true
  _ -> false)

(define collect-undefined-terms
  [] -> []
  [[term X unknown] | Rest] -> [[undefined-term X] | (collect-undefined-terms Rest)]
  [_ | Rest] -> (collect-undefined-terms Rest))

(define collect-precomputed-flags
  [] -> []
  [[undefined-term X] | Rest] -> [[precomputed-flag undefined-term X] | (collect-precomputed-flags Rest)]
  [[missing-mechanism C] | Rest] -> [[precomputed-flag missing-mechanism C] | (collect-precomputed-flags Rest)]
  [[mechanism-restates-source C Source M] | Rest] -> [[precomputed-flag mechanism-restates-source C Source M] | (collect-precomputed-flags Rest)]
  [[mechanism-restates-target C Target M] | Rest] -> [[precomputed-flag mechanism-restates-target C Target M] | (collect-precomputed-flags Rest)]
  [[mechanism-too-abstract C M] | Rest] -> [[precomputed-flag mechanism-too-abstract C M] | (collect-precomputed-flags Rest)]
  [[unclear-modality C] | Rest] -> [[precomputed-flag unclear-modality C] | (collect-precomputed-flags Rest)]
  [[unclear-scope C] | Rest] -> [[precomputed-flag unclear-scope C] | (collect-precomputed-flags Rest)]
  [[missing-context C Ctx] | Rest] -> [[precomputed-flag missing-context C Ctx] | (collect-precomputed-flags Rest)]
  [[conclusion-stronger-than-premises P K Old New] | Rest] -> [[precomputed-flag conclusion-stronger-than-premises P K Old New] | (collect-precomputed-flags Rest)]
  [[conclusion-stronger-than-ground G K Old New] | Rest] -> [[precomputed-flag conclusion-stronger-than-ground G K Old New] | (collect-precomputed-flags Rest)]
  [[claim-without-ground K] | Rest] -> [[precomputed-flag claim-without-ground K] | (collect-precomputed-flags Rest)]
  [[stage-chain-too-short C Count Min] | Rest] -> [[precomputed-flag stage-chain-too-short C Count Min] | (collect-precomputed-flags Rest)]
  [[stage-restates-claim C S Label Term] | Rest] -> [[precomputed-flag stage-restates-claim C S Label Term] | (collect-precomputed-flags Rest)]
  [[mechanism-restates-stage C S M Label] | Rest] -> [[precomputed-flag mechanism-restates-stage C S M Label] | (collect-precomputed-flags Rest)]
  [[missing-stage-bridge C S1 S2] | Rest] -> [[precomputed-flag missing-stage-bridge C S1 S2] | (collect-precomputed-flags Rest)]
  [[scope-missing F] | Rest] -> [[precomputed-flag scope-missing F] | (collect-precomputed-flags Rest)]
  [[scope-conflict F1 F2 S1 S2] | Rest] -> [[precomputed-flag scope-conflict F1 F2 S1 S2] | (collect-precomputed-flags Rest)]
  [[global-term-redefined-locally Term F1 F2] | Rest] -> [[precomputed-flag global-term-redefined-locally Term F1 F2] | (collect-precomputed-flags Rest)]
  [[modality-mutation C R Old New] | Rest] -> [[precomputed-flag modality-mutation C R Old New] | (collect-precomputed-flags Rest)]
  [[scope-mutation C R Old New] | Rest] -> [[precomputed-flag scope-mutation C R Old New] | (collect-precomputed-flags Rest)]
  [[source-mutation C R Old New] | Rest] -> [[precomputed-flag source-mutation C R Old New] | (collect-precomputed-flags Rest)]
  [[target-mutation C R Old New] | Rest] -> [[precomputed-flag target-mutation C R Old New] | (collect-precomputed-flags Rest)]
  [[plan-incomplete P] | Rest] -> [[precomputed-flag plan-incomplete P] | (collect-precomputed-flags Rest)]
  [[clear-enough P] | Rest] -> [[precomputed-flag clear-enough P] | (collect-precomputed-flags Rest)]
  [_ | Rest] -> (collect-precomputed-flags Rest))

(define collect-missing-mechanisms-h
  [] Facts -> []
  [[claim C Type _ _] | Rest] Facts -> (if (mechanism-required? Type)
                                         (if (unknown-mechanism? C Facts)
                                          [[missing-mechanism C] | (collect-missing-mechanisms-h Rest Facts)]
                                          (collect-missing-mechanisms-h Rest Facts))
                                         (collect-missing-mechanisms-h Rest Facts))
  [_ | Rest] Facts -> (collect-missing-mechanisms-h Rest Facts))

(define collect-missing-mechanisms
  Facts -> (collect-missing-mechanisms-h Facts Facts))

(define collect-unclear-modalities
  [] -> []
  [[modality C unknown] | Rest] -> [[unclear-modality C] | (collect-unclear-modalities Rest)]
  [_ | Rest] -> (collect-unclear-modalities Rest))

(define collect-unclear-scopes
  [] -> []
  [[scope C unknown] | Rest] -> [[unclear-scope C] | (collect-unclear-scopes Rest)]
  [_ | Rest] -> (collect-unclear-scopes Rest))

(define collect-mechanism-restates-source-h
  [] Facts -> []
  [[claim C _ Source _] | Rest] Facts -> (append (collect-mechanism-restates-source-for C Source Facts Facts)
                                                 (collect-mechanism-restates-source-h Rest Facts))
  [_ | Rest] Facts -> (collect-mechanism-restates-source-h Rest Facts))

(define collect-mechanism-restates-source-for
  C Source [] Facts -> []
  C Source [[mechanism C Mechanism] | Rest] Facts -> (if (similar? Source Mechanism Facts)
                                                       [[mechanism-restates-source C Source Mechanism] | (collect-mechanism-restates-source-for C Source Rest Facts)]
                                                       (collect-mechanism-restates-source-for C Source Rest Facts))
  C Source [_ | Rest] Facts -> (collect-mechanism-restates-source-for C Source Rest Facts))

(define collect-mechanism-restates-source
  Facts -> (collect-mechanism-restates-source-h Facts Facts))

(define collect-mechanism-restates-target-h
  [] Facts -> []
  [[claim C _ _ Target] | Rest] Facts -> (append (collect-mechanism-restates-target-for C Target Facts Facts)
                                                 (collect-mechanism-restates-target-h Rest Facts))
  [_ | Rest] Facts -> (collect-mechanism-restates-target-h Rest Facts))

(define collect-mechanism-restates-target-for
  C Target [] Facts -> []
  C Target [[mechanism C Mechanism] | Rest] Facts -> (if (similar? Target Mechanism Facts)
                                                       [[mechanism-restates-target C Target Mechanism] | (collect-mechanism-restates-target-for C Target Rest Facts)]
                                                       (collect-mechanism-restates-target-for C Target Rest Facts))
  C Target [_ | Rest] Facts -> (collect-mechanism-restates-target-for C Target Rest Facts))

(define collect-mechanism-restates-target
  Facts -> (collect-mechanism-restates-target-h Facts Facts))

(define collect-mechanism-too-abstract-h
  [] Facts -> []
  [[mechanism C M] | Rest] Facts -> (if (abstract? M Facts)
                                      [[mechanism-too-abstract C M] | (collect-mechanism-too-abstract-h Rest Facts)]
                                      (collect-mechanism-too-abstract-h Rest Facts))
  [_ | Rest] Facts -> (collect-mechanism-too-abstract-h Rest Facts))

(define collect-mechanism-too-abstract
  Facts -> (collect-mechanism-too-abstract-h Facts Facts))

(define collect-missing-context-h
  [] Facts -> []
  [[context-required C Ctx] | Rest] Facts -> (if (context-missing? Ctx Facts)
                                               [[missing-context C Ctx] | (collect-missing-context-h Rest Facts)]
                                               (collect-missing-context-h Rest Facts))
  [_ | Rest] Facts -> (collect-missing-context-h Rest Facts))

(define collect-missing-context
  Facts -> (collect-missing-context-h Facts Facts))

(define collect-conclusion-stronger-than-premises-h
  [] Facts -> []
  [[supports Premise Conclusion] | Rest] Facts -> (append (collect-conclusion-stronger-than-premise-for Premise Conclusion Facts Facts)
                                                          (collect-conclusion-stronger-than-premises-h Rest Facts))
  [_ | Rest] Facts -> (collect-conclusion-stronger-than-premises-h Rest Facts))

(define collect-conclusion-stronger-than-premise-for
  Premise Conclusion [] Facts -> []
  Premise Conclusion [[modality Premise Old] | Rest] Facts -> (append (collect-conclusion-stronger-than-premise-modality Premise Conclusion Old Facts Facts)
                                                                      (collect-conclusion-stronger-than-premise-for Premise Conclusion Rest Facts))
  Premise Conclusion [_ | Rest] Facts -> (collect-conclusion-stronger-than-premise-for Premise Conclusion Rest Facts))

(define collect-conclusion-stronger-than-premise-modality
  Premise Conclusion Old [] Facts -> []
  Premise Conclusion Old [[modality Conclusion New] | Rest] Facts -> (if (stronger-than? New Old Facts)
                                                                       [[conclusion-stronger-than-premises Premise Conclusion Old New] | (collect-conclusion-stronger-than-premise-modality Premise Conclusion Old Rest Facts)]
                                                                       (collect-conclusion-stronger-than-premise-modality Premise Conclusion Old Rest Facts))
  Premise Conclusion Old [_ | Rest] Facts -> (collect-conclusion-stronger-than-premise-modality Premise Conclusion Old Rest Facts))

(define collect-conclusion-stronger-than-premises
  Facts -> (collect-conclusion-stronger-than-premises-h Facts Facts))

(define collect-conclusion-stronger-than-ground-h
  [] Facts -> []
  [[infers-to Ground Conclusion] | Rest] Facts -> (append (collect-conclusion-stronger-than-ground-for Ground Conclusion Facts Facts)
                                                          (collect-conclusion-stronger-than-ground-h Rest Facts))
  [_ | Rest] Facts -> (collect-conclusion-stronger-than-ground-h Rest Facts))

(define collect-conclusion-stronger-than-ground-for
  Ground Conclusion [] Facts -> []
  Ground Conclusion [[modality Ground Old] | Rest] Facts -> (append (collect-conclusion-stronger-than-ground-modality Ground Conclusion Old Facts Facts)
                                                                    (collect-conclusion-stronger-than-ground-for Ground Conclusion Rest Facts))
  Ground Conclusion [_ | Rest] Facts -> (collect-conclusion-stronger-than-ground-for Ground Conclusion Rest Facts))

(define collect-conclusion-stronger-than-ground-modality
  Ground Conclusion Old [] Facts -> []
  Ground Conclusion Old [[modality Conclusion New] | Rest] Facts -> (if (stronger-than? New Old Facts)
                                                                       [[conclusion-stronger-than-ground Ground Conclusion Old New] | (collect-conclusion-stronger-than-ground-modality Ground Conclusion Old Rest Facts)]
                                                                       (collect-conclusion-stronger-than-ground-modality Ground Conclusion Old Rest Facts))
  Ground Conclusion Old [_ | Rest] Facts -> (collect-conclusion-stronger-than-ground-modality Ground Conclusion Old Rest Facts))

(define collect-conclusion-stronger-than-ground
  Facts -> (collect-conclusion-stronger-than-ground-h Facts Facts))

(define collect-claims-without-ground-h
  [] Facts -> []
  [[conclusion K _] | Rest] Facts -> (if (conclusion-supported? K Facts Facts)
                                       (collect-claims-without-ground-h Rest Facts)
                                       [[claim-without-ground K] | (collect-claims-without-ground-h Rest Facts)])
  [_ | Rest] Facts -> (collect-claims-without-ground-h Rest Facts))

(define collect-claims-without-ground
  Facts -> (collect-claims-without-ground-h Facts Facts))

(define collect-stage-chain-too-short-h
  [] Facts -> []
  [[stage-chain-min C Min] | Rest] Facts -> (let Count (count-stages-of C Facts)
                                              (if (< Count Min)
                                               [[stage-chain-too-short C Count Min] | (collect-stage-chain-too-short-h Rest Facts)]
                                               (collect-stage-chain-too-short-h Rest Facts)))
  [_ | Rest] Facts -> (collect-stage-chain-too-short-h Rest Facts))

(define collect-stage-chain-too-short
  Facts -> (collect-stage-chain-too-short-h Facts Facts))

(define collect-stage-restates-claim-h
  [] Facts -> []
  [[claim C _ Source Target] | Rest] Facts -> (append (collect-stage-restates-claim-for C Source Target Facts Facts)
                                                      (collect-stage-restates-claim-h Rest Facts))
  [_ | Rest] Facts -> (collect-stage-restates-claim-h Rest Facts))

(define collect-stage-restates-claim-for
  C Source Target [] Facts -> []
  C Source Target [[stage-of S C] | Rest] Facts -> (append (collect-stage-restates-claim-label C S Source Target Facts Facts)
                                                           (collect-stage-restates-claim-for C Source Target Rest Facts))
  C Source Target [_ | Rest] Facts -> (collect-stage-restates-claim-for C Source Target Rest Facts))

(define collect-stage-restates-claim-label
  C S Source Target [] Facts -> []
  C S Source Target [[stage S Label] | Rest] Facts -> (if (similar? Source Label Facts)
                                                        [[stage-restates-claim C S Label Source] | (collect-stage-restates-claim-label C S Source Target Rest Facts)]
                                                        (if (similar? Target Label Facts)
                                                         [[stage-restates-claim C S Label Target] | (collect-stage-restates-claim-label C S Source Target Rest Facts)]
                                                         (collect-stage-restates-claim-label C S Source Target Rest Facts)))
  C S Source Target [_ | Rest] Facts -> (collect-stage-restates-claim-label C S Source Target Rest Facts))

(define collect-stage-restates-claim
  Facts -> (collect-stage-restates-claim-h Facts Facts))

(define collect-mechanism-restates-stage-h
  [] Facts -> []
  [[mechanism C M] | Rest] Facts -> (append (collect-mechanism-restates-stage-for C M Facts Facts)
                                            (collect-mechanism-restates-stage-h Rest Facts))
  [_ | Rest] Facts -> (collect-mechanism-restates-stage-h Rest Facts))

(define collect-mechanism-restates-stage-for
  C M [] Facts -> []
  C M [[stage-of S C] | Rest] Facts -> (append (collect-mechanism-restates-stage-label C M S Facts Facts)
                                               (collect-mechanism-restates-stage-for C M Rest Facts))
  C M [_ | Rest] Facts -> (collect-mechanism-restates-stage-for C M Rest Facts))

(define collect-mechanism-restates-stage-label
  C M S [] Facts -> []
  C M S [[stage S Label] | Rest] Facts -> (if (similar? M Label Facts)
                                            [[mechanism-restates-stage C S M Label] | (collect-mechanism-restates-stage-label C M S Rest Facts)]
                                            (collect-mechanism-restates-stage-label C M S Rest Facts))
  C M S [_ | Rest] Facts -> (collect-mechanism-restates-stage-label C M S Rest Facts))

(define collect-mechanism-restates-stage
  Facts -> (collect-mechanism-restates-stage-h Facts Facts))

(define collect-missing-stage-bridges-h
  [] Facts -> []
  [[stage-next C S1 S2] | Rest] Facts -> (if (stage-bridge-known? S1 S2 Facts)
                                           (collect-missing-stage-bridges-h Rest Facts)
                                           [[missing-stage-bridge C S1 S2] | (collect-missing-stage-bridges-h Rest Facts)])
  [_ | Rest] Facts -> (collect-missing-stage-bridges-h Rest Facts))

(define collect-missing-stage-bridges
  Facts -> (collect-missing-stage-bridges-h Facts Facts))

(define collect-scope-missing-h
  [] Facts -> []
  [[plan-fact _ F] | Rest] Facts -> (if (fact-scope-known? F Facts)
                                      (collect-scope-missing-h Rest Facts)
                                      [[scope-missing F] | (collect-scope-missing-h Rest Facts)])
  [_ | Rest] Facts -> (collect-scope-missing-h Rest Facts))

(define collect-scope-missing
  Facts -> (collect-scope-missing-h Facts Facts))

(define collect-scope-conflicts-h
  [] Facts -> []
  [[scope-conflict-candidate F1 F2] | Rest] Facts -> (append (collect-scope-conflict-scope1 F1 F2 Facts Facts)
                                                             (collect-scope-conflicts-h Rest Facts))
  [_ | Rest] Facts -> (collect-scope-conflicts-h Rest Facts))

(define collect-scope-conflict-scope1
  F1 F2 [] Facts -> []
  F1 F2 [[fact-scope F1 S1] | Rest] Facts -> (append (collect-scope-conflict-scope2 F1 F2 S1 Facts Facts)
                                                     (collect-scope-conflict-scope1 F1 F2 Rest Facts))
  F1 F2 [_ | Rest] Facts -> (collect-scope-conflict-scope1 F1 F2 Rest Facts))

(define collect-scope-conflict-scope2
  F1 F2 S1 [] Facts -> []
  F1 F2 S1 [[fact-scope F2 S2] | Rest] Facts -> (if (scope-incompatible? S1 S2 Facts)
                                                  [[scope-conflict F1 F2 S1 S2] | (collect-scope-conflict-scope2 F1 F2 S1 Rest Facts)]
                                                  (collect-scope-conflict-scope2 F1 F2 S1 Rest Facts))
  F1 F2 S1 [_ | Rest] Facts -> (collect-scope-conflict-scope2 F1 F2 S1 Rest Facts))

(define collect-scope-conflicts
  Facts -> (collect-scope-conflicts-h Facts Facts))

(define collect-global-term-redefined-locally-h
  [] Facts -> []
  [[term-definition F1 Term] | Rest] Facts -> (append (collect-global-term-redefined-locally-for F1 Term Facts Facts)
                                                      (collect-global-term-redefined-locally-h Rest Facts))
  [_ | Rest] Facts -> (collect-global-term-redefined-locally-h Rest Facts))

(define collect-global-term-redefined-locally-for
  F1 Term [] Facts -> []
  F1 Term [[term-definition F2 Term] | Rest] Facts -> (if (fact-has-scope? F1 global Facts)
                                                        (if (fact-has-scope? F2 local Facts)
                                                         (if (not-equivalent? F1 F2 Facts)
                                                          [[global-term-redefined-locally Term F1 F2] | (collect-global-term-redefined-locally-for F1 Term Rest Facts)]
                                                          (collect-global-term-redefined-locally-for F1 Term Rest Facts))
                                                         (collect-global-term-redefined-locally-for F1 Term Rest Facts))
                                                        (collect-global-term-redefined-locally-for F1 Term Rest Facts))
  F1 Term [_ | Rest] Facts -> (collect-global-term-redefined-locally-for F1 Term Rest Facts))

(define collect-global-term-redefined-locally
  Facts -> (collect-global-term-redefined-locally-h Facts Facts))

(define collect-modality-mutations-h
  [] Facts -> []
  [[modality C Old] | Rest] Facts -> (append (collect-modality-mutations-for C Old Facts Facts)
                                             (collect-modality-mutations-h Rest Facts))
  [_ | Rest] Facts -> (collect-modality-mutations-h Rest Facts))

(define collect-modality-mutations-for
  C Old [] Facts -> []
  C Old [[rewrite-modality R New] | Rest] Facts -> (if (stronger-than? New Old Facts)
                                                     [[modality-mutation C R Old New] | (collect-modality-mutations-for C Old Rest Facts)]
                                                     (collect-modality-mutations-for C Old Rest Facts))
  C Old [_ | Rest] Facts -> (collect-modality-mutations-for C Old Rest Facts))

(define collect-modality-mutations
  Facts -> (collect-modality-mutations-h Facts Facts))

(define collect-scope-mutations-h
  [] Facts -> []
  [[scope C Old] | Rest] Facts -> (append (collect-scope-mutations-for C Old Facts Facts)
                                          (collect-scope-mutations-h Rest Facts))
  [_ | Rest] Facts -> (collect-scope-mutations-h Rest Facts))

(define collect-scope-mutations-for
  C Old [] Facts -> []
  C Old [[rewrite-scope R New] | Rest] Facts -> (if (stronger-than? New Old Facts)
                                                  [[scope-mutation C R Old New] | (collect-scope-mutations-for C Old Rest Facts)]
                                                  (collect-scope-mutations-for C Old Rest Facts))
  C Old [_ | Rest] Facts -> (collect-scope-mutations-for C Old Rest Facts))

(define collect-scope-mutations
  Facts -> (collect-scope-mutations-h Facts Facts))

(define collect-source-mutations-h
  [] Facts -> []
  [[claim C _ Source _] | Rest] Facts -> (append (collect-source-mutations-for C Source Facts Facts)
                                                 (collect-source-mutations-h Rest Facts))
  [_ | Rest] Facts -> (collect-source-mutations-h Rest Facts))

(define collect-source-mutations-for
  C Source [] Facts -> []
  C Source [[rewrite-claim R _ NewSource _] | Rest] Facts -> (if (broader-than? NewSource Source Facts)
                                                               [[source-mutation C R Source NewSource] | (collect-source-mutations-for C Source Rest Facts)]
                                                               (collect-source-mutations-for C Source Rest Facts))
  C Source [_ | Rest] Facts -> (collect-source-mutations-for C Source Rest Facts))

(define collect-source-mutations
  Facts -> (collect-source-mutations-h Facts Facts))

(define collect-target-mutations-h
  [] Facts -> []
  [[claim C _ _ Target] | Rest] Facts -> (append (collect-target-mutations-for C Target Facts Facts)
                                                 (collect-target-mutations-h Rest Facts))
  [_ | Rest] Facts -> (collect-target-mutations-h Rest Facts))

(define collect-target-mutations-for
  C Target [] Facts -> []
  C Target [[rewrite-claim R _ _ NewTarget] | Rest] Facts -> (if (stronger-effect? NewTarget Target Facts)
                                                               [[target-mutation C R Target NewTarget] | (collect-target-mutations-for C Target Rest Facts)]
                                                               (collect-target-mutations-for C Target Rest Facts))
  C Target [_ | Rest] Facts -> (collect-target-mutations-for C Target Rest Facts))

(define collect-target-mutations
  Facts -> (collect-target-mutations-h Facts Facts))

(define blocking-flags
  Facts -> (append (collect-precomputed-flags Facts)
           (append (collect-undefined-terms Facts)
           (append (collect-missing-mechanisms Facts)
           (append (collect-unclear-modalities Facts)
           (append (collect-unclear-scopes Facts)
           (append (collect-mechanism-restates-source Facts)
           (append (collect-mechanism-restates-target Facts)
           (append (collect-mechanism-too-abstract Facts)
           (append (collect-missing-context Facts)
           (append (collect-conclusion-stronger-than-premises Facts)
           (append (collect-conclusion-stronger-than-ground Facts)
           (append (collect-claims-without-ground Facts)
           (append (collect-stage-chain-too-short Facts)
           (append (collect-stage-restates-claim Facts)
           (append (collect-mechanism-restates-stage Facts)
           (append (collect-missing-stage-bridges Facts)
           (append (collect-scope-missing Facts)
           (append (collect-scope-conflicts Facts)
           (append (collect-global-term-redefined-locally Facts)
           (append (collect-modality-mutations Facts)
           (append (collect-scope-mutations Facts)
           (append (collect-source-mutations Facts)
                   (collect-target-mutations Facts))))))))))))))))))))))))

(define collect-plan-status-h
  [] Facts -> []
  [[plan P] | Rest] Facts -> (if (no-flags? (blocking-flags Facts))
                               [[clear-enough P] | (collect-plan-status-h Rest Facts)]
                               [[plan-incomplete P] | (collect-plan-status-h Rest Facts)])
  [_ | Rest] Facts -> (collect-plan-status-h Rest Facts))

(define collect-plan-status
  Facts -> (collect-plan-status-h Facts Facts))

(define derived-flags
  Facts -> (append (blocking-flags Facts)
                   (collect-plan-status Facts)))
