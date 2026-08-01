"""Verify the public dataset, prompt files, and frozen response counts."""

from __future__ import annotations

import csv
import hashlib
import json
import os
from collections import Counter
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATASET = ROOT / "data/responses_with_locked_human_verification_public.csv"
FROZEN = ROOT / "data/final_analysis_statistics.json"
LPM_RESULTS = ROOT / "results/lpm_results.csv"
EXPLORATORY_RESULTS = ROOT / "results/exploratory_diagnostics.json"
PUBLIC_SCHEDULE = ROOT / "design/schedule_public.csv"
FROZEN_PLAN = ROOT / "design/frozen_analysis_plan.md"
REVIEW_PROTOCOL = ROOT / "design/human_verification_protocol.md"
PROMPTS = {
    ROOT / "prompts/answer_only.txt": (
        "25bb401fb26940d0dbc0fc959303ecf809d38eacce9688f22712413dab3a3b3d"
    ),
    ROOT / "prompts/formalised_argumentation.txt": (
        "503efed385205feccf5af46b6db84cc3d25592561ffef71445773e0033b297b4"
    ),
}
PUBLIC_DATASET_SHA256 = (
    "f1f74c1877f5e79b576ed96233aec619ae26162e8a07def76556110f432c92d5"
)
FROZEN_STATISTICS_SHA256 = (
    "7150ea19ebc19a5092eb882f4aee0ccc59bd36d444a57712f0ca2f27b4208b3e"
)
PUBLIC_SCHEDULE_SHA256 = (
    "9d7331a0cbbc4f7207af28ab64433805b6ebc703673d5328fef122c7620d3322"
)
FROZEN_PLAN_SHA256 = (
    "c79f085943fba11028a355da0a37b12b10b62859d214dc244fae0f9c2cb2271b"
)
REVIEW_PROTOCOL_SHA256 = (
    "b905634282184e2136b08e85a4f6115ac1dbd9ee8dbb7dca7bbb869a09d1891a"
)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def sha256_canonical_text(path: Path) -> str:
    """Hash UTF-8 text with LF newlines on every operating system."""
    content = path.read_bytes().replace(b"\r\n", b"\n")
    return hashlib.sha256(content).hexdigest()


def main() -> int:
    assert sha256(DATASET) == PUBLIC_DATASET_SHA256, "public dataset hash mismatch"
    assert sha256(FROZEN) == FROZEN_STATISTICS_SHA256, "frozen statistics hash mismatch"
    assert sha256_canonical_text(PUBLIC_SCHEDULE) == PUBLIC_SCHEDULE_SHA256, "public schedule hash mismatch"
    assert sha256_canonical_text(FROZEN_PLAN) == FROZEN_PLAN_SHA256, "frozen analysis-plan hash mismatch"
    assert sha256_canonical_text(REVIEW_PROTOCOL) == REVIEW_PROTOCOL_SHA256, "review protocol hash mismatch"
    for path, expected in PROMPTS.items():
        assert sha256(path) == expected, f"prompt hash mismatch: {path.name}"

    with DATASET.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    frozen = json.loads(FROZEN.read_text(encoding="utf-8"))
    exploratory = json.loads(EXPLORATORY_RESULTS.read_text(encoding="utf-8"))

    assert len(rows) == 576
    assert len({row["response_id"] for row in rows}) == 576
    assert "review_row_id" not in rows[0]
    assert Counter(row["prompt_condition"] for row in rows) == {
        "answer_only": 288,
        "formalised_argumentation": 288,
    }
    assert Counter(
        (row["prompt_condition"], row["formalised_argumentation_requested"])
        for row in rows
    ) == {
        ("answer_only", "0"): 288,
        ("formalised_argumentation", "1"): 288,
    }
    assert all(row["review_status_human"] == "Complete" for row in rows)
    assert all(row["auditable_correct_answer_human"] in {"0", "1"} for row in rows)
    assert not any(
        row["reviewer_notes_human"].startswith("[SYSTEM RECONCILIATION]")
        for row in rows
    ), "stale reconciliation instruction remains in public dataset"

    with PUBLIC_SCHEDULE.open(encoding="utf-8-sig", newline="") as handle:
        schedule = list(csv.DictReader(handle))
    assert len(schedule) == 576
    assert len({row["response_id"] for row in schedule}) == 576
    schedule_by_id = {row["response_id"]: row for row in schedule}
    assert set(schedule_by_id) == {row["response_id"] for row in rows}
    for row in rows:
        scheduled = schedule_by_id[row["response_id"]]
        assert scheduled["pair_id"] == row["pair_id"]
        assert scheduled["prompt_condition"] == row["prompt_condition"]
        assert scheduled["formalised_argumentation_requested"] == row["formalised_argumentation_requested"]
        assert scheduled["generation_number"] == row["generation_number"]
        assert scheduled["randomised_call_order"] == row["randomised_call_order"]

    correct = Counter(
        row["prompt_condition"]
        for row in rows
        if row["auditable_correct_answer_human"] == "1"
    )
    assert correct == frozen["human_verified_correct"]
    assert exploratory["dataset_sha256"] == PUBLIC_DATASET_SHA256

    forbidden_names = {
        "private_accuracy_review_linkage.csv",
        "private_gold_answer.csv",
        ".env",
    }
    excluded_dirs = {".git", ".venv", ".r-library", "library", "staging"}
    for current, dirs, files in os.walk(ROOT):
        dirs[:] = [name for name in dirs if name not in excluded_dirs]
        for name in files:
            path = Path(current, name)
            assert name not in forbidden_names, f"private artifact present: {path}"

    with LPM_RESULTS.open(encoding="utf-8", newline="") as handle:
        lpm_rows = {row["outcome"]: row for row in csv.DictReader(handle)}
    expected_lpm = {
        "auditable_correct_answer_human": -1 / 24,
        "identifies_nurse_as_samis_father_human": 5 / 48,
        "answer_contradictory_human": -1 / 9,
        "unresolved_possibility_human": 47 / 288,
        "answer_ambiguous_human": 27 / 288,
    }
    assert set(lpm_rows) == set(expected_lpm)
    for outcome, expected in expected_lpm.items():
        observed = float(lpm_rows[outcome]["risk_difference"])
        assert abs(observed - expected) < 1e-12, f"LPM mismatch: {outcome}"

    print("Repository verification passed.")
    print(f"Public dataset SHA-256: {PUBLIC_DATASET_SHA256}")
    print(f"Frozen statistics SHA-256: {FROZEN_STATISTICS_SHA256}")
    print("Rows: 576; unique response IDs: 576; complete reviews: 576")
    print("Strict correct: answer-only 182/288; formalised 170/288")
    print("Linear probability model results reconcile with frozen counts.")
    print("Public schedule, frozen plan, and review protocol hashes verified.")
    print("Public-release privacy filename scan passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
