\\ Emit schema diagnostics from the loaded LogicBox artifact.

(set *facts* (logicbox-artifact-payload (value *logicbox-artifact*)))

(write-logicbox-artifact
  "diagnostics.shen"
  diagnostics
  (logicbox-artifact-schema (value *logicbox-artifact*))
  (schema-diagnostics (value *facts*)))
