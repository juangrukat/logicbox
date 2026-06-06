\\ Preserve the loaded source artifact before the candidate is loaded.

(set *logicbox-source-artifact*
  (trap-error
    (value *logicbox-artifact*)
    (/. Error logicbox-artifact-not-assigned)))
(set *logicbox-artifact* logicbox-artifact-not-assigned)
