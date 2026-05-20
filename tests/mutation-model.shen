\\ Deliberately mutated rewrite model for testing rewrite checks.

(set *facts*
  [
    [term passive-ai-dependence known]
    [term weakened-independent-judgment known]

    [claim c1 causal passive-ai-dependence weakened-independent-judgment]
    [mechanism c1 unexamined-acceptance]
    [modality c1 possible]
    [scope c1 conditional]

    [rewrite-claim r1 causal ai-use destroyed-intelligence]
    [rewrite-modality r1 certain]
    [rewrite-scope r1 universal]

    [stronger-than certain possible]
    [stronger-than universal conditional]
    [broader-than ai-use passive-ai-dependence]
    [stronger-effect destroyed-intelligence weakened-independent-judgment]
  ])
