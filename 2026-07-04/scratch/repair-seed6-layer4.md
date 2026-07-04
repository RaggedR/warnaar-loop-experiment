# Repair log: seed6-layer4 errata (E1-E4)

Agent: errata-repair, 2026-07-04. Target: proofs/prove-seed6-layer4.tex (sole ownership).

## Plan
- E4 (main): replace empirical wall enumeration in Lemma 7.3 by exact switch-locus
  enumeration of C1/C2/C3. Derived on paper (below); new pinning script
  scratch/scripts/repair6L4_walls.py verifies wall lines (incl. 4a=j family) and
  sub-chamber full-rank pinning.
- E3: add edge-parametrization proofs of Lemma 7.1(1),(2). Derivation done (below).
- E1: j>=10 -> j>=11. E2: min phi_2 = -2 -> -1.

## E4 derivation (switch loci)
phi = har_inf - C1 - C2 + C3.
- C3 = sum_{i=1..5} y(j-a-i): equals untruncated sum of ceil((j-a-i)/2) for a <= j-4
  (since ceil(m/2)=0=y(m) for m in {0,-1}); walls a=j-2, a=j-3 only.
- C1 = sum_{e=a+1}^{E}(j-2e+1)floor((3(e-a)-1)/2): empty iff a >= E; wall 2a=j+t,
  t in {-1,-2}; otherwise closed quasi-poly (period 2 in e-a), degree 3.
- C2: inner v-sum closes to G(m2)-G(m1-1) + parity part - endpoint corrections,
  m1=max(1, n_e-e), m2=n_e+min(e,a), n_e=j-2e-a; all m>=1 so y=ceil.
  e-line breakpoints: B1: e=a; B2: 3e=j-a+{0,-1}; B3: e=j-a-1 (emptiness of e<=a
  branch); B4: e=E; B5: e=1. Walls = pairwise collisions inside domain:
  B1B2: 4a=j+{-1,0}; B1B3,B1B4,B3B4: 2a=j+{-2,-1,0}; B2B5,B3B5: a=j-t, t<=6;
  B1B5: a in {0,1,2}; B2B4: a = -j/2+O(1) < 0, outside domain.
  => wall list W: {2a=j+t, |t|<=2} u {4a=j+t, |t|<=2} u {a=t, t<=2} u {a=j-t, 2<=t<=6}.
  All offsets <= 6 (verifier predicted this). 4a=j direction IS a genuine candidate
  wall (from B1B2); pinning shows it carries no polynomial jump.
- Pairwise collisions of wall lines: all at j <= 14. So for j >= 15 the cell
  structure is stable; on each cell (3 open chambers LOW-A 4a<j, LOW-B j/4<a<j/2,
  HIGH; plus wall lines) phi is quasi-poly deg<=3 period 12 (endpoints denominators
  2,3; integrand parity 2).

## E3 derivation (edge parametrization of S_e)
Edges: E1: (s,s-e), s=0..e (u0+u1 = 2s-e, hits each v=e mod 2, |v|<=e once);
E2: (e-2t,t), t=0..e (u0+u1 = e-t, hits 0..e once); E3: (s,-2s-e), s=-e..0
(u0+u1 = -s-e, hits -e..0 once). Vertices shared: (e,0)@v=e, (-e,e)@v=0, (0,-e)@v=-e.
=> mu_e(v) = [v==e mod 2] + [v>=0] + [v<=0] - [|v|=e] - [v=0] = 1+[v==e(2)]-[|v|=e]. QED (1).
(2): sum_{v=beta+1}^{e} mu = delta + ceil(delta/2) - 1 = floor((3delta-1)/2), delta=e-beta. QED.

## Status
- [ ] script written/run
- [ ] tex edited
- [ ] PDF built

## Script run (repair6L4_walls.py) — ALL PASS, 51s, log: scripts/repair6L4_walls.log
- STEP 1: 288 chamber + 24 strip polys refitted exact, cubic parts confirmed.
- STEP 2: sub-chamber full-rank pinning (margin 8): LOW-A 45300 pts, LOW-B 44551,
  HIGH' 88506; all 144 classes rank 10, consistent, == global fits.
  => 4a=j+t walls carry NO polynomial jump.
- STEP 3: wall lines 2a-j=t, 4a-j=t (|t|<=8), a=t (t<=8), j-a=t (2<=t<=8),
  12 classes x 10 pts each, j>=15: 6000 exact matches, 0 mismatches.
- E2 numeric confirm: phi_2(0) = -1 (min over a<=0), phi_2(1) = -2 (R0 value).
- Refined B2=B5 collision: strips from C2 are a=j-3, j-4 (not j-6); C3 gives
  a=j-2, j-3. Generous W list keeps t<=6; spurious walls harmless (pinned anyway).

## Next: tex edits (E1-E4), then pdflatex x2.

## Tex edits applied (all 7, exact-match python replacements)
1. E3: Lemma 7.1 relabeled "also machine-verified", full proof added:
   edge parametrization -> (1) mu formula, (2) tail count, (3) shift identity,
   (4) w_k(beta) derivation from (2)+(3).
2. E4: Lemma 7.3 restated with explicit wall list W (2a=j+t |t|<=2, 4a=j+t |t|<=2,
   a<=2, a=j-t 2<=t<=6), three convex wall-free regions LOW_A/LOW_B/HIGH',
   full proof via switch-locus enumeration (B1..B5 breakpoints, pairwise
   collisions). 4a=j direction INCLUDED as genuine candidate wall (from B1=B2).
3. E4: Thm 7.4 restated as unconditional piecewise formula for all j>=6; proof =
   Lemma 7.3 + pinning (repair6L4_walls.py steps 2-3 + original pipeline).
4. E1: strip comparison j>=10 -> j>=11 (with note strips positive from 10 directly).
5. E2: min_a phi_2 = -1 on domain a<=j-2; -2 is the a=j-1/R0 value.
6. Abstract updated (walls enumerated exactly, 4a=j no jump).
7. Artifacts: repair6L4_walls.py added.

## PDF build: pdflatex x2, 0 errors, 8 pages. No undefined references.
## Status: DONE. Lemma 7.3 is now PROVED (structure proof + exact full-rank
## pinning), no relabeling to "computationally verified" needed.
