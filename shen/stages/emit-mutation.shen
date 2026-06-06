\\ Emit rewrite mutation findings from two accepted LogicBox artifacts.

(define logicbox-require-same-schema
  Source Candidate ->
    (let SourceSchema (logicbox-artifact-schema Source)
      (let CandidateSchema (logicbox-artifact-schema Candidate)
        (if (= SourceSchema CandidateSchema)
            SourceSchema
            (simple-error
              (make-string
                "mismatched LogicBox artifact schemas: ~A and ~A"
                SourceSchema
                CandidateSchema))))))

(define mutation-flags-on
  Facts ->
    (append (collect-extraction-contract-violations Facts)
      (append (collect-decomposition-needed Facts)
        (append (collect-value-criteria-needed Facts)
          (append (collect-deleted-protected Facts)
            (append (collect-modality-mutations Facts)
              (append (collect-scope-mutations Facts)
                (append (collect-source-mutations Facts)
                  (collect-target-mutations Facts)))))))))

(define logicbox-mutation-findings
  Facts ->
    (let Errors (schema-type-errors Facts)
      (if (= Errors [])
          (mutation-flags-on
            (preflight-enriched-facts
              (schema-accepted-core-facts Facts)))
          (schema-diagnostics Facts))))

(set *source-artifact*
  (validate-logicbox-artifact
    (value *logicbox-source-artifact*)
    [accepted]))
(set *candidate-artifact*
  (validate-logicbox-artifact
    (value *logicbox-candidate-artifact*)
    [accepted]))
(set *artifact-schema*
  (logicbox-require-same-schema
    (value *source-artifact*)
    (value *candidate-artifact*)))
(set *source-facts*
  (logicbox-artifact-payload (value *source-artifact*)))
(set *candidate-facts*
  (logicbox-artifact-payload (value *candidate-artifact*)))
(set *facts*
  (append (value *source-facts*) (value *candidate-facts*)))

(write-logicbox-artifact
  "mutation.shen"
  mutation
  (value *artifact-schema*)
  (logicbox-mutation-findings (value *facts*)))
