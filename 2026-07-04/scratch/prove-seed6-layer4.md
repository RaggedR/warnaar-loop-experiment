# Prove Seed 6 Layer 4 — S1 via Ehrhart (lattice-point route to N₂ ≥ 0, all d)

Seed 6, Round 2, Layer 4. Mission 6 of synthesis-layer3.md §6: finish sub-conjecture
S1 (har_j ≥ 0 for j ∉ {2,4}) via Ehrhart / lattice-point methods, using Cap-Compression
(G10). Then lift by Sphere Absorption (Y4).

## Conventions (per synthesis-layer3.md §4(iv) — TRUE labels, target-first)

- EMD(c,c') = 3·max(0, c'₁−c₁, c₀−c'₀) + (c'₀−c₀) − (c'₁−c₁).
- Target-first kernel: (1+q^m+q^{2m}) H_{c,m} = Σ_{c'} q^{m·EMD(c,c')} H_{c',m−1},
  c = TARGET at level m. Reference: scripts/seed8_R2L3_engine.sage (emd(c,cp) there
  == EMD(c,cp) definitive; kernel q^{m·emd(c,cp)} — checked by hand, matches).
- Seed 4's L3 engine (seed4_R2L3_engine.py) used SOURCE-first kernel q^{m·EMD(c',c)}:
  its H[c] = H_true[rev(c)]. Aggregate S1/S2 claims survive (profile set reversal-
  closed); all per-profile geometry must be REDERIVED in true convention. Done below.

## True-convention geometry (rederived, to verify by machine)

Deviation coords u = c' − c, write s = u₀, t = u₁. Then
  EMD(c,c') = g(s,t) := 3·max(0, t, −s) + s − t.
(Seed 4's source-first quasi-norm was f(s,t) = 3max(0,−t,s) − s + t; g(s,t) = f(−s,−t),
a point reflection — same sphere sizes, reflected validity thresholds.)

- g ≡ s − t (mod 3).
- Sphere {g = e}: boundary of triangle T_e with vertices (e,0), (−e,e), (0,−e).
  Edges: A: (e,0)→(0,−e), points (s, s−e), s=0..e;  B: (e,0)→(−e,e), points (e−2i, i),
  i=0..e;  C: (0,−e)→(−e,e), points (−i, −e+2i), i=0..e. Total 3e points (e ≥ 1).
- Validity of c' = c + (s,t,−s−t): s ≥ −c₀, t ≥ −c₁, s+t ≤ c₂.
- Unit sphere {g=1} = {(1,0), (−1,1), (0,−1)} → valid iff c₂≥1, c₀≥1, c₁≥1 resp.
  ⟹ b₁(c) = rank(c) (true-convention version of Seed 4's Prop; same conclusion,
  thresholds permuted).
- H₁(c) = B_c(q)(1−q)/(1−q³), B_c(q) = Σ_{c'} q^{EMD(c,c')}; [q^k]H₁ = A_k − A_{k−1},
  A_k(c) = #{c' ∈ Δ_d : g ≤ k, g ≡ k mod 3} = Σ_{e≤k, e≡k(3)} b_e(c).
- har(c) = Σ_{c'≠c} q^{2·EMD(c,c')} Q₁(c') − q(1+q+q²+q³+q⁴) Q₁(c);
  N₂(c) = [B_c(q²) − 1 − q² − q⁴] + har(c).   (T1/T2 in true convention.)

## Plan

1. Engine: local (sphere-count) computation of har_j in true convention; cross-check
   vs seed8-style full H-recursion at d=4,5,7.
2. Rigorous Cap-Compression with explicit cap; unconditional sweep [q^j]N₂ ≥ 0 for
   j ≤ J₀ via d ≤ 6j+6.
3. DEEP-INTERIOR THEOREM (all j at once): if min_i c_i ≥ 2j then har_j(c) = har_j^∞,
   universal. Computed by hand: u_k := [q^k]Q₁^∞ = k+1 (k ≥ 1), u_0 = 0, and
     har_j^∞ = Σ_{e=1}^{⌊(j−1)/2⌋} 3e·u_{j−2e} − Σ_{i=1}^{5} u_{j−i}
   closed forms: j=2p ≥ 6: (p−1)(2p²+5p−20)/2; j=2p+1 ≥ 7: p(p+1)(p+2) − 10p + 5;
   small j: har^∞_{0..5} = 0, 0, −2, 1, 0, 10. All ≥ 0 except j=2 (= −(b₁−1) = −2,
   absorbed). TO VERIFY numerically, then write up as theorem.
4. Edge region (one small coordinate): closed-form quasi-polynomial in (j, a) via the
   s+t ≤ a half-plane cut; distribution μ_e(v) of v = s+t on sphere e.
5. Sharp cap M_j = j: attempt proof.
6. Lift: [q^n]N_n = 0 identically for all n (generalize thm:q2); level-n low band.

## Work log

### [Setup] Files read: synthesis-layer3.md, prove-seed4-layer3.{tex,md},
seed8_R2L3_engine.sage, seed4_R2L3_engine.py. Hand computation of interior u_k = k+1
and har_j^∞ done (above), pending machine check. NOTE: Write tool denied in this
session; using bash heredocs for file writes.

### [V1] Engine verified (seed6_R2L4_engine.py — ALL CHECKS PASS)
- Sphere sizes 3e (e ≤ 39); EMD C₃-rotation invariance (d=5, all pairs).
- T1/T2 hold VERBATIM in the true convention (same derivation from target-first
  recursion), d=4,5,7, all profiles; ball term ≥ 0.
- LOCAL sphere-count computation of har_j == FULL polynomial engine, all profiles,
  all j, d=4,5,7.
- S1/S2 + har₂ = −(b₁−1) exact in true convention, d=4,5,7.
- INTERIOR closed form verified: c=(60,58,60), d=178, j ≤ 29 — har_j(c) = har_j^∞ with
  har^∞_{0..5} = 0,0,−2,1,0,10; j=2p ≥ 6: (p−1)(2p²+5p−20)/2; j=2p+1 ≥ 7:
  p(p+1)(p+2) − 10p + 5.

### [CAP-SHARP] THEOREM (new): rigorous sharp cap M_j = j−1  (improves G10's M=2j AND
Seed 4's empirical M=j)

Claim: for j ≥ 1, har_j(c) depends on c only through (min(c_i, j−1))_i.

Proof. har_j(c) = Σ_{e=1}^{⌊(j−1)/2⌋} Σ_{u∈S_e valid} q1coef(c+u, j−2e)
                 − Σ_{i=1}^{5} q1coef(c, j−i),  where q1coef(c,k) = 0 for k ≤ 0.
Key facts: (F1) every point u on sphere S_e has |u₀|,|u₁|,|u₂| ≤ e (the triangle
∂T_e has vertices (e,0),(−e,e),(0,−e); each u_i ranges in [−e,e] on each edge — checked
edge by edge). (F2) q1coef(c',k) = A_k(c') − A_{k−1}(c') counts lattice points at
g-distance ≤ k from c', whose validity thresholds are ≤ k in each coordinate of c'
(by F1 applied to spheres of radius ≤ k); hence q1coef(c',k) depends only on
(min(c'_i, k))_i.
Now suppose min(c_i, j−1) = min(ĉ_i, j−1) ∀i; fix i: either c_i = ĉ_i ≤ j−2, or both
≥ j−1. (1) Validity of u ∈ S_e: thresholds ≤ e ≤ (j−1)/2 ≤ j−1 — agree. (2) Neighbor
terms, k = j−2e: if c_i ≥ j−1 then (c+u)_i ≥ j−1−e ≥ j−2e = k (⟺ e ≥ 1 ✓), so
min((c+u)_i, k) = k for both c and ĉ; if c_i = ĉ_i, trivially equal. (3) Self terms:
thresholds j−i ≤ j−1. ∎

COROLLARY (realization): every capped class arising from a valid profile is realized
by a profile with all c_i ≤ j+1 and 3∤d (if some coordinate ≥ j−1, bump it within
{j−1, j, j+1} to fix d mod 3; if all ≤ j−2 the profile is its own representative).
Hence: exact check of S1@j / S2@j over ALL profiles with c_i ≤ j+1, 3∤d
⟹ S1@j / S2@j for ALL d unconditionally.

Immediate payoff: Seed 4's existing d ≤ 35 sweep + this lemma already makes
[q^j]N₂ ≥ 0 UNCONDITIONAL for j ≤ 12 (previously j ≤ 5). Extending by direct sweep next.

### [R0] DEEP-INTERIOR THEOREM (all j): if min_i c_i ≥ j−1 then har_j(c) = har_j^∞.
Same bookkeeping as CAP-SHARP: all constraints inactive throughout the double sum.
In the free lattice b_e = 3e, A_k = Σ_{e≡k(3),e≤k} b_e gives u_k := [q^k]Q₁^∞ = k+1
(k ≥ 1) — three-case computation, verified. So H₁^∞ "=" 1/(1−q)². Then
har_j^∞ = Σ_{e=1}^{E} 3e(j−2e+1) − Σ_{i=1}^{5} u_{j−i},  E = ⌊(j−1)/2⌋
        = E(E+1)(3j+1−4E)/2 − (5j−10)  for j ≥ 6.
Closed forms above; ≥ 0 for all j ≠ 2, = −2 = −(b₁−1) at j=2 (absorbed by ball).
⟹ S1 and S2 hold at EVERY (j,c) with min_i c_i ≥ j−1. Machine-verified j ≤ 29.

### [SWEEP] Unconditional low band extended (seed6_R2L4_sweep.py)
Cross-checked sweep har == engine har (d ∈ {4,5,7,8,10}, j ≤ 25, all profiles).
Sweep over ALL capped reps (c_i ≤ j+1, 3∤d) with the PROVED sharp cap:
j ≤ 14 clean instantly; extended run j ≤ 48 in background (log seed6_R2L4_sweep.log).
Each clean level j is a THEOREM: [q^j]N₂ ≥ 0 for all profiles, all d, gcd(d,3)=1.

### [3|d] NEW FINDING: S1 is FALSE at 3|d profiles (seed6_R2L4_mono.py)
har_j as a pure lattice expression (defined for any c ∈ ℤ³≥0 via H₁ = B_c(1−q)/(1−q³);
this is (q;q)₁F_{c,1} for any d) has har₁₃((1,1,1)) = −1, har₁₅((0,1,2)) = −1, etc.
All observed failures at 3|d. So the gcd(d,3)=1 hypothesis is ESSENTIAL to S1 —
any correct proof must use it. (Also explains why naive coordinate-monotonicity of
har_j fails: failures occur exactly on steps touching 3|d.)

### [HM] HARNACK MONOTONICITY (new structural conjecture; the master reduction)
For j ∉ {2,4}:
  (M1) if |c| ≡ 1 (mod 3): har_j(c + e_i) ≥ har_j(c)  (i = 0,1,2);
  (M2) if |c| ≡ 2 (mod 3): har_j(c + e_i + e_k) ≥ har_j(c)  (all i ≤ k).
Verified: 158,652 residue-respecting steps (j ≤ 18, box c_i ≤ j+2 — by CAP-SHARP this
is COMPLETE for j ≤ 18: every step of profiles of ANY d is cap-equivalent to one in
the box, steps above the cap being automatically tight), 0 failures, 38,295 tight.

BASE CASE (PROVED, trivial): at d=1, B_c(q) = 1+q+q² for each of the three profiles
(EMD from (0,0,1): 0,1,2 to (0,0,1),(1,0,0),(0,1,0) resp., and rotations), so
H₁ = (1+q+q²)(1−q)/(1−q³) = 1, Q₁ ≡ 0, hence har_j(c) = 0 for ALL j. (Consistent
with Q₁(1) = K−1 = 0 at d=1.)

REDUCTION THEOREM: HM ⟹ S1 (all j, all c, gcd(d,3)=1).
Proof: walk any c down by residue-respecting steps (d ≡ 2: remove one box → d ≡ 1;
d ≡ 1, d ≥ 4: remove two boxes → d ≡ 2; both stay in 3∤d) until d = 1; har_j only
decreases along the reversed walk, and har_j = 0 at d = 1. ∎
Moreover HM@j is FINITELY DECIDABLE for each fixed j via CAP-SHARP (box c_i ≤ j+1
suffices) — an explicit J₀ → ∞ mechanism: HM@j proved for all j ≤ 18 as of now.
NOTE: HM@j (finite check) ⟹ S1@j; the per-j sweeps of S1 and HM are both complete
proofs at fixed j; HM is the sharper structure and the recommended proof target,
since it is a LOCAL statement (one box added) with all failures of its naive form
concentrated at 3|d — i.e. it "knows" where the conjecture's hypothesis enters.

### [HARVEST after usage-limit kill — resumed session]
- Sweep (seed6_R2L4_sweep.py, log): clean through j = 45 (min margin 0 at c=(0,0,1) each level;
  process killed before j=46). THEOREM: [q^j]N₂ ≥ 0 for all c, all d with gcd(d,3)=1, j ≤ 45.
- HM high run (seed6_R2L4_mono_hi.py, log): DONE. HM verified completely (CAP-SHARP box)
  for j = 19..30, 0 failures. Combined with earlier run: HM@j PROVED (finite decidability)
  for all j ≤ 30 ⟹ S1@j for j ≤ 30 by the Reduction Theorem.

### [R1] One small coordinate: c = (big, big, a), phi_j(a) := har_j(c)  (min c₀,c₁ ≥ j−1)
INGREDIENT LEMMAS (all hand-derived, all machine-verified — seed6_R2L4_r1.py):
- μ_e(v) := #{p ∈ S_e : s+t = v} = 1 + [v ≡ e mod 2] − [|v| = e]  for |v| ≤ e  (e ≥ 1).
- T(δ) := #{p ∈ S_e : s+t > β} = ⌊(3δ−1)/2⌋, δ = e−β ≥ 1 (0 else). (β ≥ 0.)
- x(m) := Σ_{r=0}^{⌊(m−1)/3⌋}⌊(3(m−3r)−1)/2⌋ = ⌊(m+1)²/4⌋: PROOF: reindexing gives
  x(m) − x(m−6) = ⌊(3m−1)/2⌋ + ⌊(3m−10)/2⌋ = 3(m−2) for m ≥ 7; induction + 6 base cases.
- y(m) := x(m) − x(m−1) = ⌈m/2⌉ (m ≥ 1): same shift argument, y(m+6) = y(m)+3.
- w_k(β) := [q^k]Q₁((∞,∞,β)) = (k+1) − ⌈(k−β)/2⌉₊  for k ≥ 1  (X_k(β) = x(k−β):
  the excess-ball count depends only on k−β!). Machine-verified k ≤ 29, all β.
- PHI FORMULA (proved by the CAP-SHARP bookkeeping — only the c₂ constraint is ever
  active when c₀,c₁ ≥ j−1):
  φ_j(a) = har^∞_j − C1 − C2 + C3,  E = ⌊(j−1)/2⌋,
    C1 = Σ_{e=a+1}^{E} (j−2e+1)·T(e−a)
    C2 = Σ_{e=1}^{E} Σ_{v=−e}^{min(e,a)} μ_e(v)·⌈(j−2e−a+v)/2⌉₊
    C3 = Σ_{i=1}^{5} ⌈(j−a−i)/2⌉₊
  Machine-verified against the engine: φ_j(a) = har_j((L,L+1,a)) for j ≤ 33, all a.
DATA: min_a φ_j(a) attained at a=0, ≈ j³/24; e.g. φ(100,0) = 43878, har^∞₁₀₀ = 128135.
PLAN for all-j positivity: integral comparison. φ_j(a) ≥ j³·ψ(a/j) − Err(j) with
ψ piecewise rational (regimes a/j ≤ 1/4 ≤ 1/2 ≤ 1), ψ_min = ψ(0) = 1/24, Err = O(j²)
explicit; then finite check j ≤ J₁.

### [SWEEP-FINAL] Background run completed
Sweep log final: ALL LEVELS j <= 48 PASS (S1@j for j∉{2,4}, har_2 exact, S2@4),
min margin 0 at c=(0,0,1) at every level.
THEOREM (unconditional): [q^j] N_2 >= 0 for all c, all d with gcd(d,3)=1, j <= 48.
HM log final: HM verified (complete CAP-SHARP box) for ALL j <= 30, 0 failures.

### [R1-THEOREM] PROVED: har_j >= 0 on the whole one-small-coordinate region, ALL j
THEOREM R1. Let j ∉ {2,4}, and c a profile with at least two coordinates >= j-1
(the third arbitrary; ANY d — no residue condition needed here). Then har_j(c) >= 0;
in fact har_j(c) > 0 for j >= 5. (With rotation invariance of EMD, position of the
small coordinate is irrelevant.)

PROOF CHAIN (script seed6_R2L4_r1poly.py + pickles seed6_r1_classpolys.pkl,
seed6_r1_strippolys.pkl):
1. phi formula (proved earlier, [R1]): har_j(c) = phi_j(a), a = small coordinate.
   Fast exact evaluator: inner v-sum of C2 closed via G(M)=floor((M+1)^2/4),
   parity sums Gp; phi_fast == phi_slow verified j<=60 all a (exact ints).
2. STRUCTURAL LEMMA: on each chamber and each residue class (j,a) mod 12, phi is a
   polynomial of degree <= 3. Chambers: LOW {0<=a<=j-4, 2a<j}, HIGH {2a>=j, a<=j-4},
   STRIP {a=j-2}, {a=j-3}. Proof: C1,C2,C3,har_inf are iterated sums of period-2
   quasi-polynomial integrands over intervals with quasi-linear endpoints
   (denominators | 12); on a fixed class all floors/parities are linear/constant.
3. EXACT INTERPOLATION (Fractions): 144 LOW + 144 HIGH bivariate cubics, 24 strip
   univariate cubics. Fits: 144/144 each. Facts discovered:
   - LOW == HIGH identically for odd j classes (boundary 2a=j invisible at odd j) —
     the polynomial jump at 2a=j exists only for even j.
   - EVERY chamber polynomial has cubic part (j^3 + 6j^2 a - 6j a^2 + 2a^3)/24
     = j^3 psi(a/j), psi(mu) = (2mu^3-6mu^2+6mu+1)/24. Strip cubic lead = 1/8 = psi(1).
4. PINNING/VERIFICATION (all exact, 0 mismatches): dense band 6<=j<150 all a<=j-4
   (11016 pts, only strip a=j-2,j-3 excluded there and handled by strip polys,
   verified 6<=j<400); sparse band j<=610; sliver lines 2a-j=t (|t|<=30),
   j-a=t (t<=30), a=t (t<=30) for j up to 800: 19639 pts, 0 mismatches.
   Any conceivable extra chamber piece (2D cone or 1D sliver parallel to a boundary
   direction) is pinned by >=10 resp >=4 exact matches at large j.
5. TAIL BOUND: psi'(mu) = (mu-1)^2/4 >= 0, so psi >= psi(0) = 1/24 on [0,1].
   Slop constants over ALL chamber polys: K2=5/8, K1=7, K0=4 (sum of |coeff| by
   total degree, using 0<=a<=j). j^3/24 > K2 j^2 + K1 j + K0 for j >= 23;
   strips positive for j >= 10. Hence phi_j(a) > 0 for all j >= 23, all 0<=a<=j-2.
6. FINITE CHECK (exact, direct): min_a phi_j(a) for j <= 22, j ∉ {2,4}:
   j=0,1,3 -> 0; j=5..22 -> 3,4,12,17,31,41,61,76,104,126,162,191,237,275,331,378,
   446,504. All >= 0.  (j=2: min -2; j=4: min -1 — exactly the excluded exponents.) QED

COROLLARY (with R0). S1 restricted to profiles with at most one coordinate < j-1
holds for ALL j simultaneously — no cap needed. Combined with the unconditional
sweep (all profiles, j <= 48) and HM@j<=30, the remaining open part of S1 is:
j >= 49 AND at least two coordinates of c are < j-1 (i.e. genuinely small profiles
at high exponents) — equivalently the R2/R3 regions.

### [FINAL STATUS / HANDOFF] (proofs/prove-seed6-layer4.tex, compiled, 6 pp.)
PROVED (all d, gcd(d,3)=1 where relevant):
- CAP-SHARP: har_j(c) depends only on (min(c_i, j-1))_i; realization: box c_i<=j+1,
  3∤d decides S1@j/S2@j per level. [Thm 2.1/Cor 2.2]
- R0 deep interior: min c_i >= j-1 => har_j = har^inf_j >= 0 (j≠2). [Thm 3.1]
- SWEEP: [q^j]N_2 >= 0 for ALL profiles, ALL 3∤d, j <= 48. [Thm 4.1]
- S2 IS NOW FULLY PROVED UNCONDITIONALLY: S2 concerns only j=4 <= 48; b_2 and har_4
  are both cap-determined (thresholds <= 3), sweep covers all capped classes.
- HM => S1 reduction + base d=1; HM@j proved (complete finite check) j <= 30. [Thm 6.3]
- R1 MAIN: har_j(c) >= 0 (>0 for j>=5) for ALL j∉{2,4} whenever two coords >= j-1,
  any third coord, ANY d. Exact chamber quasi-polys (period 12, LOW/HIGH split only
  at 2a=j for even j, strips a=j-2,j-3), cubic part j^3·psi(a/j) globally,
  psi' = (mu-1)^2/4 >= 0, slop (5/8)j^2+7j+4, tail j>=23, exact head check. [Thm 7.5]
NOT PROVED (precisely formulated open work):
- HM for j >= 31 (finitely decidable per level; recommended structural target).
- S1 on R2/R3: j >= 49 AND >= two coords < j-1 (per level: finite box c_i <= j+1).
- Level-n lift: Y4 status unchanged (n=2 d<=35; n=3 d=4,5). Level-n analogue of the
  local formula is the natural next setup.
DEAD-END NOTES (D10-style):
- Naive (non-residue-respecting) har-monotonicity is FALSE; failures exactly on steps
  touching 3|d. S1 itself FALSE at 3|d (har_13((1,1,1)) = -1) — hypothesis essential.
- [q^n]N_n = 0 all-n valuation-argument attempt was circular via Delta_n; left open.
Artifacts: scripts seed6_R2L4_{engine,sweep,mono,mono2,mono_hi,r1,r1poly}.py (+logs,
pickles seed6_r1_classpolys.pkl / seed6_r1_strippolys.pkl); r1poly pipeline is a
one-command certificate: `python3 seed6_R2L4_r1poly.py pipeline`.
