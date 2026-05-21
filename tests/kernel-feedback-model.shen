\\ Improved kernel example for the feedback/adjustment paragraph.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]
    [plan-fact p1 f-term-adjust]
    [plan-fact p1 f-term-better]
    [plan-context p1 result-measure-is-reliable]
    [plan-context p1 actor-can-change-future-actions]
    [plan-check p1 extraction-contract-violation]
    [plan-check p1 missing-context]
    [plan-check p1 stage-chain-too-short]
    [comment p1 "The paragraph appears to argue that feedback-based adjustment improves outcomes."]

    [term adjust-based-on-results known]
    [term better-outcomes unknown]
    [compound-domain-atom better-outcomes]
    [term repeat-what-works known]

    [ground-claim g1 adjust-based-on-results repeat-what-works]
    [conclusion k1 better-outcomes]
    [infers-to g1 k1]

    [claim c1 causal adjust-based-on-results better-outcomes]
    [mechanism c1 repeat-what-works]
    [similar adjust-based-on-results repeat-what-works]

    [context-required c1 result-measure-is-reliable]
    [context-known result-measure-is-reliable unknown]
    [context-required c1 actor-can-change-future-actions]
    [context-known actor-can-change-future-actions unknown]

    [stage-chain-min c1 3]
    [stage s1 repeat-what-works]
    [stage-of s1 c1]
    [stage-order s1 1]

    [modality c1 unknown]
    [scope c1 unknown]

    [fact-scope f-term-adjust local]
  ])
