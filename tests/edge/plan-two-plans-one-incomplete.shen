(set *facts*
  [
    [plan p1]
    [plan-source p1 edge-plan]
    [plan-goal p1 incomplete]
    [plan-claim p1 c1]
    [plan p2]
    [plan-source p2 edge-plan]
    [plan-goal p2 clear]
    [plan-claim p2 c2]
    [claim c1 causal source-a target-a]
    [mechanism c1 unknown]
    [modality c1 possible]
    [scope c1 conditional]
    [claim c2 causal source-b target-b]
    [mechanism c2 bridge]
    [modality c2 possible]
    [scope c2 conditional]
  ])
