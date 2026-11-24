# `con-leche` check of `riemannHypothesis`

**Passed on 2026-11-22 at 21:08:34 (UTC+08:00).** I exported `riemannHypothesis` and its dependencies from the locally built `Main.olean`. `con-leche` accepted 1,468,390 declarations from that export, checked 51,215 challenge declarations, and reported that the solution justified `riemannHypothesis`. The [challenge source](../RHParallelChallenge.lean) imports Mathlib's Riemann zeta module and states the target as an axiom for the checker to justify.

This comparison covers ordinary RH only. The [axiom audit](audit.txt) covers all five headline statements, including the Dirichlet L-function ones.

## Run measurements

| Measurement | Value |
| --- | ---: |
| Solution export wall time | About 1 hour 44 minutes |
| Full compare run after export | 500.1 s |
| Solution parsing and indexing | 83.0 s total |
| Solution kernel checks | 410.4 s |
| Workers | 32 |
| Solution check pool busy time | 99.8% |
| Peak checker RSS | 44.08 GiB |

[Sanitized run log](con-leche.log)

## Artifact checksums

The `Main.olean` digest is in [SHA256SUMS](../SHA256SUMS) and matches the one [MIT](https://math.mit.edu/~drew/grh/) reports. I produced these two exports locally for the single-target comparison.

| Export | Bytes | SHA-256 |
| --- | ---: | --- |
| `challenge.ndjson` | 347,115,897 | `9c3976a540a9b9964168ebca513ecebb5d866241d1847e3c65b42b1e47492eba` |
| `solution.ndjson` | 61,571,146,149 | `64f6c9d5e217834e0d06cc6fbb5d4a2591fd25793b9b5089ba2aceb4ec4b77eb` |

## Reproduce the parallel check

Start from the project build with Lean 4.33.1 and the Mathlib revision in the [README](../README.md). Build [lean4export v4.33.0](https://github.com/leanprover/lean4export/tree/v4.33.0) against Lean 4.33.1. I used the [con-leche compare revision](https://github.com/leanprover/con-leche/tree/5dc36dc15b7bee891a02406b78a8ac816a47baad), built with Lean 4.36.0. Both the export and the check ran with networking disabled.

From the proof project's root, set `AUDIT_DIR` to the absolute path of this repository, and `EXPORTER` and `CON_LECHE` to the absolute paths of the two executables. Run the commands in a directory with enough space for the exports (the solution export is about 62 GB).

```bash
export LEAN_ABORT_ON_PANIC=1
lake --no-cache env lean --root="$AUDIT_DIR" \
  -o "$AUDIT_DIR/RHParallelChallenge.olean" "$AUDIT_DIR/RHParallelChallenge.lean"

lake --no-cache env bash -c '
  export LEAN_PATH="$1:$LEAN_PATH"
  exec "$2" RHParallelChallenge -- riemannHypothesis
' bash "$AUDIT_DIR" "$EXPORTER" > challenge.ndjson

lake --no-cache env "$EXPORTER" Main -- riemannHypothesis > solution.ndjson

"$CON_LECHE" --verified --jobs=32 --progress=30s --compare \
  challenge.ndjson solution.ndjson
```

A passing run prints `axiom riemannHypothesis justified by the solution`. The log and checksums are in this repository. The NDJSON exports are too large to include and stayed on the compute node.
