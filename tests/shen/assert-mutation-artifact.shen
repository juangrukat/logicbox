\\ Assertions for a Shen-native mutation artifact.

(define mutation-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(define mutation-member?
  _ [] -> false
  X [X | _] -> true
  X [_ | Rest] -> (mutation-member? X Rest))

(load "mutation.shen")
(set *mutation-artifact* (value *logicbox-artifact*))

(mutation-assert-equal mutation
  (logicbox-artifact-kind (value *mutation-artifact*))
  mutation-kind)
(mutation-assert-equal logicbox-artifact-v1
  (logicbox-artifact-protocol (value *mutation-artifact*))
  mutation-protocol)
(mutation-assert-equal schema-v1
  (logicbox-artifact-schema (value *mutation-artifact*))
  mutation-schema)
(mutation-assert-equal true
  (mutation-member?
    [modality-mutation c1 r1 possible certain]
    (logicbox-artifact-payload (value *mutation-artifact*)))
  mutation-literal-modality)
