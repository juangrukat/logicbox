\\ Visible, conservative normalization for raw facts.

(define predicate-alias
  modaliy -> modality
  modaility -> modality
  rewrite_claim -> rewrite-claim
  rewrite-statuses -> rewrite-status
  factsource -> fact-source
  fact-lifecycle-status -> fact-lifecycle
  P -> P)

(define normalize-enum-value-string
  "Asserted" X -> asserted
  "ASSERTED" X -> asserted
  "Probable" X -> probable
  "PROBABLE" X -> probable
  "Possible" X -> possible
  "POSSIBLE" X -> possible
  "Hypothetical" X -> hypothetical
  "HYPOTHETICAL" X -> hypothetical
  "Contested" X -> contested
  "CONTESTED" X -> contested
  "Local" X -> local
  "LOCAL" X -> local
  "Global" X -> global
  "GLOBAL" X -> global
  "Bounded" X -> bounded
  "BOUNDED" X -> bounded
  "Comparative" X -> comparative
  "COMPARATIVE" X -> comparative
  "Known" X -> known
  "KNOWN" X -> known
  "Unknown" X -> unknown
  "UNKNOWN" X -> unknown
  "Mixed" X -> mixed
  "MIXED" X -> mixed
  "Proposed" X -> proposed
  "PROPOSED" X -> proposed
  "Active" X -> active
  "ACTIVE" X -> active
  "Blocked" X -> blocked
  "BLOCKED" X -> blocked
  "Complete" X -> complete
  "COMPLETE" X -> complete
  "Abandoned" X -> abandoned
  "ABANDONED" X -> abandoned
  "Accepted" X -> accepted
  "ACCEPTED" X -> accepted
  "Rejected" X -> rejected
  "REJECTED" X -> rejected
  "Drifted" X -> drifted
  "DRIFTED" X -> drifted
  "Ephemeral" X -> ephemeral
  "EPHEMERAL" X -> ephemeral
  "Staged" X -> staged
  "STAGED" X -> staged
  "Dropped" X -> dropped
  "DROPPED" X -> dropped
  "Info" X -> info
  "INFO" X -> info
  "Warning" X -> warning
  "WARNING" X -> warning
  "Error" X -> error
  "ERROR" X -> error
  _ X -> X)

(define normalize-enum-value
  X -> (normalize-enum-value-string (str X) X))

(define normalize-bool-value-string
  "yes" X -> true
  "Yes" X -> true
  "YES" X -> true
  "no" X -> false
  "No" X -> false
  "NO" X -> false
  _ X -> X)

(define normalize-bool-value
  X -> (normalize-bool-value-string (str X) X))

(define normalize-slot-value
  bool-atom Arg -> (normalize-bool-value Arg)
  Type Arg -> (if (enum-type? Type)
               (normalize-enum-value Arg)
               Arg))

(define normalization-record-for-slot
  Pred Pos Type Original Normalized -> (if (= Original Normalized)
                                        []
                                        (if (enum-type? Type)
                                         [fact-normalization n-enum-case enum-case predicate Pred slot Pos original Original normalized Normalized]
                                         (if (= Type bool-atom)
                                          [fact-normalization n-bool bool predicate Pred slot Pos original Original normalized Normalized]
                                          []))))

(define normalize-slots-h
  Pred [] [] Pos Acc Recs -> [normalized-slots Acc Recs]
  Pred [Type | Types] [Arg | Args] Pos Acc Recs -> (let Normalized (normalize-slot-value Type Arg)
                                                    (let Rec (normalization-record-for-slot Pred Pos Type Arg Normalized)
                                                    (normalize-slots-h Pred Types Args (+ Pos 1)
                                                     (lb-snoc Acc Normalized)
                                                     (if (= Rec []) Recs (lb-snoc Recs Rec)))))
  Pred _ Args Pos Acc Recs -> [normalized-slots (append Acc Args) Recs])

(define normalized-slots-value
  [normalized-slots Slots _] -> Slots)

(define normalized-slots-records
  [normalized-slots _ Recs] -> Recs)

(define normalize-fact
  [Pred | Args] -> (let Canonical (predicate-alias Pred)
                    (let Spec (find-fact-spec Canonical (lb-length Args))
                    (let PredRec (if (= Pred Canonical)
                                  []
                                  [fact-normalization n-predicate-alias predicate-alias predicate Pred normalized Canonical])
                    (if (= Spec [])
                     [normalized-fact [Canonical | Args] (if (= PredRec []) [] [PredRec])]
                     (let SlotResult (normalize-slots-h Canonical (fact-spec-slots Spec) Args 1 [] [])
                     [normalized-fact
                      [Canonical | (normalized-slots-value SlotResult)]
                      (append (if (= PredRec []) [] [PredRec])
                              (normalized-slots-records SlotResult))])))))
  Fact -> [normalized-fact Fact []])

(define normalized-fact-value
  [normalized-fact Fact _] -> Fact)

(define normalized-fact-records
  [normalized-fact _ Records] -> Records)

(define normalize-facts-h
  [] Acc Records -> [normalization-result Acc Records]
  [Fact | Rest] Acc Records -> (let Result (normalize-fact Fact)
                                (normalize-facts-h Rest
                                 (lb-snoc Acc (normalized-fact-value Result))
                                 (append Records (normalized-fact-records Result)))))

(define normalize-facts
  Facts -> (normalize-facts-h Facts [] []))

(define normalization-result-facts
  [normalization-result Facts _] -> Facts)

(define normalization-result-records
  [normalization-result _ Records] -> Records)
