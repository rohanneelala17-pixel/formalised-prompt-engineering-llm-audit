# Sami-father human verification protocol

## Scope

Verify deterministic extraction and formal-structure parsing only. Keep automated and human variables separate. Do not calculate condition-level accuracy or treatment effects during verification.

## Codes

- `1` = Yes
- `0` = No
- `98` = Uncertain
- `99` = Not reviewed
- `NA_STRUCTURAL` = Inapplicable to answer-only responses (structural fields only)

Review status: Not started; In progress; Complete; Requires adjudication; Adjudicated.

Reviewer confidence: High; Medium; Low; Not recorded.

## Response verification

Read the complete response and compare it with the extracted final answer. A human auditable-correctness code of 1 requires exactly one usable final answer that clearly commits to the neonatal nurse being Sami's father. Ambiguous, contradictory, merely possible, missing, or unusable answers cannot receive 1. Enter corrected text only when the automated extraction is wrong.

## Formal verification

For formalised responses, verify conclusion, each numbered premise and its evidential basis/evidence/justification, each inference and its classification/justification, the alternative-answer section, and overall structural compliance. Answer-only response structural fields must remain `NA_STRUCTURAL`.

## Adjudication

Use `98` and status `Requires adjudication` when a semantic judgment cannot be resolved confidently. Do not overwrite automated columns. Stable response, premise, and inference identifiers must not be edited.

## Validation

Run:

`python -m src.sami_father_verification validate --response-entry data\sami_father_reasoning_v1\review\human_verification_entry.csv`

Premise and inference CSV exports may be supplied with `--premise-entry` and `--inference-entry`; they are joined through stable identifiers.
