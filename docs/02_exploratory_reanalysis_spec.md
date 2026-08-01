# Exploratory reanalysis specification: diagnostic contrasts in the locked Sami-father dataset

**Public repository note, 1 August 2026:** The private locked dataset used during analysis remains unpublished. GitHub contains `data/responses_with_locked_human_verification_public.csv` instead. Its SHA-256 is `f1f74c1877f5e79b576ed96233aec619ae26162e8a07def76556110f432c92d5`. The public release removes `review_row_id` and corrects nine stale note strings without changing any response, judgment, or result; see `data/RELEASE_NOTES.md`.

**Label governing every number produced under this spec:** EXPLORATORY / HYPOTHESIS-GENERATING. The contrasts below were selected after observing the primary result. They must never be reported as confirmatory, must always appear after the frozen primary result, and carry no licence to revise it.

**Input:** `data/responses_with_locked_human_verification_public.csv`. No API calls or recoding. This exploratory family was closed before the diagnostic script was run, but after the primary result was known.

## 1. What is defensible about these analyses, and what is not

In favour: the diagnostic codes (`identifies_nurse_as_samis_father_human`, `answer_contradictory_human`, `unresolved_possibility_human`, `answer_ambiguous_human`) were part of the prespecified human-verification protocol and were coded blind to condition, so the *measurements* are clean even though the *contrasts* are post hoc. Against: outcome selection after results, one item, one model configuration, overlapping non-exclusive codes, and a condition-specific repair intervention (all 27 truncation repairs in the formalised arm). Every table produced under this spec repeats this paragraph in condensed form as a footnote.

## 2. Closed exploratory contrast family (fixed before running)

Four between-condition contrasts, each formalised − answer-only, n = 288 per arm, using the same machinery as the frozen primary analysis (risk difference with Newcombe hybrid-Wilson 95% CI; Fisher exact two-sided p; odds ratio for context). Multiplicity handled by Holm–Bonferroni across exactly these four tests — the family is declared here and closed.

Expected results, computed from the frozen counts in `final_analysis_statistics.json` (the script run must reproduce these exactly from the response-level CSV; a mismatch is a stop-and-investigate event, not a shrug):

| Contrast (formalised − answer-only) | Formalised | Answer-only | RD (pp) | Newcombe 95% CI | OR | Fisher p | Holm-adj. p |
|---|---:|---:|---:|---|---:|---:|---:|
| Identifies father (recognition) | 214/288 | 184/288 | +10.42 | +2.87 to +17.80 | 1.64 | 0.0088 | 0.0099 |
| Contradictory | 72/288 | 104/288 | −11.11 | −18.46 to −3.59 | 0.59 | 0.0050 | 0.0099 |
| Unresolved possibility (hedging) | 49/288 | 2/288 | +16.32 | +12.02 to +21.11 | 29.32 | 1.5×10⁻¹³ | 6.0×10⁻¹³ |
| Ambiguous | 28/288 | 1/288 | +9.38 | +6.06 to +13.36 | 30.91 | 5.9×10⁻⁸ | 1.8×10⁻⁷ |

All four survive Holm adjustment comfortably. Interpretation ceiling: "the formalised prompt changed the distribution of response behaviours on this item"; not "the formalised prompt improves reasoning."

## 3. The decomposition analysis (the one that needs the response-level data)

The marginals only bound the key quantity. From the CSV, cross-tabulate per condition: recognition (`identifies_nurse_as_samis_father_human`) × primary outcome (`auditable_correct_answer_human`). Report, per condition:

1. P(committed-correct | identified father) — the **commitment rate among recognisers**. Marginal bounds give ≥98.9% (182/184) for answer-only and ≤79.4% (170/214) for formalised; the CSV yields exact values.
2. The full 2×2×2 of condition × identified × correct, plus, within formalised-identified-but-not-correct rows, the distribution across hedged / ambiguous / contradictory codes — i.e. *where* the recognition gain leaked away.
3. A waterfall decomposition of the −4.17 pp primary difference into recognition gain (+) and conditional-commitment loss (−), presented as arithmetic identity, not a causal model.

This decomposition is the empirical core of the recognition–commitment pattern, so it gets the strictest labelling: descriptive arithmetic on exploratory strata.

## 4. Sensitivity analyses (mirroring the frozen plan's structure)

Repeat the diagnostic contrasts after excluding the 27 repaired responses and their pair partners (261 pairs), and run paired recognition via exact McNemar using `pair_id`. The script derives repaired rows from the public `response_repair_applied` field and reports diagnostic counts among repaired formal responses separately.

After exclusion, the recognition difference is +13.0 percentage points and the contradiction difference is -13.4 points. Unresolved-possibility language increases by 16.1 points and ambiguity by 8.4 points. The pattern is therefore not concentrated in repaired outputs. These remain exploratory, post-result comparisons.

## 5. Runnable script

`analysis/exploratory_diagnostics.py` implements Sections 2–4 against the public CSV with a hash check. It reproduces the frozen primary result and the expected diagnostic counts. Run from the repository root:

```
python analysis/exploratory_diagnostics.py --dataset data/responses_with_locked_human_verification_public.csv --out results/exploratory_diagnostics.json
```

The script writes JSON only; it modifies nothing. Column names are asserted against the handoff's naming convention (`_human` suffixes) and the run aborts on any mismatch rather than guessing.

## 6. Reporting rules

Every figure or table from this spec carries the word "exploratory" in its caption. The write-up presents Section 2 and 3 results only after the frozen primary table, never in the abstract's first sentence, and always with the recognition gain and commitment loss reported together. The results' proper use is as empirical motivation for the proposed replication's separated outcomes, where recognition, commitment, and calibration would each receive a pre-declared test.
