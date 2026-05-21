\\ AI-produced candidate facts for work/draft.txt — smart cooling mandate.
\\ Do not put derived flags here. Shen derives flags from these facts.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]
    [plan-fact p1 f-recommendation]
    [plan-fact p1 f-problem]
    [plan-fact p1 f-boundaries]
    [plan-fact p1 f-objection]
    [plan-fact p1 f-equity]
    [plan-fact p1 f-conclusion]
    [plan-context p1 privacy-rules-enforceable]
    [plan-context p1 subsidy-funding-available]
    [plan-context p1 large-building-threshold-defined]
    [plan-context p1 audit-data-collected]
    [plan-check p1 definition-needed]
    [plan-check p1 value-criteria-needed]
    [plan-check p1 missing-mechanism]
    [plan-check p1 missing-context]
    [plan-check p1 claim-without-ground]
    [plan-check p1 mitigation-needs-sufficiency-check]
    [comment p1 "Recommends mandating smart cooling in large apartment buildings for heat waves, conditional on tenant privacy and landlord subsidies. Claims necessity from heat danger and building heat retention, practicality from fire-safety subsidy precedent, fairness from privacy rules, opt-out, and anti-retaliation guardrails."]

    \\ ── Defined terms ──

    [term smart-cooling-system known]
    [definition smart-cooling-system "building-wide temperature monitoring and cooling management system for heat waves"]

    [term large-apartment-buildings known]
    [definition large-apartment-buildings "apartment buildings above a defined unit-count or square-footage threshold"]

    [term extreme-heat known]
    [definition extreme-heat "outdoor temperatures that pose a health risk, especially for vulnerable residents"]

    [term heat-retention known]
    [definition heat-retention "older buildings absorb heat during the day and release it slowly overnight, keeping indoor temperatures high"]

    [term unsafe-indoor-temps known]
    [definition unsafe-indoor-temps "indoor temperatures that exceed health-safety thresholds, risking heat exhaustion or heat stroke"]

    [term heat-related-illness known]
    [definition heat-related-illness "illness caused by prolonged exposure to high temperatures, including heat exhaustion and heat stroke"]

    [term tenant-privacy known]
    [definition tenant-privacy "protection against recording, tracking, or sharing apartment-level data without tenant knowledge or consent"]

    [term landlord-subsidies known]
    [definition landlord-subsidies "city financial assistance to offset the cost of installing and maintaining smart cooling systems"]

    [term fire-safety-subsidies known]
    [definition fire-safety-subsidies "existing city programs that subsidize fire-safety upgrades such as sprinklers and alarms"]

    [term opt-out known]
    [definition opt-out "tenants can decline non-emergency monitoring while remaining protected during emergencies"]

    [term data-transparency known]
    [definition data-transparency "tenants are told what data the system collects and how it is used"]

    [term audit-data known]
    [definition audit-data "statistical comparison of eviction and rent-increase rates in buildings with and without smart cooling"]

    \\ ── Undefined terms (writer concepts) ──

    [term safe-apartments-during-heat unknown]
    [definition safe-apartments-during-heat "apartments where indoor temperatures stay below health-risk thresholds during heat waves"]

    [term prioritize-repairs unknown]
    [definition prioritize-repairs "the system ranks cooling equipment failures by health urgency rather than landlord convenience"]

    [term small-landlords unknown]
    [definition small-landlords "landlords who own fewer units and may lack capital reserves for large upgrades"]

    [term retaliation unknown]
    [definition retaliation "landlord action against a tenant for reporting unsafe temperatures, such as eviction, rent increase, or harassment"]

    \\ ── Value terms (conclusions) ──

    [term fair unknown]
    [definition fair "the mandate protects tenant privacy, gives tenants control via opt-out, and prevents retaliation against tenants who report unsafe conditions"]

    [term practical unknown]
    [definition practical "the mandate is affordable for landlords because subsidies exist and a fire-safety precedent demonstrates feasibility"]

    [term necessary-response unknown]
    [definition necessary-response "extreme heat is rising, buildings trap heat, and smart cooling is a direct intervention to prevent illness that other measures do not provide"]

    \\ ── Main recommendation (typed with scope fields) ──

    [term c1 claim]
    [agent c1 city]
    [action c1 mandate]
    [target c1 smart-cooling-system]
    [location c1 large-apartment-buildings]
    [timeframe c1 next-heat-season]
    [modality c1 deontic-recommendation]
    [scope-status c1 conditional]

    \\ ── Scope conditions ──

    [term c2 claim]
    [agent c2 city]
    [action c2 require]
    [target c2 tenant-privacy]
    [applies-to c2 c1]

    [term c3 claim]
    [agent c3 city]
    [action c3 provide]
    [target c3 landlord-subsidies]
    [applies-to c3 c1]

    \\ ── Ground claims: problem diagnosis ──

    [ground-claim g1 extreme-heat health-danger]
    [term health-danger known]
    [definition health-danger "risk of heat-related illness and death, especially for elderly and medically vulnerable residents"]
    [modality g1 probable]
    [claim c-g1 causal extreme-heat health-danger]
    [mechanism c-g1 body-temperature-overload]
    [term body-temperature-overload known]
    [definition body-temperature-overload "prolonged heat exposure overwhelms the body's ability to cool itself"]
    [modality c-g1 probable]
    [scope c-g1 citywide]

    [ground-claim g2 older-buildings heat-retention]
    [modality g2 probable]
    [claim c-g2 causal older-buildings heat-retention]
    [mechanism c-g2 thermal-mass-absorption]
    [term thermal-mass-absorption known]
    [definition thermal-mass-absorption "building materials absorb daytime heat and radiate it indoors through the night"]
    [modality c-g2 probable]
    [scope c-g2 large-apartment-buildings]

    [ground-claim g3 heat-retention unsafe-indoor-temps]
    [modality g3 probable]
    [claim c-g3 causal heat-retention unsafe-indoor-temps]
    [mechanism c-g3 overnight-heat-buildup]
    [term overnight-heat-buildup known]
    [definition overnight-heat-buildup "without adequate ventilation or cooling, retained heat keeps indoor temperatures above safety thresholds"]
    [modality c-g3 probable]
    [scope c-g3 large-apartment-buildings]

    [ground-claim g4 unsafe-indoor-temps heat-related-illness]
    [modality g4 probable]
    [claim c-g4 causal unsafe-indoor-temps heat-related-illness]
    [mechanism c-g4 sustained-exposure]
    [term sustained-exposure known]
    [definition sustained-exposure "residents spend hours in unsafe temperatures, especially overnight when they cannot leave"]
    [modality c-g4 probable]
    [scope c-g4 large-apartment-buildings]

    \\ ── Ground claims: what smart cooling does ──

    [ground-claim g5 smart-cooling-system detect-unsafe-temps]
    [term detect-unsafe-temps known]
    [definition detect-unsafe-temps "identify apartments where indoor temperature exceeds health-safety thresholds"]
    [modality g5 probable]
    [claim c-g5 enables smart-cooling-system detect-unsafe-temps]
    [mechanism c-g5 sensor-threshold-alerts]
    [term sensor-threshold-alerts known]
    [definition sensor-threshold-alerts "temperature sensors trigger alerts when readings cross a predefined safety limit"]
    [modality c-g5 probable]
    [scope c-g5 large-apartment-buildings]

    [ground-claim g6 smart-cooling-system prevent-heat-illness]
    [term prevent-heat-illness known]
    [definition prevent-heat-illness "reduce incidence of heat-related illness through early detection and intervention"]
    [modality g6 probable]
    [claim c-g6 enables smart-cooling-system prevent-heat-illness]
    [mechanism c-g6 early-warning-response]
    [term early-warning-response known]
    [definition early-warning-response "alerts enable cooling activation, repair dispatch, or tenant relocation before illness occurs"]
    [modality c-g6 probable]
    [scope c-g6 large-apartment-buildings]

    \\ ── Ground claims: safeguards ──

    [ground-claim g7 tenant-privacy privacy-protected]
    [term privacy-protected known]
    [definition privacy-protected "no conversation recording, no movement tracking, no apartment-level data shared with landlords except in immediate safety emergencies"]
    [modality g7 deontic-requirement]
    [claim c-g7 prevents tenant-privacy privacy-protected]
    [mechanism c-g7 data-minimization-rules]
    [term data-minimization-rules known]
    [definition data-minimization-rules "the system collects only temperature data, deletes non-safety data after the heat season, and restricts landlord access to emergency-only"]
    [modality c-g7 probable]
    [scope c-g7 large-apartment-buildings]

    [ground-claim g8 opt-out tenant-control]
    [term tenant-control known]
    [definition tenant-control "tenants can decline non-emergency monitoring while remaining protected during emergency heat conditions"]
    [modality g8 deontic-requirement]
    [claim c-g8 enables opt-out tenant-control]
    [mechanism c-g8 consent-toggle]
    [term consent-toggle known]
    [definition consent-toggle "each tenant can independently enable or disable non-emergency data collection"]
    [modality c-g8 probable]
    [scope c-g8 large-apartment-buildings]

    [ground-claim g9 landlord-subsidies cost-manageable]
    [term cost-manageable known]
    [definition cost-manageable "installation and maintenance costs are affordable for landlords because city subsidies offset the expense"]
    [modality g9 probable]
    [claim c-g9 enables landlord-subsidies cost-manageable]
    [mechanism c-g9 subsidy-offsets-installation]
    [term subsidy-offsets-installation known]
    [definition subsidy-offsets-installation "direct financial assistance reduces the upfront and ongoing costs to a manageable level"]
    [modality c-g9 probable]
    [scope c-g9 large-apartment-buildings]
    [context-required c-g9 subsidy-funding-available]
    [context-known subsidy-funding-available unknown]

    [ground-claim g10 audit-enforcement prevents-rent-eviction-harm]
    [term audit-enforcement known]
    [definition audit-enforcement "city monitors eviction and rent-increase rates and pauses enforcement if rates rise"]
    [term prevents-rent-eviction-harm known]
    [definition prevents-rent-eviction-harm "the policy does not lead to rent hikes, evictions, or retaliation against tenants"]
    [modality g10 probable]
    [claim c-g10 prevents audit-enforcement prevents-rent-eviction-harm]
    [mechanism c-g10 enforcement-pause-trigger]
    [term enforcement-pause-trigger known]
    [definition enforcement-pause-trigger "if audit shows higher eviction or rent-increase rates, enforcement stops and investigation begins"]
    [modality c-g10 probable]
    [scope c-g10 large-apartment-buildings]

    \\ ── Ground claims: external pressure ──

    [term r1 reason]
    [reason-type r1 competitive-pressure]
    [outcome r1 city-should-not-fall-behind]
    [supports r1 c1]
    [term other-cities-piloting known]
    [definition other-cities-piloting "other cities are currently testing heat-risk monitoring and cooling technology"]

    [term r2 reason]
    [reason-type r2 tenant-preference]
    [outcome r2 tenants-want-heat-safety]
    [supports r2 c1]
    [term tenants-want-heat-safety known]
    [definition tenants-want-heat-safety "most tenants want safer apartments during extreme heat events"]

    \\ ── Objection ──

    [term o1 objection]
    [impact-type o1 cost-burden]
    [affected-group o1 landlords]
    [risks o1 mandate-too-expensive]
    [objects-to o1 c1]
    [term mandate-too-expensive unknown]
    [definition mandate-too-expensive "the cost of installing and maintaining smart cooling systems would be an unreasonable burden"]

    \\ ── Mitigations ──

    [term m1 mitigation]
    [mitigates m1 o1]
    [reason-type m1 subsidy-precedent]
    [term subsidy-precedent known]
    [definition subsidy-precedent "the city already subsidizes fire-safety upgrades; heat safety is comparable in public health importance"]
    [term heat-safety-parity known]
    [definition heat-safety-parity "heat safety should receive the same financial treatment as fire safety because both are building-related public health risks"]
    [analogizes-from m1 fire-safety-subsidies]
    [analogizes-to m1 landlord-subsidies]
    [sufficiency m1 shown]

    [term m2 mitigation]
    [mitigates m2 o1]
    [reason-type m2 targeted-relief]
    [term small-landlord-concern acknowledged]
    [sufficiency m2 shown]

    \\ ── Equity guardrails ──

    [term e1 exemption]
    [exempts e1 anti-retaliation-rules]
    [affected-group e1 tenants]
    [risks e1 rent-hikes-and-evictions]
    [action e1 pause-enforcement]
    [target e1 smart-cooling-system]
    [scope-status e1 conditional]
    [term anti-retaliation-rules unknown]
    [definition anti-retaliation-rules "protections against rent hikes, evictions, or retaliation for tenants who report unsafe temperatures"]

    \\ ── Conclusions ──

    [conclusion k1 fair]
    [modality k1 probable]
    [conclusion k2 practical]
    [modality k2 probable]
    [conclusion k3 necessary-response]
    [modality k3 probable]

    \\ ── Inference links ──

    [infers-to g7 k1]
    [infers-to g8 k1]
    [infers-to g10 k1]
    [infers-to g9 k2]
    [infers-to m1 k2]
    [infers-to g1 k3]
    [infers-to g3 k3]
    [infers-to g4 k3]
    [infers-to g6 k3]
    [supports r1 k2]
    [supports r2 k3]

    \\ ── Scope facts for plan ──

    [fact-scope f-recommendation local]
    [fact-scope f-problem local]
    [fact-scope f-boundaries local]
    [fact-scope f-objection local]
    [fact-scope f-equity local]
    [fact-scope f-conclusion local]
  ])
