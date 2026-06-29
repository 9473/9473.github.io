#import "../index.typ": template, tufted
#show: template.with(
  title: "GRDM-QMC and Off-Diagonal BRA: A Small Benchmark",
  description: "A short benchmark comparing GRDM-QMC and off-diagonal BRA for imaginary-time off-diagonal correlators.",
  date: datetime(year: 2026, month: 6, day: 29),
  lang: "en",
)

= GRDM-QMC and Off-Diagonal BRA: A Small Benchmark

This note records a small benchmark comparing off-diagonal bipartite reweight-annealing (BRA) and GRDM-QMC under a common protocol. The point is not to claim that one method universally dominates the other, but to make clear what each method pays for in a direct imaginary-time off-diagonal measurement.

We benchmark the off-diagonal BRA method from #link("https://doi.org/10.1038/s41467-025-67324-0")[our general-measurement work] and GRDM-QMC for the same observable, Hamiltonian, and exact-diagonalization reference. The test uses an XXZ chain with $L=8$, $beta=16$, $Delta=0.1$, $e=0.25$, and a fixed SSE cutoff $M_"cut"=1024$. We measure

$ G_r(tau) = chevron.l S_i^x(tau) S_(i+r)^x(0) chevron.r $

for $r=1$ and $r=4$, at $tau=2,4,8$. Each fixed $("method", r, tau)$ point contains 30 independent bins, with $2 times 10^5$ measurement sweeps per bin and independent random seeds. All runs were performed on the same local machine, a Mac mini with an M4 chip and 16 GB memory. Each subtask was timed independently, and both methods are compared with the same ED values.

For the BRA calculation, we do not assume an ED reference point. This is closer to the practical situation where an exact numerical reference may not be available. Instead, BRA first anneals the equal-time off-diagonal correlator from the Heisenberg point to $Delta=0.1$. The $Delta$-annealing path contains 20 points, and the overlap condition is chosen in the relatively loose range $0.03$-$0.27$, following the reweighting strategy of #link("https://www.nature.com/articles/s41467-025-61084-7")[the BRA entanglement-entropy work]. Since the $Delta$-annealing requires two manifolds, we include the total runtime of both manifolds.

Starting from the resulting equal-time value, BRA then anneals the operator separation in imaginary time up to $tau=beta / 2 = 8$, with timing checkpoints inserted along the path. Thus, the cost at $tau=2$ and $tau=4$ is counted only up to the corresponding target segment. For GRDM-QMC, we time each independent $(r, tau)$ task directly.

#figure(
  image("imgs/bra_stitched_runtime_precision.pdf", width: 100%),
  caption: [Runtime and statistical-precision comparison for the same benchmark. BRA times are counted as cumulative annealing times up to the target $tau$, while GRDM-QMC tasks are timed directly for each $(r, tau)$ point.]
)

Both methods reproduce the ED imaginary-time benchmark within statistical uncertainty. The agreement is characterized by the absolute deviation $abs(overline(G)_"QMC" - G_"ED")$, which remains comparable to or smaller than the corresponding statistical error bars across the tested points.

For single-$tau$ measurements, GRDM-QMC shows a clear practical advantage in this benchmark. The BRA runtime includes the cost of obtaining the equal-time reference through $Delta$-annealing and then reaching the target imaginary-time separation, whereas GRDM-QMC samples each target $(r, tau)$ point directly. Across the six benchmark points, GRDM-QMC reduces the wall time per bin by about 89%-94%. Under the same simulation setting, GRDM-QMC also gives smaller error bars for all tested $(r, tau)$ points, with an error reduction of about 89%-93%.

Thus, for the imaginary-time off-diagonal correlators tested here, GRDM-QMC reaches ED-level accuracy with lower runtime and smaller statistical uncertainty.
