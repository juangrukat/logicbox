(set *facts*
  [
    [plan p1]
    [plan-source p1 adapter-layer]
    [plan-goal p1 adapter-temporary-cleared]
    [plan-claim p1 c1]
    [plan-conclusion p1 k3]

    [term c1 claim]
    [target c1 aistudyplans]
    [requires c1 equivalentplanningsupport]
    [prohibits c1 privatestudymonitoring]
    [requires c1 voluntarytaskcompletion]
    [benefit c1 studentcontrol]
    [benefit c1 protectedstudentaccess]
    [safeguard advisorjudgment]

    [conclusion k3 justifiedconclusion]
    [ground-claim g1 firstyearconfusion justifiedconclusion]
    [infers-to g1 k3]

    [adapter-fact a1]
    [adapter-source a1 ai-semantic-bridge]
    [adapter-scope a1 current-run]
    [adapter-status a1 temporary]
    [implies voluntarytaskcompletion taskprogresssignal]
  ])
