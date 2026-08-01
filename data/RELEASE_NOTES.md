# Public dataset release notes

## 1 August 2026: reviewer-note provenance correction

Nine repaired responses already had completed post-repair codes in the final review workbook, but their `reviewer_notes_human` field still contained an earlier system instruction saying that the row required re-review. The public release replaces that stale instruction with a provenance statement. No response text, prompt assignment, automated field, human code, review status, confidence value, or statistical result changed.

- Previous public CSV SHA-256: `c70abb3184a7d7de375c051ae53ead8a4699aafa2f91453fc0ccc4b57c6f5bfb`
- Corrected public CSV SHA-256: `f1f74c1877f5e79b576ed96233aec619ae26162e8a07def76556110f432c92d5`
- Affected rows: 9
- Correctness codes changed: 0

The private locked dataset remains unchanged. The public release also omits the private `review_row_id` linkage column.
