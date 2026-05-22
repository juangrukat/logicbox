(set *facts*
  [
    [plan p1]
    [plan-claim p1 c1]
    [plan-conclusion p1 k1]

    [term c1 claim]
    [target c1 transitpass]

    [requires c1 equivalent-transit-benefit]
    [denies no-separate-benefit equivalent-transit-benefit]

    [prohibits c1 triptracking]
    [requires c1 idscan]
    [implies idscan triptracking]

    [identical-treatment fairness]
    [requires-equitable-treatment fairness]
    [value-definition fair same-transit-pass]
    [identical-treatment same-transit-pass]
    [conflicts same-transit-pass protectedaccess]
    [benefit c1 protectedgroups]
    [undermines nontransitfair protectedgroups]

    [conclusion k1 necessaryconclusion]
    [ground-claim g1 transitpass necessaryconclusion]
    [infers-to g1 k1]
    [necessity-ground k1 parking-counterfactual]
    [counterfactual parking-counterfactual]
    [evidence-status parking-counterfactual unknown]
  ])
