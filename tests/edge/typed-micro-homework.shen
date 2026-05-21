(set *facts*
  [
    [plan p1]
    [plan-source p1 edge-typed-micro]
    [plan-goal p1 homework-micro-extraction]
    [plan-claim p1 c1]

    [term c1 claim]
    [agent c1 school-district]
    [action c1 reduce]
    [target c1 homework]
    [modality c1 deontic-recommendation]

    [term r1 reason]
    [reason-domain r1 wellbeing]
    [affected-group r1 students]
    [metric r1 stress]
    [direction r1 high]
    [supports r1 c1]
  ])
