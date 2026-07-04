# INDEPENDENT VERIFICATION — Seed 2 Layer 4: two-term fermionic representation, d=8 core (mod 11)

Verifier: fresh instance, 2026-07-04. Did not write the proof; auditing adversarially.
Artifacts audited: proofs/prove-seed2-layer4.tex, scratch/prove-seed2-layer4.md (L4.1–L4.4
+ strikes), scripts scratch/scripts/seed2_R2L4_*.sage, logs scratch/tmp/seed2_L4_*.log.

## JOB 1 — KEYSTONES (literature sources opened and read at the source)

### (a) Warnaar Eq_F2 / Prop_finiteform2 — CONFIRMED, proved unconditionally
File: ../literature/tex/warnaar_A2_andrews_gordon/source.tex.
- \label{Eq_F2} at line 2834. EXISTS. Definition matches the tex's eq. (F2) VERBATIM:
  z^{n1} q^{Sum_{i=s}^k n_i + Sum_{i=t}^k m_i}/(q)_{n_k+m_k+1} * Prod q^{n_i^2-sigma_i n_i m_i+m_i^2}
  [n_{i-1};n_i][m_{i-1};m_i], with 1<=s,t<=k+1, sigma=(1,...,1,a), a in {-1,1}. The "+1" in the
  denominator (q)_{n_k+m_k+1} is present at source — this is the load-bearing detail.
- \label{Prop_finiteform2} at lines 2848–2878. EXISTS, PROVED (proof lines 2884–2962)
  via Lemma \label{Lem_F-trafo} (lines 2692ff, itself proved from Heine's 2phi1->1phi1;
  audited previously in verify-seed1-layer4.md Job 1(a) — same lemma, same admissibility
  mechanism). The u-vector here is u=(-sigma_1 n_1,...,-sigma_{t-1}n_{t-1}, 1-sigma_t n_t,...,
  1-sigma_k n_k, 1+n_k); Eq_u-ineq (weakly increasing) holds for n1>=...>=nk>=0 with a=-1
  — checked adjacent inequalities by hand incl. the block seam -n_{t-1} <= 1-n_t.
  Unconditional: Con_missing (line 2970) is only about theta evaluations at z=1, NOT in
  this chain. The footnote at 2825–2831 concerns Con_missing, not Prop_finiteform2.
- Eq_mineen (source, hypotheses 1<=s<=k+1, 1<=t<=k): transcribed VERBATIM into the tex's
  eq. (4): denominator (q)_{m0-n1+m1+delta_{t,1}}, exponent n_k^2+Sum_{i=s}^k n_i+
  Sum_{i=t}^{k-1} m_i, binomial top-shift delta_{i,t-1}, m_k:=2n_k. Exact match.
- Eq_mineen2 (source, hypotheses 1<=s<=k, t=k+1, k>=2): transcribed VERBATIM into the tex's
  eq. (5): exponent n_k^2-n_k+Sum_{i=s}^k n_i, binomial [n_i+delta_{i,k-1};n_{i+1}], no
  m-linear term, denominator (q)_{m0-n1+m1}. Exact match.
- (s,t) admissibility for the pairs actually used by the 7 orbits:
  first terms (c2+1,c3+1) in {(2,2),(3,2),(2,3),(4,2),(2,4),(3,3),(4,3)};
  second terms (c2,c3) in {(1,1),(2,1),(1,2),(3,1),(1,3),(2,2),(3,2)}.
  All except (2,4) satisfy Eq_mineen's 1<=s<=4, 1<=t<=3. (2,4) uses Eq_mineen2: s=2<=3,
  t=4=k+1, k=3>=2. ALL ADMISSIBLE.

### (b) Uncu eq:mod11list / thm:m11 — CONFIRMED, all seven rows verbatim
File: ../literature/corteel-citations/tex/uncu_proofs_modulo11_13_cylindric_kanade_russell/main.tex
(same path note as verify-seed1-layer4.md N2).
- eq:Sm1 (line 233): S_{3k-1} HAS the q^{2 r_{k-1} s_{k-1}} cross term (k=4: 2 r3 s3) and
  denominator (q)_{r_{k-1}+s_{k-1}+1}. The tex's eq:S11 matches exactly (sum over
  r1>=r2>=r3>=0 equivalent to Z^3>=0 since 1/(q)_{<0}=0).
- eq:ei (line 238): e_i = (0,...,0 (i zeros),1,...,1) in Z^3 at k=4. tex's e3,e2,e1,e0 correct.
- eq:mod11list (lines 328–352): I read every row. The seven c2,c3>0 rows are, verbatim
  (translated to e-notation):
  (6,1,1): S(e1|e1)-qS(e0|e0);  (5,2,1): S(e2|e1)-qS(e1|e0);  (5,1,2): S(e1|e2)-qS(e0|e1);
  (4,3,1): S(e3|e1)-qS(e2|e0);  (4,2,2): S(e2|e2)-qS(e1|e1);  (4,1,3): S(e1|e3)-qS(e0|e2);
  (3,3,2): S(e3|e2)-qS(e2|e1).
  EXACTLY the pattern H_c = S(e_{c2}|e_{c3}) - q S(e_{c2-1}|e_{c3-1}), per-row, all 7.
- thm:m11 (line 406): "The claimed expressions eq:mod11list and eq:H440exp hold." PROVED
  via thm:n6m11 (line 398, conj:FinIdeal for m=11, N=6, computer-assisted Gaussian
  elimination / ideal membership) => cor:Idealconjm11 => thm:m11. Same provenance caveat
  as the d=10 chain (machine-assisted certificates on arXiv).
- Normalization eq:HtoF (line ~226): H_c = (zq;q)_inf F_c/(q;q)_inf, i.e. H = G/(q)_inf —
  identical to the tex's setup.
- Chirality: Uncu's interlacing definition (main.tex, Definition before th:Borodin)
  pi^(i)_j >= pi^(i+1)_{j+c_{i+1}}, pi^(r)_j >= pi^(1)_{j+c_1} is IDENTICAL to the raw
  conjecture.tex definition (problem-description/conjecture.tex lines 19–25) = TRUE
  convention. The reversal-asymmetric pairs among the 7 are {(5,2,1),(5,1,2)} and
  {(4,3,1),(4,1,3)} (rev+cyclic swaps them); (6,1,1),(4,2,2),(3,3,2) are chirality-safe.
  Since my Job-3 engine implements Uncu's/conjecture.tex's c(J) move table directly
  (TRUE labels by construction) and Q_{(5,2,1)} != Q_{(5,1,2)}, the numeric match below
  settles chirality independently of any prior layer's label bookkeeping.
- Caveat found (see Job 2, E1): Uncu's eq:Hconj carries the normalization "assume
  c1 >= c2,c3 (cyclic)" and c2,c3 <= k-1=3; the proved list covers exactly the listed
  representatives. All 7 claimed profiles are listed representatives, so the CLAIM
  is fine — but the tex's Theorem 3 states a broader scope that is NOT covered.

## JOB 2 — LOGIC of prove-seed2-layer4.tex (line by line)

- eq:S11 (tex): matches Uncu eq:Sm1 at k=4 (see above). OK.
- eq:F2/eq:mineen/eq:mineen2 (tex): verbatim transcriptions (Job 1a). OK.
- Lemma 1 (verbatim limit): telescoping [n0;n1][n1;n2][n2;n3] ->
  1/((q)_{n1-n2}(q)_{n2-n3}(q)_{n3}) — checked ((q)_{n0}/(q)_{n0-n1}->1); the sigma=(1,1,-1)
  exponent rewrite Sum(n_i^2-sigma_i n_i m_i+m_i^2) = Sum(n_i^2-n_i m_i+m_i^2)+2n_3m_3 —
  checked (-sigma_3 = +1 = -1+2). Linear terms = e_{s-1}.n+e_{t-1}.m — checked against
  eq:ei ((e_j)_i=1 iff i>j). Denominator carried verbatim. Coefficientwise stabilization:
  for fixed z^n q^N all indices bounded (positive-definite quadratic blocks), each
  coefficient a finite eventually-constant sum. SOUND (terse but correct; machine-checked
  in Job 3 [V']).
- Lemma 2 (Ferm form): limit of Eq_mineen/Eq_mineen2 RHS at k=3. Substitution m3=2n3
  into the i=2 binomial top: n2-n3+m3+delta_{2,t-1} = n2+n3+delta_{t,3} — checked. Exponent
  Sum_{i=t}^{2} m_i — checked against Sum_{i=t}^{k-1}. t=4 shape (n3<=n2+1 from [n2+1;n3],
  exponent n3^2-n3, no m-linear term) — checked. Termwise limit justified (m1,m2 finite
  per fixed (n1,n2,n3); (q)_{m0-n1+m1+delta}->(q)_inf coefficientwise). OK.
- Theorem 3 proof: multiply eq:uncu by (q)_inf; G=(q)_inf H; Q-extraction: [z^n]Ferm
  carries the single 1/(q)_n, so (q)_n[z^n] gives the finite ferm sums. OK.
- **GAP E1 (statement overbreadth — erratum required, does NOT affect the claim).**
  Theorem 3 asserts the representation "for every profile c with c1+c2+c3=8 and
  c2,c3 >= 1". This is FALSE/undefined outside the listed representatives:
  (i) (1,6,1) has c2=6 -> Ferm_{7,2} undefined (s must be <=4); same for any c2 or c3 >= 4.
  (ii) (2,3,3) has (c2+1,c3+1)=(4,4), excluded from BOTH Eq_mineen (t<=3) and
  Eq_mineen2 (s<=3) — Ferm_{4,4} is never defined. The proof's parenthetical
  "(s,t)=(4,4) never occurs since c2+c3<=7 forces min(c2,c3)<=3" is WRONG as reasoning:
  (2,3,3) satisfies all stated hypotheses and hits (4,4). (iii) Uncu's proved list
  covers the cyclically-normalized representatives only; H_{(2,3,3)}=H_{(3,3,2)} by
  cyclic invariance, but its Uncu pair is the (3,3,2) one ((s,t)=(4,3)&(3,2)), not the
  naive (c2,c3)=(3,3) pattern. FIX: restrict the theorem to the seven listed profiles
  (equivalently: c the cyclic representative with c1>=c2,c3 and 1<=c2,c3<=3 — exactly
  the seven), and delete/repair the parenthetical. All seven claimed orbits satisfy
  1<=c2,c3<=3 with (s,t)!=(4,4) and appear verbatim in eq:mod11list, so the CLAIM
  UNDER AUDIT is unaffected.
- Same overbreadth in the tex's eq:uncu display ("for profiles with c2,c3>0") — Uncu
  proves the listed rows; harmless here since only listed rows are used, but the
  erratum should cite eq:mod11list rows rather than an unrestricted pattern.
- Abstract/Cor. 4: consistent with the theorem once restricted. Positivity explicitly
  NOT claimed — consistent with the brief.

## JOB 3 — INDEPENDENT RECOMPUTATION (script written from scratch)

Design (no seed code reused): raw Corteel–Welsh functional equation engine
(Uncu eq:Grec + eq:c(J), TRUE/conjecture.tex convention by construction), q-adic
linear solve per z-order over all 45 profiles of d=8; my own transcription of the
ferm_{s,t}(n) multisums from the tex; my own S11 truncated evaluator from Uncu eq:Sm1.
Checks: [E] engine self-consistency; [W'] Q_{n,c} == ferm_{c2+1,c3+1}(n) - q ferm_{c2,c3}(n)
exactly for all 7 profiles, n <= 12; [S'] (q)_inf(S11 pair) == [z^n]G_c per Uncu row, n<=3
(chirality + list + normalization); [V'] verbatim limit for >=2 (s,t) pairs incl. t=4;
[FF'] finite-form transcription guard Eq_F2 == Eq_mineen/mineen2 at finite n0,m0;
[K1-K3] strike-certificate spot checks.
Script: scratch/scripts/verify-seed2-layer4.sage; log: scratch/tmp/verify-seed2-layer4.log.

(Results appended when the run completes.)

## JOB 3 — RESULTS (independent recomputation): ALL PASS

Script: scratch/scripts/verify-seed2-layer4.sage (fresh code; raw CW-recursion engine
per Uncu eq:Grec/eq:c(J), q-adic linear solve per z-order over all 45 profiles of d=8 —
NOT the seeds' H/EMD kernel and NOT Seed 2's code). Log:
scratch/tmp/verify-seed2-layer4.log. Sage 10.x, NMAX=12, PREC=1500, CHK=120. Runtime 129 s.

- [E] q-adic solve converged exactly (iterates stabilized mod q^1500) for every z-order
  n=1..12 over all 45 profiles of d=8, from G_c(0,q)=1 alone.
- [W'] MAIN CHECK: Q_{n,c} := (q)_n [z^n]G_c (my raw CW engine) ==
  ferm_{c2+1,c3+1}(n) - q*ferm_{c2,c3}(n) (my own transcription of the tex's
  (Fermst)/(Fermst2) finite sums), compared mod q^1500 with max deg(Q) = 1056 < 1500,
  hence EXACT equality in Z[q]: MATCH for ALL SEVEN profiles, ALL n = 0..12.
  Bonus facts recorded: all differences coefficientwise nonneg on this range (consistent
  with Y1; NOT part of the claim), and Q_n(1) = 14^n (K-1 = 14 at d=8) for all cells.
  This exceeds the brief's target n >= 10.
- [S'] Uncu rows + normalization + CHIRALITY: (q)_inf ([z^n]S11(e_{c2}|e_{c3})
  - q [z^n]S11(e_{c2-1}|e_{c3-1})) == [z^n]G_c mod q^120, n = 0..3, for ALL SEVEN
  profiles, against my own S11 evaluator (transcribed from Uncu eq:Sm1) and my own
  TRUE-convention engine. PASS. Chirality non-vacuity confirmed separately:
  Q_3(5,2,1) != Q_3(5,1,2) and Q_3(4,3,1) != Q_3(4,1,3) (exact Z[q]), so a swapped
  label assignment would have FAILED [W']/[S'] — the labels are pinned, TRUE-convention,
  per-orbit. This kills the historical (5,1,2)-vs-(2,1,5) bug class for this artifact.
- [V'] Verbatim-limit lemma: S11(e_{s-1}|e_{t-1}) == [z^n]Ferm_{s,t}/((q)_n (q)_inf)
  mod q^120, n<=3, for (s,t) in {(2,2),(4,3),(3,3),(2,4)} — four pairs incl. the t=4
  (Eq_mineen2) case. PASS (brief asked for >= 2 orbits' worth; done symbolically per
  z-order via two independently-written evaluators).
- [FF'] Transcription guard on Warnaar Prop_finiteform2: Eq_F2 == Eq_mineen/Eq_mineen2
  as z-graded series mod q^120 at k=3, a=-1, for ALL 15 admissible (s,t), all
  n0,m0 in {0,1,2}. PASS (15/15). My transcriptions were made from source.tex directly.

## JOB 4 — STRIKE-CERTIFICATE SPOT CHECKS: all three failures are REAL

- [K1] Strike 1 (one-round absorption, (4,3,1)): rebuilt A,B from the q-Pascal split
  of the L-slice myself; residual B - q^{1+n3}A has negative coefficients on slices
  n<=5. Failure REAL. (Also re-confirmed Lemma Candidate A: L(n,n2,n3) >= 0 on all
  slices n<=5.)
- [K2] Strike 2 (elementary moves): first brackets of Route I (ferm(s,t)-ferm(s-1,t))
  and Route II (ferm(s,t)-q ferm(s,t-1)) each have negative coefficients for (4,2,2)
  and (5,2,1) already at n<=5. Failures REAL; consistent with the "irreducibly
  diagonal" structural note and with tmp/seed2_L4_moves_run1.log (all 7 orbits FAIL).
- [K3] Strike 3 (pure n-decrement): recomputed r = L(2,1,1) - L(1,1,1) =
  q^{-1} + 2 + 2q + q^2 + q^3 + q^4 + q^5 - q^6 + q^7 — EXACTLY the polynomial quoted
  in the scratch, with the -q^6 obstruction. Failure REAL.
- Bookkeeping: scratch cites tmp/seed2_L4_recur2_run1.log but only
  tmp/seed2_L4_recur_run1.log exists (recur2.sage script is present). Non-blocking;
  my K3 independently confirms the relevant negative result. Similarly no tmp log for
  lemmaA (none was cited with a filename). The dead-list is honest.

## VERDICT: SOLID-WITH-ERRATA

Every link holds for the claim as briefed (the SEVEN d=8 core-orbit profiles):
1. Warnaar Eq_F2/Prop_finiteform2: exists, PROVED unconditionally at source, all 13
   (s,t) instances used are admissible, transcription verbatim (eye + machine [FF']).
2. Verbatim limit onto Uncu S11(e_a|e_b) incl. the (q)_{r3+s3+1} denominator: sound,
   machine-checked [V'].
3. Uncu eq:mod11list rows for all 7 profiles: verbatim, proved by thm:m11
   (computer-assisted); normalization eq:HtoF identical; chirality machine-pinned [S'].
4. Q-extraction: correct; independent raw-CW engine reproduces
   Q_{n,c} = ferm_{c2+1,c3+1}(n) - q ferm_{c2,c3}(n) EXACTLY in Z[q], all 7 orbits,
   n <= 12 [W'].
Positivity of the differences is NOT claimed, and the three positivity strikes are
genuine failures (Job 4).

### Errata required in proofs/prove-seed2-layer4.tex (statement scope only; no
### mathematical content of the claimed orbits is affected)

(E1) Theorem 3 scope: "for every profile c with c1+c2+c3=8 and c2,c3>=1" is overbroad.
     Counterexamples to the statement as written: (1,6,1) (Ferm_{7,2} undefined — s,t
     must lie in the Prop_finiteform2 ranges); (2,3,3) hits (s,t)=(4,4), which is
     covered by NEITHER Eq_mineen (t<=3) nor Eq_mineen2 (s<=3), so Ferm_{4,4} is
     undefined; and Uncu's proved list covers only the cyclically-normalized
     representatives. The proof's parenthetical "(s,t)=(4,4) never occurs since
     c2+c3<=7 forces min(c2,c3)<=3" is incorrect reasoning ((2,3,3) satisfies the
     stated hypotheses). FIX: state the theorem for the seven profiles
     (6,1,1),(5,2,1),(5,1,2),(4,3,1),(4,1,3),(4,2,2),(3,3,2) — equivalently the cyclic
     representatives with c1>=c2,c3 and c2,c3>=1 at d=8 — and repair the parenthetical.
     (Every d=8 profile with c2,c3>=1 is a cyclic shift of one of the seven, so the
     G_c-level result still covers all such profiles AFTER cyclic normalization;
     the formula just cannot be read off from un-normalized (c2,c3).)
(E2) The tex's eq. (2) ("Uncu's modulo-11 theorem states, for profiles with c2,c3>0")
     over-attributes: Uncu proves the LISTED rows of eq:mod11list (normalized
     representatives), not an unrestricted c2,c3>0 pattern. Cite the rows. Only listed
     rows are used, so this is presentational.
(E3) Provenance sentence worth adding (same as d=10 chain): Uncu thm:m11 is a
     computer-assisted proof (ideal-membership/Gaussian-elimination certificates);
     any external write-up inherits that dependency.
(E4) Bookkeeping: scratch cites tmp/seed2_L4_recur2_run1.log which does not exist
     (only recur_run1). Non-blocking.

GREEN recommendation: YES for the representation theorem restricted to the seven
profiles (i.e., the claim as briefed), after applying E1/E2 to the tex. Positivity of
the six two-term differences remains YELLOW/open, as the artifact itself states.
