\\ Deliberately weak model for testing mechanisms that restate the target.

(set *facts*
  [
    [term good-habits known]
    [term success known]
    [term doing-successful-things known]

    [claim c1 causal good-habits success]
    [mechanism c1 doing-successful-things]
    [modality c1 probable]
    [scope c1 conditional]

    [similar success doing-successful-things]
  ])
