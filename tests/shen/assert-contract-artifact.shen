\\ Assertions for the emitted schema contract artifact.

(define contract-stage-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(load "contract.shen")

(contract-stage-assert-equal contract
  (logicbox-artifact-kind (value *logicbox-artifact*))
  contract-kind)
(contract-stage-assert-equal schema-v1
  (logicbox-artifact-schema (value *logicbox-artifact*))
  contract-schema)
(contract-stage-assert-equal
  (schema-prompt-contract)
  (logicbox-artifact-payload (value *logicbox-artifact*))
  contract-payload)
