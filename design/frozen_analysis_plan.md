# Preregistration-style analysis plan

## Scope

This study estimates the prompt-condition effect for one frozen Sami riddle, GPT-5.6 Luna, low reasoning effort, and the recorded collection environment. Independent generations characterise the model’s stochastic response distribution for this fixed riddle; they do not support item-level generalisation to riddles generally.

## Primary outcome and contrast

The primary binary outcome is `auditable_correct_answer`. It equals 1 only when exactly one identifiable `FINAL ANSWER:` field commits to the neonatal nurse being Sami’s father; otherwise it equals 0. The primary contrast is the formalised-argumentation correct-auditable rate minus the answer-only rate.

Report each condition proportion, absolute risk difference, relative risk where defined, a Newcombe confidence interval based on Wilson intervals for the two independent binomial proportions, and a two-sided randomisation/permutation test respecting the fixed balanced assignment counts. Fisher’s exact test is a prespecified exact sensitivity analysis. Report missing, malformed, and non-extractable responses by condition.

## Equivalence

The primary equivalence margin is ±10 percentage points. A ten-point change is large enough to matter operationally for this fixed task and is potentially estimable with the recommended design; ±5 points is a stricter secondary sensitivity margin whose precision requirements are substantially greater. Use two one-sided tests and the corresponding 90% confidence interval. Report conclusions under both ±10 and ±5 percentage-point margins without switching the primary margin after observing results.

## Regularity and exact methods

Assess whether each condition has adequate expected successes and failures for normal approximations. When rates approach zero or one, prioritise Wilson/Newcombe and exact or randomisation-based methods. The central limit theorem concerns the condition-specific sample proportions under independent generation and stable collection conditions.

## Collection order and temporal drift

Record timestamps and randomised call order. If collection spans a meaningful interval, fit a prespecified sensitivity model with condition, scaled call order, and their interaction, and compare early versus late collection strata. Treat this as a stability check, not a replacement for the randomised primary contrast.

## Secondary outcomes

Formal-argument structure and auditability outcomes are secondary manipulation/compliance measures. Do not combine them with answer correctness. Semantic claims about unsupported assumptions and decisive premises require blinded human review when no deterministic rule applies.
