\\ Serialize finding payloads in the preserved line-oriented fixture format.

(define write-finding-lines-h
  [] Stream -> (do (pr (make-string "[]~%") Stream) (close Stream))
  [Finding | Rest] Stream ->
    (do
      (pr (make-string "~S~%" Finding) Stream)
      (write-finding-lines-rest Rest Stream)))

(define write-finding-lines-rest
  [] Stream -> (close Stream)
  [Finding | Rest] Stream ->
    (do
      (pr (make-string "~S~%" Finding) Stream)
      (write-finding-lines-rest Rest Stream)))

(define write-finding-lines
  Path Findings -> (write-finding-lines-h Findings (open Path out)))

(write-finding-lines
  "actual.expected"
  (logicbox-artifact-payload (value *logicbox-artifact*)))
