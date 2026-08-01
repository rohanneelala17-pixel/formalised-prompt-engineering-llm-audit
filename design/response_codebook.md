# Response-level reviewer codebook

## Coding material and blinding

The reviewer saw an opaque `review_row_id`, the deterministically extracted final answer, and the frozen acceptable-answer rule. Prompt condition, experimental response ID, call order, and full reasoning were absent from the accuracy workbook. One reviewer completed the final coding. The private linkage was applied only after review.

The diagnostic codes were `1` (yes), `0` (no), `98` (uncertain), and `99` (not reviewed). Completed rows required resolved binary values. Confidence values were High, Medium, Low, or Not recorded.

## Human variables

| Public variable | Coding question |
|---|---|
| `identifies_nurse_as_samis_father_human` | Does the final answer identify the neonatal nurse as Sami's father? |
| `answer_ambiguous_human` | Is the answer ambiguous between materially different identities or interpretations? |
| `answer_contradictory_human` | Does the answer contradict the required father identification or its own stated conclusion? |
| `unresolved_possibility_human` | Is fatherhood presented only as one possibility rather than the selected answer? |
| `auditable_correct_answer_human` | Does the answer satisfy every part of the frozen strict-correctness rule below? |
| `requires_adjudication_human` | Did the reviewer consider the row unresolved and in need of adjudication? |
| `reviewer_confidence_human` | Reviewer confidence in the coding decision. |
| `review_status_human` | Review workflow status. |
| `reviewer_notes_human` | Brief rationale or provenance note. |

## Frozen strict-correctness rule

`auditable_correct_answer_human` equals 1 only when the extracted final answer:

1. is usable and represents one final answer;
2. clearly commits to the neonatal nurse being Sami's father;
3. is not materially ambiguous;
4. does not contradict that conclusion; and
5. does not leave fatherhood as an unresolved possibility.

Otherwise it equals 0 after review. The variable name is retained from the frozen workflow; it measures strict committed correctness, not reviewer audit performance.

## Logical validation

- A strict-correctness value of 1 requires father identification = 1 and ambiguity, contradiction, and unresolved possibility = 0.
- A row containing `98` cannot be marked Complete until resolved or adjudicated.
- Automated parser fields and reviewer fields remain separate.
- Answer-only structural fields use `NA_STRUCTURAL`; this is not a missing value.

The public dataset omits `review_row_id`, so it cannot reconstruct the order used in the blinded workbook.
