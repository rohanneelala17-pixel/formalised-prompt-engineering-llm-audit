# Project summary

## Formal argument scaffolding in LLM responses

Students are often told to check AI-generated answers, but “check it” is not an operational method. This project asks whether concepts from formal critical thinking—premises, evidence, assumptions, inference classification, entailment, and alternative explanations—can be translated into a practical prompting protocol. The experiment tested the protocol on model outputs; it did not test students or classroom use.

The study used an adapted surgeon riddle as a bias-sensitive stress test. The same model answered it 576 times under random assignment: 288 answer-only responses and 288 responses requiring a formalised argument. One reviewer coded the outcomes using opaque identifiers and without condition metadata or response IDs, although the visible formal template could reveal the likely condition. Prompts, schedule, primary outcome, and analysis plan were frozen locally before final collection; the supporting records were published retrospectively and were not independently preregistered.

The prespecified strict-correctness result was null. Answer-only prompting produced 182 successes from 288 responses (63.2%); formalisation produced 170 from 288 (59.0%). The estimated difference was -4.2 percentage points, with a 95% confidence interval from -12.0 to +3.8 points.

Exploratory diagnostics show a more complicated behavioural change:

| Outcome | Answer-only | Formalised | Effect |
|---|---:|---:|---:|
| Identified the intended solution | 63.9% | 74.3% | +10.4 points |
| Contained a contradiction | 36.1% | 25.0% | -11.1 points |
| Left the answer unresolved | 0.7% | 17.0% | +16.3 points |
| Was coded ambiguous | 0.3% | 9.7% | +9.4 points |

Random assignment supports a causal interpretation of these prompt effects for the tested riddle, model, and collection environment. The diagnostic outcomes became central after the primary result was known, so they are hypothesis-generating rather than confirmatory. The defensible conclusion is that the scaffold changed response behaviour—not that it improved correctness or reasoning overall.

The pattern exposes a measurement problem. The riddle asks for a possible explanation, while the frozen outcome rewards only unqualified commitment to the intended father solution. Formalised responses more often recognised that solution but also more often noted that it was not uniquely entailed. A future study should adjudicate item entailment in advance and measure recognition, contradiction avoidance, ambiguity, qualification, and commitment separately.

For Education AI Governance, the project supplies a model-facing case study and an operational research workflow. It motivates a separate learner hypothesis: formal critical-thinking education may help students construct prompts, expose assumptions, and evaluate whether conclusions follow from evidence. That educational effect and human auditability remain untested. The scaffold is therefore a candidate audit practice and teaching artefact, not a demonstrated educational intervention or regulatory compliance mechanism.

The repository demonstrates frozen decision records, stable identifiers, file hashes, metadata-blinded review, separation of automated and reviewer judgments, repair provenance, public amendments, and reproducible Python and R analysis. Its [literature and policy context](docs/06_literature_and_policy_context.md) explains what related evidence makes plausible and where new human data would be required.

[View the complete evidence and reproduction materials](README.md).
