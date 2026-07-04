---
name: expository
description: >
  Write an expository paper: precise definitions, diagrams, examples, and known
  theorems with proofs in your own words. Arrange pedagogically so no idea is
  used before it is proved. This is your knowledge base — go work on it when
  stuck on a hard proof. Understanding the landscape is how breakthroughs happen.
argument-hint: <topic or area to write up, e.g. "LR tableaux and puzzles">
---

# Expository: Know What You Know

You are writing an expository paper on the topic assigned in your `agent-config.md`.

This is not a research paper. This is a **pedagogical document for yourself** — a place where you organize everything that is known about a topic so that you truly understand it, and so that it is available to you when you need it during a proof.

This document is alive. It grows as your understanding deepens. When you are stuck on a proof, come here and work on this instead. The act of writing up known results in your own words builds the understanding that unblocks you.

## Output

Create or update the expository paper at `expository/expository-seed{N}-layer{L}.tex` (using your seed and layer from `agent-config.md`). This is a real LaTeX document — not scratch notes. It should be readable, well-structured, and beautiful. Compile with `pdflatex` to verify it builds.

## Phase 1 — Definitions

Write down EVERY definition relevant to the topic. For each definition:

1. **State it precisely.** Full formal definition, no shortcuts.
2. **Give the simplest nontrivial example.** If the definition is "LR tableau" then show one for a specific triple of partitions. Draw it.
3. **Give a non-example.** Show something that almost satisfies the definition but doesn't. What condition does it violate? Non-examples are often more informative than examples.
4. **Draw a diagram** if the object has visual structure (tableaux, puzzles, graphs, lattice paths — most combinatorial objects do). Use TikZ.
5. **Note equivalent definitions** if they exist, and state precisely under what conditions they are equivalent. Do not assume equivalence — verify it or cite it with a specific reference.

### Dependency order
Arrange definitions so that **no definition uses a term that hasn't been defined yet**. This is a topological sort of your concepts. If you find a circular dependency, it reveals a structural insight about the topic — note it.

## Phase 2 — What We Know

List every known result (theorem, lemma, proposition) relevant to the topic. For each:

1. **State it precisely.** Full hypotheses, full conclusion.
2. **Write the proof in your own words.** Not a citation. Not "see [KTW03, Thm 2.1]." Actually write the proof. If you cannot write the proof, you do not understand the result, and that gap will bite you during research. Mark it clearly: `% TODO: I don't understand this proof yet — need to work through it`.
3. **If the proof is long**, break it into lemmas. Each lemma gets its own proof. The same "no idea used before proved" rule applies within proofs.
4. **Give a concrete example** of the theorem in action. Walk through a specific instance with specific numbers/objects. Show the theorem being true, not just state that it is.
5. **Cite the source** even though you've written the proof yourself. Future-you needs to know where this came from.

### Arrangement
Order results so that **no proof uses a result that hasn't been proved yet in this document.** This is the pedagogical heart of the paper. If you need Theorem B to prove Theorem A, then Theorem B comes first. This ordering often reveals the logical structure of the theory in a way that reading papers in publication order does not.

## Phase 3 — Connections

After definitions and results are written up, add a section on connections:

1. **Which objects are "the same"?** Known bijections, isomorphisms, equivalences. State precisely.
2. **Which results are "the same"?** Theorems that are equivalent, or that are special cases of a common generalization.
3. **What's the picture?** Draw a diagram showing how the main objects and results relate. This can be informal — a hand-drawn map of the territory.
4. **What's missing?** What questions are natural from the exposition that don't have known answers? These are potential research directions.

## Phase 4 — Open Questions

List questions that arise naturally from the exposition. For each:
- State the question precisely
- Say what a positive answer would imply
- Say what a negative answer (counterexample) would look like
- Note any partial progress

## How to Use This Document

### When stuck on a proof
Come here. Don't work on the proof. Work on the expository paper instead. Pick a known result you haven't written up yet and write its proof in your own words. Or draw a better diagram. Or find a new example. The understanding you build will carry back to the proof.

### When starting a new problem
Read the expository paper first. Everything you know is here, organized and proved. The tool you need might already be in your toolbox — you just need to see it.

### When a result turns out to be wrong
Update the paper. The expository document must always reflect your current best understanding. Outdated results in the expository paper will poison future work.

## Rules

- **No hand-waving.** If a step in a proof is "clear" or "follows easily," write it out anyway. You are writing for yourself on a bad day, when nothing feels clear.
- **No proof by citation alone.** You may cite sources for reference, but every proof must be written in your own words in this document. If you can't write it, you don't know it.
- **Dependency order is sacred.** If you catch yourself using a concept before defining it or a result before proving it, stop and restructure. The ordering IS the understanding.
- **Diagrams are not optional.** If an object can be drawn, draw it. Combinatorics is a visual subject. The diagram often contains the proof.
- **Examples are not optional.** Every definition and every theorem gets at least one concrete example with specific values. Abstract understanding without concrete instances is illusory.
- **This document is never finished.** It grows with your understanding. Return to it regularly. The best insights often come while writing up something you thought you already knew.
