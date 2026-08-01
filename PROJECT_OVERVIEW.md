# Project overview

## Formal argument scaffolding in LLM responses

This solo research project asks whether philosophy-inspired argument structure changes identifiable failures in LLM responses. The prompt requires the model to state a conclusion, identify the basis for each premise, classify its inferences, and assess alternatives before giving a final answer. Its relevance to Education AI Governance is a hypothesis for later study: formal critical-thinking instruction may give students a practical method for constructing and examining prompts rather than relying on generic advice to “check” AI outputs.

The project's argument is deliberately cumulative. The experiment demonstrates bounded causal changes in model-output behaviour. Those changes motivate, but do not prove, the educational hypothesis that formal critical-thinking education could help students construct and scrutinise AI-assisted reasoning more effectively.

The first experiment tested one model on one riddle. A locally frozen randomised schedule assigned 576 independent generations equally between an answer-only prompt and a formalised-argumentation prompt. The reviewer worked with opaque identifiers and without condition metadata or response IDs, although the visible formal template could reveal the likely condition. The primary scoring rule and statistical plan were fixed locally before final collection and published retrospectively rather than independently preregistered.

## Confirmatory finding

The formalised prompt did not improve strict committed correctness. It produced 170 correct responses from 288 calls (59.0%). The answer-only prompt produced 182 from 288 (63.2%). The estimated effect was -4.2 percentage points, with a 95% confidence interval from -12.0 to +3.8 points.

This estimate concerns the fixed riddle and model configuration. The experiment contains repeated generations of one item, so it cannot establish a general effect across reasoning problems.

## Exploratory causal effects within the experiment

The response diagnostics reveal a change in behaviour. Formalised responses identified the intended solution 10.4 percentage points more often and were contradictory 11.1 points less often. Both contrasts remained statistically distinguishable from zero after Holm correction across the four exploratory outcomes. Randomisation supports a causal interpretation for this riddle, model configuration, and collection setting; the post-result selection of these outcomes means that they require confirmation on fresh data.

Formalised responses also expressed substantially more uncertainty about whether the intended solution followed uniquely from the facts.

This creates a distinction between three outcomes:

- **Recognition:** the response identifies the father solution.
- **Commitment:** the response selects that solution without qualification.
- **Calibration:** the response matches its confidence to what the premises support.

The original primary outcome combined these ideas. It rewarded recognition only when accompanied by decisive commitment. The formal prompt increased recognition and reduced commitment among recognisers, producing the negative net estimate.

The diagnostic comparisons are exploratory because they became central after the primary result was known. They generate hypotheses for a new study; they do not replace the frozen result.

## Education hypothesis

The experiment tested the effect of a prompt on model responses; it did not test students. It motivates a separate hypothesis that students trained to distinguish premises, evidence, assumptions, entailment, and weaker support will be better able to construct and audit formalised prompts. A learner study is required to test usability, transfer, error detection, calibration, and appropriate reliance.

## Measurement problem

The riddle asks how the nurse's statement is possible. The scoring rule requires the model to commit to fatherhood. Fatherhood fits the stated facts, while the text may permit other family arrangements as well.

The formal prompt instructs the model to distinguish entailment from support and to consider compatible alternatives. A careful response may identify fatherhood as the intended solution while refusing to call it uniquely established. The strict score treats that qualification as failure.

This tension makes item adjudication central to the next experiment. Future items should be classified as uniquely entailed or underdetermined before model responses are collected.

## Research programme

The next study should test multiple items and separate recognition, commitment, and calibration in advance. It should use a shared output budget large enough for both prompt conditions and two independent blinded reviewers.

A second design tests auditability directly. Human reviewers receive content-matched responses in prose or formalised format and attempt to detect seeded reasoning defects. That study measures whether structure helps people find and localise errors, which the first experiment did not measure.

## Repository contents

The repository provides the public response dataset, exact prompts, frozen numerical results, reproducible R and Python analyses, design evidence, figures, and follow-up study designs. The [README](README.md) explains the complete methodology and defines the statistical terms used in the reports. The [literature and policy context](docs/06_literature_and_policy_context.md) explains how the model-output evidence relates to prompting research, critical-thinking education, AI literacy, and human oversight without treating those connections as tested outcomes.

## Author

Rohan Neelala, BA Philosophy, Politics and Economics, University of Warwick.
