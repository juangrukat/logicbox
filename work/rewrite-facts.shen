\\ AI-produced rewrite-derived facts for work/rewrite.md — smart cooling mandate, tightened.
\\ Do not put derived flags here. Shen derives flags from these facts.

(set *facts*
  [
    [rewrite-claim r-c1 deontic-recommendation city mandate-smart-cooling]
    [rewrite-modality r-c1 deontic-recommendation]
    [rewrite-scope r-c1 conditional]

    \\ ── Strengthened definitions (were unknown, now known) ──

    [term safe-apartments-during-heat known]
    [definition safe-apartments-during-heat "apartments where indoor temperature stays below the health-safety threshold, monitored by sensors that trigger alerts when crossed"]

    [term prioritize-repairs known]
    [definition prioritize-repairs "the system ranks cooling failures by health urgency — apartments exceeding the safety threshold first — rather than by landlord preference"]

    [term small-landlords known]
    [definition small-landlords "landlords who own fewer than 10 units and lack capital reserves for large capital upgrades"]

    [term retaliation known]
    [definition retaliation "any landlord action penalizing a tenant for reporting unsafe temperatures: eviction, rent increase, lease non-renewal, service reduction, or harassment"]

    [term necessary-response known]
    [definition necessary-response "a measure required because extreme heat is intensifying, older buildings retain heat, and smart cooling uniquely detects dangerous indoor conditions before illness occurs — no other existing measure provides this capability"]

    [term mandate-too-expensive known]
    [definition mandate-too-expensive "installation and annual maintenance costs that exceed what typical building operating budgets can absorb without financial assistance"]

    [term anti-retaliation-rules known]
    [definition anti-retaliation-rules "annual audit comparing buildings with and without smart cooling; if statistically significant increase in eviction or rent-increase rates, enforcement pauses and a 60-day public investigation follows"]

    \\ ── Surfaced value criteria (were unspecified, now explicit) ──

    [term fair known]
    [definition fair "tenants control their data, can opt out of non-emergency monitoring without losing emergency protection, and are protected from retaliation"]

    [term practical known]
    [definition practical "landlord costs are subsidized at a rate comparable to the Fire Code Assistance Program (up to 70%), with a higher rate for small landlords, following a proven public-health subsidy model"]

    \\ ── Strengthened context ──

    [context-known subsidy-funding-available known]

    \\ ── Preserved structural claims ──

    [rewrite-claim r-g1 causal extreme-heat health-danger]
    [rewrite-modality r-g1 probable]
    [rewrite-scope r-g1 citywide]

    [rewrite-claim r-g2 causal older-buildings heat-retention]
    [rewrite-modality r-g2 probable]
    [rewrite-scope r-g2 large-apartment-buildings]

    [rewrite-claim r-g3 causal heat-retention unsafe-indoor-temps]
    [rewrite-modality r-g3 probable]
    [rewrite-scope r-g3 large-apartment-buildings]

    [rewrite-claim r-g4 causal unsafe-indoor-temps heat-related-illness]
    [rewrite-modality r-g4 probable]
    [rewrite-scope r-g4 large-apartment-buildings]

    [rewrite-claim r-g5 enables smart-cooling-system detect-unsafe-temps]
    [rewrite-modality r-g5 probable]
    [rewrite-scope r-g5 large-apartment-buildings]

    [rewrite-claim r-g6 enables smart-cooling-system prevent-heat-illness]
    [rewrite-modality r-g6 probable]
    [rewrite-scope r-g6 large-apartment-buildings]

    [rewrite-claim r-g7 prevents tenant-privacy privacy-protected]
    [rewrite-modality r-g7 deontic-requirement]
    [rewrite-scope r-g7 large-apartment-buildings]

    [rewrite-claim r-g8 enables opt-out tenant-control]
    [rewrite-modality r-g8 deontic-requirement]
    [rewrite-scope r-g8 large-apartment-buildings]

    [rewrite-claim r-g9 enables landlord-subsidies cost-manageable]
    [rewrite-modality r-g9 probable]
    [rewrite-scope r-g9 large-apartment-buildings]

    [rewrite-claim r-g10 prevents audit-enforcement prevents-rent-eviction-harm]
    [rewrite-modality r-g10 probable]
    [rewrite-scope r-g10 large-apartment-buildings]
  ])
