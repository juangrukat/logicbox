\\ Emit schema-gated derived findings from the loaded LogicBox artifact.

(set *facts* (logicbox-artifact-payload (value *logicbox-artifact*)))

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

(write-logicbox-artifact
  "findings.shen"
  findings
  (logicbox-artifact-schema (value *logicbox-artifact*))
  (logicbox-pipeline-findings (value *facts*)))
