#!/usr/bin/env python3
"""Seed 7 R2L4: automated label-audit scanner.
For each in-scope artifact, find every mention of a CHIRALITY-SENSITIVE profile tuple
(orbit(c) != orbit(rev(c))) for d in {4,5,7,8,10,11,13,14} (gcd(d,3)=1; d=2 orbits are
all reversal-symmetric). Emit file -> line numbers -> tuples, as raw material for the
audit table. Convention determination is done per-file via fingerprints/provenance
(see seed7_R2L4_fingerprints.sage output and label-audit-layer4.md)."""
import re, sys, os

ROOT = "/Users/robin/git/experiments/waarnar/loop-experiment/2026-07-04"

def orbit(c):
    r1 = (c[1], c[2], c[0]); r2 = (c[2], c[0], c[1])
    return min(c, r1, r2)

def sensitive(c):
    return orbit(c) != orbit((c[2], c[1], c[0]))

DS = [4, 5, 7, 8, 10, 11, 13, 14]
SENS = set()
for d in DS:
    for i in range(d+1):
        for j in range(d-i+1):
            c = (i, j, d-i-j)
            if sensitive(c):
                SENS.add(c)

FILES = (
    ["scratch/prove-seed%d-layer%d.md" % (s, l) for l in (1, 2) for s in range(1, 9)]
    + ["proofs/prove-seed%d-layer2.tex" % s for s in (1, 2, 3, 4, 6, 7, 8)]
    + ["synthesis-layer1.md", "synthesis-layer2.md",
       "scratch/verify-layer2-disputes.md", "scratch/verify-hm-dispute.md",
       "scratch/prove-seed3-layer3.md", "scratch/prove-seed4-layer3.md",
       "proofs/prove-seed4-layer3.tex"]
)

TUP = re.compile(r"\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\)")

for f in FILES:
    p = os.path.join(ROOT, f)
    if not os.path.exists(p):
        print("MISSING %s" % f); continue
    hits = []
    with open(p, encoding="utf-8", errors="replace") as fh:
        for ln, line in enumerate(fh, 1):
            found = sorted({(int(a), int(b), int(c)) for a, b, c in TUP.findall(line)
                            if (int(a), int(b), int(c)) in SENS})
            if found:
                hits.append((ln, found, line.strip()[:110]))
    print("== %s : %d sensitive-mention lines" % (f, len(hits)))
    for ln, found, txt in hits:
        print("   L%-5d %-28s | %s" % (ln, ",".join(str(t) for t in found), txt))
