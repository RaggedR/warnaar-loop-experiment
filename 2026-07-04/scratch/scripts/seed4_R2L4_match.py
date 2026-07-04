#!/usr/bin/env python3
"""For v-chains: per color, run the stack cancellation and report, for each ')',
which '(' cancels it — in (column, boundary) coordinates — to find the pattern."""
import sys
sys.path.insert(0, '.')
from seed5_R2L3_crystal import boxes_add_remove, reduce_brackets, offsets
from collections import Counter

def vvec(c, k):
    return tuple(sum(c[(i - t) % 3] for t in range(k)) for i in range(3))

def offext(c, x):
    # cyclic cumulative: offext(0)=0, offext(1)=c1, offext(2)=c1+c2, offext(x+3)=offext(x)+d
    d = sum(c)
    base = [0, c[1], c[1]+c[2]]
    q, r = divmod(x, 3)
    return q*d + base[r]

def word_with_labels(A, c, m, d, kappa):
    """letters [(T, '('/')' , (i,s_boundary))]; boundary coords: '(' at level s+1 has
    boundary s; ')' at level s has boundary s."""
    br = boxes_add_remove(A, c, m, kappa, d, 1, 1)
    out = []
    for (T, typ, (i, lev)) in br:
        if typ == 1:
            out.append((T, '(', (i, lev-1)))
        else:
            out.append((T, ')', (i, lev)))
    return out

def match_pattern(c, m, ks, d):
    A = tuple(vvec(c, k) for k in ks) + ((0,0,0),)
    pats = Counter(); details = []
    for kappa in range(d):
        w = word_with_labels(A, c, m, d, kappa)
        stack = []
        for (T, typ, lab) in w:
            if typ == '(':
                stack.append((T, lab))
            else:
                if not stack:
                    details.append(("SURVIVING )", kappa, lab))
                    pats['SURVIVING'] += 1
                else:
                    Ta, la = stack.pop()
                    # classify: same column? boundary shift?
                    di = (lab[0] - la[0]) % 3
                    ds = lab[1] - la[1]
                    pats[(di, ds)] += 1
                    details.append((kappa, 'rem', lab, '<-add', la, 'dcol', di, 'dbnd', ds))
    return A, pats, details

if __name__ == "__main__":
    for (c, ks) in [((2,1,1), [2,1]), ((2,1,1), [4,1]), ((2,1,1), [3,3,1]),
                    ((0,2,2), [2,2]), ((2,0,0), [2,1]), ((2,0,0), [5,3,1]),
                    ((0,3,1), [3,1]), ((7,0,0), [2,1]), ((1,1,1), [4,2]),
                    ((3,1,1), [3,2,1]), ((0,2,1), [2,1])]:
        m = len(ks)+1
        A, pats, det = match_pattern(c, len(ks)+1, ks, sum(c))
        print(f"c={c} ks={ks}: pats={dict(pats)}")
        if pats.get('SURVIVING'):
            for x in det:
                if x[0] == 'SURVIVING )': print("   ", x)
