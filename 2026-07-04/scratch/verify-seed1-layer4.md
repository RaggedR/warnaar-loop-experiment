# INDEPENDENT VERIFICATION — Seed 1 Layer 4: Q_{n,(4,3,3)} ≥ 0 at d=10 (mod 13)

Verifier: fresh instance, 2026-07-04. Did not write the proof; auditing adversarially.
Artifacts audited: proofs/prove-seed1-layer4.tex, scratch/prove-seed1-layer4.md,
scratch/scripts/seed1_R2L4_d10_chain.sage, scratch/tmp/seed1_L4_d10_chain_n12.log.

## JOB 1 — KEYSTONE (literature sources opened and read)

### (a) Warnaar Prop_finiteform — CONFIRMED
File: ../literature/tex/warnaar_A2_andrews_gordon/source.tex.
- \label{Prop_finiteform} at lines 2672–2687. EXISTS. Stated for "a positive integer k
  and nonnegative integers n0, m0" — no other hypotheses; k=3, a=+1 is admissible.
- PROVED, not conjectured: proof at lines 2784–2819 via Lemma \label{Lem_F-trafo}
  (lines 2692–2714, itself proved lines 2718–2779 from Heine's 2phi1 -> 1phi1
  transformation, GR04 (III.2)). The l=0 case of the Lemma applies since
  u=(−n1,−n2,−a·n3,n3) is weakly increasing for n1>=n2>=n3>=0, a=+1 — admissibility
  hypothesis (Eq_u-ineq) checked OK.
- a=+1 branch (lines 2681–2686) transcribed VERBATIM into the tex's eq:ff:
  denominator (q)_{m0−n1+m1}, factors [n0,n1][2n_k,m_k], product over i=1..k−1 of
  [n_i,n_{i+1}][n_i−n_{i+1}+m_{i+1},m_i], exponent Sum(n_i²−n_im_i+m_i²). Exact match.
- LHS definition Eq_F1 (lines 2631–2637) with sigma=(1,…,1,a) (Eq_sigma-a) matches the
  tex's F^{(a)} display. For a=+1, sigma_i=1 for all i. Modulus: 3k+a+3 = 13 at k=3,
  a=+1 (lines 2649–2653). OK.
- Bonus: Warnaar himself states the z=1 limit shape (lines 2664–2668) = FERM+/(q)_inf
  at z=1 — Step 1's limit is Warnaar's own observation with z tracked.

### Warnaar Con_cylindric-b — CONFIRMED as the target statement
- \label{Con_cylindric-b} lines 767–785; FIRST display: GK_{(k,k−1,k−1)}(z,q) =
  (1/(zq)_inf)·Sum… = FERM+_{k−1}/(zq)_inf. At k=4: profile (4,3,3). Warnaar's
  GK_c(z,q) := Sum_{profile(pi)=c} z^{max(pi)} q^{|pi|} (lines 393–397) = CW F_c, and
  G_c := (zq)_inf F_c, so Theorem 1 (G_{(4,3,3)} = FERM+3) IS Con_cylindric-b at k=4.
- Known cases: k=1 trivial, k=2 = CW19 Thm 3.2 (lines 787–794); k>=3 open in the paper.
  k=4 genuinely new relative to Warnaar's paper.

### (b) Uncu thm:m13 — CONFIRMED
File: ../literature/corteel-citations/tex/uncu_proofs_modulo11_13_cylindric_kanade_russell/main.tex
(NOTE: the verifier brief cited literature/tex/.../source.tex — actual file is
corteel-citations/.../main.tex, which is what the tex bibliography correctly cites.)
- eq:Sp1 (line 235): S_{3k+1}(z;rho|sigma) — NO q^{2 r_{k−1} s_{k−1}} cross term (that
  term is only in eq:Sm1, the S_{3k−1} family, line 233). Denominators for k=4:
  (q)_{r1−r2}(q)_{r2−r3}(q)_{s1−s2}(q)_{s2−s3}(q)_{r3}(q)_{s3}(q)_{r3+s3+1}. Exponent
  Sum_i(r_i²−r_is_i+s_i²+rho_i r_i+sigma_i s_i). The tex's eq:S13 matches exactly
  (sum over r1>=r2>=r3>=0 equivalent to Z³>=0 since 1/(q)_{<0}=0).
- eq:ei (line 238): e_i = (0,…,0 (i zeros),1,…,1) in Z^{k−1}; k=4 gives e3=(0,0,0),
  e2=(0,0,1). Matches the tex's usage.
- eq:mod13list (lines 452–483), LAST row (lines 480–481):
  H_{(4,3,3)}(z,q) = S13((0,0,0)|(0,0,0)) − q·S13((0,0,1)|(0,0,1)). VERBATIM match.
- thm:m13 (line 573): "The claimed expressions of eq:mod13list, … hold." PROVED via
  thm:n6m13 (line 565: conj:FinIdeal correct for m=13, N=6) => cor:Idealconjm13 =>
  thm:m13. Proof is a computer-assisted ideal-membership/Gaussian-elimination
  computation (Section 3; ancillary files M13RecHXYZ_Explicit.txt on arXiv) plus
  initial-condition checks. Published proved theorem; machine-assisted nature flagged
  for provenance only.
- Normalization eq:HtoF (line 226): H_c = (zq;q)_inf F_c/(q;q)_inf — identical to tex.
  Uncu's F_c (line 187) is the raw largest-part/size GF with the interlacing
  definition (line 182), same as Corteel–Welsh.
- Cross-corroboration: thm:M13sumprod table (line 602), row (4,3,3), has polynomial
  p_c = (1−q^{r3+s3+1}) — exactly the Pochhammer-split shape.
- Chirality: Uncu conj:Hconj assumes c1 >= c2,c3 via cyclic symmetry; F_c invariant
  under cyclic shifts (line 219). rev(4,3,3) = (3,3,4) = cyclic shift of (4,3,3)
  (cyclic orbit {(4,3,3),(3,4,3),(3,3,4)} = full dihedral orbit). Chirality-SAFE.
- KR pattern check: H_{(c1,c2,c3)} = S_m(e_{c2}|e_{c3}) − q S_m(e_{c2−1}|e_{c3−1}) for
  c2,c3>0 (eq:Hconj line 245); at (4,3,3): S(e3|e3) − qS(e2|e2). Consistent.
- R31 typo (line 276): confirmed — terms −qS_m(rho+d3|sig+2d3) and +qS_m(rho+d3|sig+2d3)
  cancel; the displayed m=1 mod 3 R3 is vacuous as printed. Also confirmed MOOT: the
  proof chain uses no contiguous relation.

## JOB 2 — LOGIC of prove-seed1-layer4.tex (line-by-line)

- Setup: G_c, H_c, Q_n definitions match standing notation (synthesis-layer3 §4(iv))
  and Uncu's normalization. eq:ferm = Con_cylindric-b first display times (zq)_inf. OK.
- Theorem 1 => Corollary 2: [z^n] picks n1=n; (q)_n cancels 1/(q)_{n1}; remaining
  summand is exactly the displayed quintuple sum (exponent and all five binomials
  checked symbol-by-symbol against eq:ferm at k=4). Manifest nonnegativity correct
  (n²−nm+m² positive-definite; q-binomials have nonneg coefficients). OK.
- Step 1 (limit): [n0,n1][n1,n2][n2,n3] -> 1/((q)_{n1−n2}(q)_{n2−n3}(q)_{n3}) — checked
  algebraically (telescoping of (q)_{n1},(q)_{n2}); m-chain likewise; explicit
  1/(q)_{n3+m3} of Eq_F1 gives (q)_{r3+s3}. RHS: [n0,n1]->1/(q)_{n1},
  (q)_{m0−n1+m1}->(q)_inf. Stabilization bound ("any index exceeding N+n contributes
  only above q^N"): checked case-by-case — an index v among r_i,s_i forces its block
  r²−rs+s² >= 1,3,7 for v=1,2,3 and >= v²/4 >= v for v>=4, so exponent > N whenever
  v > N+n. Each z^n q^N coefficient is a finite sum of eventually constant terms.
  SOUND (terse in the tex but correct; also machine-checked [D]).
- Step 2 (split): 1/(q)_{r3+s3} = (1−q^{r3+s3+1})/(q)_{r3+s3+1} exact termwise;
  q^{r3+s3+1} = q·q^{r3}·q^{s3} = shift (rho3,sigma3)->(1,1) = e2|e2 plus global q.
  S13 (eq:Sp1) has NO 2r3s3 cross term, so the split lands exactly on the S13 pair —
  VERIFIED, no cross-term discrepancy. Formal rearrangement valid (finitely many terms
  per z^a q^N coefficient). OK.
- Step 3: verbatim citation of Uncu (Job 1(b)). OK.
- Conclusion: chain of equalities in Z[[q]][[z]]; division by (q)_inf invertible. OK.
- Verification remark [FF]/[A]–[D]: consistent with the script + log (PREC=300,
  CHK=150, NMAXC=12, deg Q_12 = 1296, runtime 20s, all True).
- Bibliography cites Uncu local path corteel-citations/.../main.tex — CORRECT.

No logical gaps found.

## JOB 4 — CONVENTION

- TRUE labels: (4,3,3) in raw conjecture.tex/CW convention; chirality-safe anyway. OK.
- Engine call in seed1_R2L4_d10_chain.sage: E = {(c,cp): emd(c,cp)}, rhs uses
  q^(m·E[(c,cp)])·H[m−1][cp] — kernel evaluated as EMD(target, source), identical to
  the validated call in seed8_R2L3_engine.sage (line 69). Checked algebraically that
  the code's 2e0+e1+3max(0,−e0,−e0−e1) (e = target−source) equals §4(iv)'s
  3max(0,c'1−c1,c0−c'0)+(c'0−c0)−(c'1−c1): both = max(2e0+e1, −e0+e1, −e0−2e1).
  Target-first: YES. OK.
- Q_n(1) = 21^n: K = (d+1)(d+2)/6 = 22 at d=10, K−1 = 21. OK.

## JOB 3 — INDEPENDENT RECOMPUTATION (in progress)

Design: deliberately NOT the seeds' H-recursion/EMD-kernel engine. I implement the raw
Corteel–Welsh functional equation (Uncu th:CW / eq:Grec, main.tex lines 209–227):
  G_c(z,q) = Sum_{J nonempty subset of I_c} (−1)^{|J|−1} (zq;q)_{|J|−1} G_{c(J)}(zq^{|J|}, q),
  G_c(0,q)=1, solved coefficientwise in z by q-adic fixed-point iteration over all 66
  profiles of d=10 (c(J) per eq:c(J), cyclic convention c0=c3). Then
  Q_n = (q)_n·[z^n]G_{(4,3,3)} mod q^PREC vs my own evaluation of the Corollary-2
  fermionic sum (exact Z[q]); plus Q_n(1)=21^n, nonnegativity; plus low-order checks of
  the S13 pair (Uncu transcription + normalization), the T split, and the finite-form
  transcription — all against MY engine, none reusing seed code.
Script: scratch/scripts/verify-seed1-layer4.sage; log: scratch/tmp/verify-seed1-layer4.log.

(Results appended below when the run completes.)

## JOB 3 — RESULTS (independent recomputation): ALL PASS

Script: scratch/scripts/verify-seed1-layer4.sage (written from scratch; raw CW-recursion
engine, NOT the seeds' H/EMD kernel). Log: scratch/tmp/verify-seed1-layer4.log.
Sage 10.9, NMAX=12, PREC=1320 (> deg F_12 = 1296), CHK=120. Runtime 140 s.

- Move-table sanity: my c(J) implementation reproduces Uncu's published display
  eq:recH730 for H_{(7,3,0)} exactly (profiles (7,2,1),(6,4,0) with +, (6,3,1) with
  −(1−zq)). Structural validation of the recursion transcription.
- [E] q-adic fixed-point iteration converged EXACTLY (iterates stabilized mod q^1320)
  for every z-order n=1..12 over all 66 profiles of d=10.
- [C'] Q_n := (q)_n·[z^n]G_{(4,3,3)} (raw CW engine) == fermionic sum F_n of
  Corollary 2, for n = 0..12, compared mod q^1320 with deg F_n = 9n² ≤ 1296 < 1320:
  MATCH for all n. All F_n coefficients nonnegative. F_n(1) = 21^n for all n ≤ 12.
  This independently reproduces the seed's [C] with a DIFFERENT engine (raw CW
  functional equation vs the seeds' target-first H-kernel + Gauss inversion) — the
  two engines agree, cross-validating both.
- [S'] Uncu row + normalization vs my engine: (q)_∞·([z^n]S13(e3|e3) − q[z^n]S13(e2|e2))
  == [z^n]G_{(4,3,3)} mod q^120 for n = 0..3. PASS (replicates seed check [B]).
- [A'] Pochhammer split: T-sum == S13(e3|e3) − q·S13(e2|e2) per z-order 0..3 mod q^120.
  PASS.
- [D'] Limit: (q)_n(q)_∞[z^n]T == F_n, n = 0..3, mod q^120. PASS.
- [FF'] Transcription guard on Warnaar Prop_finiteform a=+1, k=3: exact power-series
  identity at all n0,m0 ∈ {0,1,2} mod q^120. PASS (9/9).
Final line of log: VERIFIER OVERALL: E=True C'=True S'=True A'=True D'=True FF'=True.

## Novelty spot-checks
- Warnaar source.tex lines 787–794: Con_cylindric-b known for k=1 (trivial), k=2
  (CW19 Thm 3.2) only. k=4 new.
- Uncu main.tex (Comments on Computations): Uncu tried creative telescoping on
  Warnaar's cylindric claims; "calculations were not terminating". Uncu nowhere states
  the fermionic (FERM) form; his thm:M13sumprod is the z=1 S13-form specialization.
  The G = FERM identity and the manifestly positive Q_n corollary are new.

## VERDICT: SOLID

Every link of the 3-link chain holds up under adversarial audit:
1. Warnaar Prop_finiteform (a=+1, k=3): exists, PROVED in the literature, hypotheses
   satisfied, transcription verbatim (audited by eye + machine guard [FF']).
2. Coefficientwise limit: standard stabilization, degree bounds checked case-by-case;
   machine-checked [D'].
3. Pochhammer split: exact termwise identity; no 2r3s3 cross term exists in S13
   (eq:Sp1 checked at source) so the split lands verbatim on Uncu's proved pair;
   machine-checked [A'].
4. Uncu thm:m13: exists, PROVED (computer-assisted ideal membership), eq:mod13list
   last row verbatim = the split pair; normalization eq:HtoF identical; chirality-safe
   profile; machine-checked against an independent raw-CW engine [S'].
Independent recomputation (different engine, fresh code) reproduces Q_{n,(4,3,3)}
exactly in Z[q] for n = 0..12 with nonnegative coefficients and Q_n(1) = 21^n.

Errata: NONE required in prove-seed1-layer4.tex. Two non-blocking notes:
(N1) Provenance: Uncu's thm:m13 is a computer-assisted proof (Mathematica Gaussian
     elimination + arXiv ancillary certificates); anyone citing this chain inherits
     that dependency. Worth one sentence if the result is written up externally.
(N2) The Layer-4 verifier brief circulated a stale path for Uncu's source
     (literature/tex/...) — the tex's own bibliography path
     (literature/corteel-citations/tex/uncu_proofs_modulo11_13_cylindric_kanade_russell/main.tex)
     is the correct one. No change to the artifact needed.

GREEN recommendation: YES — Q_{n,(4,3,3)} ≥ 0 at d=10, and the stronger statement
G_{(4,3,3)} = FERM⁺₃ (Con_cylindric-b, first identity, k=4), may be marked GREEN.
