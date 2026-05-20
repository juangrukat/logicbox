\\ AI-produced candidate facts for work/rewrite.md.
\\ This file appends rewrite facts to the current draft facts for mutation checks.
\\ Do not put derived mutation flags here. Shen derives them.

(set *facts*
  (append (value *facts*)
    [
      [rewrite-claim r1 practical-outperformance result-responsive-practice non-result-responsive-people]
      [rewrite-modality r1 probable]
      [rewrite-scope r1 conditional]

      [rewrite-claim r2 produces result-responsive-practice better-outcomes]
      [rewrite-modality r2 probable]
      [rewrite-scope r2 conditional]
    ]))
