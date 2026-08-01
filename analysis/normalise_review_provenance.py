"""Replace nine stale reconciliation instructions in the public release.

The final review workbook contains completed post-repair codes for these rows,
but its note column retained an earlier instruction to re-review them. This
release-only correction changes that note text and no response or judgment.
"""

from __future__ import annotations

import csv
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATASET = ROOT / "data/responses_with_locked_human_verification_public.csv"
TARGET_IDS = {
    "SFR_V3_RECOMMENDED_G0048_FA",
    "SFR_V3_RECOMMENDED_G0066_FA",
    "SFR_V3_RECOMMENDED_G0080_FA",
    "SFR_V3_RECOMMENDED_G0119_FA",
    "SFR_V3_RECOMMENDED_G0150_FA",
    "SFR_V3_RECOMMENDED_G0166_FA",
    "SFR_V3_RECOMMENDED_G0174_FA",
    "SFR_V3_RECOMMENDED_G0196_FA",
    "SFR_V3_RECOMMENDED_G0263_FA",
}
OLD_PREFIX = "[SYSTEM RECONCILIATION]"
NEW_NOTE = (
    "Post-repair coding applies to the complete repaired answer. "
    "The earlier pre-repair code was not carried forward."
)


def main() -> int:
    with DATASET.open(encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        fieldnames = reader.fieldnames
        rows = list(reader)
    if fieldnames is None:
        raise RuntimeError("dataset has no header")

    changed = set()
    for row in rows:
        if row["response_id"] not in TARGET_IDS:
            continue
        note = row["reviewer_notes_human"]
        if note == NEW_NOTE:
            changed.add(row["response_id"])
            continue
        if not note.startswith(OLD_PREFIX):
            raise RuntimeError(
                f"unexpected note for {row['response_id']}: {note!r}"
            )
        row["reviewer_notes_human"] = NEW_NOTE
        changed.add(row["response_id"])

    if changed != TARGET_IDS:
        missing = sorted(TARGET_IDS - changed)
        raise RuntimeError(f"expected nine target rows; missing {missing}")

    temporary = DATASET.with_suffix(".csv.tmp")
    with temporary.open("w", encoding="utf-8", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)
    temporary.replace(DATASET)
    print("Updated nine stale note strings; response and judgment fields unchanged.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
