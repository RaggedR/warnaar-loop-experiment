# Handover — Round 2 Orchestrator, written after Layer 3 (2026-07-04)

You are the next orchestrator instance. Read this, then root `synthesis.md`
(pointer, kept current), then `2026-07-04/synthesis-layer3.md` IN FULL — it is
the input for whatever comes next (BA29–BA35, Missions 1–8, and §4(iv)'s
DEFINITIVE convention statement, mandatory in every future brief).
HANDOVER-layer2.md is the frozen post-Layer-2 record (launch spec, model policy).

LAYER 3 IS COMPLETE AND SYNTHESIZED. Remaining queue when this was written:
(1) Lean phase 2 (step 3c below — spec now finalizable from synthesis §4(iii));
(2) SESSION-2026-07-04.md at day end;
(3) Warnaar email (step 6 below) after Robin reads the two PDFs.

## Execution log

- Wave 1 (mixed pre/post context-clear): all 8 agents launched; ALL died ~14:45
  AEST — account USAGE LIMIT ("resets 4pm"). Seeds 1-5 left partial logs
  (121/80/103/92/42 lines); Seeds 6-8 wrote nothing.
  LESSON: all workers share the account budget — a limit hit kills the whole
  wave simultaneously. Scratch files are the recovery substrate.
- Wave 2 (Robin: "retry"): all 8 relaunched, fable-inherit; Seeds 1-5 as
  continuations (append, don't redo), 6-8 fresh. IDs: S1 a9a5a054ca5146a80,
  S2 a691397685c19374a, S3 a2f70a808e8693147, S4 a45def01c30c8d070,
  S5 a57facbc333d84115, S6 a300f1f0cb4430743, S7 a21ef78c13ee90abd,
  S8 ad5e67572778cd5f0.
- ~15:25: Seeds 1,2,3,4,6,7 COMPLETED (results below). Seeds 5,8 killed by a
  session cutoff; RELAUNCHED as continuations with sibling-informed briefs:
  S5 a35cc13abc1f8c923, S8 aeba1438a4a0bf648. S8's brief now includes
  independent recomputation attacks on S6's d=4 proof and S2's (3,3,2) identity,
  plus the convention-reversal warning.

## Results so far (6 of 8 in; full reports in agents' scratch ## Handoff + proofs/)

- **S1 GREEN**: A2 Pascal ladder PROVED — ferm(m,a,b,c) − ferm(m−1,a,b,c) =
  q^{m+a} ferm(m−1,a+1,b−1,c+2); monotonicity for every orbit with such a form.
  Its "g-transform reformulation" g_{c,n} ≥ 0 was later shown by S7 to be the
  conjecture itself (g_{c,n} = Q_n) — circular, not new leverage. Ladder stands.
- **S2 GREEN**: Warnaar Conjecture 2 at k=3 PROVED for balanced profile (3,3,2)
  at d=8 — first case beyond k=2. 4-link chain: Warnaar finite form → Pochhammer
  split → one proved Kanade-Russell contiguous relation → Uncu 2024 mod-11.
  d=8 core 7 → 6. Secondary: same chain with a=+1 should give d=10 balanced
  (caution: typo in Uncu's displayed R_3 for m≡1 mod 3). Naive fermionic lift
  fails for all 5 frontier orbits.
- **S3 YELLOW**: three injection families closed WITH certificates; ILP theorem:
  no levelwise monotone injective weight+1 self-map exists on wall orbits — any
  injection must couple levels. Reframe: ribbon move-set satisfies Hall in all
  22 tests (deficiency 0) — injection EXISTS, canonicity is the obstruction.
  New target HALL-RIBBON; state lattice distributive → normalized-matching route.
- **S4 YELLOW**: T2 identity N_2 = [B_c(q²) − 1 − q² − q⁴] + har(c) (EMD
  ball/sphere geometry); [q²]N_2 = 0 identically; low-band theorem [q^j]N_2 ≥ 0
  for j ≤ 5 unconditionally (Cap-Compression), j ≤ 11 modulo sharp cap. New
  Sphere Absorption Conjecture (verified n=2,3) = uniform involution target.
- **S6 GREEN — CLAIMS d=4 FINISHED** (all 15 profiles): keystone = fully-proved
  Corteel-Welsh companion note (literature/tex/corteel_welsh_A2_RR/source.tex)
  giving bounded fermionic forms for all five d=4 orbits; Inversion Lemma;
  walls via Absorption Lemma A (double q-Pascal, orbit (0,3,1)) and B (new
  shift-cancellation identity, orbit (0,2,2)); Q_n(1) = 4^n. NEEDS VERIFIER.
- **S7 GREEN**: Q-transform PROVED (S3 had only stated it); H_m = Σ_n [m,n]_q Q_n
  unconditional; nonneg q-binomial expansion exists ⟺ conjecture (bottleneck
  exact + unique); MASTER ⟺ conjecture. **CORRECTION: Layer 2's adjudicated
  equivalence "Monotonicity ≡ f_0 ≥ 0 ≡ BFF first level" is FALSE — those are
  strictly weaker projections. Monotonicity alone cannot close the conjecture.**
- **Convention reversal found INDEPENDENTLY by S6 and S7**: project chain-model/
  EMD profile labeling is reversed vs conjecture.tex (likely root of the old C2
  confusion). Pin conventions in all future briefs.

## Pipeline (Robin-approved; adapted after S8 absorbed the recomputation role)

1. DONE — all 8 seeds landed. S5 YELLOW: Bounded Factorization (bounded mod-d
   Tingley crystal, ALL d incl. 3|d — possibly new/publishable); SHARP-F0 target.
   S8 YELLOW-confirming: NO counterexample; MASTER clean to d=31; S2's theorem
   independently reconfirmed n≤12; S6's d=4 math reconfirmed n≤40, BUT S6's tex
   orbit dictionary is in the reversed convention (true-label wall orbit is
   {(0,1,3),(1,3,0),(3,0,1)}) — erratum needed, math unchanged.
2. DONE — sonnet verifier a1221a85e7ea832a6: **KEYSTONE SOLID.** The CW
   companion note is a real peer-reviewed paper (Corteel & Welsh 2019, "The A2
   Rogers-Ramanujan identities revisited"); Theorems \ref{new} and \ref{Thm:G}
   prove the five d=4 bounded forms, transcription verbatim. S6's d=4 proof
   rests on published results. Erratum CONFIRMED (chirality rows swapped) and
   APPLIED by orchestrator to proofs/prove-seed6-layer3.tex (+ convention-note
   paragraph); PDF recompiled clean. Wall orbit in true labels: CW(3,0,1) =
   {(0,1,3),(1,3,0),(3,0,1)}. Log: 2026-07-04/scratch/verify-layer3-keystone.md.
3. DONE — Lean pilot ac6c0723c88403000: **GREEN, both targets sorry-free**
   (axioms: propext/Classical.choice/Quot.sound only). Lake project lean/
   (Lean 4.30.0-rc2 + Mathlib): WarnaarGlue.pascal_ladder,
   WarnaarGlue.qbinom_inversion (+ Q_transform_of_H / H_of_Q_transform with
   Corollary I as named hypothesis). NOTE: Mathlib has NO Gaussian binomials —
   pilot built lean/WarnaarGlue/GaussBinomial.lean (q-Pascal both forms,
   symmetry, orthogonality both ways) — reusable artifact.
   Log: 2026-07-04/scratch/lean-pilot-layer3.md.
3b. DONE — synthesizer abbcf719b310d8e22 → 2026-07-04/synthesis-layer3.md
   (580 lines, BA29–BA35, Missions 1–8; all 5 adjudications answered).
   Key verdicts: Q-positivity is the ONLY terminal target (Monotonicity/f_0
   strictly weaker — Layer 2 framing dead); g_{c,n} = Q_{n,c} (S1's g-transform
   circular; Pascal ladder survives, Lean-checked); d=4 is a THEOREM by project
   standards; Layer 2's C2 verdict RETRACTED (artifact of reversed engine);
   Mission 1 = Templates A+B on d=10 balanced (4,3,3). Root synthesis.md
   pointer updated. Note: synthesizer's Write was blocked mid-session; it
   recovered the document from its transcript — content verified intact.
3c. DONE — Lean phase 2 agent a64bf8b1cee35aa38: **GREEN, all 3 priorities,
   lake build clean, orchestrator-reverified (0 errors, no sorry/admit/
   native_decide).** New files lean/WarnaarGlue/D4Positive.lean (~540 lines:
   CoeffNonneg predicate, gauss_nonneg, two sum-level q-Pascal splitting
   lemmas, absorption_A, absorption_B as EXACT ℤ[q] identities, Qcw_nonneg
   unconditional; d4_Q_eq_Qcw / d4_positive / d4_BFF / d4_monotone conditional
   on named hypotheses hCW + hQ, with machine-checked non-vacuity witness) and
   Seed2Chain.lean (qpoch_split/shift/bridge sorry-free; seed2_assembly/chain
   abstract with hWarnaar/hSplit/hBridge/hUncu named — the termwise split
   inside the 6-fold S₁₁ series recorded as STOP: no Mathlib summability
   framework for the shape). Axioms: propext/Classical.choice/Quot.sound only
   (seed2_assembly/chain: propext only). lean-review run and acted on.
   Log + handoff: 2026-07-04/scratch/lean-phase2-layer3.md.
   Original spec (executed as written). Priority order:
   (1) d=4 glue-first: Inversion Lemma instantiation + Absorption Lemma A
       (double q-Pascal) + Absorption Lemma B (shift-cancellation) as finite
       Z[q] identities, CW Theorem `new` as named hypothesis. Target:
       `theorem d4_positive (hCW : ...) : ∀ n c, 0 ≤ Q n c`.
       Same difficulty class as the pilot; build on lean/WarnaarGlue/
       (GaussBinomial.lean has q-Pascal both forms + orthogonality).
   (2) S2's chain links 2-3 (Pochhammer split + assembly), Warnaar finite
       form/KR relation/Uncu as hypotheses. Harder — (q)_inf limits; needs a
       finite reformulation first; do not start before (1) compiles.
   (3) decide-style Q_n coefficient certificates — cheap spot-checks only.
   SKIP: infinite products in earnest; crystal/lattice structures (S3/S5 —
   targets not yet stable). One agent, fable-inherit, lean-build to iterate,
   lean-review after; log 2026-07-04/scratch/lean-phase2-layer3.md.
4. Synthesizer (FABLE-INHERIT per Robin, NOT opus) → 2026-07-04/synthesis-layer3.md.
   Named adjudication questions MUST include: (i) reconcile S7's
   strictly-weaker correction vs Layer 2's equivalence adjudication;
   (ii) g_{c,n} = Q_n circularity (S1 vs S7); (iii) S6 d=4 claim vs verifier;
   (iv) both convention-reversal findings — one convention statement for the
   whole project; (v) does S2+S6 machinery compose to attack d=10 balanced /
   remaining d=8 orbits?
5. Update root synthesis.md pointer; rewrite THIS file as the final Layer 3
   handover; SESSION-2026-07-04.md at day end (mirror 2026-07-03, include model
   policy from HANDOVER-layer2.md).
6. Warnaar email (Robin's question, agreed sequence): only after verifiers +
   synthesizer + Robin personally reads proofs/prove-seed2-layer3.pdf and
   prove-seed6-layer3.pdf. Draft = modest tone, provenance disclosure is
   Robin's call, lead with Lean-checked glue + "builds on Corteel-Welsh & Uncu".

## Orchestrator lessons (this layer)

- Do NOT write live next-layer state into the previous layer's handover —
  HANDOVER-layerN.md is the frozen record written after layer N; live state for
  layer N+1 belongs in HANDOVER-layer(N+1).md (Robin correction, 2026-07-04).
- Accidental sequencing paid off: relaunched agents briefed with siblings'
  results were sharper. Consider deliberately launching the ADVERSARY seed
  AFTER the other seeds report, next round.
- Claims of full-case proofs (S6) get a verifier regardless of internal checks;
  keystones sourced via RAG must be verified to exist and say what's claimed.
