(set *facts*
  [
    [plan p1]
    [plan-source p1 gold]
    [plan-goal p1 scope-conflict-positive]
    [plan-fact p1 f1]
    [plan-fact p1 f2]
    [fact-scope f1 global]
    [fact-scope f2 local]
    [scope-conflict-candidate f1 f2]
    [scope-incompatible global local]
  ])
