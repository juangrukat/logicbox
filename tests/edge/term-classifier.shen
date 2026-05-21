(set *facts*
  [
    [plan p1]
    [plan-source p1 edge-term-classifier]
    [plan-goal p1 split-unknown-term-classes]

    [term nurse-confirmation unknown]
    [term patients-told unknown]
    [term ai-triage-is-safe unknown]
    [term responsible-improvement unknown]

    [decomposition-candidate patients-told]
    [value-criteria-candidate ai-triage-is-safe safety]
    [value-criteria-candidate responsible-improvement responsibility]
  ])
