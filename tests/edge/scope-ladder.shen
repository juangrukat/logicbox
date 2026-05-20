(set *facts*
  [
    [plan p1]
    [plan-source p1 edge-scope]
    [plan-goal p1 scope-ladder]
    [plan-fact p1 f1]
    [fact-scope f1 local]
    [scope-transition f1 local document]
    [scope-transition f1 document global]
    [scope-transition-invalid document global]
  ])
