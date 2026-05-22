(set *adapter-facts*
  [
  ])

(set *facts*
  (append (value *facts*) (value *adapter-facts*)))
