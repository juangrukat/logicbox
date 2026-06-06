\\ Assertions for schema-gated mutation diagnostics.

(define mutation-diagnostics-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(define mutation-diagnostics-has-head?
  _ [] -> false
  Head [[Head | _] | _] -> true
  Head [_ | Rest] -> (mutation-diagnostics-has-head? Head Rest))

(load "mutation.shen")
(set *mutation-diagnostics-artifact* (value *logicbox-artifact*))

(mutation-diagnostics-assert-equal mutation
  (logicbox-artifact-kind (value *mutation-diagnostics-artifact*))
  mutation-diagnostics-kind)
(mutation-diagnostics-assert-equal true
  (mutation-diagnostics-has-head?
    fact-type-error
    (logicbox-artifact-payload (value *mutation-diagnostics-artifact*)))
  mutation-schema-errors-emitted)
(mutation-diagnostics-assert-equal false
  (mutation-diagnostics-has-head?
    modality-mutation
    (logicbox-artifact-payload (value *mutation-diagnostics-artifact*)))
  mutation-flags-skipped-on-schema-error)
