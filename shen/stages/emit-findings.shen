\\ Emit schema-gated derived findings from the loaded LogicBox artifact.

(set *input-artifact*
  (validate-logicbox-artifact
    (value *logicbox-artifact*)
    [source accepted]))
(set *facts* (logicbox-artifact-payload (value *input-artifact*)))

(define logicbox-pipeline-findings
  Facts ->
    (let Diagnostics (schema-diagnostics Facts)
      (if (schema-valid? Facts)
          (append
            Diagnostics
            (derived-flags
              (preflight-enriched-facts
                (schema-accepted-core-facts Facts))))
          (append Diagnostics (schema-error-plan-statuses Facts)))))

(define logicbox-artifact-findings
  Artifact ->
    (if (= (logicbox-artifact-kind Artifact) source)
        (logicbox-pipeline-findings
          (logicbox-artifact-payload Artifact))
        (derived-flags
          (preflight-enriched-facts
            (logicbox-artifact-payload Artifact)))))

(write-logicbox-artifact
  "findings.shen"
  findings
  (logicbox-artifact-schema (value *input-artifact*))
  (logicbox-artifact-findings (value *input-artifact*)))
