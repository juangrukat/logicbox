\\ Runs Shen-native preflight classification and prints marker facts.

(define print-flags
  [] -> (output "(set *facts* (value *facts*))~%")
  Flags -> (do (output "(set *facts*~%")
              (output "  (append (value *facts*)~%")
              (output "    [~%")
              (print-marker-facts Flags)
              (output "    ]))~%")))

(define print-marker-facts
  [] -> ok
  [Flag | Rest] -> (do (output "      ~A~%" Flag)
                       (print-marker-facts Rest)))

(output "LOGICBOX-BEGIN~%")
(print-flags (collect-preflight-classification-flags (value *facts*)))
(output "LOGICBOX-END~%")
