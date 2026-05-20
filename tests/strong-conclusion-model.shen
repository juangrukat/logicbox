\\ Deliberately weak model for testing conclusion strength.

(set *facts*
  [
    [term some-ai-use known]
    [term reduced-carefulness known]
    [term society-irrational known]

    [claim p1 causal some-ai-use reduced-carefulness]
    [mechanism p1 reduced-attention]
    [modality p1 possible]
    [scope p1 local]

    [claim k1 conclusion some-ai-use society-irrational]
    [mechanism k1 aggregation-over-time]
    [modality k1 certain]
    [scope k1 universal]

    [supports p1 k1]
    [stronger-than certain possible]
  ])
