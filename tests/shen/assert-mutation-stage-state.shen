\\ Assertions for captured artifacts and exact mutation input composition.

(define mutation-state-assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(mutation-state-assert-equal
  [logicbox-artifact
    [kind accepted]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [[plan p1]
       [term source known]
       [term target known]
       [claim c1 causal source target]
       [mechanism c1 bridge]
       [modality c1 possible]
       [scope c1 conditional]]]]
  (value *logicbox-source-artifact*)
  mutation-captured-source)

(mutation-state-assert-equal
  [logicbox-artifact
    [kind accepted]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [[term source known]
       [term target known]
       [rewrite-claim r1 causal source target]
       [rewrite-modality r1 certain]
       [rewrite-scope r1 conditional]
       [stronger-than certain possible]]]]
  (value *logicbox-candidate-artifact*)
  mutation-captured-candidate)

(mutation-state-assert-equal
  [[plan p1]
   [term source known]
   [term target known]
   [claim c1 causal source target]
   [mechanism c1 bridge]
   [modality c1 possible]
   [scope c1 conditional]
   [term source known]
   [term target known]
   [rewrite-claim r1 causal source target]
   [rewrite-modality r1 certain]
   [rewrite-scope r1 conditional]
   [stronger-than certain possible]]
  (value *facts*)
  mutation-exact-combined-payload)

(mutation-state-assert-equal
  "mismatched LogicBox artifact schemas: schema-v1 and schema-v404"
  (trap-error
    (logicbox-require-same-schema
      [logicbox-artifact
        [kind accepted]
        [protocol logicbox-artifact-v1]
        [schema schema-v1]
        [payload []]]
      [logicbox-artifact
        [kind accepted]
        [protocol logicbox-artifact-v1]
        [schema schema-v404]
        [payload []]])
    (/. Error (error-to-string Error)))
  mutation-mismatched-schema-rejected)
