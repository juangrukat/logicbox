(set *facts*
  [
    [plan p1]
    [plan-source p1 gold]
    [plan-goal p1 stage-chain-too-short-positive]
    [term source known]
    [term target known]
    [claim c1 causal source target]
    [mechanism c1 bridge]
    [modality c1 possible]
    [scope c1 conditional]
    [stage-chain-min c1 3]
    [stage s1 observe]
    [stage-of s1 c1]
    [stage-order s1 1]
    [stage s2 compare]
    [stage-of s2 c1]
    [stage-order s2 2]
  ])
