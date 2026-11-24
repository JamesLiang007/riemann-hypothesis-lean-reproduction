# Reproduction record for ordinary RH

On 2026-11-22 at 21:08:34 (UTC+08:00), my own build and export of Levent Alpöge’s Lean submission passed `con-leche --verified --compare`. This page records what I checked and where to look.

| Item | Result | Where to look |
| --- | --- | --- |
| Input archive and compiled entry module | The SHA-256 digests of the original `lean.tar.gz` and my locally built `Main.olean` both match MIT’s published ones. | [Local checksum manifest](verification-artifacts.sha256) and [MIT provenance](https://math.mit.edu/~drew/grh/#provenance) |
| Local build and axiom audit | Lake finished 183,892 build jobs. Each of the five headline theorems depends only on `propext`, `Classical.choice`, and `Quot.sound`. | [Local build and audit excerpt](audit.txt) |
| `con-leche` on my local export | Accepted 1,468,390 solution declarations in verified mode with 32 workers. Parsing, checking and comparison took 500.1 s, with 44.08 GiB peak RSS. | [Sanitized checker log](con-leche.log) and [run report](con-leche.md) |
| Link to the standard mathematical statement | A challenge that imports only Mathlib declares `riemannHypothesis : RiemannHypothesis`. The checker reported that the solution justifies it. | [Exact challenge source](../RHParallelChallenge.lean) and [checker log](con-leche.log) |

## How to cross-check

1. Compare the first two lines of the checksum manifest with MIT's public provenance table. They identify the submission archive and the built entry module.
2. Follow the [build and check commands](con-leche.md#reproduce-the-parallel-check) to regenerate the two NDJSON inputs and run the checker. To check all four hashes, put the files under the listed names in one directory and run `sha256sum -c verification-artifacts.sha256`.
3. Confirm the run prints `axiom riemannHypothesis justified by the solution`. That refers to the exact target in the challenge file.

I rehashed the four manifest files on the compute node on 2026-11-22 at 23:18–23:19 (UTC+08:00), and the export digests matched those from the successful run. The exports themselves stay on the compute node; this repository has their hashes, the log, the challenge and the commands to regenerate them. My export targets one theorem, while [MIT’s comparison](https://math.mit.edu/~drew/grh/) targets all five. Only the source archive and `Main.olean` are compared directly against MIT's hashes.

The proof is Alpöge's. This repository only documents my own build, export and checker run. For the community's verification of the original submission, see the [Lean and Mathlib statement](https://leanprover-community.github.io/blog/posts/riemann-hypothesis/).
