\\ Adversarial: tries to smuggle Shen-derived flags into the AI fact file.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]

    [term feedback known]
    [term improved-performance known]
    [claim c1 causal feedback improved-performance]
    [mechanism c1 learning-from-results]
    [modality c1 possible]
    [scope c1 conditional]

    [missing-context c1 feedback-is-reliable-enough]
    [clear-enough p1]
  ])
