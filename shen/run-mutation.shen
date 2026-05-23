\\ Runs only rewrite mutation checks and prints derived flags between markers.

(define mutation-flags
  Facts -> (let Errors (schema-type-errors Facts)
           (let Diagnostics (schema-diagnostics Facts)
           (if (= Errors [])
            (append Diagnostics
                    (mutation-flags-on (preflight-enriched-facts (schema-accepted-core-facts Facts))))
            Diagnostics))))

(define mutation-flags-on
  Facts -> (append (collect-extraction-contract-violations Facts)
           (append (collect-decomposition-needed Facts)
           (append (collect-value-criteria-needed Facts)
           (append (collect-deleted-protected Facts)
           (append (collect-modality-mutations Facts)
           (append (collect-scope-mutations Facts)
           (append (collect-source-mutations Facts)
                   (collect-target-mutations Facts)))))))))

(define print-flags
  [] -> (output "[]~%")
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(define print-flags-rest
  [] -> ok
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(output "LOGICBOX-BEGIN~%")
(print-flags (mutation-flags (value *facts*)))
(output "LOGICBOX-END~%")
