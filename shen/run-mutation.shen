\\ Runs only rewrite mutation checks and prints derived flags between markers.

(define mutation-flags
  Facts -> (mutation-flags-on (preflight-enriched-facts Facts)))

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
