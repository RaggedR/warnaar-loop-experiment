# Synthesis — Current State (Round 2, after Layer 4)

Read `2026-07-04/synthesis-layer4.md` — the synthesis of Round 2 Layer 4
(8 seeds + 4 independent verifiers + post-hoc adversary + Lemma-7.3 repair;
G13–G21, Y11–Y19, D12–D17, BA36–BA42). Headlines:

- **Second proved conjecture case — d=10 is a THEOREM**: the balanced orbit
  (4,3,3) at modulus 13, first case of Warnaar's Conjecture 2.11 (k=4), via a
  3-link Template-A chain onto Uncu's modulus-13 theorem — NO contiguous-relation
  bridge needed. Scaling law: bridges are only needed at moduli ≡ −1 mod 3.
  Verifier SOLID; adversary confirmed to n=15. We now have one proved case in
  EACH of Warnaar's two A₂ Andrews–Gordon families (moduli 11 and 13).
- **Warnaar email SENT (2026-07-04)** with the consolidated note
  (`2026-07-04/note/warnaar-note.pdf`, both proofs + methodology appendix +
  Lean mapping) and `2026-07-04/proofs/prove-seed1-layer4.pdf` attached.
- **Entire d=8 core has a two-term fermionic representation**:
  G_c = Ferm_{c₂+1,c₃+1} − q·Ferm_{c₂,c₃} for the seven listed representatives
  (theorem restricted post-verifier — BA39). d=8 positivity ⟺ six explicit
  polynomial inequalities, adversary-clean to n=32.
- **d=7 (smallest unproved level): full positive y-system** — G_c ∈ ℕ[[y,q]]
  for all 12 orbits, verifier SOLID. First positivity of any kind at d=7 in the
  literature. Q-positivity endgame is Layer-5 Mission 1 (TOP).
- **N₂/Harnack theorem factory (Seed 6, all repaired & unconditional)**:
  CAP-SHARP, low band j≤48, S2 proved, HM⟹S1 with HM verified j≤40, R1 chamber
  theorem unconditional after the wall-enumeration repair. **S1 is FALSE at 3|d**
  (BA38) — gcd(d,3)=1 is essential.
- **Deaths**: Y8/Conjecture A FALSIFIED for d≥5 — nonneg rows exactly at
  balanced targets; layer-3 §4(viii) RETRACTED (BA36). Newman route to Tingley
  2b dead (BA40). G10 har orientation corrected (BA37).
- **New structural lever (BA41)**: n=2 is the UNIQUELY hard level — raw
  residue monotonicity holds perfectly at n=3,4 but fails at n=2.
- **Adversary clean everywhere**: d=7/8 m≤32, d=10 m≤22, d=11, d=13 fresh;
  all sibling claims independently reconfirmed.
- **Lean**: TheoremD.lean added (D-tower kernel identities, ferm-monotonicity,
  Lemma E), sorry-free; public mirror github.com/RaggedR/warnaar-glue in sync.

Proved perimeter: d=2,4,5 (full levels), d=8 orbit (3,3,2), d=10 orbit (4,3,3),
d=7 at the G-level. The §4(iv) convention statement (carried verbatim in
synthesis-layer4.md §4) remains MANDATORY in every brief.

Next-layer missions: synthesis-layer4.md §6 (Missions 1–8; Mission 1 = d=7
Template-B endgame). Live orchestrator state: `2026-07-04/HANDOVER-layer5.md`.

Prior layers: `2026-07-04/synthesis-layer3.md` (BA29–BA35, §4(iv) DEFINITIVE
convention), `2026-07-04/synthesis-layer2.md` (BA20–BA28),
`2026-07-04/synthesis-layer1.md`, then `2026-07-04/synthesis-round1.md`.

Deeper history if needed:
- `2026-07-03/synthesis-layer3.md` — state after the 3 seeded layers
- `2026-07-03/synthesis-B-to-C.md` — state after Agent B
- `2026-07-03/final-report.pdf` — Round 1 final report (human-readable)
