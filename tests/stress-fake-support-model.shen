\\ Adversarial: tries to support a conclusion with an unknown ground claim.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]

    [term ai-use known]
    [term destroyed-judgment known]

    [ground-claim g1 unknown unknown]
    [modality g1 possible]
    [conclusion k1 destroyed-judgment]
    [modality k1 certain]
    [infers-to g1 k1]
    [stronger-than certain possible]
  ])
