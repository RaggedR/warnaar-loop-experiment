---
name: assumptions
description: >
  Enumerate ALL assumptions — especially the obvious ones. Use when stuck
  on a proof, debugging a persistent issue, or any time progress has stalled.
  The reason you are stuck is almost certainly that one of your assumptions is wrong.
  This skill forces you to surface and examine every one of them.
argument-hint: <what you're stuck on, or the claim/proof/code that isn't working>
---

# Assumptions: Drain the Water

You are stuck. The reason you are stuck is that something you believe is true is not true. You cannot see it because it feels so obvious that you never made it explicit. This skill forces you to surface every assumption so you can find the broken one.

Read the stuck point from your prove scratch file (`scratch/prove-seed{N}-layer{L}.md`).

## Step 1 — Write in the Assumptions File

Append to `scratch/assumptions-seed{N}-layer{L}.md` (create it if it doesn't exist). Each time you run this protocol, add a new dated section — never overwrite previous entries. The history of what you assumed and when you broke it is itself valuable data.

Write at the top of the new section:

```
## What I'm trying to show
[State precisely what you're trying to prove, build, or fix]

## What's going wrong
[Describe exactly where progress stops]
```

## Step 2 — The Exhaustive List

Now write a section: `## Every Assumption I Am Making`

List EVERY assumption. Use these categories to be thorough. **Do not skip a category because "nothing applies" — sit with each one for a moment before moving on.**

### About the objects
- What type/structure am I assuming each object has?
- Am I assuming something is finite? Countable? Nonempty?
- Am I assuming elements are distinct?
- Am I assuming an ordering exists?

### About the maps/functions/operations
- Am I assuming a map is well-defined?
- Am I assuming injectivity? Surjectivity?
- Am I assuming something commutes?
- Am I assuming linearity, continuity, monotonicity?
- Am I assuming a function terminates?

### About definitions
- Am I using the right definition? (Some terms have multiple conventions)
- Am I assuming two definitions are equivalent when they might not be?
- Am I assuming a definition extends to edge cases the way I think it does?
- What is the empty case? The base case? Am I sure?

### About prior results
- Am I citing a theorem correctly? Do its hypotheses actually apply here?
- Am I assuming a result is "well known" without checking?
- Am I assuming a result from a source that might use different conventions?

### About the problem itself
- Am I sure I'm solving the right problem?
- Am I assuming the claim is true? (What if it's false?)
- Am I assuming a particular proof strategy is the right one?
- Could the problem decompose differently than I think?

### The ones that feel too obvious
- What would a beginner ask about this that I'd dismiss?
- What am I treating as "clearly true" without justification?
- If I had to explain this to someone with no background, what would I gloss over?

**Write every assumption down, no matter how trivial it seems.** The list should be uncomfortable — if it feels too short, you haven't gone deep enough. Aim for at least 15-20 assumptions.

## Step 3 — Challenge Each One

Go through the list. For EACH assumption, write:

```
Assumption: [X]
Status: TRUE / UNCERTAIN / UNTESTED
What if wrong: [What happens to the proof/code if this is false?]
How to test: [A specific computation, counterexample search, or reference check]
```

Any assumption marked UNCERTAIN or UNTESTED is a suspect. Do not proceed until you have tested it.

## Step 4 — Test the Suspects

For each UNCERTAIN/UNTESTED assumption:
- Write a small Python script, or
- Check a specific small example by hand, or
- Look up the precise statement of a cited result, or
- Construct the simplest possible case where the assumption could fail

**When you find the broken assumption — and you will — write it down explicitly:**

```
## THE BROKEN ASSUMPTION
[What I believed]: ...
[What is actually true]: ...
[Why I didn't see it]: ...
[What this means for the proof/approach]: ...
```

## Step 5 — Rebuild

Now return to the original problem with the corrected understanding. The approach may need to change entirely — that is fine. You now know something true that you didn't know before. That is progress.

## Rules

- **Do not shortcut the list.** The whole point is exhaustiveness. The broken assumption is always the one you almost didn't write down.
- **Do not mark assumptions as TRUE without justification.** "It's obvious" is not a justification. Either prove it, test it, or mark it UNCERTAIN.
- **If you find no broken assumption after a thorough pass**, go back to proving. Drop the weakest assumption and see what happens — try to prove the result without it. The list itself is valuable because it shows exactly what you've verified.
- **Keep the assumptions file.** It is a cumulative record of your epistemic state at each stuck point. Never overwrite — always append.
