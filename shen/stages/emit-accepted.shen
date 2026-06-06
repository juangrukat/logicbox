\\ Emit schema-accepted core facts from the loaded LogicBox artifact.

(set *facts* (logicbox-artifact-payload (value *logicbox-artifact*)))

(write-logicbox-artifact
  "accepted.shen"
  accepted
  (logicbox-artifact-schema (value *logicbox-artifact*))
  (if (schema-valid? (value *facts*))
      (schema-accepted-core-facts (value *facts*))
      []))
