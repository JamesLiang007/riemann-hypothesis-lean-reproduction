# Local reproduction and resource observations

The local run rebuilt the published submission with Lean 4.33.1 and pinned Mathlib artifacts. The SHA-256 digests of both the source archive and the locally built `Main.olean` match the digests in [MIT's verification report](https://math.mit.edu/~drew/grh/). The statement and axiom checks are recorded in [the audit excerpt](audit.txt).

## Replay experiments

The later [independent `con-leche` run](con-leche.md) passed for `riemannHypothesis`. The table also records earlier experiments with Lean's own replay API.

| Run | Outcome | Checker memory |
| --- | --- | --- |
| 192 project modules, 16 modules per process | All passed. The sum of the 12 check durations was 669.52 seconds, about 17 modules/minute in this sample. | Highest recorded physical RSS 121 GiB. Highest recorded virtual address space 145 GiB. |
| 16 heavier modules in one process, including `Main` | The checker reported an artifact read failure as it reached its address-space limit. | Virtual address space reached 300 GiB. Physical RSS peaked at about 248 GiB in the sampled process data. |
| Earlier targeted Lean declaration replay for `riemannHypothesis` | Statement and stored axiom audit passed. At 03:34 UTC+08:00 on 2026-11-22, the dependency walk had logged 1,470,000 declarations. A later post-replay check found a declaration absent from the resulting environment, so this run did not report a pass. | The dependency-collection process had about 89 GiB resident memory at that snapshot. |
| `con-leche --verified --compare`, 32 workers | Passed. Accepted 1,468,390 solution declarations and justified `riemannHypothesis` against a Mathlib-only challenge. The full check took 500.1 seconds after export. | Peak RSS 44.08 GiB. |

The 300 GiB limit applied to virtual address space via Linux `RLIMIT_AS`. The heavy-run failure was a file-read error at that limit. The run did not report a kernel rejection. Resource numbers are rounded and come from the checker's own Linux process status. A few early groups lacked end-of-group memory statistics. The initial pilot samples are unsuitable for projecting total replay time because import closures vary between modules.

The local run complements public checks by documenting a separate build and its matching artifact. For checks using other kernels and an independently constructed challenge, see the [Lean and Mathlib joint statement](https://leanprover-community.github.io/blog/posts/riemann-hypothesis/) and MIT's report.
