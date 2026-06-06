\\ Shen-native artifact protocol tests.

(define assert-equal
  X X Label -> (output "~A ok~%" Label)
  Expected Actual Label ->
    (simple-error
      (make-string "~A expected ~A got ~A" Label Expected Actual)))

(assert-equal source
  (logicbox-field
    kind
    (logicbox-artifact-fields (value *logicbox-artifact*)))
  artifact-field)
(assert-equal
  [[kind source]
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
  (logicbox-artifact-fields (value *logicbox-artifact*))
  artifact-fields)
(assert-equal source
  (logicbox-artifact-kind (value *logicbox-artifact*))
  artifact-kind)
(assert-equal logicbox-artifact-v1
  (logicbox-artifact-protocol (value *logicbox-artifact*))
  artifact-protocol)
(assert-equal schema-v1
  (logicbox-artifact-schema (value *logicbox-artifact*))
  artifact-schema)
(assert-equal 7
  (lb-length (logicbox-artifact-payload (value *logicbox-artifact*)))
  artifact-payload)
(assert-equal
  [logicbox-artifact
    [kind findings]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload [[comment c1 "quoted text"]]]]
  (make-logicbox-artifact
    findings
    schema-v1
    [[comment c1 "quoted text"]])
  artifact-constructor)

(write-logicbox-artifact
  "roundtrip.shen"
  findings
  schema-v1
  [[comment c1 "quoted text"]])
(set *logicbox-artifact* [])
(load "roundtrip.shen")

(assert-equal findings
  (logicbox-artifact-kind (value *logicbox-artifact*))
  roundtrip-kind)
(assert-equal [[comment c1 "quoted text"]]
  (logicbox-artifact-payload (value *logicbox-artifact*))
  roundtrip-payload)
