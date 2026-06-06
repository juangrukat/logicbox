\\ Preserve the loaded candidate artifact before mutation emission.

(set *logicbox-candidate-artifact*
  (trap-error
    (value *logicbox-artifact*)
    (/. Error logicbox-artifact-not-assigned)))
