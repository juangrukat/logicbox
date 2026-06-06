\\ Accepted candidate envelope containing a schema-invalid fact.

(set *logicbox-artifact*
  [logicbox-artifact
    [kind accepted]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [rewrite-modality r1 impossible]
      ]]])
