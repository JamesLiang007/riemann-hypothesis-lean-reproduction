# Local reproduction and resource notes

I rebuilt the published submission with Lean 4.33.1 and pinned Mathlib artifacts. The SHA-256 digests of the source archive and of my `Main.olean` both match [MIT's verification report](https://math.mit.edu/~drew/grh/). The statement and axiom checks are in the [audit excerpt](audit.txt).

## Replay experiments

The [`con-leche` run](con-leche.md) later passed for `riemannHypothesis`. The table also lists my earlier attempts with Lean's own replay API.

| Run | Outcome | Checker memory |
| --- | --- | --- |
| 192 project modules, 16 modules per process | All passed. The 12 checks took 669.52 seconds in total, about 17 modules per minute. | Peak physical RSS 121 GiB, peak virtual address space 145 GiB. |
| 16 heavier modules in one process, including `Main` | Failed with an artifact read error at the address-space limit. | Virtual address space hit 300 GiB. Physical RSS peaked at about 248 GiB in the sampled data. |
| Targeted Lean replay for `riemannHypothesis` | The statement and stored axiom audit passed. At 03:34 UTC+08:00 on 2026-11-22 the dependency walk had logged 1,470,000 declarations. A later check found a declaration missing from the resulting environment, so this run did not count as a pass. | The dependency walk held about 89 GiB resident at that point. |
| `con-leche --verified --compare`, 32 workers | Passed. Accepted 1,468,390 solution declarations and justified `riemannHypothesis` against a Mathlib-only challenge. 500.1 seconds after export. | Peak RSS 44.08 GiB. |

The 300 GiB limit is a virtual address space limit set with Linux `RLIMIT_AS`. The heavy run failed with a file-read error at that limit, not a kernel rejection. Memory numbers are rounded and come from the checker's own Linux process status; a few early groups have no end-of-group figures. Don't extrapolate total replay time from the pilot runs, since import closures differ a lot between modules.

This is one more independent build with matching artifacts. For checks with other kernels and an independently written challenge, see the [Lean and Mathlib joint statement](https://leanprover-community.github.io/blog/posts/riemann-hypothesis/) and MIT's report.
