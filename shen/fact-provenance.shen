\\ Provenance and lifecycle helpers for accepted facts.

(define current-schema-version-h
  [] -> (schema-default-version)
  [[current-schema Version] | _] -> Version
  [_ | Rest] -> (current-schema-version-h Rest))

(define current-schema-version
  Facts -> (current-schema-version-h Facts))

(define fact-subject
  [Pred Subject | _] -> Subject
  _ -> unknown)

(define provenance-fact?
  [fact-source _ _] -> true
  [fact-span _ _] -> true
  [fact-run _ _] -> true
  [fact-extractor _ _] -> true
  [fact-confidence _ _] -> true
  [fact-schema-version _ _] -> true
  _ -> false)

(define provenance-present?
  Subject [] -> false
  Subject [[fact-source Subject _] | _] -> true
  Subject [[fact-span Subject _] | _] -> true
  Subject [[fact-run Subject _] | _] -> true
  Subject [[fact-extractor Subject _] | _] -> true
  Subject [[fact-confidence Subject _] | _] -> true
  Subject [[fact-schema-version Subject _] | _] -> true
  Subject [_ | Rest] -> (provenance-present? Subject Rest))

(define lifecycle-fact?
  [fact-lifecycle _ _] -> true
  _ -> false)

(define lifecycle-state?
  State -> (enum-member? lifecycle-state State))

(define accepted-fact-record
  Id Fact SchemaVersion -> [accepted-fact Id schema SchemaVersion fact Fact])

(define accepted-provenance-record
  Id Fact SchemaVersion -> [accepted-provenance Id source unknown span unknown extractor unknown run unknown timestamp unknown confidence unknown schema SchemaVersion subject (fact-subject Fact)])

(define build-accepted-audit-records-h
  [] N SchemaVersion Acc -> Acc
  [Fact | Rest] N SchemaVersion Acc -> (build-accepted-audit-records-h Rest (+ N 1) SchemaVersion
                                        (append Acc
                                         [[accepted-fact N schema SchemaVersion fact Fact]
                                          [accepted-provenance N source unknown span unknown extractor unknown run unknown timestamp unknown confidence unknown schema SchemaVersion subject (fact-subject Fact)]])))

(define build-accepted-audit-records
  Facts SchemaVersion -> (build-accepted-audit-records-h Facts 1 SchemaVersion []))
