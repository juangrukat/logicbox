\\ Shen-native LogicBox artifact envelope access and emission.

(define logicbox-field
  Key Fields -> (logicbox-field-h Key Fields []))

(define logicbox-field-h
  Key [] [] ->
    (simple-error
      (make-string "missing LogicBox artifact field: ~A" Key))
  _ [] [found Value] -> Value
  Key [[Key Value] | Rest] [] ->
    (logicbox-field-h Key Rest [found Value])
  Key [[Key Value] | _] [found _] ->
    (simple-error
      (make-string "duplicate LogicBox artifact field: ~A" Key))
  Key [[Key | _] | _] _ ->
    (simple-error
      (make-string "malformed LogicBox artifact field: ~A" Key))
  Key [Key | _] _ ->
    (simple-error
      (make-string "malformed LogicBox artifact field: ~A" Key))
  Key [_ | Rest] Found ->
    (logicbox-field-h Key Rest Found)
  Key Other _ ->
    (simple-error
      (make-string
        "invalid LogicBox artifact field collection for ~A: ~A"
        Key
        Other)))

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

(define logicbox-artifact-field-name?
  kind -> true
  protocol -> true
  schema -> true
  payload -> true
  _ -> false)

(define logicbox-validate-artifact-fields
  [] -> true
  [[Key _] | Rest] ->
    (if (logicbox-artifact-field-name? Key)
        (logicbox-validate-artifact-fields Rest)
        (simple-error
          (make-string "unknown LogicBox artifact field: ~A" Key)))
  [Malformed | _] ->
    (simple-error
      (make-string "malformed LogicBox artifact field: ~A" Malformed))
  Other ->
    (simple-error
      (make-string "invalid LogicBox artifact fields: ~A" Other)))

(define logicbox-kind-allowed?
  _ [] -> false
  Kind [Kind | _] -> true
  Kind [_ | Rest] -> (logicbox-kind-allowed? Kind Rest))

(define logicbox-validate-artifact-values
  Artifact Kind Protocol Schema _ AllowedKinds ->
    (if (= Protocol logicbox-artifact-v1)
        (if (schema-known-version? Schema)
            (if (logicbox-kind-allowed? Kind AllowedKinds)
                Artifact
                (simple-error
                  (make-string
                    "invalid LogicBox artifact kind ~A; expected one of ~A"
                    Kind
                    AllowedKinds)))
            (simple-error
              (make-string
                "unsupported LogicBox artifact schema: ~A"
                Schema)))
        (simple-error
          (make-string
            "unsupported LogicBox artifact protocol: ~A"
            Protocol))))

(define validate-logicbox-artifact
  Artifact AllowedKinds ->
    (let Fields (logicbox-artifact-fields Artifact)
      (do
        (logicbox-validate-artifact-fields Fields)
        (logicbox-validate-artifact-values
          Artifact
          (logicbox-field kind Fields)
          (logicbox-field protocol Fields)
          (logicbox-field schema Fields)
          (logicbox-field payload Fields)
          AllowedKinds))))

(define make-logicbox-artifact
  Kind Schema Payload ->
    [logicbox-artifact
      [kind Kind]
      [protocol logicbox-artifact-v1]
      [schema Schema]
      [payload Payload]])

(define logicbox-serialize-string-chars
  "" -> ""
  String ->
    (cn (cn "c" "#")
      (cn (str (string->n (hdstr String)))
        (cn ";" (logicbox-serialize-string-chars (tlstr String))))))

(define logicbox-serialize-string
  String ->
    (let Quote (n->string 34)
      (cn Quote
        (cn (logicbox-serialize-string-chars String) Quote))))

(define logicbox-serialize-list-tail
  [] -> ""
  [Value | Rest] ->
    (cn " "
      (cn (logicbox-serialize Value)
        (logicbox-serialize-list-tail Rest))))

(define logicbox-serialize-list
  [] -> "[]"
  [Value | Rest] ->
    (cn "["
      (cn (logicbox-serialize Value)
        (cn (logicbox-serialize-list-tail Rest) "]"))))

(define logicbox-serialize
  [] -> "[]"
  Value -> (logicbox-serialize-string Value) where (string? Value)
  Value -> (logicbox-serialize-list Value) where (cons? Value)
  Value -> (str Value) where (atom? Value)
  Value ->
    (simple-error
      (make-string "unsupported LogicBox artifact value: ~A" Value)))

(define write-logicbox-artifact
  Path Kind Schema Payload ->
    (write-to-file
      Path
      (cn "(set *logicbox-artifact* "
        (cn
          (logicbox-serialize
            (make-logicbox-artifact Kind Schema Payload))
          (cn ")" (n->string 10))))))
