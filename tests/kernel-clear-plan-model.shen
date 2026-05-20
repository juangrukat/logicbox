\\ A minimally complete reasoning plan.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]
    [plan-fact p1 f-term-feedback]
    [plan-fact p1 f-term-improvement]
    [plan-check p1 missing-context]
    [comment p1 "The plan has concrete terms, known context, staged mechanism, and modest modality."]

    [term feedback known]
    [term improved-performance known]
    [term causal-attribution known]
    [term strategy-selection known]
    [term effective-actions known]

    [ground-claim g1 feedback causal-attribution]
    [modality g1 possible]

    [conclusion k1 improved-performance]
    [modality k1 possible]
    [infers-to g1 k1]

    [claim c1 causal feedback improved-performance]
    [mechanism c1 causal-attribution-and-strategy-selection]
    [modality c1 possible]
    [scope c1 conditional]

    [context-required c1 feedback-is-reliable-enough]
    [context-known feedback-is-reliable-enough known]
    [context-required c1 actor-can-change-future-actions]
    [context-known actor-can-change-future-actions known]

    [stage-chain-min c1 3]
    [stage s1 observe-results]
    [stage-of s1 c1]
    [stage-order s1 1]
    [stage s2 identify-effective-actions]
    [stage-of s2 c1]
    [stage-order s2 2]
    [stage s3 allocate-effort-to-effective-actions]
    [stage-of s3 c1]
    [stage-order s3 3]
    [stage-bridge s1 s2 causal-attribution]
    [stage-bridge s2 s3 strategy-selection]
    [stage-next c1 s1 s2]
    [stage-next c1 s2 s3]

    [fact-scope f-term-feedback local]
    [fact-scope f-term-improvement local]
  ])
