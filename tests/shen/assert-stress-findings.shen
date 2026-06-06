\\ Assert that dense stress fixtures exercise distinct rule families.

(define stress-member?
  _ [] -> false
  X [X | _] -> true
  X [_ | Rest] -> (stress-member? X Rest))

(define stress-require
  Fact Findings ->
    (if (stress-member? Fact Findings)
        true
        (simple-error (make-string "missing stress finding: ~S" Fact))))

(set *stress-artifact*
  (validate-logicbox-artifact
    (value *logicbox-artifact*)
    [findings]))
(set *stress-findings*
  (logicbox-artifact-payload (value *stress-artifact*)))

(if (= (value *stress-case*) policy)
    (do
      (stress-require [unclear-scope c1 location downtown]
        (value *stress-findings*))
      (stress-require [modality-mixed c1] (value *stress-findings*))
      (stress-require [unresolved-objection c1 o1]
        (value *stress-findings*))
      (stress-require [unresolved-objection c1 o2]
        (value *stress-findings*))
      (stress-require [mitigation-needs-sufficiency-check m1 o3]
        (value *stress-findings*))
      (stress-require [analogy-needs-comparability a1]
        (value *stress-findings*))
      (stress-require [popularity-weak-support p1-support c1]
        (value *stress-findings*))
      (stress-require [exception-boundary-needed e1]
        (value *stress-findings*))
      (stress-require [broad-ban-vs-exemptions c1 e1]
        (value *stress-findings*)))
    (do
      (stress-require
        [context-conflict all-users-experts most-users-novices]
        (value *stress-findings*))
      (stress-require [missing-stage-bridge c1 s1 s2]
        (value *stress-findings*))))
