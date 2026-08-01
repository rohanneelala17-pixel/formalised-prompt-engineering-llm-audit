# Design evidence and provenance

The files in this directory document the locally frozen design used for the final collection. They were copied into this public repository after the experiment. They are therefore evidence of the recorded workflow, supported by the hashes below, but they are **not** a public or third-party preregistration.

| Artifact | Role | Original SHA-256 |
|---|---|---|
| `frozen_analysis_plan.md` | Primary outcome and statistical plan | `c79f085943fba11028a355da0a37b12b10b62859d214dc244fae0f9c2cb2271b` |
| `human_verification_protocol.md` | Reviewer codes and decision rule | `82a4c764f56963a2ea55e95c1176080857ee93a57d29de865c7a3e33740ab9cd` |
| Original full schedule | Assignment and randomised call order | `316c896c9125e6cd4d974931af8efe2d700e5812be74dcf735b1ce5ab6c8aefc` |
| Original collection-freeze manifest | Freeze metadata | `67ca1d08b3c5108ba77b9976fee950d5da6048a9cca1a52deb0943091d57ce7b` |

`schedule_public.csv` is a privacy-safe projection of the original schedule. It retains response ID, pair ID, condition assignment, treatment indicator, generation number, and call order. Rendered prompt text and local paths are omitted; the exact prompts are published separately in `prompts/`.

Public schedule canonical-text SHA-256: `9d7331a0cbbc4f7207af28ab64433805b6ebc703673d5328fef122c7620d3322`. Text artifacts are canonicalised to LF before verification so the check is stable across Windows and Linux.

The private gold answer and the random linkage between opaque review-row IDs and experimental response IDs remain unpublished. Their absence prevents the public release from serving as a key to the blinded workbook.
