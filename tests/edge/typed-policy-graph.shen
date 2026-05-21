(set *facts*
  [
    [plan p1]
    [plan-source p1 edge-typed-policy]
    [plan-goal p1 inspect-decomposed-policy-argument]
    [plan-claim p1 c1]

    [term c1 claim]
    [agent c1 city-government]
    [action c1 ban]
    [target c1 private-car-use]
    [location c1 downtown]
    [scope-status c1 underspecified]
    [timeframe c1 five-years]
    [modality c1 deontic-recommendation]

    [term r1 reason]
    [reason-type r1 environmental-impact]
    [outcome r1 reduced-air-pollution]
    [supports r1 c1]

    [term r2 reason]
    [reason-type r2 feasibility]
    [resource r2 buses]
    [resource r2 subway]
    [modality r2 feasibility]
    [supports r2 c1]

    [term o1 objection]
    [affected-group o1 poor-transit-neighborhoods]
    [objects-to o1 c1]

    [term o2 objection]
    [affected-group o2 night-shift-workers]
    [objects-to o2 c1]

    [term o3 objection]
    [impact-type o3 equity-impact]
    [affected-group o3 low-income-residents]
    [objects-to o3 c1]

    [term m1 mitigation]
    [policy-tool m1 transit-pass-subsidy]
    [mitigates m1 o3]

    [term e1 exception]
    [exempts e1 emergency-vehicles]
    [exempts e1 disabled-residents]
    [applies-to e1 c1]

    [term a1 analogy]
    [analogizes-from a1 other-cities]
    [analogizes-to a1 this-city]
    [supports a1 c1]

    [term p1-support popularity-claim]
    [content p1-support most-people-support-cleaner-air]
    [supports p1-support c1]
  ])
