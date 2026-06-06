\\ Assertions for valid schema and analysis stage artifacts.

(define stage-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(define stage-member?
  _ [] -> false
  X [X | _] -> true
  X [_ | Rest] -> (stage-member? X Rest))

(load "accepted.shen")
(set *stage-accepted* (value *logicbox-artifact*))
(load "diagnostics.shen")
(set *stage-diagnostics* (value *logicbox-artifact*))
(load "findings.shen")
(set *stage-findings* (value *logicbox-artifact*))

(stage-assert-equal accepted
  (logicbox-artifact-kind (value *stage-accepted*))
  valid-accepted-kind)
(stage-assert-equal diagnostics
  (logicbox-artifact-kind (value *stage-diagnostics*))
  valid-diagnostics-kind)
(stage-assert-equal findings
  (logicbox-artifact-kind (value *stage-findings*))
  valid-findings-kind)
(stage-assert-equal schema-v1
  (logicbox-artifact-schema (value *stage-accepted*))
  valid-accepted-schema)
(stage-assert-equal schema-v1
  (logicbox-artifact-schema (value *stage-diagnostics*))
  valid-diagnostics-schema)
(stage-assert-equal schema-v1
  (logicbox-artifact-schema (value *stage-findings*))
  valid-findings-schema)
(stage-assert-equal true
  (stage-member?
    [claim c1 causal source target]
    (logicbox-artifact-payload (value *stage-accepted*)))
  valid-accepted-claim)
(stage-assert-equal
  (logicbox-pipeline-findings
    (logicbox-artifact-payload (value *stage-source*)))
  (logicbox-artifact-payload (value *stage-findings*))
  valid-findings-match-pipeline)
