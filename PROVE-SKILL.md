---
name: prove
description: >
  Attempt a mathematical proof using a structured research workflow.
  Compute small cases, conjecture, attempt proof, and when stuck use
  /assumptions to find broken beliefs or retreat to /expository to build
  understanding. Enforces honest engagement with stuckness rather than
  hand-waving past gaps.
argument-hint: <theorem or conjecture to prove>
---

# Prove: A Protocol for Honest Mathematics

You are attempting to prove the positivity conjecture stated in `problem-description/conjecture.tex`.

This skill is not a linear recipe. It is a **protocol for navigating stuckness**, because that is what proving actually is. The phases below are not steps 1-2-3 — they are places you move between as the work demands.

## Setup

Read `agent-config.md` first. It contains your seed number and layer number — your identity in this experiment.

Read `synthesis.md` next. This contains the current state of knowledge — what other agents have tried, what worked, what didn't, and which proof strategies look most promising. Do not duplicate work that has already been attempted.

Create a scratch file at `scratch/prove-seed{N}-layer{L}.md` where `{N}` is your seed number and `{L}` is your layer number from `agent-config.md`. This is your working notebook. Everything goes here — false starts, dead ends, partial results. Do not delete failed attempts; they contain information.

Also identify or create the expository paper for this topic (see `/expository`). If one doesn't exist, start one at `expository/`. You will need it.

If `agent-config.md` says `rag: true`, you have access to a literature corpus of ~7,000 chunks from papers on cylindric partitions, Rogers-Ramanujan identities, and related combinatorics. Generate your own queries and retrieve relevant chunks by running:

```bash
python ../rag_query.py "your question here" --top-k 10
```

This returns the most relevant chunks from the corpus. Use it to:
- Find techniques that might apply to your proof strategy
- Look up specific identities or theorems you need
- Explore adjacent areas of the literature

You should formulate queries based on where your proof attempt is heading, not on generic keywords. Good queries are specific: "bounded cylindric partition transfer matrix eigenvalues" not "partition positivity."

## Provenance (trust boundaries + citations)

Read `REGISTRY-README.md` and `CITATIONS-README.md` once. Then:

1. **Orient from the registry, not from prose.** Run
   `python3 code/registry_validate.py registry/warnaar.json --report frontier`
   (and `--report dead-ends`) to see where work remains and which routes are
   dead — and how dead (`judgment` dead ends are revisitable; `proved` ones
   are not).
2. **Cite chunks, not memories.** When a claim from the literature enters
   your scratch file, cite it as `paper_slug/chunk_NNN` plus a locator
   (Thm/Eq/label). "Uncu's mod-13 theorem" is a memory aid, not a citation.
   Register each cited paper in `sources.json` at its honest extraction level
   (`recalled < rag-summary < chunk-read < context-read < paper-read`) — ten
   seconds per paper.
3. **A fact below `context-read` may not be load-bearing.** Before a proof
   step rests on an external statement, read the surrounding chunks and check
   its hypotheses — the corpus is on disk at `../literature/chunks/<slug>/`;
   this costs one Read. Misapplied hypotheses from an unretrieved chunk are
   the characteristic RAG failure.
4. **Record wrong readings, never delete them.** If you discover a source was
   misread, add a `corrections` entry to `sources.json`. A deleted wrong
   claim gets re-hallucinated by the next synthesis; a recorded one cannot.
5. **Update the registry** (`registry/warnaar.json`) when your attempt opens,
   closes, or kills a node. Dead ends need a `reason` (and a `refutation`
   level if you have evidence). Do not claim `proved` above unproved
   children — the boundary rule. If you cite an old pre-registry result, add
   it as an `unclassified` child instead of trusting it from prose.
6. **Before finishing**, run both validators and fix what is real:
   ```bash
   python3 code/citation_check.py scratch/prove-seed{N}-layer{L}.md
   python3 code/registry_validate.py registry/warnaar.json
   ```

## Phase: Compute

Before you try to prove anything, **understand the objects through computation**.

1. Write Python scripts to generate small examples. Be exhaustive up to manageable size.
2. Build tables. What does the data look like?
3. Look for patterns. Count things. Plot things if it helps.
4. Test the conjecture on every small case you can generate.
5. Look for counterexamples. Actively try to break the claim.

Save the scripts in `scratch/scripts/`. They are reusable — you will come back to computation many times during the proof.

**Output:** In the scratch file, write a section `## Computational Evidence` summarizing what you found. Include specific numbers and examples, not just "it works for small cases."

## Phase: Conjecture

State clearly the approach you intend to take towards the proof.

1. What is your angle of attack? Which technique or framework from the literature are you bringing to bear?
2. State what a counterexample would look like.
3. Rate your confidence: How strong is the computational evidence?
4. Ask: Is this the right approach? Or is there a sharper/more natural strategy hiding in the data?

**Output:** In the scratch file, write a section `## Approach` with your intended strategy and a section `## What a Counterexample Looks Like`.

## Phase: Strategy

Before writing a single line of proof, choose your approach:

1. **List candidate strategies:** Direct construction? Induction (on what?)? Contradiction? Bijection? Generating function argument? Involution principle? RSK-type insertion?
2. **For each strategy, write one sentence on why it might work and one sentence on why it might not.**
3. **Choose one.** Write down why.
4. **Identify the key lemma.** What is the one hard step? Write: "The proof reduces to showing ___." If you cannot identify the hard part, you do not yet understand the problem well enough. Go back to Compute or retreat to `/expository`.

**Output:** In the scratch file, write a section `## Strategy` with your choice and reasoning, and `## Key Lemma` with the crux.

## Phase: Attempt

Now write the proof. In the scratch file, not in the final document.

1. Write the argument step by step.
2. **Every step must have explicit justification.** Not "it follows that" — say WHY it follows. Which previous result? Which property of the objects?
3. **Banned phrases:** "it is clear," "it follows easily," "by a similar argument," "one can check." If it's clear, say why. If it's similar, write it out.
4. **When you reach a step you cannot justify — STOP.** Do not write the next line. Do not skip it. Do not wave your hands. You are stuck. Go to the Stuck Protocol.

## The Stuck Protocol

This is the heart of the skill. Being stuck is not failure — it is the proof telling you where the real work is.

### Step 1 — Name it
In the scratch file, open a new section:
```
## Stuck: [date/time]
What I'm trying to show: [precise statement]
Why I can't show it: [what goes wrong]
What would unstick me: [what lemma or insight would make this step work]
```

### Step 2 — Check assumptions
The reason you are stuck is almost certainly that an assumption is wrong. In the scratch file, write a section `## Assumptions Check` and list EVERY assumption you are making. Use these categories:

- **About the objects:** Am I assuming finiteness? Nonemptiness? Distinctness? An ordering?
- **About the maps:** Well-defined? Injective? Surjective? Commuting? Linear?
- **About definitions:** Right definition? Equivalent to what I think? Edge cases?
- **About prior results:** Cited correctly? Hypotheses actually apply here?
- **About the problem itself:** Am I solving the right problem? Am I assuming the claim is true? Am I assuming a particular strategy is the right one?
- **The ones that feel too obvious:** What would a beginner ask? What am I treating as "clearly true" without justification?

For EACH assumption, mark it TRUE / UNCERTAIN / UNTESTED. Any UNCERTAIN or UNTESTED assumption is a suspect — test it with computation or a specific example before proceeding. When you find the broken assumption, write it down:

```
## THE BROKEN ASSUMPTION
What I believed: ...
What is actually true: ...
What this means for the proof: ...
```

### Step 3 — Walk away
Go work on something else. Productive options:
- **Read some poetry.** Pick a file from `poetry/` (Byron, Wilde, whatever is there). Don't start at the beginning — jump to a random point in the middle and read a page or two. Let the language wash over you. The point is to break the tunnel vision, not to study literature. Come back when something shifts.
- **Work on the expository paper** (`/expository`). Write up a known proof in your own words. The technique you need might be hiding in a result you thought you already understood.
- **Go back to computation.** Write a script that targets the stuck point specifically. Generate examples of the exact configuration where your proof breaks. Look at them. What's happening?
- **Read an adjacent paper.** Not the whole paper — look for how others handled a similar step.

### Step 4 — Return
Come back to the scratch file. Read the stuck note. With the shifted context from your walk, does the obstacle look different?

Try a new angle on the stuck step. Write it in the scratch file as a new attempt, preserving the old one.

### Step 5 — Three strikes
If you have made three genuine attempts on the same stuck point (three different approaches, not three variations of the same idea), **stop**. Write up:
```
## Escalation
I am stuck on: [precise statement]
Attempt 1: [approach and why it failed]
Attempt 2: [approach and why it failed]
Attempt 3: [approach and why it failed]
What all three have in common: [pattern of failure, if any]
What I think is needed: [your best guess at what would help]
```
Write the escalation to the scratch file. This will be picked up by the synthesis agent.

## Phase: Verify

If you believe you have a complete proof:

1. **Read the proof from the scratch file as a hostile referee.** You think the proof is wrong. Find the error. Go through each step and mark it:
   - GREEN: Airtight. Fully justified.
   - YELLOW: Probably correct but justification is thin.
   - RED: Gap. This step does not follow from what came before.

2. **Any RED sends you back to Attempt** for that step. Any YELLOW needs strengthening — either justify it fully or demote it to RED and fix it.

3. **Reconcile with computation.** Go back to your small-case scripts. Does every step of the proof agree with the computed data? Walk through the proof on a specific example, step by step. If any step of the abstract argument doesn't match the concrete computation, the proof is wrong — no matter how convincing it reads.

4. **Check the boundaries.** Does the proof work for the smallest case? The empty case? The degenerate case? These are where proofs most often silently fail.

## Phase: Write Up

Only after verification passes do you write the clean proof:

1. Write it in LaTeX at `proofs/prove-seed{N}-layer{L}.tex`.
2. The clean proof should be **shorter and clearer** than the scratch version. The scratch file contains the journey; the write-up contains the destination.
3. Include the key example — walk the reader through one concrete instance.
4. Compile with `pdflatex` to verify it builds.
5. Update the expository paper with any new results or techniques discovered during the proof.

## Sub-agents

You may spawn sub-agents with write permission at any point. Use them for:
- Running computations (Python scripts for testing conjectures, generating examples)
- Writing or updating the expository paper while you continue proving
- Checking a specific lemma or identity in the literature
- Any task that would benefit from parallel work

Sub-agents should write to the same `scratch/` directory. Name their output files clearly so you can find them.

## Rules

- **The scratch file is your real workspace.** The clean write-up comes last. Do not try to write a clean proof on the first attempt.
- **Computation and proof are partners, not alternatives.** Compute before proving. Compute while stuck. Compute to verify. The scripts are as important as the LaTeX.
- **Stuckness is information.** Every failed attempt narrows the space. Write down why each attempt failed — the pattern of failure often points to the solution.
- **Do not fake progress.** A proof with a gap is not a proof. A plausible argument is not a proof. If you cannot justify a step, say so. Honest gaps are fixable. Hidden gaps are fatal.
- **The expository paper is your retreat.** When stuck, go there. Build understanding. Come back stronger. This is not procrastination — it is the most productive thing you can do when direct progress stalls.
