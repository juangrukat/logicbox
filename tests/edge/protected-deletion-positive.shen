(set *facts*
  [
    [term c1 claim]
    [action c1 deploy]
    [target c1 ai-scheduling-assistant]
    [protected c1 main-claim]

    [term c2 claim]
    [action c2 maintain]
    [target c2 patient-coverage]
    [applies-to c2 c1]
    [protected c2 core-condition]

    [term c3 claim]
    [action c3 maintain]
    [target c3 nurse-fairness]
    [applies-to c3 c1]
    [protected c3 core-condition]

    [term c4 claim]
    [action c4 maintain]
    [target c4 emergency-staffing]
    [applies-to c4 c1]
    [protected c4 core-condition]

    [rewrite-status placeholder-only marked-unresolved]
  ])
