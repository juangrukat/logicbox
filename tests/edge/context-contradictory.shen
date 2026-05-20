(set *facts*
  [
    [plan p1]
    [plan-source p1 edge-context]
    [plan-goal p1 contradictory-contexts]
    [context-known all-users-experts known]
    [context-known most-users-novices known]
    [context-incompatible all-users-experts most-users-novices]
  ])
