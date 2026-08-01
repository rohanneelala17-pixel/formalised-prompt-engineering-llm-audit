# Literature and policy context

## The project's argument

Formal critical-thinking methods can be translated into a structured prompting protocol. In this experiment, that protocol causally changed the model's responses: it increased identification of the intended solution and reduced contradiction, although it did not improve the prespecified strict-correctness outcome and also increased qualification and ambiguity. These results motivate, but do not yet prove, the educational hypothesis that formal critical-thinking education could help students construct and scrutinise AI-assisted reasoning more effectively.

That argument contains three distinct claims:

1. **Demonstrated in this experiment:** random assignment to the formalised prompt changed the response distribution for one riddle and model configuration.
2. **Suggested by the pattern:** explicit premises, inference labels, and alternative checks may make some reasoning failures easier to expose, but the experiment does not identify which component caused each change or whether the displayed reasoning was faithful to the model's internal process.
3. **Proposed for future study:** sustained education in argument structure may help people construct and audit AI-assisted reasoning. No students or human auditors were tested here.

Keeping these levels separate allows the project to make a positive contribution without treating a model-output pilot as evidence about classroom learning or regulatory compliance.

## Structured prompting and inspectable reasoning

The formalised prompt is not ordinary chain-of-thought prompting. It combines conclusion-first argument mapping, separation of premises from evidence, inference classification, alternative checking, and a constrained final-answer format. Adjacent prompting research shows that decomposition and planning can improve performance on some tasks, including least-to-most prompting and plan-and-solve prompting ([Zhou et al., 2022](https://arxiv.org/abs/2205.10625); [Wang et al., 2023](https://arxiv.org/abs/2305.04091)). Those findings establish plausible neighbouring methods, not prior validation of this particular scaffold.

Prompt format can itself change model behaviour. Sclar et al. found large performance variation across meaning-preserving prompt formats, including changes in model rankings ([Sclar et al., 2024](https://arxiv.org/abs/2310.11324)). That evidence makes the present randomised contrast substantively interesting, but it also means the experiment cannot attribute its effects to a single component of the composite prompt. The current result is therefore about the complete protocol as implemented.

The experiment found two potentially useful exploratory changes. Identification of the intended father solution increased by 10.4 percentage points, and contradiction decreased by 11.1 points. It also found a cost: unresolved-possibility language increased by 16.3 points and ambiguity by 9.4 points. The prespecified strict-correctness outcome consequently did not improve. These four exploratory contrasts were selected after the primary result was known and require confirmation on new data, but random assignment supports a causal interpretation within the fixed experiment.

## Readability is not proof of faithful reasoning

A structured explanation can be easier to inspect without revealing the computation that actually determined the answer. Turpin et al. showed that models can produce plausible explanations that omit biasing features which changed their answers ([Turpin et al., 2023](https://arxiv.org/abs/2305.04388)). Lanham et al. likewise found that dependence on stated reasoning varies substantially across tasks and models ([Lanham et al., 2023](https://arxiv.org/abs/2307.13702)). These studies justify caution about treating a polished rationale as a transparent record of internal reasoning.

They do not establish that unfaithful rationalisation caused this project's results. The observed pattern is also compatible with better inspection of the stated constraints, mandatory enumeration of alternatives, increased verbosity, or greater caution produced by the template. The appropriate inference is behavioural: the scaffold changed what the model wrote in several measurable ways. Determining why would require component comparisons or interventions on the stated reasoning.

The riddle's underdetermination is relevant here. Fan et al. found that specialised reasoning models can over-elaborate on questions with missing premises rather than identifying the problem efficiently ([Fan et al., 2025](https://arxiv.org/abs/2504.06514)). This is a useful analogue for the increased qualification observed here, but it is not a direct explanation: the present experiment used a different model, prompt, and task.

## What one item can establish

The 576 responses provide a comparatively precise view of output variation for the tested riddle and model configuration. They do not provide variation across questions. Research on generalisability warns that statistical precision over repeated observations of a fixed stimulus cannot substitute for sampling the stimuli, tasks, or settings to which a claim is intended to extend ([Yarkoni, 2022](https://pubmed.ncbi.nlm.nih.gov/33342451/)).

This does not invalidate the randomised comparison. It means the causal claim is conditional: it describes what assigning this formalised prompt rather than the answer-only prompt did to responses in this setting. The wider claim that formal scaffolding improves a class of reasoning tasks requires a multi-item replication.

## Education: a plausible hypothesis, not a tested outcome

The project's educational premise is that students need something more operational than an instruction to "check" an AI answer. The scaffold offers a candidate method: identify the conclusion, distinguish stated facts from assumptions, examine the evidence for each premise, classify the strength of inferences, and test alternatives.

Research on critical-thinking education supports the plausibility of teaching such practices while warning against a one-shot intervention. A meta-analysis by Abrami et al. found that critical-thinking instruction can improve skills and dispositions, with outcomes depending on how explicitly and effectively it is taught ([Abrami et al., 2008](https://doi.org/10.3102/0034654308326084)). Willingham argues that critical thinking depends heavily on domain knowledge and practice rather than operating as a context-free skill ([Willingham, 2008](https://doi.org/10.3200/AEPR.109.4.21-32)). Kuhn and Crowell demonstrated transfer after sustained dialogic argumentation practice, not after exposure to a single template ([Kuhn and Crowell, 2011](https://pubmed.ncbi.nlm.nih.gov/21422465/)).

The resulting education hypothesis is deliberately bounded: formal argument scaffolding may be useful as an audit-time tool and as one teaching artefact within sustained, domain-informed critical-AI-literacy education. The model-output experiment does not show that giving students the template would by itself improve learning, error detection, or reliance decisions.

This direction is consistent with UNESCO's AI Competency Framework for Students, which emphasises critical judgement of AI solutions alongside knowledge, ethics, and human agency ([UNESCO, 2024](https://www.unesco.org/en/articles/ai-competency-framework-students?hub=66925)). The framework supports the importance of the educational problem; it does not endorse or validate this particular method.

## Policy context: AI literacy and human oversight

The policy relevance is strongest when the scaffold is treated as a candidate micro-skill for scrutiny, not as a compliance mechanism.

As amended by Regulation (EU) 2026/1744, Article 4 of the EU AI Act requires providers and deployers to take measures supporting the development of AI literacy among staff and other people operating AI systems on their behalf. It does not require them to guarantee a particular level for every individual ([Regulation (EU) 2026/1744](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32026R1744); [European Commission guidance](https://digital-strategy.ec.europa.eu/en/faqs/ai-literacy-questions-answers)). This creates a demand for evidence about whether proposed literacy measures improve behaviour, rather than merely confidence or familiarity.

Education is not categorically high-risk under the Act. Annex III covers specified uses, including admissions or assignment, evaluation of learning outcomes, assessment of the level of education a person may receive, and monitoring prohibited behaviour during tests. The relevant Chapter III provisions for Annex III systems apply from 2 December 2027 ([Annex III](https://ai-act-service-desk.ec.europa.eu/en/ai-act/annex-3); [Regulation (EU) 2026/1744](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32026R1744)).

For high-risk systems, Article 14 requires human oversight arrangements that allow appropriately authorised people to understand limitations, recognise automation bias, interpret outputs, disregard or override them, and intervene where necessary ([Article 14](https://ai-act-service-desk.ec.europa.eu/en/ai-act/article-14)). Premise checking and inference classification are conceptually relevant to interpretation and resistance to over-reliance, but an individual reasoning checklist cannot substitute for system documentation, provider-side risk management, suitable interfaces, organisational accountability, or the authority to stop a system.

Laux's account of "institutionalised distrust" reinforces this distinction: effective oversight depends on competence and institutional design, and proposed oversight arrangements need behavioural evidence rather than assumed human reliability ([Laux, 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11614927/)). The project's planned human-auditability study is therefore the appropriate next test of its policy-facing claim.

## Contribution and next evidential step

The completed experiment contributes evidence that a formal argument scaffold can produce desirable and undesirable causal changes at the same time. It increased intended-solution identification and reduced contradiction, while increasing qualification and ambiguity and leaving strict committed correctness unimproved. That combination is more informative for governance than a simple claim that the prompt "worked" or "failed": evaluation criteria determine which changes count as success.

The next decisive question is human-facing. If content-matched formalised responses help people detect and localise reasoning defects without creating misplaced trust, the scaffold would have direct evidence as an audit aid. If they change confidence without improving detection, or make weak reasoning look more authoritative, its educational use would need revision. The present project establishes the rationale and a reproducible way to investigate that question; it does not claim the answer in advance.
