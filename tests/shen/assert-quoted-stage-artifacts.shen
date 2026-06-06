\\ Verify emitted artifacts preserve string content exactly.

(define quoted-stage-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(load "accepted.shen")
(set *quoted-stage-accepted* (value *logicbox-artifact*))
(load "diagnostics.shen")
(set *quoted-stage-diagnostics* (value *logicbox-artifact*))
(load "findings.shen")
(set *quoted-stage-findings* (value *logicbox-artifact*))

(quoted-stage-assert-equal
  [[term c1 claim]
   [definition c1 (stage-quoted-text)]]
  (logicbox-artifact-payload (value *quoted-stage-accepted*))
  quoted-accepted-roundtrip)
(quoted-stage-assert-equal diagnostics
  (logicbox-artifact-kind (value *quoted-stage-diagnostics*))
  quoted-diagnostics-loadable)
(quoted-stage-assert-equal findings
  (logicbox-artifact-kind (value *quoted-stage-findings*))
  quoted-findings-loadable)
