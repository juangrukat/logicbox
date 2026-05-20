\\ Adversarial: supplies stages, but they mostly rename the source/target.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]

    [term adjust-based-on-results known]
    [term better-outcomes known]
    [term repeat-what-works known]

    [claim c1 causal adjust-based-on-results better-outcomes]
    [mechanism c1 repeat-what-works]
    [modality c1 probable]
    [scope c1 conditional]

    [stage-chain-min c1 3]
    [stage s1 adjust-based-on-results]
    [stage-of s1 c1]
    [stage-order s1 1]
    [stage s2 repeat-what-works]
    [stage-of s2 c1]
    [stage-order s2 2]
    [stage-next c1 s1 s2]
  ])
