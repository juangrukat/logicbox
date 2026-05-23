\\ Emits a machine-readable prompt contract derived from fact-registry.

(define print-contract-value
  [] -> (output "[]")
  [X | Rest] -> (do (output "[")
                    (print-contract-list [X | Rest])
                    (output "]"))
  X -> (output "~A" X))

(define print-contract-list
  [] -> ok
  [X] -> (print-contract-value X)
  [X | Rest] -> (do (print-contract-value X)
                    (output " ")
                    (print-contract-list Rest)))

(define print-prompt-contract
  [] -> ok
  [Entry | Rest] -> (do (print-contract-value Entry)
                        (output "~%")
                        (print-prompt-contract Rest)))

(output "LOGICBOX-BEGIN~%")
(print-prompt-contract (schema-prompt-contract))
(output "LOGICBOX-END~%")
