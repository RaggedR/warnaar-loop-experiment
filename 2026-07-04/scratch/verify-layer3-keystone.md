# Verification Report — Round 2, Layer 3 Post-processing

Agent: Verification agent (Layer 3 keystone + erratum)
Date: 2026-07-04

---

## JOB 1 — KEYSTONE CHECK

### (a) The Corteel-Welsh companion note: identity and status

File: `/Users/robin/git/experiments/waarnar/literature/tex/corteel_welsh_A2_RR/source.tex`

- **Title**: "The A2 Rogers-Ramanujan identities revisited"
- **Authors**: Sylvie Corteel (IRIF, CNRS/Univ. Paris Diderot) and Trevor Welsh (Univ. Melbourne)
- **Status**: This is a **complete, fully proved paper** — not a draft or conjectural note.
  Version history (lines 1–4): versions 03–05 dated June–July 2019.
  Dedicated to George Andrews for his 80th birthday, with acknowledgment of an anonymous referee ("her excellent suggestions and careful reading"), indicating peer review. The proofs proceed by uniqueness induction on an explicit positive functional system — not conjectural.

### (b) Does it state and prove the bounded fermionic forms Seed 6 cites?

**Theorem \ref{new}** (lines 193–212, labeled `\label{new}`): This is exactly the theorem
Seed 6's prove-seed6-layer3.md §1 quotes. It gives the bounded generating functions
$F_{c,n}(q)$ for all **five** CW labels: $(4,0,0)$, $(3,1,0)$, $(3,0,1)$, $(2,2,0)$,
$(2,1,1)$ — precisely the five $d=4$ orbit representatives (level $\ell=4$, $k=3$ parts,
modulus $d+3=7$).

**Theorem \ref{Thm:G}** (lines 430–474, labeled `\label{Thm:G}`): Gives the y-refined
$G_c(y,q) = (yq;q)_\infty F_c(y,q)$ as explicit double sums for all five labels.
This is the theorem Seed 6's md §1 quotes for the functional system **Eq:Fun** (lines
493–501 of source.tex). The proof (lines 476–542) is a complete uniqueness induction on
y-exponents.

**Theorem \ref{new} proof** (lines 545–567): Derives the bounded forms from Thm:G by the
q-binomial theorem — fully rigorous, 3 lines.

**All five orbits covered**: The paper states explicitly (line 307–311): "we need only
compute the generating functions for the compositions $(4,0,0)$, $(3,1,0)$, $(3,0,1)$,
$(2,2,0)$, and $(2,1,1)$." All five appear in both Thm:G and Thm \ref{new}. Warnaar's
open problem for the bounded analogue is solved here.

**Statement match with Seed 6**: The formulas in source.tex Thm:G lines 433–471 match
exactly those transcribed in prove-seed6-layer3.md §1 and prove-seed6-layer3.tex
"Input from the literature" paragraph. The functional system Eq:Fun (lines 493–501) also
matches §1's quoted relations exactly.

### (c) Convention mismatch check

Seed 6's own md (§7 V1 finding) notes: "brute_F(c) = F_{rev(c)}, rev(c0,c1,c2)=(c2,c1,c0).
F is constant on C3-orbits, so reversal-symmetric orbits masked this." The tex file's
orbit dictionary (which mislabeled the two chirality-sensitive orbits) arose from Seed 6
using the OLD source-first kernel in their own verification scripts. The CW note itself
defines cylindric partitions of profile $c=(c_1,\ldots,c_k)$ by the standard rule
(Definition, lines 248–257) — no kernel orientation issue there. The CW formulas are
cited correctly in the tex (the five formulas match Thm:G and Thm \ref{new} exactly).
The convention error only affects which engine orbit label the tex attaches to each CW
formula — the formulas themselves are correctly transcribed and proved.

## Verdict — JOB 1

**KEYSTONE SOLID** (with convention note applied by erratum in JOB 2).

The Corteel-Welsh note is a complete, peer-reviewed paper with fully proved Theorems
\ref{new} and \ref{Thm:G} covering all five d=4 orbits. Seed 6's proof chain rests on
genuine proved results. The formulas are transcribed correctly. Convention consistency is
addressed by the JOB 2 erratum.

---

## JOB 2 — ERRATUM

### Independent verification of adversary's claim

Script: `seed8_R2L3_swapcheck.sage`, run at n≤28.

Output (independent rerun, this agent):
```
CW(3,1,0) formula == engine orbit of (0,3,1), n<=28: True
CW(3,0,1) formula == engine orbit of (0,1,3), n<=28: True
C3-rotation invariance within orbits: True True
```

Confirmed: In the target-first (raw conjecture.tex) engine convention, Seed 6's
tex dictionary is WRONG for the two chirality-sensitive orbits. The dictionary prints:
- CW(3,1,0) = {(0,1,3),(1,3,0),(3,0,1)}   [WRONG — this is actually CW(3,0,1)'s orbit]
- CW(3,0,1) = {(0,3,1),(1,0,3),(3,1,0)}   [WRONG — this is actually CW(3,1,0)'s orbit]

Corrected (identity map, confirmed n≤28):
- CW(3,1,0) = {(0,1,3),(1,3,0),(3,0,1)}  maps to engine orbit {(0,1,3),...}  ✓
- CW(3,0,1) = {(0,3,1),(1,0,3),(3,1,0)}  maps to engine orbit {(0,3,1),...}  ✓

Wait — re-reading: the swapcheck shows CW(3,1,0) formula matches engine orbit (0,3,1),
and CW(3,0,1) formula matches engine orbit (0,1,3). So the corrected dictionary IS:
- CW(3,1,0) = orbit {(0,3,1),(1,0,3),(3,1,0)} 
- CW(3,0,1) = orbit {(0,1,3),(1,3,0),(3,0,1)}

This matches the adversary's stated correction: "In raw labels the d=4 chirality-sensitive
WALL orbit is {(0,1,3),(1,3,0),(3,0,1)}" which is CW(3,0,1) (the wall).

The seed6 tex has the two chirality-sensitive rows swapped relative to the corrected truth.

Seed6_walls script with corrected (identity) dictionary: ALL 5 orbits MPS (Match, Positive,
Sum=4^n) for n≤10. Confirmed.

### Erratum edit to prove-seed6-layer3.tex

**NOTE**: The Edit tool was denied permission during this session. The erratum edit
could not be applied. The required change is described below precisely for manual
application or a subsequent agent with edit permissions.

**File**: `/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04/proofs/prove-seed6-layer3.tex`

**Change needed**: In the "Orbit dictionary" paragraph (lines 50–61), the two
chirality-sensitive rows are currently:
```
\mathrm{CW}(3,1,0)=\{(0,1,3),(1,3,0),(3,0,1)\}, &
\mathrm{CW}(3,0,1)=\{(0,3,1),(1,0,3),(3,1,0)\},\\
```
These must be SWAPPED to:
```
\mathrm{CW}(3,1,0)=\{(0,3,1),(1,0,3),(3,1,0)\}, &
\mathrm{CW}(3,0,1)=\{(0,1,3),(1,3,0),(3,0,1)\},\\
```
Then a "Convention note (erratum)" paragraph should be added explaining:
- The original dictionary used the source-first reversed kernel
- The corrected dictionary uses the target-first kernel (raw conjecture.tex convention)
- The identity: each CW label c maps to the orbit containing c itself
- Validation: adversary agent seed8_R2L3_swapcheck.sage n≤28
- The mathematics (formulas, absorption lemmas, main theorem) is unaffected

## Verdict — JOB 2

**ADVERSARY CLAIM CONFIRMED** (exact Z[q], n≤28, independently rerun).
**ERRATUM: COULD NOT APPLY** (Edit tool permission denied in this session).
The precise corrected text is documented above and in this file.

---

## Summary for synthesis

JOB 1: KEYSTONE SOLID. The CW note is a complete peer-reviewed paper; Theorems \ref{new}
and \ref{Thm:G} cover all five d=4 orbits with full proofs; Seed 6's citations are
accurate.

JOB 2: The orbit dictionary in prove-seed6-layer3.tex has CW(3,1,0) and CW(3,0,1) row
labels swapped relative to the raw conjecture.tex convention. CONFIRMED independently at
n≤28. The mathematics is unaffected (all five formulas positive and correct). The erratum
edit was blocked by tool permissions and must be applied manually or by a subsequent agent.
