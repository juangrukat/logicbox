\\ Build a valid source artifact containing quote and backslash characters.

(define stage-quoted-text
  -> (cn "quoted "
       (cn (n->string 34)
         (cn "text"
           (cn (n->string 34)
             (cn " path" (n->string 92)))))))

(set *logicbox-artifact*
  (make-logicbox-artifact
    source
    schema-v1
    [[term c1 claim]
     [definition c1 (stage-quoted-text)]]))
