(set *facts*
  [
    [plan p1]
    [plan-source p1 edge-scope]
    [plan-goal p1 hard-conflict]
    [plan-fact p1 f-global-feedback]
    [plan-fact p1 f-local-feedback]
    [term-definition f-global-feedback feedback]
    [fact-scope f-global-feedback global]
    [term-definition f-local-feedback feedback]
    [fact-scope f-local-feedback local]
    [not-equivalent f-global-feedback f-local-feedback]
    [scope-conflict-candidate f-global-feedback f-local-feedback]
    [scope-incompatible global local]
  ])
