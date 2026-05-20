\\ Deliberately incomplete model for testing basic structural checks.

(set *facts*
  [
    [term overreliance unknown]
    [term weakened-judgment unknown]

    [claim c1 causal overreliance weakened-judgment]
    [mechanism c1 unknown]
    [modality c1 unknown]
    [scope c1 unknown]

    \\ Non-causal claims should not trigger missing-mechanism.
    [claim n1 assertion overreliance weakened-judgment]
    [mechanism n1 unknown]
  ])
