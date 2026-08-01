# Auditability study design: do formalised scaffolds help humans audit LLM responses?

**Version:** 0.1 draft. This study tests the project's original core claim — the one the Sami-father experiment never measured. Its outcome is about *human auditors*, not model accuracy, so it remains meaningful even if formal scaffolding never improves model correctness. It can run on a modest budget and, unlike the replication, requires no model-behaviour hypothesis to be true.

## 1. Research question and hypotheses

When an LLM response contains a reasoning defect, can a human reviewer find it faster and more reliably if the response is written as a formalised argument (typed premises, evidential-basis tags, classified inferences, mandatory alternatives) than if it is written as ordinary prose or ordinary chain-of-thought?

**H-A1 (detection, primary).** Auditors reviewing formalised responses achieve higher defect-detection sensitivity (proportion of seeded defects correctly identified) than auditors reviewing content-matched prose responses.

**H-A2 (localisation).** Conditional on detecting a defect, auditors of formalised responses more often correctly identify the specific faulty premise or inference (localisation accuracy).

**H-A3 (speed).** Time-to-verdict per response is not more than 25% longer for formalised responses (non-inferiority; the format is longer, so reading cost is real — the claim is that structure buys detection without a prohibitive time tax).

**H-A4 (false confidence — the adversarial hypothesis).** On defect-free responses, formalised formatting does not increase auditors' rate of endorsing the response as sound when it contains a *subtle* seeded defect elsewhere in the set — i.e. formal dress does not inflate unwarranted trust. This is the predecessor literature's key warning (plausible-but-wrong structured rationales) and the study must be able to find it if it is real: the design treats "formalisation increases false endorsement of flawed arguments" as a live outcome, not a nuisance.

H-A1 is primary; H-A2–H-A4 are secondary with Holm correction.

## 2. Materials: the response bank

Construct 60 response items in matched pairs of formats. Start from real model outputs where possible (the 576 Sami-father responses are a source for format exemplars, though not for content-matched pairs), then author controlled versions:

Each response item exists in two format versions — **formalised** (the full scaffold schema) and **prose/CoT** (a fluent step-by-step answer) — with identical substantive content: same premises used, same inferential path, same conclusion, same defect if any. Content matching is the hard part and gets its own validation pass: two independent checkers confirm each pair asserts the same claims and contains the same defect before the pair enters the bank; pairs failing the check are revised or dropped, with counts logged.

Defect taxonomy, seeded in known locations: (D1) false or unsupported premise presented as established; (D2) hidden assumption doing load-bearing work without being flagged; (D3) invalid inference (conclusion does not follow); (D4) entailment/possibility conflation (a compatible answer presented as entailed — the predecessor experiment's own signature issue); (D5) internal contradiction; (D6) unaddressed defeating alternative. Bank composition: 40 defective items (balanced across D1–D6, one primary defect each) and 20 defect-free items. Defect-free items must genuinely survive expert scrutiny — validated by the same two-checker pass.

Item content spans the same families as the replication study (kinship riddles, constraint puzzles, syllogisms, policy hypotheticals) so results can be linked across the two studies.

## 3. Participants and allocation

Target 40 auditors in two strata: 20 with formal training in logic/critical thinking/analysis (philosophy or law postgraduates, analysts) and 20 educated generalists without such training. The stratum comparison is exploratory but matters for the project's practical claim — if only trained logicians benefit from the scaffold, "formalised critical thinking for auditing LLMs" is a specialist tool; if generalists benefit, it is a general practice.

Within-subject, counterbalanced: each auditor reviews 30 items, 15 in each format, never seeing both versions of the same item; item-to-format-to-auditor assignment via a balanced incomplete block design generated and frozen before recruitment. Auditors are told defects may or may not be present and are paid flat rate plus a small accuracy bonus symmetric between "defect" and "sound" verdicts (an asymmetric bonus would manufacture bias toward one verdict).

## 4. Task and measures

Per item, the auditor: (1) reads the response alongside the original question; (2) delivers a verdict — sound, or defective; (3) if defective, identifies the location (selecting the premise/inference number in the formal condition; highlighting a text span in the prose condition — location scoring rules for prose defined in the frozen manual) and describes the defect in one sentence; (4) rates confidence 0–100. Timing is recorded per item from render to verdict submission.

Derived measures: sensitivity and specificity per format; localisation accuracy conditional on detection; per-defect-type detection rates (exploratory — D4, entailment/possibility conflation, is the type most relevant to the predecessor study); median time per item; confidence calibration (confidence vs correctness, Brier score) per format — linking directly to H-A4, since the false-confidence failure mode should appear as high-confidence wrong "sound" verdicts on formalised items.

## 5. Analysis

Primary: mixed-effects logistic regression on defect detection (defective items only) with fixed effect format, random intercepts for auditor and item, random format slope by auditor. Report marginal detection-rate difference with bootstrap 95% CI clustered by auditor and item. Specificity analysed symmetrically on defect-free items (this is where H-A4 lives: a format×confidence interaction on false "sound" verdicts). Time analysed on log scale with the same random-effects structure; non-inferiority margin +25%. Stratum (trained vs generalist) enters as an exploratory moderator. All defect-type breakdowns exploratory. Freeze list mirrors the replication prereg: response bank, defect key, assignment design, coding manual, analysis code dry-run on synthetic data, all hashed before recruitment.

## 6. Interpretation map

If H-A1 and H-A2 succeed, the project's core claim has direct evidence: formal structure makes model reasoning auditable by humans, independently of whether it improves model accuracy — and the predecessor's null on accuracy becomes a bounded loss rather than a refutation of the programme. If detection improves but H-A4 fails (formal dress inflates trust in flawed arguments), the honest conclusion is double-edged and important: scaffolds help skilled scrutiny and mislead casual scrutiny, which argues for scaffold-plus-training rather than scaffold-alone as the practice recommendation. If nothing improves, the auditability claim needs revision toward machine-checkable formats (schemas a parser can verify) rather than human-facing formatting. Every branch produces a publishable, decision-relevant result; none requires the predecessor experiment to have come out differently.
