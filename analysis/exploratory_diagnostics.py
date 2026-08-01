"""Exploratory diagnostic reanalysis for the Sami-father experiment.

EXPLORATORY / HYPOTHESIS-GENERATING. Contrasts chosen after observing the
frozen primary result. Never report output of this script as confirmatory.

Reads the locked response-level dataset READ-ONLY and writes a JSON report.
Aborts if expected columns are missing or the file hash does not match one of
the two documented locked datasets (unless --skip-hash-check). Implements sections 2-4 of
02_exploratory_reanalysis_spec.md.

Usage:
  python exploratory_diagnostics.py \
      --dataset data/responses_with_locked_human_verification_public.csv \
      --out results/exploratory_diagnostics.json \
      [--skip-hash-check]

Dependencies: pandas, scipy.
"""

import argparse
import hashlib
import json
import math
import sys

import pandas as pd
from scipy import stats

EXPECTED_DATASET_HASHES = {
    # Private original. This includes review_row_id and is not published.
    "e1a15f7898cf1885ec69e24c718f768d27ad7844e02ba54101dc3a1f3e720e7e": "private locked dataset",
    # Public release. review_row_id is omitted and nine stale reconciliation
    # instructions were replaced without changing any response or judgment.
    "f1f74c1877f5e79b576ed96233aec619ae26162e8a07def76556110f432c92d5": "public release dataset",
}

COND_COL = "prompt_condition"
COND_FORMAL = "formalised_argumentation"
COND_ANSWER = "answer_only"
PRIMARY = "auditable_correct_answer_human"
RECOG = "identifies_nurse_as_samis_father_human"
CONTRA = "answer_contradictory_human"
UNRES = "unresolved_possibility_human"
AMBIG = "answer_ambiguous_human"
PAIR = "pair_id"
RESP_ID = "response_id"
REPAIR_APPLIED = "response_repair_applied"

DIAGNOSTICS = [
    ("recognition", RECOG),
    ("contradictory", CONTRA),
    ("unresolved_possibility", UNRES),
    ("ambiguous", AMBIG),
]

# Frozen counts from reports/final_analysis_statistics.json. The CSV must
# reproduce these exactly; any mismatch aborts the run.
FROZEN = {
    "n_per_arm": 288,
    "primary": {COND_ANSWER: 182, COND_FORMAL: 170},
    RECOG: {COND_ANSWER: 184, COND_FORMAL: 214},
    CONTRA: {COND_ANSWER: 104, COND_FORMAL: 72},
    UNRES: {COND_ANSWER: 2, COND_FORMAL: 49},
    AMBIG: {COND_ANSWER: 1, COND_FORMAL: 28},
}

EXPLORATORY_NOTE = (
    "EXPLORATORY: contrasts selected after observing the primary result. "
    "Measurements were coded by one condition-blinded reviewer under a frozen protocol; the contrasts "
    "are post hoc. One item, one model configuration; 27 condition-specific "
    "truncation repairs in the formalised arm."
)


def wilson(k, n, z):
    p = k / n
    d = 1 + z * z / n
    c = p + z * z / (2 * n)
    e = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return (c - e) / d, (c + e) / d


def newcombe(k1, n1, k2, n2, conf=0.95):
    """Risk difference p1 - p2 with Newcombe hybrid-Wilson CI."""
    z = stats.norm.ppf(1 - (1 - conf) / 2)
    l1, u1 = wilson(k1, n1, z)
    l2, u2 = wilson(k2, n2, z)
    p1, p2 = k1 / n1, k2 / n2
    d = p1 - p2
    lo = d - math.sqrt((p1 - l1) ** 2 + (u2 - p2) ** 2)
    hi = d + math.sqrt((u1 - p1) ** 2 + (p2 - l2) ** 2)
    return d, lo, hi


def contrast(k_f, k_a, n):
    d, lo, hi = newcombe(k_f, n, k_a, n)
    orr, p = stats.fisher_exact([[k_f, n - k_f], [k_a, n - k_a]], alternative="two-sided")
    return {
        "formalised": f"{k_f}/{n}",
        "answer_only": f"{k_a}/{n}",
        "risk_difference": d,
        "newcombe_95_ci": [lo, hi],
        "odds_ratio": orr,
        "fisher_exact_two_sided_p": p,
    }


def holm(pvals):
    order = sorted(range(len(pvals)), key=lambda i: pvals[i])
    m = len(pvals)
    adj = [None] * m
    running = 0.0
    for rank, i in enumerate(order):
        running = max(running, min(1.0, (m - rank) * pvals[i]))
        adj[i] = running
    return adj


def mcnemar_exact(b, c):
    """Exact binomial McNemar on discordant counts b, c."""
    n = b + c
    if n == 0:
        return 1.0
    res = stats.binomtest(min(b, c), n, 0.5, alternative="two-sided")
    return res.pvalue


def die(msg):
    sys.exit(f"ABORT: {msg}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dataset", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--skip-hash-check", action="store_true")
    args = ap.parse_args()

    with open(args.dataset, "rb") as fh:
        digest = hashlib.sha256(fh.read()).hexdigest()
    if digest not in EXPECTED_DATASET_HASHES and not args.skip_hash_check:
        expected = ", ".join(sorted(EXPECTED_DATASET_HASHES))
        die(f"dataset SHA-256 {digest} is not an expected locked-dataset hash. "
            f"Expected one of: {expected}. Verify the dataset, or pass "
            "--skip-hash-check and document why.")

    df = pd.read_csv(args.dataset)
    needed = [
        COND_COL, PRIMARY, RECOG, CONTRA, UNRES, AMBIG, PAIR, RESP_ID,
        REPAIR_APPLIED,
    ]
    missing = [c for c in needed if c not in df.columns]
    if missing:
        die(f"missing expected columns {missing}; refusing to guess. "
            f"Available: {sorted(df.columns)}")

    f = df[df[COND_COL] == COND_FORMAL]
    a = df[df[COND_COL] == COND_ANSWER]
    n = FROZEN["n_per_arm"]
    if len(f) != n or len(a) != n:
        die(f"arm sizes {len(f)}/{len(a)} != {n}/{n}")

    # Reconcile against frozen counts before doing anything else.
    for col, frozen in [(PRIMARY, FROZEN["primary"])] + [
        (c, FROZEN[c]) for _, c in DIAGNOSTICS
    ]:
        got_a, got_f = int(a[col].sum()), int(f[col].sum())
        if got_a != frozen[COND_ANSWER] or got_f != frozen[COND_FORMAL]:
            die(f"count mismatch for {col}: CSV gives AO={got_a}, F={got_f}; "
                f"frozen JSON says AO={frozen[COND_ANSWER]}, F={frozen[COND_FORMAL]}. "
                "Stop and investigate; do not proceed.")

    report = {
        "note": EXPLORATORY_NOTE,
        "dataset_sha256": digest,
        "dataset_variant": EXPECTED_DATASET_HASHES.get(digest, "unverified custom dataset"),
    }

    # Section 2: closed post-result exploratory contrast family + Holm.
    contrasts = {}
    for name, col in DIAGNOSTICS:
        contrasts[name] = contrast(int(f[col].sum()), int(a[col].sum()), n)
    adj = holm([contrasts[name]["fisher_exact_two_sided_p"] for name, _ in DIAGNOSTICS])
    for (name, _), p_adj in zip(DIAGNOSTICS, adj):
        contrasts[name]["holm_adjusted_p"] = p_adj
    report["section2_contrasts"] = contrasts

    # Section 3: recognition x commitment decomposition.
    decomp = {}
    for label, arm in [("answer_only", a), ("formalised_argumentation", f)]:
        ident = arm[arm[RECOG] == 1]
        not_ident = arm[arm[RECOG] == 0]
        ident_correct = int(ident[PRIMARY].sum())
        leak = ident[ident[PRIMARY] == 0]
        decomp[label] = {
            "identified": len(ident),
            "identified_and_correct": ident_correct,
            "commitment_rate_among_recognisers": ident_correct / len(ident) if len(ident) else None,
            "correct_without_identification": int(not_ident[PRIMARY].sum()),
            "identified_not_correct_breakdown": {
                "unresolved_possibility": int(leak[UNRES].sum()),
                "ambiguous": int(leak[AMBIG].sum()),
                "contradictory": int(leak[CONTRA].sum()),
                "total": len(leak),
                "note": "codes overlap; rows may carry more than one",
            },
        }
    # Waterfall: arithmetic identity, not a causal model.
    p_rec_a, p_rec_f = decomp["answer_only"]["identified"] / n, decomp["formalised_argumentation"]["identified"] / n
    p_com_a = decomp["answer_only"]["commitment_rate_among_recognisers"]
    p_com_f = decomp["formalised_argumentation"]["commitment_rate_among_recognisers"]
    decomp["waterfall_pp"] = {
        "recognition_component": (p_rec_f - p_rec_a) * p_com_a * 100,
        "commitment_component": p_rec_f * (p_com_f - p_com_a) * 100,
        "non_recognition_correct_component": (
            decomp["formalised_argumentation"]["correct_without_identification"]
            - decomp["answer_only"]["correct_without_identification"]
        ) / n * 100,
        "note": "components sum to the primary risk difference (in pp); descriptive arithmetic only",
    }
    report["section3_decomposition"] = decomp

    # Section 4a: paired McNemar on recognition.
    wide = df.pivot(index=PAIR, columns=COND_COL, values=RECOG)
    if wide.isna().any().any() or len(wide) != n:
        die("pair_id pivot malformed; expected 288 complete pairs")
    b = int(((wide[COND_FORMAL] == 1) & (wide[COND_ANSWER] == 0)).sum())
    c = int(((wide[COND_FORMAL] == 0) & (wide[COND_ANSWER] == 1)).sum())
    report["section4_recognition_mcnemar"] = {
        "formal_only_identified": b,
        "answer_only_only_identified": c,
        "exact_two_sided_p": mcnemar_exact(b, c),
    }

    # Section 4b: exclude every repaired response and its matched pair partner.
    # The public release contains the repair indicator, so this sensitivity does
    # not depend on a private mapping file.
    repair_flag = pd.to_numeric(df[REPAIR_APPLIED], errors="raise")
    if not set(repair_flag.unique()).issubset({0, 1}):
        die(f"{REPAIR_APPLIED} must contain only 0/1")
    repaired_rows = df[repair_flag == 1]
    if len(repaired_rows) != 27 or not (repaired_rows[COND_COL] == COND_FORMAL).all():
        die("expected exactly 27 repaired rows, all in the formalised arm")
    excl_pairs = set(repaired_rows[PAIR])
    kept = df[~df[PAIR].isin(excl_pairs)]
    kf = kept[kept[COND_COL] == COND_FORMAL]
    ka = kept[kept[COND_COL] == COND_ANSWER]
    if len(kf) != 261 or len(ka) != 261:
        die("repair exclusion did not leave 261 matched pairs")
    repair_contrasts = {
        name: contrast(int(kf[col].sum()), int(ka[col].sum()), len(kf))
        for name, col in DIAGNOSTICS
    }
    repair_adj = holm([
        repair_contrasts[name]["fisher_exact_two_sided_p"]
        for name, _ in DIAGNOSTICS
    ])
    for (name, _), p_adj in zip(DIAGNOSTICS, repair_adj):
        repair_contrasts[name]["holm_adjusted_p"] = p_adj
    report["section4_repair_exclusion"] = {
        "excluded_pairs": len(excl_pairs),
        "remaining_pairs": int(len(kept) / 2),
        "contrasts": repair_contrasts,
        "diagnostics_among_repaired_formal_rows": {
            name: int(repaired_rows[col].sum()) for name, col in DIAGNOSTICS
        },
        "repaired_formal_rows": len(repaired_rows),
    }

    with open(args.out, "w") as fh:
        json.dump(report, fh, indent=2, default=float)
    print(f"Wrote {args.out}")
    print(EXPLORATORY_NOTE)


if __name__ == "__main__":
    main()
