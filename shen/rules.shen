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

(define valid-scope?
  local -> true
  section -> true
  document -> true
  global -> true
  _ -> false)

(define context-missing?
  Ctx Facts -> (if (context-known-positive? Ctx Facts) false true))

(define fact-scope-known?
  F [] -> false
  F [[fact-scope F _] | _] -> true
  F [[scope F _] | _] -> true
  F [[scope-status F _] | _] -> true
  F [[location F _] | _] -> true
  F [[setting F _] | _] -> true
  F [[population F _] | _] -> true
  F [[timeframe F _] | _] -> true
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

(define context-incompatible?
  C1 C2 [] -> false
  C1 C2 [[context-incompatible C1 C2] | _] -> true
  C1 C2 [[context-incompatible C2 C1] | _] -> true
  C1 C2 [_ | Rest] -> (context-incompatible? C1 C2 Rest))

(define equal-symbol?
  X X -> true
  _ _ -> false)

(define term-is?
  X Kind [] -> false
  X Kind [[term X Kind] | _] -> true
  X Kind [_ | Rest] -> (term-is? X Kind Rest))

(define compound-domain-atom?
  X [] -> false
  X [[compound-domain-atom X] | _] -> true
  X [_ | Rest] -> (compound-domain-atom? X Rest))

(define decomposition-candidate?
  X [] -> false
  X [[decomposition-candidate X] | _] -> true
  X [_ | Rest] -> (decomposition-candidate? X Rest))

(define value-criteria-candidate?
  X [] -> false
  X [[value-criteria-candidate X _] | _] -> true
  X [_ | Rest] -> (value-criteria-candidate? X Rest))

(define claim-node?
  C [] -> false
  C [[claim C _ _ _] | _] -> true
  C [[term C claim] | _] -> true
  C [[term C value-conclusion] | _] -> true
  C [_ | Rest] -> (claim-node? C Rest))

(define has-scope-status?
  X Status [] -> false
  X Status [[scope-status X Status] | _] -> true
  X Status [_ | Rest] -> (has-scope-status? X Status Rest))

(define unclear-scope-status?
  unknown -> true
  underspecified -> true
  unbounded -> true
  unclear -> true
  _ -> false)

(define typed-scope-unclear?
  X [] -> false
  X [[scope-status X Status] | _] -> (unclear-scope-status? Status)
  X [_ | Rest] -> (typed-scope-unclear? X Rest))

(define objection-answered?
  O [] -> false
  O [[mitigates _ O] | _] -> true
  O [[rebuts _ O] | _] -> true
  O [[concedes _ O] | _] -> true
  O [_ | Rest] -> (objection-answered? O Rest))

(define sufficiency-known?
  M [] -> false
  M [[sufficiency M sufficient] | _] -> true
  M [[sufficiency M shown] | _] -> true
  M [[sufficiency-status M sufficient] | _] -> true
  M [[sufficiency-status M shown] | _] -> true
  M [[evidence-status M provided] | _] -> true
  M [[evidence-status M present] | _] -> true
  M [_ | Rest] -> (sufficiency-known? M Rest))

(define criteria-known?
  X [] -> false
  X [[criteria-status X specified] | _] -> true
  X [[criteria-status X defined] | _] -> true
  X [[criteria-status X shown] | _] -> true
  X [_ | Rest] -> (criteria-known? X Rest))

(define source-condition-known?
  M [] -> false
  M [[source-condition M _] | _] -> true
  M [_ | Rest] -> (source-condition-known? M Rest))

(define process-known?
  M [] -> false
  M [[process M _] | _] -> true
  M [_ | Rest] -> (process-known? M Rest))

(define intermediate-effect-known?
  M [] -> false
  M [[intermediate-effect M _] | _] -> true
  M [_ | Rest] -> (intermediate-effect-known? M Rest))

(define final-outcome-known?
  M [] -> false
  M [[final-outcome M _] | _] -> true
  M [_ | Rest] -> (final-outcome-known? M Rest))

(define mechanism-path-complete?
  M Facts -> (if (source-condition-known? M Facts)
              (if (process-known? M Facts)
               (if (intermediate-effect-known? M Facts)
                (final-outcome-known? M Facts)
                false)
               false)
              false))

(define comparability-known?
  A [] -> false
  A [[comparability A known] | _] -> true
  A [[comparability A shown] | _] -> true
  A [_ | Rest] -> (comparability-known? A Rest))

(define boundary-known?
  E [] -> false
  E [[boundary-status E defined] | _] -> true
  E [[boundary-status E bounded] | _] -> true
  E [_ | Rest] -> (boundary-known? E Rest))

(define scope-transition-invalid?
  From To [] -> false
  From To [[scope-transition-invalid From To] | _] -> true
  From To [_ | Rest] -> (scope-transition-invalid? From To Rest))

(define ground-known?
  G [] -> false
  G [[ground-claim G unknown unknown] | _] -> false
  G [[ground-claim G unknown] | _] -> false
  G [[ground-claim G _ _] | _] -> true
  G [_ | Rest] -> (ground-known? G Rest))

(define conclusion-supported?
  K [] Facts -> false
  K [[infers-to G K] | _] Facts -> (if (ground-known? G Facts) true false)
  K [[supports _ K] | _] Facts -> true
  K [_ | Rest] Facts -> (conclusion-supported? K Rest Facts))

(define count-stages-of
  C [] -> 0
  C [[stage-of _ C] | Rest] -> (+ 1 (count-stages-of C Rest))
  C [_ | Rest] -> (count-stages-of C Rest))

(define stage-bridge-known?
  S1 S2 [] -> false
  S1 S2 [[stage-bridge S1 S2 _] | _] -> true
  S1 S2 [_ | Rest] -> (stage-bridge-known? S1 S2 Rest))

(define plan-membership-mode?
  [] -> false
  [[plan-claim _ _] | _] -> true
  [[plan-ground _ _] | _] -> true
  [[plan-conclusion _ _] | _] -> true
  [_ | Rest] -> (plan-membership-mode? Rest))

(define claim-belongs-to-plan?
  P C Facts -> (claim-belongs-to-plan-h P C Facts Facts))

(define claim-belongs-to-plan-h
  P C [] Facts -> false
  P C [[plan-claim P C] | _] Facts -> true
  P C [[plan-fact P C] | _] Facts -> (claim-node? C Facts)
  P C [_ | Rest] Facts -> (claim-belongs-to-plan-h P C Rest Facts))

(define ground-belongs-to-plan?
  P G [] -> false
  P G [[plan-ground P G] | _] -> true
  P G [_ | Rest] -> (ground-belongs-to-plan? P G Rest))

(define conclusion-belongs-to-plan?
  P K [] -> false
  P K [[plan-conclusion P K] | _] -> true
  P K [_ | Rest] -> (conclusion-belongs-to-plan? P K Rest))

(define fact-belongs-to-plan?
  P F [] -> false
  P F [[plan-fact P F] | _] -> true
  P F [_ | Rest] -> (fact-belongs-to-plan? P F Rest))

(define plan-flag?
  P [precomputed-flag clear-enough P] Facts -> true
  P [precomputed-flag plan-incomplete P] Facts -> true
  P [precomputed-flag missing-mechanism C] Facts -> (claim-belongs-to-plan? P C Facts)
  P [precomputed-flag missing-context C _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [extraction-contract-violation _] Facts -> true
  P [definition-needed _] Facts -> true
  P [decomposition-needed _] Facts -> true
  P [value-criteria-needed _ _] Facts -> true
  P [mechanism-needs-causal-path _] Facts -> true
  P [undefined-term X] Facts -> false
  P [missing-mechanism C] Facts -> (claim-belongs-to-plan? P C Facts)
  P [unclear-modality C] Facts -> (claim-belongs-to-plan? P C Facts)
  P [unclear-scope C] Facts -> (claim-belongs-to-plan? P C Facts)
  P [unclear-scope C _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [mechanism-restates-source C _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [mechanism-restates-target C _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [mechanism-too-abstract C _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [missing-context C _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [context-conflict C1 C2] Facts -> true
  P [context-scope-leak C _ _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [conclusion-stronger-than-premises C K _ _] Facts -> (if (claim-belongs-to-plan? P C Facts) true (conclusion-belongs-to-plan? P K Facts))
  P [conclusion-stronger-than-ground G K _ _] Facts -> (if (ground-belongs-to-plan? P G Facts) true (conclusion-belongs-to-plan? P K Facts))
  P [claim-without-ground K] Facts -> (conclusion-belongs-to-plan? P K Facts)
  P [stage-chain-too-short C _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [stage-restates-claim C _ _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [mechanism-restates-stage C _ _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [missing-stage-bridge C _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [scope-missing F] Facts -> (fact-belongs-to-plan? P F Facts)
  P [invalid-scope F _] Facts -> (fact-belongs-to-plan? P F Facts)
  P [scope-conflict F1 F2 _ _] Facts -> (if (fact-belongs-to-plan? P F1 Facts) true (fact-belongs-to-plan? P F2 Facts))
  P [scope-transition-conflict F _ _] Facts -> (fact-belongs-to-plan? P F Facts)
  P [global-term-redefined-locally _ F1 F2] Facts -> (if (fact-belongs-to-plan? P F1 Facts) true (fact-belongs-to-plan? P F2 Facts))
  P [shadowed-support G _ _] Facts -> (ground-belongs-to-plan? P G Facts)
  P [modality-mixed C] Facts -> (claim-belongs-to-plan? P C Facts)
  P [unresolved-objection C _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [mitigation-needs-sufficiency-check _ O] Facts -> true
  P [analogy-needs-comparability _] Facts -> true
  P [popularity-weak-support _ C] Facts -> (claim-belongs-to-plan? P C Facts)
  P [exception-boundary-needed _] Facts -> true
  P [broad-ban-vs-exemptions C _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [evidence-needed _ _] Facts -> true
  P [modality-mutation C _ _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [scope-mutation C _ _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [source-mutation C _ _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P [target-mutation C _ _ _] Facts -> (claim-belongs-to-plan? P C Facts)
  P _ Facts -> false)

(define plan-has-flag?
  P [] Facts -> false
  P [Flag | Rest] Facts -> (if (plan-flag? P Flag Facts) true (plan-has-flag? P Rest Facts)))

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

(define collect-definition-needed
  Facts -> (collect-definition-needed-h Facts Facts))

(define collect-definition-needed-h
  [] Facts -> []
  [[term X unknown] | Rest] Facts -> (if (compound-domain-atom? X Facts)
                                       (collect-definition-needed-h Rest Facts)
                                       (if (decomposition-candidate? X Facts)
                                        (collect-definition-needed-h Rest Facts)
                                        (if (value-criteria-candidate? X Facts)
                                         (collect-definition-needed-h Rest Facts)
                                         [[definition-needed X] | (collect-definition-needed-h Rest Facts)])))
  [_ | Rest] Facts -> (collect-definition-needed-h Rest Facts))

(define collect-extraction-contract-violations
  [] -> []
  [[compound-domain-atom X] | Rest] -> [[extraction-contract-violation X] | (collect-extraction-contract-violations Rest)]
  [_ | Rest] -> (collect-extraction-contract-violations Rest))

(define collect-decomposition-needed
  [] -> []
  [[decomposition-candidate X] | Rest] -> [[decomposition-needed X] | (collect-decomposition-needed Rest)]
  [_ | Rest] -> (collect-decomposition-needed Rest))

(define collect-value-criteria-needed-h
  [] Facts -> []
  [[value-criteria-candidate X Value] | Rest] Facts -> (if (criteria-known? X Facts)
                                                         (collect-value-criteria-needed-h Rest Facts)
                                                         [[value-criteria-needed X Value] | (collect-value-criteria-needed-h Rest Facts)])
  [[value-type X Value] | Rest] Facts -> (if (criteria-known? X Facts)
                                           (collect-value-criteria-needed-h Rest Facts)
                                           [[value-criteria-needed X Value] | (collect-value-criteria-needed-h Rest Facts)])
  [_ | Rest] Facts -> (collect-value-criteria-needed-h Rest Facts))

(define collect-value-criteria-needed
  Facts -> (collect-value-criteria-needed-h Facts Facts))

(define collect-precomputed-flags
  [] -> []
  [[extraction-contract-violation X] | Rest] -> [[precomputed-flag extraction-contract-violation X] | (collect-precomputed-flags Rest)]
  [[definition-needed X] | Rest] -> [[precomputed-flag definition-needed X] | (collect-precomputed-flags Rest)]
  [[decomposition-needed X] | Rest] -> [[precomputed-flag decomposition-needed X] | (collect-precomputed-flags Rest)]
  [[value-criteria-needed X V] | Rest] -> [[precomputed-flag value-criteria-needed X V] | (collect-precomputed-flags Rest)]
  [[mechanism-needs-causal-path M] | Rest] -> [[precomputed-flag mechanism-needs-causal-path M] | (collect-precomputed-flags Rest)]
  [[undefined-term X] | Rest] -> [[precomputed-flag undefined-term X] | (collect-precomputed-flags Rest)]
  [[missing-mechanism C] | Rest] -> [[precomputed-flag missing-mechanism C] | (collect-precomputed-flags Rest)]
  [[mechanism-restates-source C Source M] | Rest] -> [[precomputed-flag mechanism-restates-source C Source M] | (collect-precomputed-flags Rest)]
  [[mechanism-restates-target C Target M] | Rest] -> [[precomputed-flag mechanism-restates-target C Target M] | (collect-precomputed-flags Rest)]
  [[mechanism-too-abstract C M] | Rest] -> [[precomputed-flag mechanism-too-abstract C M] | (collect-precomputed-flags Rest)]
  [[unclear-modality C] | Rest] -> [[precomputed-flag unclear-modality C] | (collect-precomputed-flags Rest)]
  [[unclear-scope C] | Rest] -> [[precomputed-flag unclear-scope C] | (collect-precomputed-flags Rest)]
  [[unclear-scope C K V] | Rest] -> [[precomputed-flag unclear-scope C K V] | (collect-precomputed-flags Rest)]
  [[missing-context C Ctx] | Rest] -> [[precomputed-flag missing-context C Ctx] | (collect-precomputed-flags Rest)]
  [[conclusion-stronger-than-premises P K Old New] | Rest] -> [[precomputed-flag conclusion-stronger-than-premises P K Old New] | (collect-precomputed-flags Rest)]
  [[conclusion-stronger-than-ground G K Old New] | Rest] -> [[precomputed-flag conclusion-stronger-than-ground G K Old New] | (collect-precomputed-flags Rest)]
  [[claim-without-ground K] | Rest] -> [[precomputed-flag claim-without-ground K] | (collect-precomputed-flags Rest)]
  [[stage-chain-too-short C Count Min] | Rest] -> [[precomputed-flag stage-chain-too-short C Count Min] | (collect-precomputed-flags Rest)]
  [[stage-restates-claim C S Label Term] | Rest] -> [[precomputed-flag stage-restates-claim C S Label Term] | (collect-precomputed-flags Rest)]
  [[mechanism-restates-stage C S M Label] | Rest] -> [[precomputed-flag mechanism-restates-stage C S M Label] | (collect-precomputed-flags Rest)]
  [[missing-stage-bridge C S1 S2] | Rest] -> [[precomputed-flag missing-stage-bridge C S1 S2] | (collect-precomputed-flags Rest)]
  [[scope-missing F] | Rest] -> [[precomputed-flag scope-missing F] | (collect-precomputed-flags Rest)]
  [[invalid-scope F S] | Rest] -> [[precomputed-flag invalid-scope F S] | (collect-precomputed-flags Rest)]
  [[scope-conflict F1 F2 S1 S2] | Rest] -> [[precomputed-flag scope-conflict F1 F2 S1 S2] | (collect-precomputed-flags Rest)]
  [[scope-transition-conflict F S1 S2] | Rest] -> [[precomputed-flag scope-transition-conflict F S1 S2] | (collect-precomputed-flags Rest)]
  [[global-term-redefined-locally Term F1 F2] | Rest] -> [[precomputed-flag global-term-redefined-locally Term F1 F2] | (collect-precomputed-flags Rest)]
  [[shadowed-support G F1 F2] | Rest] -> [[precomputed-flag shadowed-support G F1 F2] | (collect-precomputed-flags Rest)]
  [[modality-mixed C] | Rest] -> [[precomputed-flag modality-mixed C] | (collect-precomputed-flags Rest)]
  [[unresolved-objection C O] | Rest] -> [[precomputed-flag unresolved-objection C O] | (collect-precomputed-flags Rest)]
  [[mitigation-needs-sufficiency-check M O] | Rest] -> [[precomputed-flag mitigation-needs-sufficiency-check M O] | (collect-precomputed-flags Rest)]
  [[analogy-needs-comparability A] | Rest] -> [[precomputed-flag analogy-needs-comparability A] | (collect-precomputed-flags Rest)]
  [[popularity-weak-support P C] | Rest] -> [[precomputed-flag popularity-weak-support P C] | (collect-precomputed-flags Rest)]
  [[exception-boundary-needed E] | Rest] -> [[precomputed-flag exception-boundary-needed E] | (collect-precomputed-flags Rest)]
  [[broad-ban-vs-exemptions C E] | Rest] -> [[precomputed-flag broad-ban-vs-exemptions C E] | (collect-precomputed-flags Rest)]
  [[evidence-needed R M] | Rest] -> [[precomputed-flag evidence-needed R M] | (collect-precomputed-flags Rest)]
  [[context-conflict C1 C2] | Rest] -> [[precomputed-flag context-conflict C1 C2] | (collect-precomputed-flags Rest)]
  [[context-scope-leak C Ctx S1 S2] | Rest] -> [[precomputed-flag context-scope-leak C Ctx S1 S2] | (collect-precomputed-flags Rest)]
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

(define collect-context-conflicts-h
  [] Facts -> []
  [[context-incompatible C1 C2] | Rest] Facts -> (if (context-known-positive? C1 Facts)
                                                  (if (context-known-positive? C2 Facts)
                                                   [[context-conflict C1 C2] | (collect-context-conflicts-h Rest Facts)]
                                                   (collect-context-conflicts-h Rest Facts))
                                                  (collect-context-conflicts-h Rest Facts))
  [_ | Rest] Facts -> (collect-context-conflicts-h Rest Facts))

(define collect-context-conflicts
  Facts -> (collect-context-conflicts-h Facts Facts))

(define collect-context-scope-leaks-h
  [] Facts -> []
  [[context-required-scope C Ctx RequiredScope] | Rest] Facts -> (append (collect-context-scope-leaks-for C Ctx RequiredScope Facts Facts)
                                                                         (collect-context-scope-leaks-h Rest Facts))
  [_ | Rest] Facts -> (collect-context-scope-leaks-h Rest Facts))

(define collect-context-scope-leaks-for
  C Ctx RequiredScope [] Facts -> []
  C Ctx RequiredScope [[context-scope Ctx ActualScope] | Rest] Facts -> (if (scope-incompatible? ActualScope RequiredScope Facts)
                                                                          [[context-scope-leak C Ctx ActualScope RequiredScope] | (collect-context-scope-leaks-for C Ctx RequiredScope Rest Facts)]
                                                                          (collect-context-scope-leaks-for C Ctx RequiredScope Rest Facts))
  C Ctx RequiredScope [_ | Rest] Facts -> (collect-context-scope-leaks-for C Ctx RequiredScope Rest Facts))

(define collect-context-scope-leaks
  Facts -> (collect-context-scope-leaks-h Facts Facts))

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

(define collect-invalid-scopes
  [] -> []
  [[fact-scope F Scope] | Rest] -> (if (valid-scope? Scope)
                                     (collect-invalid-scopes Rest)
                                     [[invalid-scope F Scope] | (collect-invalid-scopes Rest)])
  [_ | Rest] -> (collect-invalid-scopes Rest))

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

(define collect-scope-transition-conflicts-h
  [] Facts -> []
  [[scope-transition F From To] | Rest] Facts -> (if (scope-transition-invalid? From To Facts)
                                                   [[scope-transition-conflict F From To] | (collect-scope-transition-conflicts-h Rest Facts)]
                                                   (collect-scope-transition-conflicts-h Rest Facts))
  [_ | Rest] Facts -> (collect-scope-transition-conflicts-h Rest Facts))

(define collect-scope-transition-conflicts
  Facts -> (collect-scope-transition-conflicts-h Facts Facts))

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

(define collect-shadowed-support-h
  [] Facts -> []
  [[ground-uses-definition G GlobalFact] | Rest] Facts -> (append (collect-shadowed-support-for G GlobalFact Facts Facts)
                                                                  (collect-shadowed-support-h Rest Facts))
  [_ | Rest] Facts -> (collect-shadowed-support-h Rest Facts))

(define collect-shadowed-support-for
  G GlobalFact [] Facts -> []
  G GlobalFact [[local-definition-overrides GlobalFact LocalFact] | Rest] Facts -> [[shadowed-support G GlobalFact LocalFact] | (collect-shadowed-support-for G GlobalFact Rest Facts)]
  G GlobalFact [_ | Rest] Facts -> (collect-shadowed-support-for G GlobalFact Rest Facts))

(define collect-shadowed-support
  Facts -> (collect-shadowed-support-h Facts Facts))

(define collect-unclear-location-scope-h
  [] Facts -> []
  [[location C Loc] | Rest] Facts -> (if (typed-scope-unclear? C Facts)
                                       [[unclear-scope C location Loc] | (collect-unclear-location-scope-h Rest Facts)]
                                       (collect-unclear-location-scope-h Rest Facts))
  [_ | Rest] Facts -> (collect-unclear-location-scope-h Rest Facts))

(define collect-unclear-location-scope
  Facts -> (collect-unclear-location-scope-h Facts Facts))

(define collect-modality-mixed-h
  [] Facts -> []
  [[supports R C] | Rest] Facts -> (if (term-is? C claim Facts)
                                     (append (collect-modality-mixed-for R C Facts Facts)
                                             (collect-modality-mixed-h Rest Facts))
                                     (collect-modality-mixed-h Rest Facts))
  [_ | Rest] Facts -> (collect-modality-mixed-h Rest Facts))

(define collect-modality-mixed-for
  R C [] Facts -> []
  R C [[modality C M1] | Rest] Facts -> (append (collect-modality-mixed-reason R C M1 Facts Facts)
                                                (collect-modality-mixed-for R C Rest Facts))
  R C [_ | Rest] Facts -> (collect-modality-mixed-for R C Rest Facts))

(define collect-modality-mixed-reason
  R C M1 [] Facts -> []
  R C M1 [[modality R M2] | Rest] Facts -> (if (equal-symbol? M1 M2)
                                             (collect-modality-mixed-reason R C M1 Rest Facts)
                                             [[modality-mixed C] | (collect-modality-mixed-reason R C M1 Rest Facts)])
  R C M1 [_ | Rest] Facts -> (collect-modality-mixed-reason R C M1 Rest Facts))

(define collect-modality-mixed
  Facts -> (collect-modality-mixed-h Facts Facts))

(define collect-unresolved-objections-h
  [] Facts -> []
  [[objects-to O C] | Rest] Facts -> (if (objection-answered? O Facts)
                                       (collect-unresolved-objections-h Rest Facts)
                                       [[unresolved-objection C O] | (collect-unresolved-objections-h Rest Facts)])
  [_ | Rest] Facts -> (collect-unresolved-objections-h Rest Facts))

(define collect-unresolved-objections
  Facts -> (collect-unresolved-objections-h Facts Facts))

(define collect-mitigation-sufficiency-h
  [] Facts -> []
  [[mitigates M O] | Rest] Facts -> (if (sufficiency-known? M Facts)
                                      (collect-mitigation-sufficiency-h Rest Facts)
                                      [[mitigation-needs-sufficiency-check M O] | (collect-mitigation-sufficiency-h Rest Facts)])
  [_ | Rest] Facts -> (collect-mitigation-sufficiency-h Rest Facts))

(define collect-mitigation-sufficiency
  Facts -> (collect-mitigation-sufficiency-h Facts Facts))

(define collect-analogy-comparability-h
  [] Facts -> []
  [[term A analogy] | Rest] Facts -> (if (comparability-known? A Facts)
                                       (collect-analogy-comparability-h Rest Facts)
                                       [[analogy-needs-comparability A] | (collect-analogy-comparability-h Rest Facts)])
  [_ | Rest] Facts -> (collect-analogy-comparability-h Rest Facts))

(define collect-analogy-comparability
  Facts -> (collect-analogy-comparability-h Facts Facts))

(define collect-popularity-weak-support-h
  [] Facts -> []
  [[supports P C] | Rest] Facts -> (if (term-is? P popularity-claim Facts)
                                     [[popularity-weak-support P C] | (collect-popularity-weak-support-h Rest Facts)]
                                     (collect-popularity-weak-support-h Rest Facts))
  [_ | Rest] Facts -> (collect-popularity-weak-support-h Rest Facts))

(define collect-popularity-weak-support
  Facts -> (collect-popularity-weak-support-h Facts Facts))

(define collect-exception-boundaries-h
  [] Facts -> []
  [[term E exception] | Rest] Facts -> (if (boundary-known? E Facts)
                                         (collect-exception-boundaries-h Rest Facts)
                                         [[exception-boundary-needed E] | (collect-exception-boundaries-h Rest Facts)])
  [_ | Rest] Facts -> (collect-exception-boundaries-h Rest Facts))

(define collect-exception-boundaries
  Facts -> (collect-exception-boundaries-h Facts Facts))

(define collect-broad-ban-exceptions-h
  [] Facts -> []
  [[action C ban] | Rest] Facts -> (append (collect-broad-ban-exceptions-for C Facts Facts)
                                           (collect-broad-ban-exceptions-h Rest Facts))
  [_ | Rest] Facts -> (collect-broad-ban-exceptions-h Rest Facts))

(define collect-broad-ban-exceptions-for
  C [] Facts -> []
  C [[applies-to E C] | Rest] Facts -> (if (term-is? E exception Facts)
                                         [[broad-ban-vs-exemptions C E] | (collect-broad-ban-exceptions-for C Rest Facts)]
                                         (collect-broad-ban-exceptions-for C Rest Facts))
  C [_ | Rest] Facts -> (collect-broad-ban-exceptions-for C Rest Facts))

(define collect-broad-ban-exceptions
  Facts -> (collect-broad-ban-exceptions-h Facts Facts))

(define collect-mechanism-path-needed-h
  [] Facts -> []
  [[term M mechanism] | Rest] Facts -> (if (mechanism-path-complete? M Facts)
                                         (collect-mechanism-path-needed-h Rest Facts)
                                         [[mechanism-needs-causal-path M] | (collect-mechanism-path-needed-h Rest Facts)])
  [_ | Rest] Facts -> (collect-mechanism-path-needed-h Rest Facts))

(define collect-mechanism-path-needed
  Facts -> (collect-mechanism-path-needed-h Facts Facts))

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

(define evidence-known?
  R [] -> false
  R [[evidence R shown] | _] -> true
  R [[evidence R provided] | _] -> true
  R [_ | Rest] -> (evidence-known? R Rest))

(define collect-evidence-needed-h
  [] Facts -> []
  [[metric R M] | Rest] Facts -> (if (evidence-known? R Facts)
                                   (collect-evidence-needed-h Rest Facts)
                                   [[evidence-needed R M] | (collect-evidence-needed-h Rest Facts)])
  [_ | Rest] Facts -> (collect-evidence-needed-h Rest Facts))

(define collect-evidence-needed
  Facts -> (collect-evidence-needed-h Facts Facts))

(define blocking-flags
  Facts -> (append (collect-precomputed-flags Facts)
           (append (collect-extraction-contract-violations Facts)
           (append (collect-definition-needed Facts)
           (append (collect-decomposition-needed Facts)
           (append (collect-value-criteria-needed Facts)
           (append (collect-missing-mechanisms Facts)
           (append (collect-unclear-modalities Facts)
           (append (collect-unclear-scopes Facts)
           (append (collect-mechanism-restates-source Facts)
           (append (collect-mechanism-restates-target Facts)
           (append (collect-mechanism-too-abstract Facts)
           (append (collect-missing-context Facts)
           (append (collect-context-conflicts Facts)
           (append (collect-context-scope-leaks Facts)
           (append (collect-conclusion-stronger-than-premises Facts)
           (append (collect-conclusion-stronger-than-ground Facts)
           (append (collect-claims-without-ground Facts)
           (append (collect-stage-chain-too-short Facts)
           (append (collect-stage-restates-claim Facts)
           (append (collect-mechanism-restates-stage Facts)
           (append (collect-missing-stage-bridges Facts)
           (append (collect-scope-missing Facts)
           (append (collect-invalid-scopes Facts)
           (append (collect-scope-conflicts Facts)
           (append (collect-scope-transition-conflicts Facts)
           (append (collect-global-term-redefined-locally Facts)
           (append (collect-shadowed-support Facts)
           (append (collect-unclear-location-scope Facts)
           (append (collect-modality-mixed Facts)
           (append (collect-unresolved-objections Facts)
           (append (collect-mitigation-sufficiency Facts)
           (append (collect-analogy-comparability Facts)
           (append (collect-popularity-weak-support Facts)
           (append (collect-exception-boundaries Facts)
           (append (collect-broad-ban-exceptions Facts)
           (append (collect-mechanism-path-needed Facts)
           (append (collect-evidence-needed Facts)
           (append (collect-modality-mutations Facts)
           (append (collect-scope-mutations Facts)
           (append (collect-source-mutations Facts)
                   (collect-target-mutations Facts))))))))))))))))))))))))))))))))))))))))))

(define collect-plan-status-h
  [] Facts -> []
  [[plan P] | Rest] Facts -> (if (plan-membership-mode? Facts)
                               (if (plan-has-flag? P (blocking-flags Facts) Facts)
                                [[plan-incomplete P] | (collect-plan-status-h Rest Facts)]
                                [[clear-enough P] | (collect-plan-status-h Rest Facts)])
                               (if (no-flags? (blocking-flags Facts))
                                [[clear-enough P] | (collect-plan-status-h Rest Facts)]
                                [[plan-incomplete P] | (collect-plan-status-h Rest Facts)]))
  [_ | Rest] Facts -> (collect-plan-status-h Rest Facts))

(define collect-plan-status
  Facts -> (collect-plan-status-h Facts Facts))

(define derived-flags
  Facts -> (append (blocking-flags Facts)
                   (collect-plan-status Facts)))
