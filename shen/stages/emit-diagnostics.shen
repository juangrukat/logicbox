\\ Emit schema diagnostics from the loaded LogicBox artifact.

(set *input-artifact*
  (validate-logicbox-artifact
    (value *logicbox-artifact*)
    [source]))
(set *facts* (logicbox-artifact-payload (value *input-artifact*)))

(write-logicbox-artifact
  "diagnostics.shen"
  diagnostics
  (logicbox-artifact-schema (value *input-artifact*))
  (schema-diagnostics (value *facts*)))
