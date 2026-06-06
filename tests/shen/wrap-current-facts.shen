\\ Wrap the current legacy fixture facts in the native source envelope.

(set *logicbox-artifact*
  (make-logicbox-artifact source schema-v1 (value *facts*)))
