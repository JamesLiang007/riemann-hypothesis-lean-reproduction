# Lean reproduction of the Riemann hypothesis formalization

Scripts and logs from my local rebuild and check of Levent Alpöge's November 2026 Lean formalization. The proof itself is in the [author's announcement](https://alpo.ge/remark.pdf) and the [community verification repository](https://github.com/leanprover-community/riemann-hypothesis). Nothing here replaces those.

## What I checked

- Lake finished the local build in 183,892 jobs, covering 175,187 Lean source modules.
- `riemannHypothesis` is definitionally equal to the reference statement.
- Each of the five headline theorems depends only on `propext`, `Classical.choice` and `Quot.sound`.
- `con-leche` passed for ordinary RH. In `--verified --compare` mode it accepted 1,468,390 declarations from my local export and justified `riemannHypothesis` against a challenge that imports only Mathlib. That took 32 workers about 8 minutes 20 seconds after the export.

Details: [reproduction record](results/independent-verification.md), [con-leche run and commands](results/con-leche.md), [audit excerpt](results/audit.txt), [resource notes](results/reproduction.md).

## Reproducing it

For the `con-leche` check, follow [these instructions](results/con-leche.md#reproduce-the-parallel-check). The steps below cover the statement audit and the Lean kernel replay.

I used Lean `v4.33.1` and Mathlib commit `0df444a360eaa60ab8c11dca51a86af692955474`. Check the author's archive against [SHA256SUMS](SHA256SUMS) before extracting it. In the extracted project, install the pinned toolchain and fetch Mathlib while you still have network access, then run `lake build Main`. For a clean build and another verifier, see the community repository's instructions.

From the extracted project root, with `AUDIT_DIR` set to this repository:

```bash
export LEAN_ABORT_ON_PANIC=1
lake --no-cache env lean "$AUDIT_DIR/Statement.lean"
lake --no-cache env lean --threads=8 --run "$AUDIT_DIR/Replay.lean"
```

`Statement.lean` compares the imported theorem with an explicit reference statement and prints its axioms. `Replay.lean` reads the compiled declarations, collects everything the theorem's type and proof depend on, checks their axiom names, and replays that set in an empty environment using Lean's own kernel. It only covers ordinary RH.

My run used a pinned Mathlib cache with networking turned off. The source archive and my `Main.olean` match the digests MIT publishes. Compiled files that contain diagnostics can have path-dependent digests.

This repository holds only scripts and excerpts. Get the original proof archive and the large compiled files separately.
