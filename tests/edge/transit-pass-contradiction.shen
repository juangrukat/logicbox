(set *facts*
  [
    [plan p1]
    [plan-claim p1 c1]
    [plan-conclusion p1 k1]

    [term c1 claim]
    [target c1 transitpass]

    [requires-equivalent-benefit transitgap]
    [mitigation-type transitgap equivalent-benefit-fallback]
    [denies-equivalent-benefit transitgap]

    [no-trip-tracking privacy]
    [id-scan-verification privacy]

    [identical-treatment fairness]
    [requires-equitable-treatment fairness]

    [conclusion k1 necessaryconclusion]
    [ground-claim g1 transitpass necessaryconclusion]
    [infers-to g1 k1]
    [necessity-ground k1 parking-counterfactual]
    [counterfactual parking-counterfactual]
    [evidence-status parking-counterfactual unknown]
  ])
