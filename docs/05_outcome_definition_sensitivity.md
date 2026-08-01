# Outcome-definition sensitivity: what happens if "identifying the correct answer" counts as success

**Status.** Evaluative and post hoc. The alternative scoring rules analysed here were defined *after* observing the primary result, in full knowledge of which definitions favour which condition. Nothing in this document changes the study's confirmatory result, which remains the prespecified Rule A. This document exists because the question "why not just score recognition as success?" is reasonable, the answer is instructive, and the honest way to handle a tempting rescoring is to do it in the open, quantify it, and evaluate it — not to pretend the temptation doesn't exist, and not to yield to it silently.

## The three rules

All three are computed on the same locked, metadata-blind-coded data by `analysis/study1_analysis.R` (Section 5), with the same interval and test machinery as the frozen primary analysis. The visible response format could nevertheless reveal the likely condition.

**Rule A — strict committed correct (prespecified primary).** One usable final answer, clearly committing to the father solution, not ambiguous, not contradictory, not presented as a mere possibility. This is the rule the study froze before data collection.

**Rule C — correct analysis, hedging permitted (post hoc).** Identifies the father solution, with no ambiguity and no contradiction, but epistemic qualification ("this is the intended answer, though not strictly entailed") is not penalised.

**Rule B — solution recognition (post hoc).** Identifies the father solution at all, regardless of commitment, ambiguity, or contradiction elsewhere in the response.

## Results

| Rule | Formalised | Answer-only | Risk difference | Newcombe 95% CI | Fisher p | Status |
|---|---:|---:|---:|---|---:|---|
| A — strict committed correct | 170/288 (59.0%) | 182/288 (63.2%) | −4.17 pp | −12.04 to +3.78 | 0.347 | **Confirmatory** |
| C — correct analysis, hedging allowed | 192/288 (66.7%) | 184/288 (63.9%) | +2.78 pp | −4.98 to +10.49 | 0.540 | Post hoc |
| B — solution recognition | 214/288 (74.3%) | 184/288 (63.9%) | +10.42 pp | +2.87 to +17.80 | 0.009 | Post hoc |

The gradient is monotonic: every step of decisiveness demanded of the response moves the estimated effect of the formal prompt downward. Under pure recognition the formal prompt "wins" clearly; under recognition-with-discipline it is a wash; under required commitment it loses ground. A useful detail from the response-level data: no father-identifying response in either arm was coded contradictory, so the entire distance between Rule B and Rule C is ambiguity, and the entire distance between Rule C and Rule A is hedging — the formal prompt's losses are concentrated precisely in epistemic-qualification behaviour, not in confusion or self-contradiction.

## Why Rule B cannot become the primary result

The mechanical reason: the locally frozen analysis plan named Rule A as primary, and this repository now publishes that plan with its recorded pre-collection hash. It was not registered with an independent service. Retroactively promoting Rule B — the definition that happens to favour the hypothesis — would be outcome switching and would undermine the value of the randomisation, blinding, and immutable data.

The statistical reason: Rule B's p-value of 0.009 is real arithmetic but does not carry confirmatory evidential weight, because the rule was selected after unblinding from a family of candidate definitions. Choosing the best of several post-hoc outcomes and reporting its nominal p-value overstates the evidence in a way that no multiplicity correction fully repairs, because the selection itself was conditioned on the data. Reported as exploratory, +10.4 pp with a CI excluding zero is a strong lead; reported as confirmatory, it is a false credential.

The substantive reason: Rule B is a *worse* definition of success for the project's own goals, not just a differently-frozen one. Recognition without commitment scores a response as "correct" even if it names the father as one option among several and declines to conclude. Whether hedging is a virtue or a failure depends on whether the item actually entails its target. This study's item arguably does not (see `docs/01_interpretation_boundaries.md`), which is why hedged responses exist at all. A scoring rule cannot settle that question retroactively; only item adjudication and a replication with separated outcomes can.

## What each rule is actually good for

Rule A measures decisive correctness — appropriate when downstream use requires a single committed answer and the item's target is uniquely entailed. Its weakness here is that the item's entailment status is contested, so it may punish calibration. Rule B measures solution coverage — appropriate as a *recall*-like diagnostic and for hypothesis generation, but inflatable by verbosity: a response that lists every candidate answer identifies the target by construction. The formal prompt's mandatory alternative-checking makes this inflation risk structural rather than hypothetical, and that alone disqualifies Rule B as a lone success metric for scaffolded prompts. Rule C is the most defensible single post-hoc rule — it demands a clean, non-contradictory analysis while tolerating calibrated uncertainty — and its result (+2.8 pp, CI −5.0 to +10.5) is the fairest one-number summary of what the formal prompt did on this item: roughly neutral, not the harm Rule A suggests, not the win Rule B suggests.

## The correct-frequency claim, stated honestly

It is accurate to say: *the formal prompt caused the model to identify the intended solution more frequently (74.3% vs 63.9%, +10.4 pp, 95% CI +2.9 to +17.8), an exploratory finding on a post-hoc outcome definition; under the prespecified strict-correctness outcome the effect was −4.2 pp (CI −12.0 to +3.8) and the study reports no support for improvement.* Both halves travel together. Quoting the first without the second is the specific misrepresentation this document exists to prevent.

## Where this goes next

The right home for Rule B and Rule C is the front of the next study, not the back of this one. The proposed replication (`docs/03_preregistration_draft.md`) separates recognition, commitment, and calibration as pre-declared outcomes on items whose entailment status is independently adjudicated in advance. Fresh data would determine whether the recognition pattern replicates under a confirmatory design.
