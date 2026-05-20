\\ Deliberately weak model for testing explanatory-distance checks.

(set *facts*
  [
    [term adjust-based-on-results known]
    [term better-outcomes known]
    [term repeat-what-works known]

    [claim c1 causal adjust-based-on-results better-outcomes]
    [mechanism c1 repeat-what-works]
    [modality c1 probable]
    [scope c1 conditional]

    [similar adjust-based-on-results repeat-what-works]
  ])
