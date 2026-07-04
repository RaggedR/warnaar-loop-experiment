# Handover — Round 2 Orchestrator, Layer 5 (live state; 2026-07-04)

You are the orchestrator. Read this, then root `synthesis.md` (pointer, current),
then `2026-07-04/synthesis-layer4.md` IN FULL (G13–G21, Y11–Y19, D12–D17,
BA36–BA42, Missions 1–8; §4 carries the layer-3 §4(iv) DEFINITIVE convention
verbatim — mandatory citation in every brief). HANDOVER-layer4.md is the frozen
post-Layer-4 record.

## State when this was written

- Layer 4 complete + synthesized + verified. Proved perimeter: d=2,4,5 (full),
  d=8 orbit (3,3,2) [Conj 2.5 k=3], d=10 orbit (4,3,3) [Conj 2.11 k=4 — NEW,
  verifier SOLID, adversary to n=15], d=7 at the G-level (all 12 orbits,
  ℕ[[y,q]], verifier SOLID). Adversary clean: d=7/8 m≤32, d=10 m≤22, d=11,
  d=13; no counterexample anywhere.
- **Warnaar email SENT by Robin 2026-07-04** (after reading the note PDF; all
  preconditions met). Attachments: 2026-07-04/note/warnaar-note.pdf (12pp, both
  proofs, methodology appendix, Lean table) + proofs/prove-seed1-layer4.pdf.
  If Warnaar replies, that conversation OUTRANKS the layer pipeline — surface
  it to Robin immediately and adjust missions accordingly.
- Lean: lean/WarnaarGlue/ sorry-free incl. TheoremD.lean; public mirror
  github.com/RaggedR/warnaar-glue in sync (last commit c7f394a). Any lean/
  change → push to mirror (Claude authorship approved for this repo).
- Post-verifier errata are APPLIED in the current texs: prove-seed2 (scope
  restricted to 7 representatives), prove-seed3 (index/wording), prove-seed6
  (Lemma 7.3 wall enumeration PROVED in repair pass — R1 unconditional).
- Seeds 4/5 of Layer 4 carry SEED-ONLY pedigree (no independent verifier ran)
  — verification is folded into Layer-5 Seed 8(a).

## Layer 5 launch spec

- Seeds: 2026-07-04/seeds-layer5/seeds.md (fresh, from Missions 1–8).
  Seed 1 = Mission 1 (d=7 endgame, TOP). Seed 7 is Lean (rag: false).
- **Sequencing: launch Seeds 1–7 first; Seed 8 (verifier+adversary) only AFTER
  the others report**, briefed with their claims for independent recomputation.
- Model policy: workers fable-inherit (Robin, HANDOVER-layer2.md); synthesizer
  fable-inherit, NOT opus. Sub-agent prompts start with
  "First, read ~/.claude/AGENT.md for instructions."
- rag: true except Seeds 7/8; RAG tool: python ../rag_query.py "query" --top-k 10
  (from loop-experiment/). `timeout` does not exist on this Mac.
- Sandbox quirks: sub-agents' Edit/Write often permission-denied → bash
  heredocs; `sage file.sage` sets __name__ to "sage.all" (main() guards
  silently skip); background agents can SURVIVE session boundaries and
  usage-limit kills — before relaunching "dead" agents, check for the original
  (TaskStop duplicates immediately; two live agents on one file = corruption
  hazard). Scratch files 2026-07-04/scratch/prove-seed{N}-layer5.md are the
  recovery substrate — WRITE INCREMENTALLY.
- Every brief cites §4(iv) + the new errata (BA37 G10 orientation, BA38 S1
  needs gcd(d,3)=1, BA39 seven-representative scope, BA42 refined rev() map).
- Any completed-proof claim → independent verifier (own code, own transcription)
  before it enters synthesis as GREEN. Verifier errata → orchestrator applies
  to the tex and rebuilds the PDF before adjudicating GREEN.
- Synthesizer after all 8 land → 2026-07-04/synthesis-layer5.md (or next day's
  dir); update root synthesis.md pointer; write HANDOVER-layer6.md (do NOT
  edit this file retroactively except to mark queue items DONE).

## Remaining queue (beyond Layer 5)

1. SESSION-2026-07-04.md at day end (mirror 2026-07-03's; include model policy
   from HANDOVER-layer2.md and today's full arc: Layer 3 synthesis, Lean
   phase 2 + TheoremD, repo publication, consolidated note, d=10 theorem,
   EMAIL SENT, Layer 4 complete, Layer 5 prepared).
2. Watch for Warnaar's reply (Robin's inbox — ask Robin, don't guess).
3. If Mission 6 (m=16 certificates) succeeds, consider a note/email UPDATE —
   but only with Robin's explicit approval; the sent email is the record.

## Orchestrator lessons carried + new

- Frozen handovers stay frozen; live state lives here.
- Adversary/verifier AFTER siblings report; verifiers write their own code.
- Full-proof claims get verifiers regardless of internal checks — Layer 4's
  verifier caught a real statement-overbreadth (BA39) that n≤12 numerics
  could never catch.
- Verifier errata get APPLIED immediately (orchestrator or repair agent with
  sole ownership), not just recorded.
- Background agents: TaskStop suspected duplicates before they write; check
  the original's output file before declaring it dead.
- Robin approved Claude authorship on public artifacts for THIS project.
  Still confirm scope for anything new that goes public.
