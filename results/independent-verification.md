# Independent reproduction record for ordinary RH

On 2026-11-22 at 21:08:34 (UTC+08:00), a separate local build and proof export of Levent Alpöge’s Lean submission passed `con-leche --verified --compare`. This records the local contribution to independent verification.

| Evidence | Local result | Where to check |
| --- | --- | --- |
| Input archive and compiled entry module | The SHA-256 digests of the original `lean.tar.gz` and our locally built `Main.olean` both match MIT’s published digests. | [Local checksum manifest](verification-artifacts.sha256) and [MIT provenance](https://math.mit.edu/~drew/grh/#provenance) |
| Local build and axiom audit | Lake completed 183,892 build jobs. The five headline theorems each reported only `propext`, `Classical.choice`, and `Quot.sound`. | [Local build and audit excerpt](audit.txt) |
| Independent kernel on the locally generated export | Accepted 1,468,390 solution declarations in verified mode with 32 workers. Parsing, checking and comparison took 500.1 s, with 44.08 GiB peak RSS. | [Sanitized checker log](con-leche.log) and [run report](con-leche.md) |
| Link to the standard mathematical statement | A challenge importing only Mathlib declared `riemannHypothesis : RiemannHypothesis`. The checker reported that the solution justified it. | [Exact challenge source](../RHParallelChallenge.lean) and [checker log](con-leche.log) |

## How to cross-check

1. Compare the first two entries in the checksum manifest with the public MIT provenance table. These matches identify the submission archive and the built entry module.
2. Follow the [local build and check commands](con-leche.md#reproduce-the-parallel-check) to regenerate the two NDJSON inputs and run the checker. The manifest records the inputs from this run. You can check all four hashes by placing the artifacts under the listed filenames in one directory and running `sha256sum -c verification-artifacts.sha256`.
3. Check that the verified run reports `axiom riemannHypothesis justified by the solution`. The result refers to the exact target in the checked challenge file.

The four files in the manifest were rehashed on the original compute node on 2026-11-22 at 23:18–23:19 (UTC+08:00). The export digests matched those written by the successful run. The proof exports are retained on the compute node. The repository provides their hashes, the verification log, the challenge and commands needed to reproduce them. The local export targets one theorem, while [MIT’s published comparison](https://math.mit.edu/~drew/grh/) targets all five. The source archive and `Main.olean` are the two direct hash comparisons with MIT.

The proof is attributable to Alpöge. This repository documents our separate build, export and checker run. The [Lean and Mathlib community statement](https://leanprover-community.github.io/blog/posts/riemann-hypothesis/) provides independent context for their verification of the original submission.
