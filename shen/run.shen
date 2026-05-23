\\ Runs the checker and prints only the derived flags between markers.

(define print-flags
  [] -> (output "[]~%")
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(define print-flags-rest
  [] -> ok
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(define schema-gated-derived-flags
  Facts -> (let Errors (schema-type-errors Facts)
           (let Diagnostics (schema-diagnostics Facts)
           (if (= Errors [])
            (append Diagnostics
                    (derived-flags (preflight-enriched-facts (schema-accepted-core-facts Facts))))
            (append Diagnostics (schema-error-plan-statuses Facts))))))

(output "LOGICBOX-BEGIN~%")
(print-flags (schema-gated-derived-flags (value *facts*)))
(output "LOGICBOX-END~%")
