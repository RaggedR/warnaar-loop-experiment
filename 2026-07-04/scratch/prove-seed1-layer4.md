# Seed 1, Layer 4, Round 2 — Mission 1: Q_{n,(4,3,3)} >= 0 at d=10 (modulus 13)

Date: 2026-07-04. Convention: TRUE labels + target-first kernel per synthesis-layer3.md §4(iv).
Reference engine: scratch/scripts/seed8_R2L3_engine.sage.

## Plan (Template A, §4(v))
1. Warnaar finite form F^(+1) (a=+1, k=3) -> coefficientwise limit -> T-shaped sum.
2. Pochhammer split -> S13-pair difference D1.
3. Re-derive m == 1 (mod 3) KR contiguous relation from KR arXiv 2022 Lemma 9.2
   (Uncu's displayed R3 has a typo). Verify numerically BEFORE use.
4. Uncu 2024 thm:m13: proved S13 expression for H_{(4,3,3)}. Bridge D1 to it.
5. Numerical verification of every link in exact Z[q] vs seed8 engine.

## Literature files located
- Uncu 2024: literature/corteel-citations/tex/uncu_proofs_modulo11_13_cylindric_kanade_russell/main.tex
- KR 2022: literature/corteel-citations/tex/kanade_russell_completing_a2_andrews_schilling_warnaar/cylindric.arXiv.new.tex
- Warnaar A2 AG: literature/tex/warnaar_A2_andrews_gordon/source.tex

## Work log
- [start] Read synthesis-layer3.md, prove-seed2-layer3.tex, seed2_R2L3_s11_chain.sage,
  seed8_R2L3_engine.sage. Located Uncu + KR tex. (Write tool denied; using bash heredoc.)

## Finding 1 (structural, big): the d=10 chain may need NO bridging relation
Quoted from Uncu main.tex (literature/corteel-citations/tex/uncu_proofs_modulo11_13_cylindric_kanade_russell/main.tex):
- eq:Sp1 (line 235), m=3k+1, k=4: S_13(z;rho|sigma) = sum z^{r1}
  q^{sum_{i=1..3}(r_i^2 - r_i s_i + s_i^2 + rho_i r_i + sigma_i s_i)}
  / [ (q)_{r1-r2}(q)_{r2-r3}(q)_{s1-s2}(q)_{s2-s3} (q)_{r3}(q)_{s3}(q)_{r3+s3+1} ]
  — NOTE: NO q^{2 r3 s3} cross term (that is only in S_{3k-1}, eq:Sm1).
- eq:mod13list (line 480-481): H_{(4,3,3)}(z,q) = S_13((0,0,0)|(0,0,0)) - q S_13((0,0,1)|(0,0,1)).
- thm:m13 (line 573): PROVED — "The claimed expressions of eq:mod13list ... hold."

Chain logic: Warnaar F^(+1) (sigma=(1,1,1), so i=3 exponent is r3^2 - r3 s3 + s3^2, NO cross
term) -> limit -> T with denominator (q)_{r3+s3} -> Pochhammer split
1/(q)_{r3+s3} = (1-q^{r3+s3+1})/(q)_{r3+s3+1} = shift (rho3,sigma3)->(+1,+1):
T = S_13((0,0,0)|(0,0,0)) - q S_13((0,0,1)|(0,0,1)) = Uncu's PROVED H_{(4,3,3)} EXACTLY.
=> The m==1 mod 3 R3 typo caution is MOOT for this orbit: no contiguous relation needed.
The 4-link chain collapses to 3 links. Must still: (a) confirm Warnaar's finite form a=+1
exists & its exact statement; (b) confirm which profile FERM corresponds to; (c) verify all
numerically vs engine.

## Finding 2: Warnaar Prop_finiteform a=+1 — exact statement located and quoted
File: literature/tex/warnaar_A2_andrews_gordon/source.tex, Proposition \label{Prop_finiteform}
(lines 2672-2687), a=1 branch (lines 2681-2686):
  F^{(1)}_{n0,m0;k}(z,q) = sum_{n1..nk>=0, m1..mk>=0}
    z^{n1} q^{sum_{i=1}^k (n_i^2-n_i m_i+m_i^2)} / (q)_{m0-n1+m1}
    * [n0,n1] [2 n_k, m_k] prod_{i=1}^{k-1} [n_i, n_{i+1}] [n_i - n_{i+1} + m_{i+1}, m_i]
with LHS eq Eq_F1: F^{(a)}_{n0,m0;k} = sum z^{n1}/(q)_{n_k+m_k} prod_i q^{n_i^2-sigma_i n_i m_i+m_i^2}
[n_{i-1},n_i][m_{i-1},m_i], sigma=(1,...,1,a). For a=+1 all sigma_i=1.
PROVED in the paper (proof lines 2784-2819 via Lemma Lem_F-trafo). Modulus: 3k+a+3 = 13
at k=3, a=+1 (line 2652-2653).

Limit n0,m0 -> infinity, k=3, rename (n,m)->(r,s):
LHS -> T(z,q) = sum_{r1>=r2>=r3>=0, s1>=s2>=s3>=0} z^{r1} q^{sum_i (r_i^2-r_i s_i+s_i^2)}
       / [(q)_{r1-r2}(q)_{r2-r3}(q)_{r3}(q)_{s1-s2}(q)_{s2-s3}(q)_{s3}(q)_{r3+s3}]
RHS -> FERM3p(z,q)/(q)_inf,  FERM3p := sum_{n1,n2,n3,m1,m2,m3>=0} z^{n1}
       q^{sum_i(n_i^2-n_i m_i+m_i^2)}/(q)_{n1} [2n3,m3][n1,n2][n1-n2+m2,m1][n2,n3][n2-n3+m3,m2]
Pochhammer split on (q)_{r3+s3} gives T = S13(e3|e3) - q S13(e2|e2) which IS Uncu's proved
H_{(4,3,3)} (eq:mod13list line 480-481, thm:m13). Chain closes with NO KR relation.

Positivity corollary: Q_{n,(4,3,3)} = (q)_n [z^n] FERM3p =
  sum_{n>=n2>=n3>=0; m1,m2,m3>=0} q^{n^2+n2^2+n3^2-n m1-n2 m2-n3 m3+m1^2+m2^2+m3^2}
  [n,n2][n-n2+m2,m1][n2,n3][n2-n3+m3,m2][2n3,m3]   — manifestly nonneg.

TODO next: (a) check Uncu's H normalization (eq:HtoF) matches ours; (b) Warnaar Conjecture 2
statement for a=+1 (profile (k+1,k,k)?); (c) full numeric verification.

## Finding 3: conventions all check out (quoted from Uncu main.tex)
- Uncu eq:HtoF (line 226): H_c(z,q) = (zq;q)_inf/(q;q)_inf F_c(z,q) — identical to ours.
- Uncu's F_c (line 187) is the raw max-part/total-size GF; his cylindric ineqs (line 182)
  pi^(i)_j >= pi^(i+1)_{j+c_{i+1}} — the conjecture.tex interlacing definition.
- Cyclic invariance F_c = F_{c'} stated line 219. rev(4,3,3)=(3,3,4) is a CYCLIC shift of
  (4,3,3), so this orbit is chirality-SAFE: no rev() bookkeeping risk at all.
- conj:Hconj (line 242): H_{(c1,c2,c3)} = S_m(e_{c2}|e_{c3}) - q S_m(e_{c2-1}|e_{c3-1}) for
  c2,c3>0; at (4,3,3), k=4: e_3=(0,0,0), e_2=(0,0,1) — matches eq:mod13list line 480.
- Uncu's displayed R31 (line 276) indeed has the typo: terms
  "- q S_m(rho+d3 | sig+2 d3) + q S_m(rho+d3 | sig+2 d3)" cancel. IRRELEVANT to this proof:
  no contiguous relation is needed (Finding 1).

## Verification plan (script scratch/scripts/seed1_R2L4_d10_chain.sage)
[FF] Warnaar Prop_finiteform a=+1, k=3, exact check at finite n0,m0 <= 3 (transcription guard).
[A]  T-form == S13(e3|e3) - q S13(e2|e2) per z-order n=0..4 (Pochhammer split; termwise).
[B]  (q)_n (q)_inf [z^n](S13(e3|e3)-qS13(e2|e2)) == engine Q_n at d=10 c=(4,3,3), n=0..4.
[C]  FERM3p Q_n formula (finite qbinomial sum) == engine Q_n, n as far as feasible (>=8).
[D]  FERM3p/(q)_inf == T per z-order (limit sanity).
Plus Q_n(1) = 21^n (K=22 at d=10).

- Env note: Sage 10.9 via ~/miniforge3/envs/sage (run: ~/miniforge3/envs/sage/bin/sage script.sage).

## VERIFICATION RESULTS (run 1, NMAXC=9): ALL PASS
Script: scratch/scripts/seed1_R2L4_d10_chain.sage, Sage 10.9, PREC=300, CHK=150, SMAX=26.
- [FF] Warnaar Prop_finiteform a=+1 k=3, exact power-series identity at all n0,m0 in {0..3}: PASS (16/16).
- engine (target-first kernel, d=10, exact Z[q], Phi_3(q^m)-division exact): H to m=9; Q_n
  via Gauss inversion; Q_n(1) == 21^n for n<=9: PASS.
- [C] FERM3p Q_n formula == engine Q_n EXACTLY in Z[q], n=0..9 (deg Q_9 = 729): PASS;
  all coefficients nonneg: PASS.
- [A] T == S13(e3|e3) - q S13(e2|e2) at z-orders 0..4 to q^150: PASS.
- [B] (q)_n (q)_inf [z^n](S13(e3|e3)-qS13(e2|e2)) == engine Q_n, n=0..4, to q^150: PASS.
- [D] (q)_n (q)_inf [z^n]T == Q_ferm(n), n=0..4 (coefficientwise limit sanity): PASS.
Total runtime 16s. Rerunning with NMAXC=12.

## Theorem identification
The proved statement is Warnaar's Conjecture \label{Con_cylindric-b} (source.tex lines
767-785), FIRST display, at k=4: GK_{(k,k-1,k-1)} = (4,3,3), modulus 3k+1 = 13.
Known cases: k=1 trivial, k=2 = CW19 Thm 3.2 (line 793). k=3 (d=7, mod 10) remains OPEN
(Uncu has no m=10 theorem). This is the first proved case with k >= 3, and the first
proved-positive core orbit at d=10.

## VERIFICATION RESULTS (run 2, NMAXC=12): ALL PASS
Log: scratch/tmp/seed1_L4_d10_chain_n12.log. FF=True A=True B=True C=True D=True.
[C] extended: FERM3p Q_n == engine Q_n exactly in Z[q] for n=0..12 (deg Q_12 = 1296),
all coefficients nonneg, Q_n(1)=21^n. Total 20s.

## Novelty check
- Warnaar source.tex line 793: Con_cylindric-b known only for k=1 (trivial), k=2 (CW19
  Thm 3.2). k>=3 open.
- Uncu main.tex line 654: Uncu TRIED to prove Warnaar's cylindric claims by creative
  telescoping and it did not terminate — he does not state the fermionic corollary
  anywhere; his thm:M13sumprod is the z=1 specialization only, in S13 form (not FERM form).
- RAG query "Warnaar cylindric partition conjecture balanced profile (4,3,3) modulus 13
  fermionic form proof": top hits are Warnaar's own k=1,2 proof section and the
  conjecture summary — no prior proof of k=4.
=> New-to-the-world in the same sense as Seed 2's d=8 (3,3,2) theorem.

## Chain status (final)
1. Warnaar Prop_finiteform a=+1, k=3: PROVED in literature (source.tex 2784-2819);
   transcription verified exactly [FF].
2. Coefficientwise limit n0,m0->inf: standard stabilization argument (same as proved d=8
   template Step 1); verified numerically [D].
3. Pochhammer split -> S13(e3|e3) - q S13(e2|e2): exact termwise identity; verified [A].
4. Uncu thm:m13 (PROVED): H_{(4,3,3)} = S13((0,0,0)|(0,0,0)) - q S13((0,0,1)|(0,0,1)).
   Quoted from main.tex lines 480-481, 573. NO KR contiguous relation needed (the R31
   typo is confirmed present but moot).
=> G_{(4,3,3)} = FERM3p; Q_{n,(4,3,3)} manifestly nonneg for all n. THEOREM.

## Deliverables
- proofs/prove-seed1-layer4.tex + .pdf (compiled, 4 pages).
- scratch/scripts/seed1_R2L4_d10_chain.sage (all 5 checks).
- scratch/tmp/seed1_L4_d10_chain_n12.log (full pass log).

## Claim classification: GREEN-candidate
Every link is either peer-reviewable literature (Warnaar Prop, Uncu thm:m13), a
half-page standard argument (limit), or a one-line termwise identity (split); all
numerically verified against the raw-validated reference engine to n=12 exact Z[q].
Core at d=10 shrinks by the balanced orbit. d=7 (k=3, mod 10) remains the smallest
unproved balanced case (no Uncu m=10 theorem exists).
