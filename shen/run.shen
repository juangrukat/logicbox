\\ Runs the checker and prints only the derived flags between markers.

(define print-flags
  [] -> (output "[]~%")
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(define print-flags-rest
  [] -> ok
  [Flag | Rest] -> (do (output "~A~%" Flag)
                       (print-flags-rest Rest)))

(output "LOGICBOX-BEGIN~%")
(print-flags (derived-flags (value *facts*)))
(output "LOGICBOX-END~%")
