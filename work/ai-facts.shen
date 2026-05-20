\\ AI-produced candidate facts for work/draft.txt.
\\ Do not put derived flags here. Shen derives flags from these facts.

(set *facts*
  [
    [plan p1]
    [plan-source p1 draft-1]
    [plan-goal p1 clarify-argument]
    [plan-fact p1 f-result-responsive-practice]
    [plan-fact p1 f-better-outcomes]
    [plan-fact p1 f-feedback]
    [plan-context p1 feedback-is-reliable-enough]
    [plan-context p1 actor-can-change-future-actions]
    [plan-check p1 undefined-term]
    [plan-check p1 missing-mechanism]
    [plan-check p1 missing-context]
    [plan-check p1 stage-chain-too-short]
    [comment p1 "The paragraph argues that result-responsive practice improves outcomes through feedback-guided correction."]

    [term daily-self-questioning known]
    [definition daily-self-questioning "making a daily habit of questioning one's own thinking"]

    [term result-based-behavior-adjustment known]
    [definition result-based-behavior-adjustment "adjusting behavior based on real-world results"]

    [term result-responsive-practice known]
    [definition result-responsive-practice "daily questioning of one's thinking combined with behavior adjustment based on real-world results"]

    [term real-world-results known]
    [definition real-world-results "observable practical outcomes rather than wishes, assumptions, or self-image"]

    [term better-outcomes known]
    [definition better-outcomes "better results in health, finances, and life satisfaction"]

    [term health known]
    [definition health "physical and mental well-being"]

    [term finances known]
    [definition finances "financial stability and practical money outcomes"]

    [term life-satisfaction known]
    [definition life-satisfaction "subjective well-being and satisfaction with one's life"]

    [term non-result-responsive-people known]
    [definition non-result-responsive-people "people who do not regularly question their own thinking or adjust behavior based on results"]

    [term early-problem-detection known]
    [definition early-problem-detection "noticing small problems before they compound"]

    [term effort-reallocation known]
    [definition effort-reallocation "redirecting time, attention, or energy away from ineffective routines"]

    [term low-cost-correction known]
    [definition low-cost-correction "changing course while the practical or emotional cost of correction is still relatively low"]

    [term better-choice-making known]
    [definition better-choice-making "selecting future actions with better information from previous results"]

    [term compounding-problems known]
    [definition compounding-problems "small problems becoming larger or harder to fix over time"]

    [claim c1 practical-outperformance result-responsive-practice non-result-responsive-people]
    [mechanism c1 early-problem-detection]
    [modality c1 probable]
    [scope c1 conditional]

    [claim c2 produces result-responsive-practice better-outcomes]
    [mechanism c2 effort-reallocation]
    [modality c2 probable]
    [scope c2 conditional]

    [ground-claim g1 result-responsive-practice better-choice-making]
    [modality g1 probable]
    [conclusion k1 better-outcomes]
    [modality k1 probable]
    [infers-to g1 k1]

    [context-required c2 feedback-is-reliable-enough]
    [context-known feedback-is-reliable-enough known]
    [context-required c2 actor-can-change-future-actions]
    [context-known actor-can-change-future-actions known]

    [stage-chain-min c2 3]
    [stage s1 observe-results]
    [stage-of s1 c2]
    [stage-order s1 1]
    [stage s2 identify-ineffective-routines]
    [stage-of s2 c2]
    [stage-order s2 2]
    [stage s3 redirect-effort]
    [stage-of s3 c2]
    [stage-order s3 3]
    [stage-bridge s1 s2 real-world-feedback]
    [stage-bridge s2 s3 effort-reallocation]
    [stage-next c2 s1 s2]
    [stage-next c2 s2 s3]

    [fact-scope f-result-responsive-practice local]
    [fact-scope f-better-outcomes local]
    [fact-scope f-feedback local]

    [claim p1 prevents early-problem-detection compounding-problems]
    [mechanism p1 low-cost-correction]
    [modality p1 probable]
    [scope p1 conditional]

    [claim p2 enables result-responsive-practice effort-reallocation]
    [term real-world-feedback known]
    [definition real-world-feedback "information from actual outcomes that shows whether a routine is working"]
    [mechanism p2 real-world-feedback]
    [modality p2 probable]
    [scope p2 conditional]

    [claim p3 enables result-responsive-practice better-choice-making]
    [mechanism p3 real-world-feedback]
    [modality p3 probable]
    [scope p3 conditional]
  ])
