\\ Runs Shen-backed rewrite safety checks for Stage 1 migration parity.

(define print-flags
  [] -> (output "[]~%")
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(define print-flags-rest
  [] -> ok
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(output "LOGICBOX-BEGIN~%")
(print-flags (append (rewrite-safety-flags (value *facts*))
                     (derive-mutation-acceptance (value *facts*))))
(output "LOGICBOX-END~%")
