\\ AI-produced candidate facts — three-day remote work policy.
\\ Do not put derived flags here. Shen derives flags from these facts.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]
    [plan-fact p1 f-recommendation]
    [plan-fact p1 f-problem]
    [plan-fact p1 f-implementation]
    [plan-fact p1 f-objection]
    [plan-fact p1 f-equity]
    [plan-fact p1 f-conclusion]
    [plan-context p1 collaboration-measured]
    [plan-context p1 client-responsiveness-measured]
    [plan-context p1 outcome-metrics-reliable]
    [plan-context p1 hr-guidelines-enforced]
    [plan-check p1 definition-needed]
    [plan-check p1 value-criteria-needed]
    [plan-check p1 missing-mechanism]
    [plan-check p1 missing-context]
    [plan-check p1 claim-without-ground]
    [plan-check p1 mitigation-needs-sufficiency-check]
    [comment p1 "Recommends three-day remote work conditional on collaboration and client responsiveness. Claims productivity, stress reduction, and retention benefits from reduced commute and office distraction. Guards against mentorship/onboarding/coordination loss with HR guidelines. Rebuts accountability objection with outcome measurement. Equity guardrails for workspace, internet, caregiving, and seniority gaps."]

    \\ ── Defined terms ──

    [term threeday known]
    [definition threeday "employees may work remotely three days per week"]

    [term commutewaste known]
    [definition commutewaste "commuting consumes time that could be used for work or recovery"]

    [term officedistract known]
    [definition officedistract "office noise, interruptions, and open-plan layouts reduce sustained concentration"]

    [term deepworkremote known]
    [definition deepworkremote "remote days provide uninterrupted blocks for cognitively demanding work"]

    [term moreprod known]
    [definition moreprod "employees complete more or higher-quality work"]

    [term lessstress known]
    [definition lessstress "reduced mental and emotional strain from work demands"]

    [term lessquit known]
    [definition lessquit "lower voluntary employee turnover"]

    [term teamnorms known]
    [definition teamnorms "managers set expectations for meetings, availability hours, and documentation practices"]

    [term hrguides known]
    [definition hrguides "company-wide remote-work guidelines"]
    [policy-rule hrguides uniform-rules]
    [policy-rule hrguides no-manager-exceptions]
    [user-supplied G4 hrguides]

    [term outcomemetric known]
    [definition outcomemetric "accountability measured by completed work, client outcomes, and team reliability, not office visibility"]

    [term trackedmetrics known]
    [definition trackedmetrics "project delivery, client satisfaction, and employee retention are already measured by the company"]

    [term othercosadopted known]
    [definition othercosadopted "other companies have adopted hybrid work and report successful outcomes"]

    [term employeesupport known]
    [definition employeesupport "most employees favor more remote flexibility"]

    \\ ── Undefined terms ──

    [term collabok known]
    [definition collabok "employees attend one required in-person team meeting every Wednesday"]

    [term clientok known]
    [definition clientok "all client messages receive a same-business-day response"]

    [term mentorshipweak known]
    [definition mentorshipweak "new employees must work in the office four days per week for their first six months"]

    [term onboardweak known]
    [definition onboardweak "new employees must work in the office four days per week for their first six months"]

    [term coordweak unknown]
    [definition coordweak "remote work impairs coordination and handoff between teams"]

    [term unfairnorms known]
    [definition unfairnorms "HR guidelines require all teams to use the same remote-work rules with no manager-level exceptions"]

    [term accountfear known]
    [definition accountfear "executives worry about productivity loss"]

    [term slackrule known]
    [policy-condition c1 slackrule]
    [rule-type slackrule availability]
    [availability-window slackrule workday]
    [response-time slackrule ten-minutes]
    [undermines slackrule deep-work]
    [user-supplied G3 slackrule]

    [term homespacegap unknown]
    [definition homespacegap "some employees lack quiet, private space at home for focused remote work"]

    [term netgap unknown]
    [definition netgap "some employees lack reliable high-speed internet for remote work"]

    [term caregap unknown]
    [definition caregap "some employees lack caregiving flexibility that makes remote work viable"]

    [term seniorgap unknown]
    [definition seniorgap "junior employees may lack the experience or relationships to work effectively without in-person guidance"]

    [term alternatives known]
    [definition alternatives "employees who cannot benefit from remote work may work from the office instead"]
    [mitigates alternatives equitygap]
    [mitigation-type alternatives office-fallback]
    [equivalence-status alternatives unknown]
    [user-supplied G5 alternatives]

    \\ ── Value terms ──

    [term fair unknown]
    [definition fair "the policy applies evenly via HR guidelines; employees who cannot benefit equally receive alternatives"]

    [term practical unknown]
    [definition practical "the policy has team norms and guidelines; other companies have done it; most employees support it"]

    [term necessaryresp known]
    [definition necessaryresp "the policy is necessary to address retention risk"]

    \\ ── Main recommendation ──

    [term c1 claim]
    [agent c1 company]
    [action c1 allow]
    [target c1 threeday]
    [population c1 all-employees]
    [benefit c1 deep-work]
    [benefit c1 employee-focus]
    [benefit c1 reduced-stress]
    [benefit c1 retention]
    [modality c1 deontic-recommendation]
    [scope-status c1 conditional]

    \\ ── Scope conditions ──

    [term c2 claim]
    [agent c2 company]
    [action c2 maintain]
    [target c2 collabok]
    [applies-to c2 c1]

    [term c3 claim]
    [agent c3 company]
    [action c3 maintain]
    [target c3 clientok]
    [applies-to c3 c1]

    \\ ── Ground claims: problem diagnosis ──

    [ground-claim g1 commutewaste burnout]
    [term burnout known]
    [definition burnout "employees are exhausted and disengaged from sustained work pressure, contributing to retention problems"]
    [modality g1 probable]
    [claim c-g1 causal commutewaste burnout]
    [mechanism c-g1 timetheft]
    [term timetheft known]
    [definition timetheft "commuting steals personal time that could be used for rest, exercise, or family, increasing cumulative stress"]
    [modality c-g1 probable]
    [scope c-g1 company]

    [ground-claim g2 officedistract focuslost]
    [term focuslost known]
    [definition focuslost "employees cannot sustain deep concentration due to office noise and interruptions"]
    [modality g2 probable]
    [claim c-g2 causal officedistract focuslost]
    [mechanism c-g2 openplaninterrupt]
    [term openplaninterrupt known]
    [definition openplaninterrupt "open-plan offices and ad-hoc interruptions fragment attention and prevent flow states"]
    [modality c-g2 probable]
    [scope c-g2 company]

    [ground-claim g3 deepworkremote moreprod]
    [modality g3 probable]
    [claim c-g3 enables deepworkremote moreprod]
    [mechanism c-g3 uninterruptedblocks]
    [term uninterruptedblocks known]
    [definition uninterruptedblocks "remote days provide extended periods without office interruptions for cognitively demanding work"]
    [modality c-g3 probable]
    [scope c-g3 company]

    \\ ── Ground claims: benefits ──

    [ground-claim g4 threeday lessstress]
    [modality g4 probable]
    [claim c-g4 enables threeday lessstress]
    [mechanism c-g4 commutereduction]
    [term commutereduction known]
    [definition commutereduction "eliminating three days of commuting per week returns significant time for recovery and personal life"]
    [modality c-g4 probable]
    [scope c-g4 company]

    [ground-claim g5 threeday lessquit]
    [modality g5 probable]
    [claim c-g5 enables threeday lessquit]
    [mechanism c-g5 flexibilityretention]
    [term flexibilityretention known]
    [definition flexibilityretention "remote flexibility is a valued benefit that reduces the incentive to leave for more flexible employers"]
    [modality c-g5 probable]
    [scope c-g5 company]

    \\ ── Ground claims: implementation guardrails ──

    [ground-claim g6 hrguides prevents-unfairness]
    [term prevents-unfairness known]
    [definition prevents-unfairness "company-wide guidelines prevent different managers from creating inconsistent or confusing remote-work norms"]
    [modality g6 deontic-requirement]

    [ground-claim g10 teamnorms practical-structure]
    [term practical-structure known]
    [definition practical-structure "team-level norms for meetings, availability, and documentation provide operational scaffolding for the policy"]
    [modality g10 probable]

    [ground-claim g11 newoffice prevents-mentorship-loss]
    [term newoffice known]
    [definition newoffice "new employees work in the office four days per week for their first six months"]
    [group-rule newoffice new-employees]
    [required-location newoffice office]
    [required-office-days newoffice four-days-per-week]
    [duration newoffice six-months]
    [exception-rule newoffice]
    [exception-group newoffice new-employees]
    [exception-to newoffice c1]
    [conflicts-with-target newoffice threeday]
    [user-supplied G7 newoffice]
    [term prevents-mentorship-loss known]
    [definition prevents-mentorship-loss "requiring office presence for new employees protects mentorship, onboarding, and skill transfer"]
    [modality g11 deontic-requirement]

    \\ ── Ground claims: scope conditions ──

    [ground-claim g12 wednesday-meeting collabok]
    [modality g12 deontic-requirement]

    [ground-claim g13 sameday-response clientok]
    [modality g13 deontic-requirement]

    \\ ── Ground claims: necessity evidence ──

    [ground-claim g14 quitrisk mustremote]
    [term quitrisk known]
    [definition quitrisk "employees will leave if the company does not offer more remote flexibility"]
    [counterfactual quitrisk]
    [evidence-status quitrisk unknown]
    [user-supplied G6 quitrisk]
    [term mustremote known]
    [definition mustremote "the three-day remote policy is necessary to prevent attrition"]
    [modality g14 probable]
    [claim c-g14 causal quitrisk mustremote]
    [mechanism c-g14 retention-mechanism]
    [term retention-mechanism known]
    [definition retention-mechanism "remote flexibility is a benefit that competing employers offer; without it, employees have an incentive to leave"]
    [modality c-g14 probable]
    [scope c-g14 company]

    \\ ── Ground claims: accountability rebuttal ──

    [ground-claim g7 outcomemetric answerfear]
    [term answerfear known]
    [definition answerfear "measuring by outcomes rather than visibility addresses the concern that remote work reduces accountability"]
    [modality g7 probable]
    [claim c-g7 enables outcomemetric answerfear]
    [mechanism c-g7 outcomevsvisibility]
    [term outcomevsvisibility known]
    [definition outcomevsvisibility "switching from visibility-based oversight to outcome-based measurement reveals actual accountability"]
    [modality c-g7 probable]
    [scope c-g7 company]

    [ground-claim g8 trackedmetrics enablecheck]
    [term enablecheck known]
    [definition enablecheck "the company can evaluate the policy because it already tracks project delivery, client satisfaction, and employee retention"]
    [modality g8 probable]
    [claim c-g8 enables trackedmetrics enablecheck]
    [mechanism c-g8 existingdata]
    [term existingdata known]
    [definition existingdata "pre-existing metrics provide a baseline and ongoing measurement without new instrumentation"]
    [modality c-g8 probable]
    [scope c-g8 company]

    \\ ── Ground claims: equity ──

    [ground-claim g9 alternatives protects-gapgroups]
    [term protects-gapgroups known]
    [definition protects-gapgroups "employees who cannot benefit equally from remote work are not disadvantaged"]
    [modality g9 deontic-requirement]

    \\ ── Ground claims: external support ──

    [term r1 reason]
    [reason-type r1 precedent]
    [outcome r1 company-can-adopt]
    [supports r1 c1]

    [term r2 reason]
    [reason-type r2 stakeholder-support]
    [outcome r2 employeesupport]
    [supports r2 c1]

    \\ ── Objection ──

    [term o1 objection]
    [impact-type o1 accountability-risk]
    [affected-group o1 executives]
    [risks o1 accountfear]
    [objects-to o1 c1]

    \\ ── Rebuttals ──

    [term m1 rebuttal]
    [rebuts m1 o1]
    [reason-type m1 measurement-correction]
    [sufficiency m1 shown]

    [term m2 rebuttal]
    [rebuts m2 o1]
    [reason-type m2 existing-evidence]
    [term othercosresults known]
    [definition othercosresults "other companies have adopted hybrid work and report maintained or improved accountability"]
    [sufficiency m2 shown]

    \\ ── Equity provisions ──

    [term e1 exemption]
    [exempts e1 equitygap]
    [affected-group e1 homespacegap]
    [affected-group e1 netgap]
    [affected-group e1 caregap]
    [affected-group e1 seniorgap]
    [action e1 provide-alternatives]
    [target e1 threeday]
    [scope-status e1 conditional]
    [term equitygap known]
    [definition equitygap "employees who lack quiet space, reliable internet, caregiving flexibility, or seniority may work from the office instead"]

    \\ ── Conclusions ──

    [conclusion k1 fair]
    [modality k1 probable]
    [conclusion k2 practical]
    [modality k2 probable]
    [conclusion k3 necessaryresp]
    [value-type k3 necessity]
    [criteria-status k3 grounded]
    [necessity-ground k3 quitrisk]
    [modality k3 probable]

    \\ ── Inference links ──

    [infers-to g6 k1]
    [infers-to g9 k1]
    [infers-to g11 k1]
    [infers-to g10 k2]
    [supports r1 k2]
    [supports r2 k2]
    [infers-to g1 k3]
    [infers-to g2 k3]
    [infers-to g4 k3]
    [infers-to g5 k3]
    [infers-to g14 k3]

    \\ ── Scope facts for plan ──

    [fact-scope f-recommendation local]
    [fact-scope f-problem local]
    [fact-scope f-implementation local]
    [fact-scope f-objection local]
    [fact-scope f-equity local]
    [fact-scope f-conclusion local]
  ])
