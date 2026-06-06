\\ Assertions for schema-invalid stage artifacts.

(define invalid-stage-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(define invalid-stage-has-head?
  _ [] -> false
  Head [[Head | _] | _] -> true
  Head [_ | Rest] -> (invalid-stage-has-head? Head Rest))

(define invalid-stage-member?
  _ [] -> false
  X [X | _] -> true
  X [_ | Rest] -> (invalid-stage-member? X Rest))

(load "accepted.shen")
(set *invalid-stage-accepted* (value *logicbox-artifact*))
(load "diagnostics.shen")
(set *invalid-stage-diagnostics* (value *logicbox-artifact*))
(load "findings.shen")
(set *invalid-stage-findings* (value *logicbox-artifact*))

(invalid-stage-assert-equal []
  (logicbox-artifact-payload (value *invalid-stage-accepted*))
  invalid-accepted-empty)
(invalid-stage-assert-equal true
  (invalid-stage-has-head?
    fact-type-error
    (logicbox-artifact-payload (value *invalid-stage-findings*)))
  invalid-findings-have-type-error)
(invalid-stage-assert-equal true
  (invalid-stage-member?
    [plan-status p1 translation-error]
    (logicbox-artifact-payload (value *invalid-stage-findings*)))
  invalid-findings-have-plan-status)
(invalid-stage-assert-equal
  (logicbox-artifact-payload (value *invalid-stage-diagnostics*))
  (schema-diagnostics
    (logicbox-artifact-payload (value *stage-source*)))
  invalid-diagnostics-match-schema)
