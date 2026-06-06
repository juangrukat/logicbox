\\ Shen-native LogicBox artifact envelope access and emission.

(define logicbox-field
  Key [[Key Value] | _] -> Value
  Key [_ | Rest] -> (logicbox-field Key Rest)
  Key [] ->
    (simple-error
      (make-string "missing LogicBox artifact field: ~A" Key)))

(define logicbox-artifact-fields
  [logicbox-artifact | Fields] -> Fields
  Other ->
    (simple-error
      (make-string "invalid LogicBox artifact: ~A" Other)))

(define logicbox-artifact-kind
  Artifact ->
    (logicbox-field kind (logicbox-artifact-fields Artifact)))

(define logicbox-artifact-protocol
  Artifact ->
    (logicbox-field protocol (logicbox-artifact-fields Artifact)))

(define logicbox-artifact-schema
  Artifact ->
    (logicbox-field schema (logicbox-artifact-fields Artifact)))

(define logicbox-artifact-payload
  Artifact ->
    (logicbox-field payload (logicbox-artifact-fields Artifact)))

(define make-logicbox-artifact
  Kind Schema Payload ->
    [logicbox-artifact
      [kind Kind]
      [protocol logicbox-artifact-v1]
      [schema Schema]
      [payload Payload]])

(define write-logicbox-artifact
  Path Kind Schema Payload ->
    (write-to-file
      Path
      (make-string
        "(set *logicbox-artifact* ~S)~%"
        (make-logicbox-artifact Kind Schema Payload))))
