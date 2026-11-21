# Lean reproduction of the Riemann hypothesis formalization

Reproduction artifacts for Levent Alpöge's November 2026 formalization. The proof source is available from the [author's announcement](https://alpo.ge/remark.pdf) and the [community verification repository](https://github.com/leanprover-community/riemann-hypothesis).

## What this run checked

- Lake completed the local build with 183,892 jobs. The project has 175,187 Lean source modules.
- The statement of `riemannHypothesis` matched the reference statement by definitional equality.
- The five headline theorems each listed exactly `propext`, `Classical.choice`, and `Quot.sound` in the local axiom audit.
- A declaration-level replay of the ordinary RH theorem is in progress. This repository records the local run. See [MIT's verification report](https://math.mit.edu/~drew/grh/) for separate kernel and Comparator results.

[Local audit excerpt](results/audit.txt) · [Reproduction and resource observations](results/reproduction.md)

## Reproduce

The run used Lean `v4.33.1` and Mathlib commit `0df444a360eaa60ab8c11dca51a86af692955474`. Verify the author archive using [SHA256SUMS](SHA256SUMS) before extracting it. In the extracted Lean project, install the pinned toolchain and fetch the Mathlib dependencies before going offline. Build with `lake build Main`. For a clean build and an independent verifier, see the community repository's checking instructions linked above.

Run the following from the extracted project root, with `AUDIT_DIR` pointing to this repository:

```bash
export LEAN_ABORT_ON_PANIC=1
lake --no-cache env lean "$AUDIT_DIR/Statement.lean"
lake --no-cache env lean --threads=8 --run "$AUDIT_DIR/Replay.lean"
```

`Statement.lean` compares the imported theorem against an explicit reference statement and prints its axiom dependencies. `Replay.lean` reads compiled declarations, follows the theorem's type and proof into their transitive declaration dependencies, checks their axiom names, and replays the resulting set in an empty Lean environment. This uses Lean's own kernel. The local declaration replay targets ordinary RH only.

The local run reused a pinned Mathlib cache and ran the checks with networking disabled. The source archive and local `Main.olean` match the digests published by MIT. Compiled files that contain diagnostics can have path-dependent digests.

The repository holds scripts and excerpts. The original proof archive and bulky compiled files are obtained separately.
