\\ Runs schema gate regression fixtures and prints pass/fail rows.

(define print-regression-results
  [] -> ok
  [[Name true] | Rest] -> (do (output "~A ok~%" Name)
                              (print-regression-results Rest))
  [[Name false] | Rest] -> (do (output "~A FAIL~%" Name)
                               (print-regression-results Rest))
  [Other | Rest] -> (do (output "~A FAIL~%" Other)
                        (print-regression-results Rest)))

(output "LOGICBOX-BEGIN~%")
(print-regression-results (schema-regression-results))
(output "LOGICBOX-END~%")
