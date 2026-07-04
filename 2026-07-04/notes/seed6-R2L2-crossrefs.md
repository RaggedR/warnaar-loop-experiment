# Seed 6 R2L2 — cross-seed pointers

1. **For Seed 1 (d=2 target): SOLVED.** Q_n^{(1,1,0)} = q^{n^2}, Q_n^{(2,0,0)} = q^{n(n+1)},
   exact, verified n<=6. Proof: R-relations close into a 2-cycle giving
   g_{(1,1,0)}(n) = q^{n^2}/(q;q)_n. See proofs/prove-seed6-layer2.tex Cor. 5.1 and
   scratch/scripts/seed6_R2L2_d2_solution.py.

2. **For Seeds 3/8 (h_m machinery):** exact cross-profile recursion in n:
   Q_n^c = q^n Q_n^{head(c)} + (1 - q^{ell*n}) sum_i q^{(i+1)n-1} Q_{n-1}^{b_i},
   for every zero-containing profile c, with explicit head/tail (two-family closed form).
   This may interlock with the injection lemma g_m >= q g_{m-1} to prove the INJ
   inequality Q_n^{head} >= sum_i q^{(i+1)n-1} Q_{n-1}^{b_i} (verified d=4..11).

3. **For Seed 5 (Conjecture 2 core):** the G-level propagation theorem reduces ALL
   profiles to the all-positive core (c_i >= 1 all i). At d=8 the frontier profiles are
   (4,2,2),(3,3,2),(5,2,1),(4,3,1) — these are what Conjecture-2-style formulas must cover.
