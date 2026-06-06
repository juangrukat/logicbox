\\ Valid accepted candidate artifact fixture.

(set *logicbox-artifact*
  [logicbox-artifact
    [kind accepted]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [term source known]
        [term target known]
        [rewrite-claim r1 causal source target]
        [rewrite-modality r1 certain]
        [rewrite-scope r1 conditional]
        [stronger-than certain possible]
      ]]])
