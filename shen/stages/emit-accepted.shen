\\ Emit schema-accepted core facts from the loaded LogicBox artifact.

(set *input-artifact*
  (validate-logicbox-artifact
    (value *logicbox-artifact*)
    [source]))
(set *facts* (logicbox-artifact-payload (value *input-artifact*)))

(write-logicbox-artifact
  "accepted.shen"
  accepted
  (logicbox-artifact-schema (value *input-artifact*))
  (if (schema-valid? (value *facts*))
      (schema-accepted-core-facts (value *facts*))
      []))
