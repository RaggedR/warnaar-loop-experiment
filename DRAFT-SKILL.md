---
name: draft
description: >
  Iterative thinking-through-files. Write code or ideas to a scratch file,
  then revise through multiple read-edit passes with different lenses.
  Use for hard problems where first-pass thinking isn't good enough.
  Inspired by the essay-writing process: dump, structure, refine, polish.
argument-hint: <description of what to build or solve>
---

# Draft: Iterative Thinking Through Files

You are about to work on a hard problem using an **iterative drafting process** rather than your default one-shot generation. This matters because your internal thinking is append-only — you cannot revise your own thoughts. Files give you random-access working memory. Use them.

Read your task from `agent-config.md` and `synthesis.md`.

## Setup

Create a scratch file at `scratch/draft-seed{N}-layer{L}.md` (using your seed and layer from `agent-config.md`). This is your **thinking medium**, not your output. Treat it like a messy notebook, not a deliverable.

## Pass 1 — Dump

Write everything to the scratch file. Your initial approach, rough code, open questions, doubts, half-formed ideas, notes to yourself. **Do not self-censor. Do not polish.** The goal is to get your first-pass thinking *out of your head* and into a file where you can see it from the outside.

Include a section at the bottom: `## Things I'm Not Sure About`

## Context Walk

Before reading your draft back, go do something else:
- Read 2-3 files in the codebase that are **adjacent** to the problem (tests, related modules, the code that will call yours)
- Read any existing patterns that your solution should be consistent with
- Note anything surprising — assumptions you were making that the codebase contradicts

This shifts your context. When you return to the scratch file, you will read it with slightly different eyes.

## Pass 2 — Structure

Now `Read` your scratch file. You are reading someone else's rough draft. Evaluate it:

- Is the overall architecture right?
- Are the abstractions at the right level? (Too deep? Too shallow?)
- Is anything in the wrong order?
- Did the context walk reveal anything that invalidates the approach?

`Edit` the scratch file with structural changes. Reorganize. Cut dead ends. Promote good ideas. Add sections that are missing. It is fine to rewrite large portions.

## Pass 3 — Correctness

`Read` the scratch file again. This time you are a **reviewer**, not the author. Look for:

- Edge cases not handled
- Off-by-one errors, type mismatches, null/undefined paths
- Implicit assumptions that aren't guaranteed
- Race conditions, ordering dependencies
- Things that would fail on the second run but not the first

`Edit` to fix every issue you find. If you find a design flaw (not just a bug), go back to structural thinking — don't patch around it.

## Pass 4 — Clarity

`Read` one more time. Now you are a **future maintainer** who has never seen this code. Ask:

- Could someone understand this without the context you have right now?
- Is anything unnecessarily clever?
- Can any abstraction be removed without loss?
- Does the naming make the intent obvious?

`Edit` for clarity and simplicity. Remove anything that doesn't earn its place.

## Deploy

Your scratch file should now contain well-thought-through code or design. Move it to its real destination:

1. Write the actual code to the target files
2. Run tests or build to verify
3. If tests fail, **do not jump to fixing** — go back to the scratch file, read it, understand why, and revise there before touching the real code again

Keep the scratch file around — it's a record of your thinking process.

## Rules

- **Every Read is a real Read tool call.** Do not skip reads by relying on what you remember writing. The whole point is the perspective shift from re-reading.
- **Every Edit is a real Edit tool call.** Do not rewrite the whole file from memory. Edit what's there. This forces you to engage with what you actually wrote rather than what you think you wrote.
- **Do not combine passes.** Each pass has one lens. Resist the urge to fix everything at once.
- **The scratch file is append-only between passes, random-access within passes.** Add new sections freely; restructure existing ones through Edit.
- **If a pass reveals the approach is fundamentally wrong**, that is the process working. Start a new section in the scratch file with the revised approach rather than deleting the old one — the contrast is informative.
