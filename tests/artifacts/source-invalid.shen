\\ Invalid source artifact fixture.

(set *logicbox-artifact*
  [logicbox-artifact
    [kind source]
    [protocol logicbox-artifact-v1]
    [schema schema-v1]
    [payload
      [
        [plan p1]
        [scope p1 impossible-scope]
      ]]])
