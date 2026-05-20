\\ Adversarial: comment claims context is satisfied, but no fact does.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]
    [comment p1 "The feedback is reliable and the actor can change behavior."]

    [term feedback known]
    [term improved-performance known]

    [claim c1 causal feedback improved-performance]
    [mechanism c1 learning-from-results]
    [modality c1 possible]
    [scope c1 conditional]

    [context-required c1 feedback-is-reliable-enough]
  ])
