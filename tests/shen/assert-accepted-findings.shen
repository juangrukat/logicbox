\\ Assertions for findings emitted directly from an accepted artifact.

(define accepted-findings-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(load "findings.shen")

(accepted-findings-assert-equal findings
  (logicbox-artifact-kind (value *logicbox-artifact*))
  accepted-findings-kind)
(accepted-findings-assert-equal schema-v1
  (logicbox-artifact-schema (value *logicbox-artifact*))
  accepted-findings-schema)
(accepted-findings-assert-equal
  [[plan-status p1 ready-for-final-rewrite]]
  (logicbox-artifact-payload (value *logicbox-artifact*))
  accepted-findings-payload)
