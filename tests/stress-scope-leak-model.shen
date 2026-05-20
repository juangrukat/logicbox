\\ Adversarial: tries to mix local and global facts without admitting the scope clash.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]
    [plan-fact p1 f-global-feedback]
    [plan-fact p1 f-local-feedback]
    [plan-fact p1 f-unscoped-claim]

    [term feedback known]
    [term improved-performance known]

    [term-definition f-global-feedback feedback]
    [definition f-global-feedback "information from actual outcomes"]
    [fact-scope f-global-feedback global]

    [term-definition f-local-feedback feedback]
    [definition f-local-feedback "approval from a nearby audience"]
    [fact-scope f-local-feedback local]

    [not-equivalent f-global-feedback f-local-feedback]
    [scope-conflict-candidate f-global-feedback f-local-feedback]
    [scope-incompatible global local]

    [claim c1 causal feedback improved-performance]
    [mechanism c1 unknown]
    [modality c1 possible]
    [scope c1 conditional]
  ])
