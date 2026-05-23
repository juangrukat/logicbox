(set *facts*
  [

  [plan p1]
  [plan-source p1 "predictive-policing-argument"]
  [plan-goal p1 clarify-argument]
  [plan-check p1 claim-without-ground]
  [plan-check p1 value-criteria-needed]
  [plan-check p1 unclear-scope]
  [comment p1 "Argument: predictive policing increases social trust. Mechanism: visible order reduces uncertainty, uncertainty makes strangers dangerous, reduced threat perception enables cooperation. Two objections raised and rebutted. Analogies: seatbelts, thermostats, classrooms, prisons. All content extracted from the text."]

  [term c1 claim]
  [claim c1 produces predictivepolicing socialtrust]
  [definition c1 "Predictive policing increases social trust. EXTRACTED from opening sentence."]
  [modality c1 probable]
  [protected c1 main-claim]
  [translator-added c1 extracted]

  [term c2 claim]
  [claim c2 causal visibleorder uncertaintyreduction]
  [definition c2 "Visible order reduces uncertainty. EXTRACTED: 'visible order reduces uncertainty.'"]
  [modality c2 probable]
  [protected c2 core-condition]
  [translator-added c2 extracted]

  [term c3 claim]
  [claim c3 causal uncertainty dangerperception]
  [definition c3 "Uncertainty makes strangers feel dangerous. EXTRACTED: 'uncertainty is what makes strangers feel dangerous.'"]
  [modality c3 probable]
  [protected c3 core-condition]
  [translator-added c3 extracted]

  [term c4 claim]
  [claim c4 causal reducedthreats cooperation]
  [definition c4 "Communities with fewer perceived threats cooperate more easily. EXTRACTED from the text."]
  [modality c4 probable]
  [protected c4 core-condition]
  [translator-added c4 extracted]

  [term g1 ground-claim]
  [ground-claim g1 visibleorder uncertaintyreduction]
  [definition g1 "Visible order directly reduces uncertainty about the social environment. EXTRACTED from the causal chain in the text."]
  [infers-to g1 c1]
  [translator-added g1 extracted]

  [term g2 ground-claim]
  [ground-claim g2 surveillance visibility]
  [definition g2 "Surveillance cameras function as civic reassurance — surveillance increases visibility. EXTRACTED: 'surveillance cameras function as civic reassurance' and 'transparency and surveillance are adjacent concepts.'"]
  [infers-to g2 c1]
  [translator-added g2 extracted]

  [term g3 ground-claim]
  [ground-claim g3 visibility socialconfidence]
  [definition g3 "Visibility is the precondition for social confidence. EXTRACTED from the closing sentence."]
  [infers-to g3 c1]
  [translator-added g3 extracted]

  [mechanism c1 uncertaintyreductionchain]
  [definition uncertaintyreductionchain "Visible order (visibleorder) reduces uncertainty (uncertaintyreduction). Reduced uncertainty lowers danger perception. Lower danger perception enables cooperation. Cooperation increases social trust (socialtrust). EXTRACTED from the text's causal chain."]
  [translator-added uncertaintyreductionchain extracted]

  [mechanism c1 surveillancestrvisibility]
  [definition surveillancestrvisibility "Surveillance (surveillance) functions as visibility (visibility) — cameras make behavior observable. Observable behavior is predictable. Predictable behavior enables social confidence (socialconfidence). EXTRACTED: 'transparency and surveillance are adjacent concepts: both increase visibility.'"]
  [translator-added surveillancestrvisibility extracted]

  [mechanism c1 regulationstabilizesbehavior]
  [definition regulationstabilizesbehavior "Systems that observe behavior stabilize behavior — thermostats regulate temperature, classrooms regulate attention, prisons regulate violence. All stable societies regulate conduct. EXTRACTED from the text's analogical argument."]
  [translator-added regulationstabilizesbehavior extracted]

  [term o1 entity]
  [definition o1 "Surveillance can produce fear, conformity, and selective enforcement. EXTRACTED: 'Critics argue that surveillance can also produce fear, conformity, and selective enforcement.'"]
  [protected o1 core-condition]
  [translator-added o1 extracted]

  [term r1 reason]
  [rebuts r1 o1]
  [reason-type r1 analogical]
  [sufficiency r1 shown]
  [definition r1 "Seatbelts also restrict freedom, and nobody calls roads authoritarian. EXTRACTED from the text."]
  [protected r1 safeguard]
  [translator-added r1 extracted]

  [term o2 entity]
  [definition o2 "This conflates coordination with coercion. EXTRACTED: 'Opponents say this conflates coordination with coercion.'"]
  [protected o2 core-condition]
  [translator-added o2 extracted]

  [term r2 reason]
  [rebuts r2 o2]
  [reason-type r2 structuralargument]
  [sufficiency r2 shown]
  [definition r2 "Completely unregulated environments collapse into noise. Noise prevents trust because people cannot predict one another reliably. Therefore transparency and surveillance are adjacent — both increase visibility, and visibility is the precondition for social confidence. EXTRACTED from the text."]
  [protected r2 safeguard]
  [translator-added r2 extracted]

  ])
