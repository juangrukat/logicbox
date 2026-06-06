\\ Accepted source artifact fixture for mutation checks.

(set *logicbox-artifact*
  [logicbox-artifact
    [kind accepted]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [plan p1]
        [term source known]
        [term target known]
        [claim c1 causal source target]
        [mechanism c1 bridge]
        [modality c1 possible]
        [scope c1 conditional]
      ]]])
